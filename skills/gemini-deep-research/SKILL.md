---
name: gemini-deep-research
description: Lance une Deep Research sur gemini.google.com via Chrome MCP (extension Claude for Chrome). Attend la complétion (5-15 min), extrait le rapport complet, sauvegarde en Markdown. Use when the user wants a deep research done on a topic via Gemini Advanced without manual copy-paste.
context: fork
---

# gemini-deep-research

Automatisation complète d'une Deep Research Gemini Advanced depuis Claude Code.

## Prérequis (déjà OK côté {{USER_NAME}})
- Extension Claude for Chrome installée (v1.0.68 confirmée, ID `fcoeoabgfenejglbffodgkkbkcdhcgfn`)
- Claude Desktop ouvert avec extension Chrome connectée
- Session `gemini.google.com` loggée sur compte Gemini Advanced / Google One AI Premium
- MCP `mcp__Control_Chrome__*` ou `mcp__Claude_in_Chrome__*` dispo dans la session

## Usage
```
/gemini-deep-research <sujet de recherche détaillé>
```

## Workflow

### 1. Vérifier Chrome MCP
Si aucun tool `mcp__Control_Chrome__*` ni `mcp__Claude_in_Chrome__*` disponible : ping {{USER_NAME}} pour rouvrir Claude Desktop + extension Chrome, puis relancer Claude Code.

### 2. Ouvrir Gemini Advanced
Appel `mcp__Control_Chrome__open_url` → `https://gemini.google.com/app`
Attendre 3 sec (chargement SPA).

### 3. Activer le mode Deep Research
Via `mcp__Control_Chrome__execute_javascript`, stratégies de recherche du bouton dans l'ordre :
1. Par aria-label : `[aria-label*="Deep Research" i]` ou `[aria-label*="Recherche approfondie" i]`
2. Par text content sur `button` et `[role="button"]`
3. Via menu "tools" / "outils" qui ouvre un sous-menu contenant l'option

Cliquer dès trouvé.

### 4. Coller le prompt et soumettre
JS à exécuter :
- Trouver éditeur : `rich-textarea .ql-editor`, `[contenteditable="true"]`, ou fallback `textarea`
- Focus + clear content (textContent pour contenteditable, value="" pour textarea)
- Insérer le prompt via `document.execCommand('insertText', false, prompt)`
- Dispatcher un Event `input` bubbles:true
- Trouver bouton Send via aria-label (`Send`, `Envoyer`, `Submit`)
- Click

### 5. Démarrer la recherche (si plan intermédiaire)
Gemini propose souvent un plan de recherche à valider. Poll 20×3sec pour trouver un bouton dont le text content matche `/start research|lancer la recherche|démarrer/i`. Clic dès trouvé. Si non trouvé en 60sec, considérer que la recherche a démarré directement.

### 6. Polling complétion
Toutes les 30 sec (max 20 itérations = 10 min), exec JS pour détecter la fin :
- Absence de progress bar `[role="progressbar"]`
- Présence d'un bouton export / share avec aria-label matchant `/export|share|partager/i`

Si > 10 min, ping {{USER_NAME}} avec option de continuer ou arrêter.

### 7. Extraire le résultat
Charger et exécuter le fichier `extract_result.js` (livré avec le skill) via `mcp__Control_Chrome__execute_javascript`. Retourne un objet avec :
- `success`
- `markdown` (conversion HTML→MD basique)
- `text` (plain)
- `word_count`
- `links` (sources extraites)

### 8. Sauvegarder
Écrire dans :
```
~/Desktop/workspace/08_VEILLE/deep-research/deep-research-<slug>-<YYYY-MM-DD>.md
```

Format :
```yaml
---
source: Gemini Advanced Deep Research
date: 2026-04-20
topic: "<sujet original>"
word_count: <nombre>
duration_minutes: <durée observée>
sources_count: <nombre de liens>
---

# <titre>

<contenu markdown extrait>

## Sources
- [Texte](url)
- ...
```

### 9. Notifier {{USER_NAME}}
- Chemin du fichier
- Nombre de mots + nombre de sources
- Durée réelle
- TL;DR 3-bullets extrait des premiers paragraphes

## Fallback

Si Chrome MCP indisponible : proposer Option 1 (skill `/deep-research` basé sur WebSearch parallèles, gratuit, 3-5 min).

## Robustesse

- Extension Claude for Chrome = vraie intégration navigateur, pas de détection anti-bot
- Sélecteurs multi-fallback (aria-label + text content + menu navigation)
- Timeout global 20 min ; au-delà, extraction partielle + notification

## Exemples de prompts

**Tech** :
```
Évolution prix LLM APIs sept 2025 → avr 2026 : Anthropic, OpenAI, Mistral, Google.
Prix input/output/M tokens, tokenizer changes, DPA, hébergement EU.
Tableau final + reco freelance IA FR B2B souverain.
```

**Marché** :
```
Freelance IA France 2026 : TJM moyen par profil (Dev IA, expert RAG, LLMOps).
Plateformes Malt/Comet/FreelanceRepublik.
Trends missions "Assistant IA custom" vs "RAG pipeline".
```

**Prospection** :
```
Recherche approfondie sur <entreprise cible>.
Secteur, CA, dirigeants, outils IA actuels, 10 dernières actus.
3 opportunités mission IA + profil LinkedIn décideur IT.
```


## OUTPUT CONTRACT
Respect `~/.claude/rules/output-contract.md`. Before claiming the task done:
1. **Declare the deliverable path** explicitly (file or artifact)
2. **Run testable checks** (`test -f`, `wc`, `grep`, `jq`, smoke test command — paste output)
3. **Final response format** :
```
LIVRABLE: <one-liner>
FICHIER: <absolute path> (<size/lines>)
CHECKS PASS: X/Y (paste failing ones)
NEXT {{USER_NAME}} ACTION: <what he should do with the output>
```
4. **If incomplete** : use `INCOMPLETE: <missing / cause / needs>` — never claim "done" with empty output.
