---
name: design-md
description: Génère un DESIGN.md conforme à la spec officielle Google Labs (apr 2026, Apache 2.0) pour un projet de {{USER_NAME}} ({{CLIENT_WP}}, {{PROJECT_APP}}, Portfolio, {{GAME_PROJECT}}, {{CLIENT_EDU}}…). Lit les sources existantes (CSS mu-plugins, Tailwind config, charte client validée, screenshots), produit un fichier YAML frontmatter + Markdown body conforme, valide la cohérence (WCAG AA, doublons couleur, niveaux typo 9-15), et exporte optionnellement vers tailwind.config.js / tokens.json / Figma variables. Trigger sur "/design-md", "Crée un DESIGN.md", "Génère le design system pour [projet]". Différent de awesome-design-md qui consomme des designs existants — ici on CRÉE le tien dans un format standard.
---

# DESIGN.md Generator — pour {{USER_NAME}}

Crée des DESIGN.md conformes à la spec officielle Google Labs (`github.com/google-labs-code/design.md`, push 21/04/2026, Apache 2.0).

## Différenciation

| Skill | Rôle |
|---|---|
| `awesome-design-md` (existant) | **Consommer** 59 design systems pré-faits (Claude, Stripe, Apple…) |
| `design-md` (ce skill) | **Créer le tien** dans le format standard Google Labs |
| `{{CLIENT_WP_LOWER}}-design` (existant) | Charte {{CLIENT_WP}} spécifique, hard-codée |

## Spec officielle (résumé)

Un fichier `DESIGN.md` contient :

1. **YAML frontmatter** (machine-readable, optionnel mais recommandé)
2. **Corps Markdown** avec sections dans cet ordre strict :
   1. Overview (alias "Brand & Style")
   2. Colors
   3. Typography
   4. Layout (alias "Layout & Spacing")
   5. Elevation & Depth
   6. Shapes
   7. Components
   8. Do's and Don'ts

Sections facultatives, mais l'ordre doit être respecté. Les `<h2>` (`##`) sont parsés comme sections.

### Schéma YAML

```yaml
---
version: alpha          # constante, current spec version
name: <string>          # obligatoire, nom du design system
description: <string>   # optionnel
colors:
  primary: "#hex"       # au moins primary obligatoire
  secondary: "#hex"
  tertiary: "#hex"
  neutral: "#hex"
  surface: "#hex"
  on-surface: "#hex"
  error: "#hex"
typography:
  <token>:              # 9-15 niveaux typo recommandés
    fontFamily: <string>
    fontSize: <Dimension>     # px, em, rem
    fontWeight: <number>
    lineHeight: <Dimension|number>
    letterSpacing: <Dimension>
    fontFeature: <string>     # optionnel
    fontVariation: <string>   # optionnel
rounded:
  xs: <Dimension>
  sm: <Dimension>
  md: <Dimension>
  lg: <Dimension>
  full: <Dimension>
spacing:
  xs: <Dimension|number>
  sm: <Dimension|number>
  md: <Dimension|number>
  lg: <Dimension|number>
  xl: <Dimension|number>
components:
  button-primary:
    backgroundColor: "{colors.primary}"   # token reference
    textColor: "{colors.neutral}"
    rounded: "{rounded.md}"
    padding: "12px 24px"
---
```

### Règles tokens

- **Color** : doit commencer par `#` + hex SRGB
- **Dimension** : string avec unité `px`, `em`, ou `rem`
- **Token reference** : `{path.to.token}` entre accolades
- Les tokens référencent des primitives (sauf dans `components` où composite OK)

## Workflow

### Étape 1 — Identifier le projet cible

Demande ou infère parmi les projets actifs de {{USER_NAME}} :
- **{{CLIENT_WP}}** — site WP {{CLIENT_CONTACT}}, charte validée Inter + Lora + navy + accent corail (pas de jaune sur bleu)
- **{{PROJECT_APP}}** — app basket Firebase + React Native
- **Portfolio Next.js** — personal brand {{USER_NAME}}, R3F + GLSL
- **{{GAME_PROJECT}}** — chaîne YouTube {{GAME_PROJECT}} (Godot), style gaming/meme
- **{{CLIENT_EDU}}** — site Drupal école com (institutionnel)
- **Autre** — projet ad-hoc

Si {{USER_NAME}} demande un projet hors de cette liste, prends les sources qu'il indique.

### Étape 2 — Collecter les sources existantes

Pour chaque projet, scan les sources de charte :

#### {{CLIENT_WP}}
- `~/Desktop/{{CLIENT_WP_DIR}}/03_STAGING/SESSION_LOG_28-04.md` (charte validée)
- `~/Local Sites/{{CLIENT_WP_LOWER}}-preprod/app/public/wp-content/mu-plugins/{{CLIENT_WP_LOWER}}-*.php` (CSS injecté)
- `~/Desktop/{{CLIENT_WP_DIR}}/05_ADMIN/cadrage/MAIL_EMILIE_24-04_VALIDATION.md` (questions éditoriales)
- Screenshots `~/Desktop/{{CLIENT_WP_DIR}}/02_AUDIT_SITE/screenshots_comparaison_24-04/`

#### {{PROJECT_APP}}
- `~/Desktop/{{PROJECT_APP}}/CLAUDE.md`
- App.tsx + tailwind.config.js si présents

#### Portfolio
- `~/Desktop/workspace/06_PORTFOLIO_WEB/CLAUDE.md`
- `tailwind.config.js`, GLSL shaders, R3F components

#### {{GAME_PROJECT}}
- `~/Desktop/battle-engine/CLAUDE.md` + `PERSONNAGES.md`
- Couleurs des HTML teasers HyperFrames récents (#0a0a0e + #ff2d55 + #ffd60a)

#### {{CLIENT_EDU}}
- `~/Desktop/{{CLIENT_EDU}}/CLAUDE.md`
- CSS Drupal child theme

### Étape 3 — Synthétiser les valeurs primaires

À partir des sources, extrais :
- **3-5 couleurs primaires** (primary, secondary, tertiary, neutral, surface)
- **2 polices max** (titres + body, optionnel mono pour techy)
- **9-12 niveaux typo** (display-lg/md, headline-lg/md/sm, body-lg/md/sm, label, caption)
- **Échelle spacing** (xs 4px, sm 8px, md 16px, lg 32px, xl 64px — base 8px)
- **Échelle rounded** (none, sm, md, lg, full)
- **3-5 composants clés** (button-primary, button-secondary, input, card, chip)

### Étape 4 — Générer le DESIGN.md

Structure obligatoire :

```markdown
---
version: alpha
name: <Nom du système>
description: <1 phrase>
colors:
  primary: "#..."
  secondary: "#..."
  tertiary: "#..."
  neutral: "#..."
  surface: "#..."
  on-surface: "#..."
  error: "#..."
typography:
  display-lg:
    fontFamily: ...
    fontSize: 64px
    fontWeight: 600
    lineHeight: 1.0
  display-md: ...
  headline-lg: ...
  headline-md: ...
  headline-sm: ...
  body-lg: ...
  body-md: ...
  body-sm: ...
  label: ...
  caption: ...
rounded:
  sm: 4px
  md: 8px
  lg: 16px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 32px
  xl: 64px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.neutral}"
    rounded: "{rounded.md}"
    padding: "12px 24px"
  ...
---

# <Nom du système>

## Overview

<Description marque + public + émotion visée + feeling général. 100-200 mots.>

## Colors

<Description palette avec rationale par couleur. 4-6 lignes par couleur.>

## Typography

<Stratégie typo + rationale par police choisie. Quel niveau pour quoi.>

## Layout

<Stratégie layout (fluid/fixed-width), grid, spacing scale, rythm.>

## Elevation & Depth

<Comment la hiérarchie visuelle est créée (ombres, tonal layers, borders).>

## Shapes

<Langage des formes — corner radius logique, exceptions.>

## Components

### Buttons
- Primary: <description + tokens utilisés>
- Secondary: ...
- Disabled: ...

### Inputs
- Default: ...
- Focus: ...
- Error: ...

### Cards
- Default: ...

## Do's and Don'ts

- ✅ <règle 1>
- ✅ <règle 2>
- ❌ <règle 3>
- ❌ <règle 4>
```

### Étape 5 — Valider

Checks obligatoires avant livraison :

1. **WCAG AA contrast** : ratio ≥ 4.5:1 pour text on background, ≥ 3:1 pour UI components. Test manuel via formule WCAG ou via le CLI Google si installé.
2. **Cohérence palette** : pas de doublons couleur (#FFF et #FFFFFF = doublon, normalise)
3. **Typo** : 9-15 niveaux max, pas plus (sinon trop)
4. **Token references** : tous les `{path.to.token}` doivent pointer vers une primitive existante
5. **Sections** : ordre exact respecté (Overview → Colors → Typo → Layout → Elevation → Shapes → Components → Do's)
6. **YAML valid** : pas de virgule manquante, indentation 2 espaces

CLI officiel (si installé) :
```bash
cd ~/Desktop/PROJETS_DEV/design-md-google
bun install
bun run validate <chemin-vers-DESIGN.md>
```

### Étape 6 — Exports optionnels

Sur demande de {{USER_NAME}} :

#### Tailwind config
```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#...',
        secondary: '#...',
        // depuis YAML
      },
      fontFamily: {
        // depuis YAML
      },
      spacing: {
        // depuis YAML
      },
      borderRadius: {
        // depuis YAML
      },
    },
  },
}
```

#### tokens.json (Style Dictionary / Figma compatible)
Structure plate avec `$value` et `$type` selon spec Design Tokens W3C.

#### Figma Variables
Format propriétaire Figma — exporter depuis tokens.json via le plugin Figma Variables Importer.

## Localisation des livrables

Sauvegarde toujours dans le projet cible :

| Projet | Path DESIGN.md |
|---|---|
| {{CLIENT_WP}} | `~/Desktop/{{CLIENT_WP_DIR}}/DESIGN.md` |
| {{PROJECT_APP}} | `~/Desktop/{{PROJECT_APP}}/DESIGN.md` |
| Portfolio | `~/Desktop/workspace/06_PORTFOLIO_WEB/DESIGN.md` |
| {{GAME_PROJECT}} | `~/Desktop/battle-engine/DESIGN.md` |
| {{CLIENT_EDU}} | `~/Desktop/{{CLIENT_EDU}}/DESIGN.md` |

## Cas d'usage {{USER_NAME}} spécifiques

### {{CLIENT_WP}} (priorité ⭐⭐⭐)
- Asset transmissible à {{CLIENT_CONTACT}} comme livrable bonus
- Anti-REVERT 24/04 : la charte devient écrite, pas inventée — chaque modif visuel pointable au DESIGN.md
- Source de vérité pour les futurs agents IA qui interviendront

### Portfolio (priorité ⭐⭐⭐)
- Définit le personal brand {{USER_NAME}} pour tout le mois (LinkedIn posts, slides MBA, pitch alternance)
- Réutilisable dans tous les futurs projets

### {{PROJECT_APP}} (priorité ⭐⭐)
- Cohérence Firebase + React Native garantie
- Préparation transition production

### {{GAME_PROJECT}} (priorité ⭐)
- Plus design gaming/meme que SaaS, format DESIGN.md moins adapté
- Optionnel — le HyperFrames teaser actuel suffit

### {{CLIENT_EDU}} (priorité ⭐⭐)
- Si pitchs {{CLIENT_EDU}} → preuve de méthode designer
- Charte écolejdownload référence

## Anti-patterns à éviter

- ❌ Inventer des couleurs ou polices que le client n'a pas validées (REVERT 24/04 rule)
- ❌ Plus de 15 niveaux typo (trop)
- ❌ Mixer hex codes et noms (#FFF + white = doublon)
- ❌ Ignorer WCAG AA contrast pour faire joli
- ❌ Mettre des explications dans le YAML (commentaires interdits, c'est le markdown body qui explique)
- ❌ Sortir un DESIGN.md générique non sourcé sur le projet réel

## Note d'évolution

Format `version: alpha` officiel Google Labs. Suivre les évolutions sur :
- [github.com/google-labs-code/design.md/releases](https://github.com/google-labs-code/design.md/releases)
- [github.com/google-labs-code/design.md/blob/main/docs/spec.md](https://github.com/google-labs-code/design.md/blob/main/docs/spec.md)

Si la spec passe à `version: beta` ou `1.0`, mettre à jour ce skill.
