---
name: oracle-ampere-a1-setup
description: Setup complet Oracle Cloud Ampere A1 ARM64 Always Free. Provisioning + piège VNIC Paravirtualized + backup BorgBackup + Rclone vers Object Storage (200 GB free). Usage - /oracle-ampere-a1-setup [step]
---

Setup Oracle Ampere A1 Free Tier pour : $ARGUMENTS

## 🎁 Ce que tu obtiens gratuitement (Always Free)
- **2 instances ARM Ampere A1** (config flexible, total **4 OCPU + 24 GB RAM**)
- **200 GB Block Storage** (stockage bloc pour disques VM)
- **10 GB Object Storage + 10 GB Archive** + 50 000 requêtes/mois (pour backups)
- **10 TB Outbound transfer/mois**
- 2 Load Balancers, DNS zones, monitoring — tout gratuit à vie

⚠ **Important** : pour éviter la **reclamation après 30 jours d'inactivité** sur les ressources Always Free, ajouter une CB en mode **Pay As You Go** (aucun débit si tu restes sous les plafonds free). C'est la seule protection fiable contre la résiliation surprise.

## Provisioning de l'instance

### Étape 1 — Créer un compte Oracle Cloud
- https://signup.cloud.oracle.com/
- Région : **Paris (eu-paris-1)** ou Frankfurt (eu-frankfurt-1) pour proximité RGPD
- Ajouter CB → passe en PAYG → protège contre la reclamation 30j

### Étape 2 — Créer l'instance VM.Standard.A1.Flex
- Menu : Compute → Instances → Create Instance
- **Shape** : VM.Standard.A1.Flex — 4 OCPU, 24 GB RAM (max Always Free)
- **Image** : Canonical Ubuntu 24.04 (recommandé) ou Oracle Linux 9
- **Boot volume** : 100 GB (sous le plafond 200 GB)

### ⚠ PIÈGE CRITIQUE — VNIC configuration
Au moment du provisioning, dans **Advanced Options → Networking** :
- **Launch mode** : choisir `Paravirtualized`  → ✅
- **PAS** `Hardware-assisted (SR-IOV)` → ❌ erreur bloquante

Si tu laisses la config par défaut sur A1, tu peux obtenir :
```
Failed to validate instance launch options
```
ou pire, corruption silencieuse des paquets réseau en cours d'exploitation.

### Étape 3 — SSH keys
- Générer en local : `ssh-keygen -t ed25519 -f ~/.ssh/oracle_a1 -C "oracle-a1"`
- Copier la clé publique dans le formulaire de création
- Connexion : `ssh -i ~/.ssh/oracle_a1 ubuntu@<public-ip>`

### Étape 4 — Network Security List
Ouvrir les ports dont tu as besoin (par défaut seul 22 est ouvert) :
- Menu : Virtual Cloud Network → votre VCN → Security Lists → Default Security List
- Ajouter Ingress Rules :
  - 80 (HTTP) — source `0.0.0.0/0` pour Let's Encrypt
  - 443 (HTTPS) — source `0.0.0.0/0`
  - Autres ports custom selon tes services (8000 FastAPI, etc.)

## Post-install système (Ubuntu 24.04)

```bash
# Update + outils de base
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git curl wget htop tmux ufw fail2ban

# Firewall applicatif (en plus des Security Lists OCI)
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Python 3.12 + pip
sudo apt install -y python3.12 python3.12-venv python3-pip

# Node.js 22 (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Docker (optionnel mais pratique)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu

# Nginx
sudo apt install -y nginx
sudo systemctl enable nginx

# Certbot (Let's Encrypt)
sudo apt install -y certbot python3-certbot-nginx
```

## Backup stack : BorgBackup + Rclone vers Object Storage

### Installation
```bash
sudo apt install -y borgbackup rclone
```

### Config Rclone pour Oracle Object Storage (S3-compatible)
```bash
# Récupérer les credentials
# Menu OCI : User Settings → Customer Secret Keys → Generate Secret Key
# Note l'Access Key + Secret Key

rclone config
# New remote → name: oci-s3
# Storage: s3
# Provider: Other
# env_auth: false
# access_key_id: <ton access key>
# secret_access_key: <ton secret key>
# region: eu-paris-1 (ou ta région)
# endpoint: https://<namespace>.compat.objectstorage.eu-paris-1.oraclecloud.com
# location_constraint: laisser vide
```

Tester : `rclone lsd oci-s3:` (liste les buckets)

### Script backup quotidien

```bash
sudo nano /usr/local/bin/backup.sh
```

```bash
#!/bin/bash
set -e

# Variables
BORG_REPO="/mnt/backups/borg-repo"
BORG_PASSPHRASE_FILE="/root/.borg-passphrase"
BACKUP_DIRS="/home/ubuntu /etc /var/lib/postgresql /var/www"
BUCKET="oci-s3:backups"
DATE=$(date +%Y-%m-%d)

# Export passphrase Borg
export BORG_PASSPHRASE=$(cat "$BORG_PASSPHRASE_FILE")

# 1. Snapshot Borg local (dédup + chiffrement)
borg create \
  --stats --compression zstd,3 \
  "$BORG_REPO::${DATE}-$(date +%H%M)" \
  $BACKUP_DIRS

# 2. Pruning : garder 7 daily, 4 weekly, 12 monthly
borg prune \
  --list "$BORG_REPO" \
  --keep-daily=7 --keep-weekly=4 --keep-monthly=12

# 3. Sync vers Object Storage (delta only)
rclone sync "$BORG_REPO" "$BUCKET/borg-repo" \
  --transfers=4 --checkers=8 \
  --log-file /var/log/backup-rclone.log

echo "✅ Backup $DATE terminé"
```

```bash
# Initialiser le repo Borg
sudo mkdir -p /mnt/backups
openssl rand -base64 48 | sudo tee /root/.borg-passphrase
sudo chmod 600 /root/.borg-passphrase
export BORG_PASSPHRASE=$(sudo cat /root/.borg-passphrase)
sudo -E borg init --encryption=repokey /mnt/backups/borg-repo

# Permissions script
sudo chmod +x /usr/local/bin/backup.sh

# Cron quotidien 3h du matin
sudo crontab -e
# Ajouter : 0 3 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

## Monitoring + alerting gratuit

### Uptime Kuma (monitoring self-hosted)
```bash
docker run -d --restart=always -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma louislam/uptime-kuma:1
# Interface http://<ip>:3001 — envoie alertes email/Telegram/Discord
```

### OCI Alarms natifs (gratuits)
- Menu : Monitoring → Alarm Definitions
- Créer : CPU > 80% sur 5 min → notification email
- Créer : Memory > 90% sur 5 min → notification email

## Performance attendue sur Ampere A1
- **FastAPI + Uvicorn** : 3 000-5 000 req/s sur endpoint simple JSON
- **PostgreSQL 17** : ~8 000 QPS sur queries indexées simples
- **Turso LibSQL Embedded Replica** : lectures <1ms, writes async
- **sqlite-vec** sur 50k chunks 1024-dim : <2ms recherche cosinus
- **BorgBackup snapshot** : 100 GB source → 500 MB net (déduplication agressive)
- **Rclone upload** vers Object Storage : ~50 MB/s en région

## ❌ À NE PAS FAIRE
- Laisser VNIC en "Hardware-assisted" → erreur bloquante
- Faire tourner un LLM dense 7B+ localement → 2-3 tokens/s, inutilisable
- Laisser le compte en mode Free Tier pur sans CB → reclamation après 30j d'inactivité
- Stocker les backups UNIQUEMENT sur le disque local → perte en cas de compromission VM
- Partager les Customer Secret Keys Object Storage dans un repo git

## Troubleshooting
- **Instance ne démarre pas** : vérifier VNIC = Paravirtualized
- **SSH timeout** : vérifier Security List ingress 22 + UFW allow 22
- **Rclone 403 sur OCI** : vérifier endpoint URL inclut le namespace correct + la région
- **OOM Killer** : `sudo journalctl -k | grep -i oom` → probablement un process gourmand, `htop` pour identifier
- **Résiliation imminente** : vérifier si ton compte est encore en "Free Tier" (menu Account → Tenancy) → basculer en PAYG via support

## Ressources
- Oracle Cloud Always Free : https://www.oracle.com/cloud/free/
- Known issues Ampere : https://docs.oracle.com/en-us/iaas/Content/Compute/known-issues.htm
- BorgBackup docs : https://borgbackup.readthedocs.io
- Rclone Oracle OCI : https://rclone.org/s3/#oracle-cloud-storage
