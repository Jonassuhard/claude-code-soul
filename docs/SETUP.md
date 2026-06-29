# Setup

> Install complet, depuis 0 jusqu'à `/claude-council` qui répond.

---

## Prérequis

| Outil | Version min | Pourquoi |
|---|---|---|
| **Claude Code CLI** | latest | Évident |
| `bash` | 4.0+ | macOS 12+ a 3.2 — installer via brew pour les meilleurs hooks (`brew install bash`) |
| `git` | 2.30+ | Clone + future PR |
| `~/.claude/` | doit exister | Créé automatiquement au premier lancement de Claude Code |

### Optionnels (selon les hooks utilisés)

| Outil | Pour quel hook | Install |
|---|---|---|
| `ccusage` | `token-tracker.sh` | `npm i -g ccusage` |
| `gitleaks` | pre-commit | `brew install gitleaks` |
| `jq` | hooks divers | `brew install jq` |
| `curl` | `token-tracker.sh` (Telegram) | présent par défaut |

---

## Install pas-à-pas

### 1. Clone

```bash
cd ~/Projects   # ou n'importe où
git clone https://github.com/Jonassuhard/claude-code-soul.git
cd claude-code-soul
```

### 2. Configurer `.env`

```bash
cp .env.example .env
$EDITOR .env
```

**Minimum requis** : `USER_NAME=ToiOuTonAlias`

Les autres variables peuvent rester vides — elles seront laissées comme `{{XXX}}` dans les fichiers générés, ce qui signale visuellement que tu peux les remplir plus tard.

### 3. Dry-run

```bash
./setup.sh --dry-run
```

Affiche tous les paths qui seraient écrits dans `~/.claude/` sans rien modifier. Utile pour vérifier que l'install fera ce que tu penses.

### 4. Install réel

```bash
./setup.sh
```

Le script :
- Backup `~/.claude/soul.md` et `~/.claude/CLAUDE.md` existants dans `~/.claude/_soul-backup-<timestamp>/`
- Copie les 12 skills dans `~/.claude/skills/`
- Copie les 4 agents dans `~/.claude/agents/`
- Copie les 8 hooks dans `~/.claude/hooks/` + `chmod +x`
- Copie les 6 rules dans `~/.claude/rules/`
- Génère `~/.claude/soul.md` à partir du template + ton `.env`

### 5. Activer dans `CLAUDE.md` global

Ajouter ces 3 lignes au début de `~/.claude/CLAUDE.md` (créer le fichier si absent) :

```markdown
@soul.md
@rules/personality.md
@rules/workflow.md
```

L'ordre compte : soul d'abord (qui), personality (comment), workflow (quoi faire).

### 6. Configurer les hooks dans `settings.json`

Éditer `~/.claude/settings.json` (à la racine, pas `settings.local.json`) :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/guard-sensitive.sh" },
          { "type": "command", "command": "~/.claude/hooks/dev-ram-guard.sh" }
        ]
      },
      {
        "matcher": "mcp__computer-use__*",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/guard-sensitive.sh" }
        ]
      }
    ],
    "PostToolUseFailure": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/mcp-health-check.sh" }] }
    ],
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/session-start.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/token-tracker.sh" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/mcp-cleanup.sh" }] },
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/redact-secrets.sh" }] }
    ]
  }
}
```

### 7. Test

```bash
claude
```

Puis dans Claude Code :

```
/claude-council "Should I publish my side project as a public repo before it's polished?"
```

Si tu obtiens un débat de 5 IA contradictoires avec un verdict unique → l'install est OK.

---

## Setup avancé

### Touch ID (macOS)

Les hooks `guard-sensitive.sh` + `confirm-send.sh` utilisent `bioutil -s` et `osascript` pour déclencher Touch ID. Pas de config supplémentaire — Touch ID est utilisé via l'API système.

Test :
```bash
# Forcer un trigger Touch ID
echo "test" | sudo -k -p "Test Touch ID: " sudo true
```

### Telegram alerts (token-tracker.sh)

1. Créer un bot via `@BotFather` sur Telegram → noter le token
2. Obtenir ton chat ID via `@userinfobot`
3. Stocker dans macOS Keychain :
   ```bash
   security add-generic-password -s claude-telegram-bot -a $USER -w "<token>"
   security add-generic-password -s claude-telegram-chatid -a $USER -w "<chat_id>"
   ```
4. Vérifier que `token-tracker.sh` lit bien Keychain (ouvrir le fichier, ligne `security find-generic-password`)
5. Ajuster les seuils en haut du fichier (`THRESHOLD_USD`, `THRESHOLD_TOKENS`)

### MCP lazy-load (optionnel mais recommandé)

Ce repo n'inclut pas le wrapper `mcp on/off` (différent par environnement). Si tu veux le pattern :

```bash
# Vault tes MCP dans un fichier
~/.claude/mcp-vault.json

# Wrapper rapide
mcp() {
  case "$1" in
    list)  jq -r '.mcpServers | keys[]' ~/.claude/mcp-vault.json ;;
    on)    # Copie le bloc du vault vers .mcp.json ;;
    off)   # Retire le bloc du .mcp.json ;;
  esac
}
```

Pattern détaillé : voir `LAZY_LOAD.md`.

---

## Troubleshooting

### `/claude-council` ne se déclenche pas

- Vérifier que le skill est bien dans `~/.claude/skills/claude-council/SKILL.md`
- Vérifier le frontmatter YAML (name + description)
- Redémarrer Claude Code (`exit` puis `claude`) — la liste des skills est lue au startup

### Touch ID ne se déclenche pas

- Vérifier les permissions du hook : `ls -la ~/.claude/hooks/guard-sensitive.sh` doit être `-rwxr-xr-x`
- Vérifier le mapping matcher dans `settings.json`
- Tester manuellement : `bash ~/.claude/hooks/guard-sensitive.sh` (doit demander Touch ID si une action sensible est en cours)

### Le token-tracker ne notifie pas Telegram

- Vérifier que `ccusage` est installé : `which ccusage`
- Vérifier les creds Keychain : `security find-generic-password -s claude-telegram-bot -w`
- Lire les logs : `tail ~/.claude/token-usage.log`

### Setup.sh échoue avec "USER_NAME is required"

- Vérifier `.env` : `grep USER_NAME .env`
- Vérifier qu'il n'y a pas d'espace après le `=` : `USER_NAME=Marie` pas `USER_NAME = Marie`

### Restaurer un état antérieur

```bash
ls -la ~/.claude/_soul-backup-*
cp ~/.claude/_soul-backup-<timestamp>/soul.md ~/.claude/
cp ~/.claude/_soul-backup-<timestamp>/CLAUDE.md ~/.claude/
```

---

## Uninstall

```bash
# Restaurer le backup le plus récent
LATEST=$(ls -td ~/.claude/_soul-backup-* | head -1)
cp "$LATEST"/* ~/.claude/

# Supprimer skills/agents/hooks/rules ajoutés
rm -rf ~/.claude/skills/{claude-council,deep-research,gemini-deep-research,smart-router,audit-short-1v1,audit-short-ffa,gemini-sprite,anti-ai-detect-writing,editorial-design-audit,awesome-design-md,design-md,oracle-ampere-a1-setup}
rm -f ~/.claude/agents/{youtube-shorts-pipeline,personal-daily-scan,personal-evolution-analyzer,design-visual-auditor}.md
rm -f ~/.claude/hooks/{guard-sensitive,confirm-send,mcp-cleanup,mcp-health-check,token-tracker,redact-secrets,dev-ram-guard,session-start}.sh
```

Et retirer les `@soul.md` / `@rules/X.md` de `~/.claude/CLAUDE.md`.
