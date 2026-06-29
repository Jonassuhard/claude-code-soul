# MEMORY MANAGEMENT — Système anti-bordel mémoire

Référencé par `workflow.md` (rules aux). À consulter en fin de session importante OU quand un MD dépasse sa limite.

**Cause origine** : feedback {{USER_NAME}} 02/06/2026 — "tu assimile mal certaines choses, tu découpes mal ta mémoire, je suis obligé de faire le tri moi-même, y a pas d'intuition réelle." J'ai pas d'intuition naturelle pour trier ce qui mérite d'être mémorisé. Donc : règle explicite > intuition.

## Limites strictes des fichiers mémoire

| Fichier | Limite | Si dépassé |
|---|---|---|
| `~/.claude/primer.md` | **200 lignes max** | Externaliser dans `~/.claude/primer-details/<sujet>.md` + remplacer par pointeur 2-3 lignes |
| `~/.claude/tasks/lessons.md` | **80 lignes max** | Compression thématique → archive `lessons-archive-YYYY-MM.md` |
| `~/.claude/rules/*.md` | **100 lignes max** | Externaliser sous-fichiers thématiques |
| `~/Desktop/<projet>/CLAUDE.md` | **150 lignes max** | Idem |

## Convention de tagging dans le primer

Chaque entrée du primer DOIT avoir un tag implicite ou explicite :

| Tag | Durée de vie | Exemple |
|---|---|---|
| `[ÉPHÉMÈRE 7j]` | Session courante + 7 jours max | Bug fix en cours, debug session |
| `[PROJET ACTIF]` | Tant que le projet tourne | {{CLIENT_WP}} round 4, {{PROJECT_EDU_APP}} V3.5.x |
| `[DEADLINE J-XX]` | Jusqu'à la date | Mémoire MBA 14/06, soutenance 15/07 |
| `[ARCHIVE Q3]` | À déplacer fin trimestre | Sessions terminées qui peuvent servir d'historique |
| `[RÉFLEXE PERMANENT]` | Jamais purgé | Règles métier durcies ({{EMPLOYEE_ID}}, URLs Sage SEE) |

Sans tag = défaut `[ÉPHÉMÈRE 7j]`.

## Verdict de fin de session (3 phrases obligatoires)

Avant de fermer une session productive importante, écrire :
```
À GARDER dans primer : <bullet list, 2-5 items max>
À ARCHIVER : <bullet list, ce qui sort du primer pour aller en archive>
À JETER : <bullet list, ce qui n'a plus aucune utilité>
```

{{USER_NAME}} valide en 30 secondes. Je purge selon.

## Compression lessons.md (mensuelle)

Tous les 1er du mois, OU quand `lessons.md > 80 lignes` :

1. Archiver le fichier actuel : `cp lessons.md tasks/lessons-archive-YYYY-MM.md`
2. Grouper les leçons par thème (WordPress / Code TS / {{GAME_PROJECT}} / {{PROJECT_EDU_APP}} / Process / Infra Mac)
3. Garder seulement :
   - **Leçons fraîches** (< 30 jours, pattern pas encore acquis)
   - **Leçons hautement transversales** (s'appliquent à plusieurs projets)
4. Jeter :
   - Leçons devenues réflexe (j'applique systématiquement sans effort)
   - Leçons obsolètes (techno changée, projet fermé)
5. Format compact : 1 ligne par leçon dans une table, pas un paragraphe par leçon.

## Pour les MDs projet ({{CLIENT_WP}} / {{GAME_PROJECT}} / {{PROJECT_EDU_APP}} / etc.)

Même règle : `CLAUDE.md` ≤ 150 lignes. Si plus :
- Sortir le détail dans `<projet>/_docs/<sous-sujet>.md`
- Garder dans CLAUDE.md uniquement : architecture haute, commandes clés, gotchas critiques, pointeurs

## Trigger automatique

Hook `session-end.sh` rappelle (silencieusement dans le log) :
- Si `wc -l primer.md > 200` : "primer en dépassement, compresser"
- Si `wc -l lessons.md > 80` : "lessons en dépassement, compresser"

Le check est dans le log, pas spammé dans le chat. Mais {{USER_NAME}} peut consulter avec `tail ~/.claude/session-end.log` si besoin.

## Anti-pattern à éviter (cause origine {{USER_NAME}} 02/06)

❌ Dump tout dans primer sans tri (génère 405 lignes en 5 jours)
❌ Ajouter une lesson sans vérifier si elle est déjà couverte (doublons)
❌ Garder une lesson qui est devenue réflexe (pollue)
❌ Sessions actives stackées sans tag de durée de vie
❌ Pointer vers un fichier qui n'existe pas / lien mort

## Checklist fin de session

- [ ] `wc -l primer.md` ≤ 200 (sinon externaliser)
- [ ] `wc -l lessons.md` ≤ 80 (sinon compresser)
- [ ] Verdict 3 phrases écrit ("À GARDER / ARCHIVER / JETER")
- [ ] Tags posés sur les nouvelles entrées primer
- [ ] Aucune lesson doublon ajoutée
