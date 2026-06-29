# claude-code-soul

> Claude Code, mais avec une âme. 12 skills curatés, 4 agents, 8 hooks, et un fichier `soul.md` qui transforme le CLI en majordome cognitif au lieu d'un chatbot poli.

```
vanilla Claude Code      claude-code-soul
─────────────────         ──────────────────
"Sure, I can help!"  →    "Bon. C'est fait. La suite ?"
"That's a great       →   "Si je puis me permettre, ce business
 question..."             plan murit depuis trois semaines."
"I'll do my best."   →    "Techniquement faisable. Pas raisonnable.
                          Mais quand est-ce que ça t'a arrêté ?"
```

---

## Ce que c'est

Un pack de configuration pour [Claude Code CLI](https://docs.claude.com/en/docs/claude-code) qui ajoute :

| Couche | Contenu | Rôle |
|---|---|---|
| **Identité** | `soul.md` | Qui est l'IA pour toi. Ton, valeurs, refus. |
| **Personnalité** | `rules/personality.md` | Comment elle parle (majordome dosable). |
| **Workflow** | `rules/workflow.md` + 4 autres | Comment elle décide quoi faire. |
| **Skills** | 12 skills custom | Compétences invocables via `/nom-du-skill`. |
| **Agents** | 4 agents autonomes | Sous-tâches déléguées sans polluer le contexte. |
| **Hooks** | 8 hooks shell | Touch ID sécu, MCP cleanup, RAM guard, token tracker. |

Pas une refonte de Claude Code — une couche de personnalité + outillage par-dessus.

## Ce que ce n'est pas

- ❌ Un fork de Claude Code (c'est juste de la config dans `~/.claude/`)
- ❌ Un IDE ou une UI (tout en CLI, en MD, en bash)
- ❌ Une promesse de "vrai Jarvis" — c'est un outil statistique, pas une conscience
- ❌ Plug-and-play à 100% — tu remplis un `.env` et tu adaptes `soul.md` à ton identité

---

## Install

```bash
git clone https://github.com/Jonassuhard/claude-code-soul.git
cd claude-code-soul

# 1. Configurer ton identité
cp .env.example .env
$EDITOR .env                    # remplis au minimum USER_NAME

# 2. (Optionnel) Dry-run pour voir ce qui sera installé
./setup.sh --dry-run

# 3. Installer
./setup.sh

# 4. Activer soul.md dans ton CLAUDE.md global
echo "@soul.md" >> ~/.claude/CLAUDE.md
echo "@rules/personality.md" >> ~/.claude/CLAUDE.md
echo "@rules/workflow.md" >> ~/.claude/CLAUDE.md
```

Détail complet : [`docs/SETUP.md`](docs/SETUP.md)

---

## Test en 30 secondes

```
claude
> /claude-council "Should I publish my side project as a public repo before it's polished?"
```

Tu obtiens un débat de 5 IA contradictoires (anti-flatterie obligatoire) qui rend un verdict unique. Pas un "ça dépend".

---

## Stack par couche

### Skills (12)

| Skill | Quoi |
|---|---|
| `claude-council` | 5 IA débattent ta décision business/tech, verdict unique anti-flatterie |
| `deep-research` | WebSearch parallèle multi-axes + synthèse MD fact-checked |
| `gemini-deep-research` | Pilote Gemini Advanced via Chrome MCP, sauvegarde MD |
| `smart-router` | Avant plan mode : inventaire outils + stack optimale |
| `audit-short-1v1` | Audit pré-publication YouTube Shorts format 1v1, score viralité 0-100 |
| `audit-short-ffa` | Idem pour format Free-For-All (4-way) |
| `gemini-sprite` | Génère sprites de combat via Gemini UI + chroma cleanup |
| `anti-ai-detect-writing` | Style d'écriture qui passe ZeroGPT 78% humain (validé) |
| `editorial-design-audit` | Critique DA senior : 6 axes scorés, références (Gentlewoman, A24, Linear) |
| `awesome-design-md` | Wrapper sur 59 design systems open source (Stripe, Apple, Linear…) |
| `design-md` | Génère DESIGN.md conforme spec Google Labs (Apache 2.0) |
| `oracle-ampere-a1-setup` | Setup VPS ARM Always Free + BorgBackup + Rclone |

### Agents (4)

| Agent | Quoi |
|---|---|
| `youtube-shorts-pipeline` | Pipeline render Godot + FFmpeg + RIFE + upload YouTube |
| `personal-daily-scan` | Scan quotidien projets, journal, triage mémoire, alertes deadlines |
| `personal-evolution-analyzer` | Analyse compétences mensuelle, détection patterns négatifs (dispersion, gap revenu) |
| `design-visual-auditor` | Audit visuel 3 viewports (mobile/tablet/desktop) vs charte référence |

### Hooks (8)

| Hook | Quoi | Trigger |
|---|---|---|
| `guard-sensitive.sh` | Touch ID sur computer-use + suppressions apps | PreToolUse |
| `confirm-send.sh` | Touch ID + session 30min + lockout escalant | helper |
| `mcp-cleanup.sh` | Kill MCP zombies orphelins | SessionEnd |
| `mcp-health-check.sh` | Auto-reconnect MCP | PreToolUse + PostToolUseFailure |
| `token-tracker.sh` | ccusage + alerte Telegram si seuil $/tokens dépassé | Stop |
| `redact-secrets.sh` | Rédige secrets dans transcripts `.jsonl` | SessionEnd |
| `dev-ram-guard.sh` | Anti-runaway `npm run dev` sur Mac 16 Go | PreToolUse Bash |
| `session-start.sh` | Injection minimale anti-doublon (skip primer importé via @) | SessionStart |

### Rules (6)

| Rule | Quoi |
|---|---|
| `personality.md.template` | Ton majordome dosable (sarcasme, understatement, dry wit) |
| `workflow.md` | Action minimale d'abord, anti-overengineering, Boris Cherny principles |
| `output-contract.md` | Standard agents/skills : fichier attendu + checks testables + format réponse |
| `loop-template.md` | Template `/loop` autonome anti-runaway (critère DONE + checks + bornes) |
| `memory-management.md` | Tagging primer (`[PROJET ACTIF]`, `[DEADLINE J-XX]`, `[RÉFLEXE PERMANENT]`) |
| `goal-command.md` | Guide d'usage `/goal` (Claude Code autonome turn-par-turn) |

---

## Pourquoi `soul.md` ?

Pattern communautaire fin 2025 (Geoffrey Huntley, Simon Willison) : séparer "l'âme" de l'IA (ton, valeurs, refus) de la config technique (CLAUDE.md/AGENTS.md). Inspiré du Jarvis MCU (calme, dry wit, loyauté non-servile), pas du Jarvis "cool AI assistant" générique.

Détail conceptuel + sources : [`docs/SOUL_PATTERN.md`](docs/SOUL_PATTERN.md)

---

## Architecture

```
~/.claude/
├── CLAUDE.md              ← @soul.md @rules/personality.md @rules/workflow.md
├── soul.md                ← Qui je suis pour toi
├── primer.md              ← Sessions actives (200L max, tags discipline)
├── rules/
│   ├── personality.md     ← Ton majordome
│   ├── workflow.md        ← Anti-overengineering
│   └── ...
├── skills/                ← Invocables via /nom-du-skill
├── agents/                ← Délégables via Task tool
└── hooks/                 ← Triggers automatiques
```

Détail : [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

---

## Lazy-load (config opt-in)

Tous les MCP servers, LaunchAgents, et agents lourds sont à la demande, pas chargés au startup. Économie tokens + RAM significative.

Détail : [`docs/LAZY_LOAD.md`](docs/LAZY_LOAD.md)

---

## Sécurité

- Touch ID obligatoire pour : suppressions apps, `computer-use` MCP, `git push`, `rm -rf`, `sudo`
- `gitleaks` scan recommandé en pre-commit
- Secrets via macOS Keychain, jamais en clair dans `.env` (sauf dev local éphémère)
- `redact-secrets.sh` rédige les transcripts `.jsonl` post-session

---

## Contribuer

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md). Toute PR doit passer :
- `gitleaks detect`
- 0 PII (nom, email, ID nominatif)
- 0 path absolu personnel (`/Users/<name>/`)
- 1 nouveau skill = 1 nouveau test d'invocation documenté

---

## License

MIT — voir [`LICENSE`](LICENSE).

## Credits

- Pattern `soul.md` : Geoffrey Huntley, Simon Willison (community fin 2025)
- Inspirations Jarvis : MCU (Iron Man / Avengers), Paul Bettany voicing
- Stack Claude Code : [Anthropic](https://anthropic.com)
- Skills marketing (exclus de ce repo car non-mienne) : pack Obra (cold-email, copywriting, page-cro, etc.)
- Agents VoltAgent (exclus pour la même raison) : [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
