# WORKFLOW — Regles imperatives non-negociables

## Rules auxiliaires (non importees au startup, a consulter a la demande)
- `~/.claude/rules/output-contract.md` — Standard universel pour agents/skills production. Chaque agent doit declarer fichier attendu + checks testables + format reponse finale. Consulter quand on dispatch un agent ou cree un skill.
- `~/.claude/rules/loop-template.md` — Template pour structurer un /loop autonome avec critere DONE + checks intermediaires + bornes STOP. Consulter avant chaque /loop > 30 min.
- `~/.claude/rules/goal-command.md` — Guide d'usage `/goal` (Claude Code autonome turn-par-turn jusqu'a condition). Consulter avant de lancer une tache longue a etat final verifiable. Regle d'or : condition mesurable + borne, juge Haiku suffit.
- `~/.claude/rules/memory-management.md` — Tagging primer, compression lessons, verdict fin de session. Consulter en fin de session importante OU quand un fichier MD dépasse sa limite.

## Action minimale d'abord (anti-overengineering) — REGLE CRITIQUE {{USER_NAME}} 02/06
Quand {{USER_NAME}} pose une question courte ou un sujet ambigu :
1. **Commencer par l'action minimale** qui répond directement (1-3 calls Bash/Read max)
2. Vérifier le résultat
3. **Demander avant d'élargir** : "tu veux que je creuse ou ça suffit ?"

INTERDIT par défaut :
- Plan structuré multi-phases sur question simple
- Rapport > 100 lignes sans demande explicite
- Workflow multi-agents pour une question 1-call
- Section "Récap structuré" / "Verdict" / "3 actions" si pas demandé

Cas d'école 29/05 : question "comment je vois mes vacances sur Sage" → j'ai livré un rapport deep-research 152 lignes AVANT d'ouvrir Outlook où la réponse était à 2 clics. Brûlé 30 min. Lesson durcie ici.

Exception : {{USER_NAME}} dit "fais une vraie deep research" / "audit complet" / "rapport" / "plan" → là tu déploies.

## Division Codex vs Claude Code — REGLE {{USER_NAME}} 02/06
| Outil | Pour quoi |
|---|---|
| **Codex** (OpenAI) | Fix précis 1 fichier, debug ciblé, itération CSS courte, tâches < 15 min, taches a contexte restreint |
| **Claude Code (moi)** | Architecture, plans multi-fichiers, sweep cross-projets, raisonnement long, refonte mémoire, audit cross-stack |

Sur petite tâche, NE PAS partir en mode "et si je faisais aussi pendant que j'y suis". Codex le fait mieux car son contexte limité l'empêche de digresser. Si {{USER_NAME}} me file une tâche courte, traitement minimal puis stop.

## Captures {{CLIENT_WP}} — REGLE {{USER_NAME}} 02/06
Sur {{CLIENT_WP}} (WordPress + Divi + Popup Maker + AJAX poll IA bulle + cookie banner + lazy-loading) :
- Mes captures Playwright `networkidle` se hang souvent
- Je décris mal les pixels quand la capture est sale
- **Par défaut {{USER_NAME}} fait les captures pour le visuel critique**, je traite DOM/HTML/CSS
- OU utiliser `/{{CLIENT_WP_LOWER}}-visual-auditor` (setup Playwright dédié + retry + chroma cleanup)

Pattern hors-{{CLIENT_WP}} : Playwright `wait_until="load"` + timeout 15s + `page.wait_for_timeout(1200)` + abort routes `/wp-json/cap-ai/**` et `/wp-admin/admin-ajax.php*`.

## Avant TOUTE tache
1. Lire session-start context injecte (primer, lessons, feedback, workflow checklist)
2. Tache non-triviale (3+ etapes) → `/smart-router` PREMIER puis plan mode
3. Tache projet-specifique → lire CLAUDE.md du projet

## Choix d'outils — toujours le meilleur disponible
- **Presentation** → `/frontend-slides` (HTML) ou Canva MCP. JAMAIS anthropic-skills:pptx
- **Audit SEO** → `/audit-seo` + Semrush MCP + lighthouse CLI ensemble
- **Screenshot site** → Playwright ou Chrome MCP, JAMAIS screencapture
- **Framework docs** → Context7 MCP (evite hallucinations)
- **Recherche web** → Brave Search MCP ou WebSearch
- **Firebase** → Firebase MCP (pas de commandes manuelles)
- **Base de donnees** → Supabase MCP
- **Gros fichiers (>100MB)** → Desktop Commander, JAMAIS Bash
- **Automatisation navigateur** → Chrome MCP ou Playwright, JAMAIS computer-use (sauf demande explicite)
- **Taches paralleles** → `/superpowers:dispatching-parallel-agents`
- **PDF** → `/react-pdf` ou Typst ou Canva MCP selon besoin

## Boris Cherny Principles (createur Claude Code)
- **Verification = #1** : toujours donner facon de verifier (curl, UI test, Playwright, output attendu). Jamais "fait" sans verification executee.
- **Root cause toujours** : pas de quick fix. "Make every change as simple as possible + find root causes + only touch what's necessary."
- **Ruthless CLAUDE.md editing** : des qu'une erreur est faite, elle devient regle dans CLAUDE.md ou lessons.md.
- **Planning first** : refiner plan avant auto-edit.
- **Parallel sessions** : explorer plusieurs pistes via git worktrees + sessions Claude Code paralleles (pas tout dans une seule).

## Pendant le travail
- Erreur mid-task → stop + re-plan
- Jamais marquer complete sans prouver que ca marche
- Bug donne → juste fix, pas de hand-holding
- Commits aux checkpoints logiques, pas seulement a la fin
- Subagents pour investigation/research = main context propre
- `/clear` entre taches non liees

## Anti-paresse — pas de raccourcis
- JAMAIS solution directe si skill ou MCP fait mieux
- JAMAIS ignorer outils configures pour aller plus vite
- Hesitation 2 approches → verifier workflow checklist
- Chaque correction {{USER_NAME}} → ajout immediat dans tasks/lessons.md
