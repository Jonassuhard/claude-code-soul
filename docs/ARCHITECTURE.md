# Architecture

> Comment les couches `soul.md` / `rules/` / `skills/` / `agents/` / `hooks/` interagissent.

---

## Vue d'ensemble

```
┌───────────────────────────────────────────────────────────────┐
│                    ~/.claude/CLAUDE.md                         │
│  (Hub — importe tout via @ syntax)                             │
│                                                                 │
│  @soul.md              ← Qui je suis                            │
│  @rules/personality.md ← Ton                                    │
│  @rules/workflow.md    ← Anti-overengineering                   │
└───────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
       ┌──────────┐    ┌──────────┐    ┌──────────┐
       │ soul.md  │    │ rules/   │    │ primer.md │
       │ (identité)│    │ (méthode)│    │ (état)    │
       └──────────┘    └──────────┘    └──────────┘
                              │
                              │  invocations
                              ▼
              ┌─────────────────────────────┐
              │       skills/ (12)           │
              │  /claude-council             │
              │  /deep-research              │
              │  /smart-router               │
              │  /audit-short-1v1            │
              │  ...                         │
              └─────────────────────────────┘
                              │
                              │  délégations
                              ▼
              ┌─────────────────────────────┐
              │       agents/ (4)            │
              │  youtube-shorts-pipeline     │
              │  personal-daily-scan         │
              │  personal-evolution-analyzer │
              │  design-visual-auditor       │
              └─────────────────────────────┘
                              │
                              │  side effects
                              ▼
              ┌─────────────────────────────┐
              │       hooks/ (8)             │
              │  guard-sensitive (PreToolUse)│
              │  mcp-cleanup (SessionEnd)    │
              │  token-tracker (Stop)        │
              │  ...                         │
              └─────────────────────────────┘
```

---

## La couche identité — `soul.md`

Chargé à chaque session via `@soul.md` dans `CLAUDE.md`. 6 KB, ~90 lignes max recommandé.

Rôle : établir **qui** l'IA est pour cet utilisateur avant que la moindre instruction technique arrive. Quand l'IA hésite sur le ton, le périmètre, ou un refus, elle remonte à soul.md.

---

## La couche méthode — `rules/`

| Fichier | Rôle |
|---|---|
| `personality.md.template` | Le ton (majordome dosable, sarcasme contrôlé) |
| `workflow.md` | Anti-overengineering (action minimale d'abord), choix d'outils (skill > MCP > CLI) |
| `output-contract.md` | Standard universel agents/skills : fichier(s) attendu(s) + checks testables + format réponse |
| `loop-template.md` | Template `/loop` anti-runaway (critère DONE + bornes + métriques) |
| `memory-management.md` | Tagging primer (`[PROJET ACTIF]`, `[DEADLINE J-XX]`, `[RÉFLEXE PERMANENT]`) + limites de lignes |
| `goal-command.md` | Guide d'usage `/goal` (Claude Code autonome turn-par-turn) |

Importés via `@rules/X.md` au choix dans `CLAUDE.md`. Les 3 essentiels : personality, workflow, output-contract.

---

## La couche état — `primer.md` + `lessons.md`

**Pas dans ce repo** (c'est du contenu utilisateur, pas du template). Mais le pattern est documenté ici :

### `primer.md` (≤ 200 lignes)
- Sessions actives en cours
- Deadlines critiques
- Stack actuelle
- Pointeurs vers `CLAUDE.md` de chaque projet
- Tagging discipline obligatoire

### `lessons.md` (≤ 80 lignes)
- Erreurs/corrections accumulées
- Format : `| date | erreur | règle à suivre |`
- Compression mensuelle (archive ancienne dans `lessons-archive-YYYY-MM.md`)

Cf. `rules/memory-management.md` pour la discipline complète.

---

## La couche outils — `skills/`

Invocables via `/nom-du-skill` dans Claude Code.

### Types de skills

| Type | Exemple | Description |
|---|---|---|
| **Process** | `claude-council`, `smart-router`, `deep-research` | Déterminent HOW approcher une tâche |
| **Implementation** | `gemini-sprite`, `design-md`, `oracle-ampere-a1-setup` | Exécutent un job concret |
| **Audit** | `audit-short-1v1`, `editorial-design-audit` | Évaluent un livrable selon une grille |
| **Style** | `anti-ai-detect-writing` | Appliquent un ton/format spécifique |

### Activation

Lazy par défaut : Claude lit la `description` du frontmatter de tous les skills disponibles au start mais ne charge le corps que sur invocation explicite ou trigger contextuel.

---

## La couche déléguée — `agents/`

Sous-tâches autonomes lancées via `Task` ou `Agent` tool. Avantage = ne pollue pas le contexte principal.

| Agent | Quand l'invoquer |
|---|---|
| `personal-daily-scan` | Matin/soir, pour scan état projets + alertes deadlines |
| `personal-evolution-analyzer` | Mensuel (28 du mois), pour rapport évolution compétences |
| `youtube-shorts-pipeline` | Sur demande pipeline gamedev/AI video complète |
| `design-visual-auditor` | Sur demande audit visuel 3 viewports |

Chaque agent a son `system prompt` complet + sa whitelist d'outils. Pas d'agent avec tools `*` (sécurité + clarté).

---

## La couche side effects — `hooks/`

Triggers Claude Code natifs. Configurés dans `~/.claude/settings.json` (jamais commité).

### Mapping trigger → hook

| Trigger Claude Code | Hook | Effet |
|---|---|---|
| `PreToolUse` (Bash) | `guard-sensitive.sh` | Touch ID sur suppressions apps + computer-use |
| `PreToolUse` (Bash) | `dev-ram-guard.sh` | Anti-runaway `npm run dev` accumulés |
| `PreToolUse` + `PostToolUseFailure` | `mcp-health-check.sh` | Auto-reconnect MCP |
| `SessionStart` | `session-start.sh` | Injection minimale (skip primer importé via @) |
| `Stop` | `token-tracker.sh` | ccusage parser + alerte Telegram si seuil |
| `SessionEnd` | `mcp-cleanup.sh` | Kill MCP zombies orphelins |
| `SessionEnd` | `redact-secrets.sh` | Rédige secrets dans transcripts `.jsonl` |

### Pourquoi des hooks shell et pas du JS/Python

- Bash = zéro dépendance (présent partout)
- Coût exécution : ~10ms par hook (acceptable sur chaque tool call)
- Lecture rapide pour audit (pas de transpilation, pas de stack trace)
- Compatible Linux/macOS sans portage

---

## Sécurité

Trois layers :

1. **Touch ID layer** — `guard-sensitive.sh` + `confirm-send.sh` interceptent tout ce qui peut détruire (apps, files, prod). Session 30 min après une auth réussie, lockout escalant 2/10 min après 3/6 échecs.
2. **Secrets layer** — `redact-secrets.sh` post-session + `.gitignore` strict + jamais `.env` commité + Keychain pour les creds CI.
3. **Permission layer** — au niveau Claude Code, deny rules dans `settings.json` pour bloquer tout MCP/CLI dangereux par défaut.

---

## Lazy-load

Le repo expose une convention mais pas l'implémentation complète. Voir [`LAZY_LOAD.md`](LAZY_LOAD.md) pour le concept.

Principe : MCP servers et LaunchAgents lourds (Telegram daemon, etc.) sont en vault et activés à la demande via wrapper `mcp on <name>` ou `agent on <name>`. Économie tokens significative (15 MCP × ~2 KB description = ~30 KB économisés au startup).

---

## Convention de nommage

| Cas | Convention | Exemple |
|---|---|---|
| Skill | `kebab-case`, verbe-substantif | `audit-short-1v1`, `deep-research` |
| Agent | `kebab-case`, substantif-noun | `personal-daily-scan` |
| Hook | `kebab-case.sh` | `guard-sensitive.sh` |
| Rule | `kebab-case.md` | `output-contract.md` |
| Template | `<base>.md.template` | `personality.md.template` |
| Variable env | `UPPER_SNAKE_CASE` | `USER_NAME`, `CLIENT_EDU` |

---

## Extensibilité

Ce repo est **un point de départ**, pas une référence absolue. Patterns recommandés pour évoluer :

- **Forker** + ajouter tes propres skills (cf. `CONTRIBUTING.md`)
- **Garder soul.md court** (≤ 100 lignes) — c'est là que la dilution arrive vite
- **Compresser lessons.md mensuellement** — sinon il devient une dump de 500 lignes que personne ne lit
- **Auditer hooks tous les 6 mois** — la dépendance bash + outils externes (ccusage, telegram-cli) évolue
