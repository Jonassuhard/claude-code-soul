# Contributing to claude-code-soul

Toute contribution est bienvenue. Quelques règles strictes pour ne pas dégrader le repo.

---

## Avant toute PR

1. **`gitleaks detect --source .`** doit retourner 0 finding.
2. **Anonymisation** : aucune PII (nom, email, téléphone, adresse, ID nominatif, employee ID, SIRET, etc.).
3. **Paths absolus** : aucun `/Users/<name>/`, `/home/<name>/`, `~/Desktop/<workspace>/` hardcodé. Utiliser `$HOME`, `$WORKSPACE`, ou les variables documentées dans `.env.example`.
4. **License** : tout fichier source ajouté est MIT-compatible.

---

## Ajouter un nouveau skill

Un skill = un dossier `skills/<nom>/` avec au minimum `SKILL.md`.

### Format `SKILL.md` (frontmatter YAML obligatoire)

```yaml
---
name: my-new-skill
description: |
  Une description claire qui décrit (1) ce que le skill fait, (2) quand l'invoquer
  (mots-clés / contextes), (3) ce qui est explicitement hors-périmètre.
  La description sert au routing : si elle est floue, le skill ne sera jamais
  automatiquement invoqué.
---

# my-new-skill

## Quoi
[Description du skill]

## Quand
[Triggers d'invocation]

## OUTPUT CONTRACT
[Référence à rules/output-contract.md + spécificités]
```

### Checklist nouveau skill

- [ ] Frontmatter YAML valide avec `name` et `description` ≥ 30 mots
- [ ] Section `## OUTPUT CONTRACT` qui déclare : fichier(s) attendu(s), checks testables, format réponse finale
- [ ] Au moins un exemple d'invocation dans le README ou la doc du skill
- [ ] Aucune dépendance MCP/CLI sans note d'installation
- [ ] Test d'invocation manuel : `/my-new-skill <arg>` → vérifier que le skill se charge bien

---

## Ajouter un nouveau hook

Un hook = un fichier `hooks/<nom>.sh` (bash) ou `hooks/<nom>` (binaire compilé).

### Checklist nouveau hook

- [ ] Shebang `#!/bin/bash` ou `#!/usr/bin/env bash`
- [ ] `set -euo pipefail` en début
- [ ] Pas d'effet de bord sur l'exit code Claude Code (utiliser `exit 0` même en erreur si l'erreur ne doit pas bloquer)
- [ ] Logs dans `~/.claude/<hook-name>.log` (pas stdout/stderr qui pollue)
- [ ] Documentation en commentaires d'en-tête : quand le hook se déclenche, ce qu'il fait, dépendances
- [ ] Si le hook fait du réseau (Telegram, etc.) : variables d'environnement uniquement, pas de creds en clair

### Configuration Claude Code

Ajouter une entrée dans `settings.json` (jamais commité directement) :
```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "~/.claude/hooks/my-new-hook.sh" }] }
    ]
  }
}
```

---

## Ajouter un nouvel agent

Un agent = un fichier `agents/<nom>.md` avec frontmatter YAML.

```yaml
---
name: my-new-agent
description: |
  Quoi fait l'agent + 2-3 examples Context/user/assistant pour le triage automatique.
tools:
  - Read
  - Write
  - Bash
  - Grep
---

# my-new-agent

[Prompt système de l'agent]
```

### Checklist nouvel agent

- [ ] Frontmatter avec `name`, `description` (≥ 2 examples), `tools` (whitelist explicite)
- [ ] Pas d'accès à des paths hardcodés — utiliser des variables ou demander en input
- [ ] Section `## OUTPUT CONTRACT` (cf. `rules/output-contract.md`)
- [ ] Test d'invocation : depuis Claude Code, déléguer une tâche test à l'agent et vérifier qu'il rend le format attendu

---

## Modifier soul.md.template ou personality.md.template

Ces fichiers sont des **templates**, pas des opinions. Garder :
- Sections structurelles (I. Qui je suis, II. Le ton, etc.)
- Placeholders `{{XXX}}` pour les variables de `.env.example`
- Pas de PII, pas de refs projet spécifique

Pour exposer une opinion personnelle (style, refus, valeurs), utiliser `examples/soul.md.example`.

---

## Process PR

1. Fork → branche `feat/<nom>` ou `fix/<nom>`
2. Commits atomiques, message en anglais ou français au choix mais sans "fix" vague
3. Description PR : quoi, pourquoi, comment tester
4. CI passe (gitleaks + lint shell + lint markdown)
5. Review par 1 maintainer minimum

---

## Reporter un secret ou une PII oublié

Si tu trouves un secret ou une donnée perso (même mineure) dans le repo :
- **N'ouvre PAS d'issue publique** — ça expose le problème
- Ouvre une issue privée ou contacte directement le mainteneur
- Le secret sera rotaté + l'historique git réécrit si nécessaire

---

Merci de respecter ces règles. Le but du repo est de partager une **méthode** de personnalisation Claude Code propre, pas de fuiter des données.
