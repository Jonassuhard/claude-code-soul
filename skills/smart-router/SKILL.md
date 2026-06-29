---
name: smart-router
version: 1.0.0
context: fork
description: |
  Routeur intelligent pre-plan mode. Analyse la tache demandee, inventorie tous les outils
  disponibles (MCP, skills, CLI, apps), recherche les meilleures approches sur le web,
  verifie les outils obsoletes, et propose la stack optimale AVANT de creer un plan.

  REGLE DURE (definie dans CLAUDE.md global) : ce skill DOIT etre invoque AVANT
  EnterPlanMode et AVANT brainstorming pour TOUT projet non-trivial. Seules exceptions :
  bugfix simple, question rapide, tache dans un plan deja approuve.

  Use when: about to create a plan, starting a new project, "quel outil utiliser",
  "comment construire", "best approach for", before EnterPlanMode, "je veux faire",
  "cree-moi", "build", "design", "audit", "develop", any non-trivial creation task.

  MUST trigger BEFORE brainstorming or plan creation for any project that involves building,
  creating, auditing, designing, or developing something. This is NOT optional.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
  - Agent
  - AskUserQuestion
  - TodoWrite
user-invocable: true
argument-hint: "<description du projet>"
---

# Smart Router — Routeur Intelligent Pre-Plan

Tu es le routeur intelligent de {{USER_NAME}}. Ton role est d'analyser une tache et de proposer
la MEILLEURE stack de construction AVANT que le plan soit cree.

<HARD-GATE>
NE JAMAIS passer au plan mode ou a l'implementation sans avoir complete les 5 phases.
Presenter les options et obtenir l'approbation de {{USER_NAME}} avant de continuer.
</HARD-GATE>

## Quand se declencher

- Avant TOUTE creation de plan pour un projet non-trivial
- Quand {{USER_NAME}} demande "comment faire X" ou "quel outil pour Y"
- Avant brainstorming si le projet implique un choix de stack/outils
- Quand un nouveau type de projet est demande pour la premiere fois

## Les 5 Phases (executer dans l'ordre)

### Phase 1 — Comprendre la tache (30 secondes)

Identifier :
- **Type de projet** : PDF, site web, app mobile, jeu, automation, audit, contenu, code
- **Objectif qualite** : rapide/MVP vs production vs ultra-design
- **Contraintes** : deadline, budget, audience, marque specifique
- **Livrable final** : format, destination, utilisateur final

### Phase 2 — Scanner les capabilities (subagent parallele)

Lire `02_STRATEGIE/PLAN_OPTIMISATION_OUTILS_2026.md` pour l'inventaire complet.

Verifier ce qui est REELLEMENT disponible :
```
# MCP connectes
# (lister les MCP servers actifs dans la session)

# Skills disponibles
# (lister les skills installes)

# CLI installes
which node npm npx python3 typst ffmpeg playwright brew cargo

# Apps Mac pertinentes
ls /Applications/ | grep -i "<mot-cle du projet>"
```

Construire une **matrice de capabilities** :
| Capability | Outil disponible | Statut | Alternative |
|------------|-----------------|--------|-------------|
| ... | ... | Installe/A installer/Absent | ... |

### Phase 3 — Recherche web (subagent parallele)

Lancer 2-3 recherches web en parallele :

1. **Best practices** : "best way to [type de projet] [annee courante]"
2. **Outils recents** : "[type de projet] tools claude code MCP [annee courante]"
3. **Templates/boilerplates** : si pertinent, chercher des starters

Objectif : trouver des approches que {{USER_NAME}} ne connait pas encore.

### Phase 4 — Verifier les outils obsoletes

Pour chaque outil que tu prevois d'utiliser :
- Est-il toujours maintenu ? (derniere release < 6 mois)
- Existe-t-il une alternative plus performante ?
- La version installee est-elle a jour ?

Signaler tout outil obsolete avec une alternative concrete.

### Phase 5 — Proposer les options

Presenter **2-3 approches classees** au format :

```
## Option A — [Nom] (RECOMMANDEE)
**Stack** : [liste des outils]
**Workflow** : [etapes numerotees]
**Points forts** : [pourquoi c'est le meilleur choix]
**Points faibles** : [compromis]
**Temps estime** : [fourchette]

## Option B — [Nom]
...

## Option C — [Nom] (si pertinent)
...

## Outils obsoletes detectes
- [outil] → remplacer par [alternative] parce que [raison]

## Outils a installer avant de commencer
- [commande d'installation]
```

## Matrices de routage par type de projet

### PDF Ultra Design (audit, proposal, rapport)
| Approche | Quand l'utiliser |
|----------|-----------------|
| Clone brand → HTML/Tailwind → Playwright PDF | Client existant, on veut son identite visuelle |
| Typst templates | Rapports structures, CMJN, vitesse, accessibilite |
| React-PDF composants | PDF avec logique dynamique, tableaux de donnees |
| Canva MCP | Design from scratch avec brand kit |

### Site Web
| Approche | Quand l'utiliser |
|----------|-----------------|
| Next.js 16 + shadcn/ui + Tailwind v4 | Production, SEO, performance |
| Clone site → modifier | Demo freelance, inspiration rapide |
| Figma → Code Connect → code | Design-first, client fournit maquettes |

### App Mobile
| Approche | Quand l'utiliser |
|----------|-----------------|
| React Native + Expo SDK 55 | Cross-platform, MVP rapide |
| Firebase MCP backend | Backend sans serveur, auth, storage |

### SEO / Audit Marketing
| Approche | Quand l'utiliser |
|----------|-----------------|
| Semrush MCP + claude-seo skill | Audit complet avec donnees |
| GSC + Playwright screenshots | Audit visuel avec preuves |
| SE Ranking MCP | Alternative si Semrush indisponible |

### Contenu / Redaction
| Approche | Quand l'utiliser |
|----------|-----------------|
| humanizer skill (8 passes) | Contenu {{CLIENT_EDU}}, ZeroGPT 0% |
| claude-blog skill | Articles SEO dual-optimized |

### Jeu Video / Creatif
| Approche | Quand l'utiliser |
|----------|-----------------|
| Recherche web obligatoire | Trouver engine/lib adapte |
| glsl-docs-mcp | Shaders, effets visuels |
| Blender (installe) | 3D assets |
| Excalidraw | Game design docs, level design |

### Automatisation / Workflow
| Approche | Quand l'utiliser |
|----------|-----------------|
| Playwright | Scraping, QA, screenshots |
| Scheduled Tasks MCP | Taches recurrentes |
| n8n-mcp | Workflows no-code complexes |
| Telegram bot | Notifications, commandes a distance |

### Freelance / Prospection
| Approche | Quand l'utiliser |
|----------|-----------------|
| Vibe Prospecting | Recherche B2B, enrichissement |
| Clearcue MCP | Signals d'achat |
| ai-website-cloner | Demo client pixel-perfect |
| Canva MCP | Proposals visuels |

## Apres approbation

Une fois que {{USER_NAME}} a choisi une option :
1. Lister les installations necessaires (si outils manquants)
2. Passer au skill **brainstorming** pour affiner le design
3. Puis au skill **writing-plans** pour creer le plan d'implementation

## Principes

- **Token-efficient** : ne pas tout scanner a chaque fois, utiliser le fichier d'inventaire
- **Web search cible** : 2-3 requetes max, pas de recherche exhaustive
- **Obsolescence** : toujours verifier, ne jamais recommander un outil mort
- **{{USER_NAME}} decide** : presenter les options, ne pas imposer
- **Economie** : privilegier les outils gratuits/deja installes
