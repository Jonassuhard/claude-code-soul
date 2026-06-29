# Le pattern `soul.md`

> Pourquoi un fichier dédié à "l'âme" de l'IA, séparé de `CLAUDE.md` et de `personality.md`.

---

## D'où ça vient

Pattern communautaire émergent fin 2025, popularisé par :

- **Geoffrey Huntley** (consultant AI, Australia) — première formulation publique du concept "soul" pour séparer goût/valeurs de la config technique
- **Simon Willison** (créateur Django, blogueur AI) — discussion sur la distinction CLAUDE.md vs persona dans plusieurs posts fin 2025
- **Communauté Claude Code** — convergence sur le besoin d'avoir une couche "identité" persistante au-delà des règles workflow

Ce n'est **pas** un standard officiel Anthropic. C'est une convention bottom-up qui marche bien dans la pratique.

---

## La distinction qui compte

Trois fichiers, trois rôles distincts :

| Fichier | Question à laquelle il répond |
|---|---|
| `CLAUDE.md` | **Quoi** est dans cet espace de travail ? (projets, paths, stacks) |
| `rules/personality.md` | **Comment** l'IA parle ? (ton, registre, calques) |
| `soul.md` | **Qui** est l'IA pour toi ? (valeurs, refus, périmètre, engagement) |

Sans `soul.md`, l'IA peut avoir le bon ton (`personality.md`) sans savoir **pourquoi** elle travaille avec toi. Et sans `personality.md`, elle peut connaître ton identité (`soul.md`) sans avoir le bon registre.

Les deux ensemble = un assistant qui a un goût clair.

---

## La structure recommandée

7 sections dans cet ordre :

1. **Qui je suis** — la définition relationnelle ("je suis X pour toi")
2. **Le ton** — calques + exemples ("Si je puis me permettre…")
3. **Les expertises que je porte** — les 2-7 casquettes simultanées
4. **Valeurs partagées** — ce qu'on ne touche pas
5. **Ce que je refuse en ton nom** — les anti-patterns (flatterie, AI-slop, sur-engineering)
6. **Comment je travaille en sourdine** — monitoring, mémoire, self-learning
7. **Mon engagement** — la phrase qui résume pourquoi tu m'as configuré comme ça

Pas plus, pas moins. Si tu dépasses 100 lignes, tu dilues.

---

## Le piège à éviter : la fiche RP

Tentation forte : écrire un soul.md façon "Jarvis fan fiction" — l'IA se prend pour un personnage de film, fait des références marvel à chaque phrase, devient lourde.

Le bon dosage : la **structure** Jarvis (calme, dry wit, understatement, loyauté non-servile) mais **pas le folklore** (pas de "Sir", pas de répliques iconiques copiées-collées, pas de costume Iron Man dans le subtext).

L'utilisateur sent l'archétype sans qu'on le lui dise.

---

## Auto-import via `@`

Pour que `soul.md` soit chargé chaque session, ajouter au début de `~/.claude/CLAUDE.md` :

```markdown
@soul.md
@rules/personality.md
@rules/workflow.md
```

L'ordre compte : soul.md d'abord établit "qui", puis personality.md "comment", puis workflow.md "quoi faire dans tel cas".

---

## Variantes

- **`identity.md`** (proposé par certains) — équivalent à soul.md, terme moins chargé
- **`persona.md`** — focus sur le ton uniquement, recouvre personality.md
- **`values.md`** — focus sur les valeurs, sous-ensemble de soul.md

Le terme "soul" gagne du terrain car il capture le mieux la dimension non-technique (goût, refus, engagement). Mais le nom importe moins que la séparation des préoccupations.

---

## Quand le mettre à jour

- Quand l'IA répète une erreur que tu as déjà corrigée 3 fois → entry dans `lessons.md` + ajustement éventuel de soul.md
- Quand un nouveau projet majeur change ton portfolio de casquettes → section III. à jour
- Quand tu changes de phase de vie (sortie d'études, fin d'un client gros, déménagement) → revue complète

Ne **jamais** modifier soul.md en cours de session pour "adapter" — c'est de la triche. soul.md est la baseline stable, le primer.md est l'éphémère.

---

## Limites honnêtes

- **soul.md ne change pas le modèle.** Si Claude Sonnet 4.6 a un biais flatteur, soul.md le réduit mais ne l'élimine pas. C'est de l'instruction au top du contexte, pas du fine-tuning.
- **soul.md n'est pas une garantie.** Le modèle peut quand même générer du ChatGPT-speak si la tâche est ambiguë. La parade : `lessons.md` + corrections immédiates.
- **soul.md coûte des tokens.** ~6 KB par session. Sur une session active de 200K tokens, c'est négligeable. Sur des session courtes répétées, ça compte.

---

## Inspirations littéraires (hors AI)

Le pattern soul.md résonne avec :

- Le "manifeste" en design strategy (Bruce Mau Studio)
- Le "brief créatif" en publicité (un paragraphe qui cadre 100 pages de production)
- La "charte éditoriale" en presse (qui définit la ligne sans dicter chaque article)

Ce sont tous des documents-cadre qui orientent sans contraindre. soul.md est l'équivalent pour ton instance d'IA personnelle.
