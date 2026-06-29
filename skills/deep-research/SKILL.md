---
name: deep-research
description: Lance une recherche approfondie multi-axes via WebSearch parallèle (5-10 queries) puis synthèse MD avec sources cliquables, fact-check anti-hallucination, verdict tranchant. Équivalent maison de Gemini/OpenAI Deep Research mais via Claude. Trigger sur "/deep-research", "lance une deep research sur X", "recherche approfondie", "fais-moi un rapport sur", ou questions complexes nécessitant plusieurs angles + sources fact-checkées. Différent de `gemini-deep-research` (qui pilote Gemini Advanced via Chrome MCP). Format builder {{USER_NAME}} — verdict + 4-5 axes + anti-AI-slop + sources vérifiables uniquement.
context: fork
---

# Deep Research — Claude maison

Workflow de recherche approfondie reproduisant Gemini/OpenAI Deep Research mais 100% Claude. Pas de chaining 10-15 min, mais parallélisation agressive + fact-check rigoureux + format livrable verdict-driven.

## Différence avec les autres skills

| Skill | Rôle |
|---|---|
| `gemini-deep-research` | Pilote Gemini Advanced via Chrome MCP, attend 5-15 min |
| `customer-research` | Spécifique persona/customer marketing |
| `web-search` | Single search, pas de structure |
| `deep-research` (ce skill) | **Multi-axes, parallèle, synthèse MD avec verdict** |

## Quand l'invoquer

- "Fais une deep research sur X"
- "Recherche approfondie : portfolio premium 2026"
- "Compare 5 outils Y avec fact-check"
- "Rapport sur Z avec sources"
- "Investigue ce sujet en profondeur"
- "/deep-research [sujet]"

**Quand NE PAS l'invoquer** :
- Question simple ("c'est quoi X ?") → utiliser WebSearch direct
- Recherche unique factuelle ("date sortie iOS 17") → WebSearch direct
- Question sur le code/projet → utiliser le contexte projet
- Quand on veut Gemini spécifiquement → utiliser `gemini-deep-research`

## Workflow en 6 étapes

### Étape 1 — Reformulation + identification des axes

Reformule la question en 1 phrase nette. Identifie 4-6 axes de recherche complémentaires.

**Exemples d'axes typiques** :
- Benchmark / cas réels
- Stack technique / outils
- Anti-patterns / risques
- Coûts / business model
- Adaptations FR / cultural
- Inspirations / références culturelles

Si la question manque de contexte critique → **1 question de clarification max**, puis tu continues.

### Étape 2 — Lancement parallèle des WebSearch

**Règle d'or** : 5-10 queries en parallèle dans **un seul message** (multi tool calls).

Chaque query doit être :
- Spécifique (pas de "best X")
- Avec date 2025-2026 (forcer fraîcheur)
- En anglais ou français selon le sujet
- Avec mots-clés techniques précis

**Format query exemple** :
```
✓ "premium dark mode editorial portfolio 2026 designer"
✓ "free component library Next.js 15 Tailwind v4 shadcn 2026"
✓ "anti-patterns AI slop dark mode portfolio 2026"
✗ "best portfolio websites" (trop vague)
✗ "portfolio 2024" (trop vieux)
```

### Étape 3 — Fact-check anti-hallucination

Pour chaque claim critique extrait des résultats :
- **URL vérifiable** dans les sources retournées ? sinon flag `[à vérifier]`
- **Chiffres précis** sourcés ? sinon flag `[chiffre indicatif]`
- **Noms propres** vérifiés (pas inventés) ? sinon ne PAS les inclure

**Pattern Gemini Deep Research a souvent halluciné** :
- Noms de projets/personnes inventés mais plausibles
- URLs qui n'existent pas
- Chiffres arrondis sans source
- Citations attribuées à des "experts" génériques

**Toujours préciser** : "fact-check effectué sur N claims sur M" en fin de rapport.

### Étape 4 — Cross-référencement entre sources

Identifier les patterns récurrents qui apparaissent dans 3+ sources indépendantes = signal fort.
Identifier les claims qui n'apparaissent qu'1 fois = signal faible (à pondérer).

### Étape 5 — Génération du rapport MD

Format strict :

```markdown
# RAPPORT [SUJET] — [Date]

> Recherche autonome via WebSearch (N queries parallèles + connaissances curatives). Sources fact-checkées. Anti-sycophancy.

## SYNTHÈSE EXÉCUTIVE (300 mots)
[Ce qui ressort. Verdict global. 3 mots-clés direction.]

## AXE 1 — [Nom]
[Findings + tableau si comparatif + anti-patterns]

## AXE 2 — [Nom]
[...]

## VERDICT TRANCHANT
[1 phrase. Ce qu'on retient. Aucun "ça dépend".]

## 3 ACTIONS CONCRÈTES (24-72h)
1. ...
2. ...
3. ...

## SOURCES
- [Title](URL)
- [Title](URL)
[10-15 URLs vérifiables minimum]
```

### Étape 6 — Sauvegarde + chat

**Double output obligatoire** (cohérence règle {{USER_NAME}} primer #6 pour prompts Gemini, étendue ici) :

1. **Rapport complet** dans `~/Desktop/[projet pertinent]/RAPPORT_[SUJET]_[DATE].md` (archive)
2. **Récap exécutif** dans le chat avec :
   - 3-5 findings critiques
   - Verdict tranchant 1 phrase
   - 3 actions concrètes
   - Sources cliquables (top 10-15)

## Format du verdict (anti-sycophancy)

**Interdits stricts** :
- ❌ "Ça dépend de plusieurs facteurs..."
- ❌ "Plusieurs pistes intéressantes..."
- ❌ "Il faudrait considérer..."
- ❌ "C'est une bonne question, mais..."

**Format autorisé** :
- ✅ "Verdict : option A. Voici les 3 raisons."
- ✅ "Pas concluant — voici l'info manquante à collecter d'abord."
- ✅ "Cliché en 2026. Pivote vers X."
- ✅ "Aucune solution gratuite réelle. Reste payant."

## Cas d'usage concrets pour {{USER_NAME}}

### 1. Veille concurrentielle ({{CLIENT_EDU}})
```
/deep-research veille concurrentielle écoles communication France 2026
→ 5 axes : EFAP / Sup de Com / {{CLIENT_EDU}} / ECS / Tendances LinkedIn
→ Output : rapport `~/Desktop/{{CLIENT_EDU}}/_REFERENCE_2026/VEILLE_CONCURRENCE_[DATE].md`
```

### 2. Stack technique évaluation
```
/deep-research stack RAG production Mistral Qdrant FastAPI 2026 best practices
→ 5 axes : architecture / outils / coûts / cas réels / risques
→ Output : rapport `~/Desktop/PROJETS_DEV/rag-starter-kit/RAPPORT_STACK_[DATE].md`
```

### 3. Direction artistique projet
```
/deep-research direction artistique "Paris Nuit" portfolio web 2026
→ 5 axes : sites références / bibliothèques / anti-patterns / culturel / stack
→ Output : déjà fait 29/04 dans `06_PORTFOLIO_WEB/RAPPORT_PARIS_NUIT_CLAUDE.md`
```

### 4. Veille tools IA
```
/deep-research nouveaux skills MCP Claude Code avril 2026 must-have alternance Paris
→ 5 axes : skills officiels / communauté / MCPs / risques / cas adoption
→ Output : rapport `~/Desktop/workspace/02_STRATEGIE/VEILLE_CLAUDE_TOOLS_[DATE].md`
```

### 5. Décision business
```
/deep-research SASU vs micro-entreprise freelance IA 2026 France juridique fiscal
→ 5 axes : juridique / fiscal / cotisations / cas réels / abus de droit
→ Output : rapport `~/Desktop/workspace/04_ADMIN_MICRO/RAPPORT_SASU_VS_MICRO_[DATE].md`
```

## Compléments d'outils (si disponibles)

Si les MCPs suivants sont installés, les utiliser en priorité sur WebSearch :

- **Tavily MCP** : meilleure qualité d'extraction de contenu (article complet, pas juste snippet)
- **Exa MCP** : semantic search, contenu curated (filtre les listicles SEO)
- **Perplexity MCP** : recherche IA-ready avec synthèse intégrée
- **Brave Search MCP** : alternative WebSearch basique

**Reco priorité** : Tavily > Exa > WebSearch > Brave.

## Limitations honnêtes

| Limite | Compensation |
|---|---|
| Pas de chaining 10-15 min comme Gemini DR | Parallélisation 5-10 queries simultanées |
| WebSearch Claude moins puissant que Tavily/Exa | Cross-référencer + fact-check obligatoire |
| Risque hallucination si fact-check négligé | Toujours flagger `[à vérifier]` quand source manquante |
| Pas d'images / OCR PDF | Compléter manuellement si besoin |

## Évolution

Si la recherche rate (verdict mou, sources insuffisantes) → invoquer `claude-council` pour challenger les findings + lancer 3 nouveaux WebSearch ciblés.

Si la recherche concerne un projet design → enchaîner avec `design-md` pour figer les décisions visuelles.

Si la recherche concerne un projet content marketing → enchaîner avec `content-strategy` ou `content-writer`.

---

## Notes développeur

Ce skill complète `gemini-deep-research` (qui pilote Gemini) sans le remplacer. Cas d'usage différents :
- Gemini DR = recherche académique long-form (15 min, 8-15 pages)
- Claude deep-research (ce skill) = recherche tactique rapide (5 min, 3-5 pages avec verdict tranchant)

Pour des recherches critiques (>1 000 € impact), lancer **les 2 en parallèle** et cross-référencer les findings.

## OUTPUT CONTRACT
Respecte `~/.claude/rules/output-contract.md`.

**Fichiers attendus (double output)** :
- `~/Desktop/<project>/RAPPORT_<SUJET>_<YYYY-MM-DD>.md` (archive complète)
- Récap exécutif dans le chat (court, verdict + actions)

**Checks testables** :
- [ ] `test -f` rapport MD
- [ ] **Structure** : `grep -c "^## SYNTHÈSE EXÉCUTIVE\|^## AXE [0-9]\|^## VERDICT TRANCHANT\|^## 3 ACTIONS CONCRÈTES\|^## SOURCES" <rapport>` ≥ 5 sections
- [ ] **Sources** : `grep -cE "^\- \[.*\]\(http" <rapport>` ≥ 10 URLs
- [ ] **Chaque URL est unique** : `grep -oE "\(http[^)]+\)" <rapport> | sort -u | wc -l` = nombre URLs total
- [ ] **WebSearches réellement faites** : 5-10 queries parallèles citées dans le rapport (paste les requêtes ou tool calls visibles)
- [ ] **Fact-check effectué** : ligne explicite "fact-check effectué sur N claims sur M" en fin de rapport
- [ ] **Verdict tranchant** : pas de "ça dépend" / "plusieurs pistes" / "il faudrait considérer"
- [ ] **3 actions concrètes 24-72h** présentes avec verbes d'action
- [ ] Pour chaque claim flou ou non-sourcé : `[à vérifier]` ou `[chiffre indicatif]`

**Format réponse** :
```
LIVRABLE: deep-research <sujet>
RAPPORT: <path> (<lignes>)
AXES TRAITÉS: N
QUERIES LANCÉES: M (parallèle dans 1 message)
SOURCES: K URLs vérifiables
FACT-CHECK: X/Y claims vérifiés
VERDICT: <one-liner tranchant>
3 ACTIONS 24-72h:
  1. <action>
  2. <action>
  3. <action>
PROCHAINE ACTION {{USER_NAME}}: <décider / approfondir / passer à l'action>
```

**Anti-hallucination** :
- Si tu n'as pas fait 5-10 WebSearch en parallèle : `INCOMPLETE: pas de parallel research`
- Si URL inventée (pas dans les résultats WebSearch) : retire
- Si nom propre/projet pas vérifié dans une source : `[à vérifier]` ou retire
- Si verdict mou : reprends, exige tranchant
