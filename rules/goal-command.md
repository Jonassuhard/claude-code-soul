# /goal — Claude Code autonome (guide d'usage {{USER_NAME}})

Référencé quand tu lances une tâche longue à état final vérifiable. `/goal` requiert Claude Code v2.1.139+. Doc : `code.claude.com/docs/en/goal`.

## Ce que c'est

`/goal <condition>` : Claude bosse turn après turn sans que tu re-prompts. Après chaque turn, un évaluateur (modèle frais, Haiku par défaut) lit le transcript et décide si la condition est remplie. Non → relance avec la raison comme guidance. Oui → clôt le goal. Un seul goal actif par session.

C'est la version NATIVE du pattern bricolé la nuit du 25/05 (7 `/loop 1h` + ScheduleWakeup + LaunchAgent watcher). À privilégier sur ce bricolage pour toute tâche à critère mesurable.

## Règle d'or — la condition fait tout

L'évaluateur **ne lit que le transcript**. Il n'appelle aucun outil, ne relance pas les tests, ne lit pas les fichiers. Il juge ce que Claude a déjà affiché à l'écran.

Donc : écris une condition **mesurable que la sortie de Claude peut démontrer**.

Bonne condition :
- `tous les tests de test/auth passent et le lint est clean`
- `npm test exits 0 et git status est clean`
- `chaque page du backlog labellisé est traitée, queue vide`
- borne incluse : `... ou stop après 20 turns`

Mauvaise condition (floue, l'évaluateur ne peut pas trancher) :
- `le code est propre` / `c'est bien fait` / `l'app est belle`

Si tu écris flou, le problème n'est pas le juge, c'est ta condition. 4000 caractères max.

Structure qui tient sur la durée : un état final mesurable + une preuve attendue (`npm test exits 0`) + les contraintes à ne pas violer (`aucun autre fichier de test modifié`).

## Modèle évaluateur — laisser Haiku

L'évaluateur = le "small fast model" (alias `haiku`). Sur une condition mesurable, Haiku lit `14 passed` aussi bien qu'Opus → **ne pas changer**.

Changer via `ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-opus-4-8` est une fausse bonne idée : cette variable pilote AUSSI toute la background functionality (résumés, titres, compaction) → coût qui explose. Ne jamais mettre en permanent.

L'anti-hallucination vient de la **séparation** (juge frais ≠ codeur), pas de la puissance du juge. Si Haiku valide à tort des "done" récurrents → écrire un Stop hook prompt-based custom ciblé (pas toucher au background global).

## Quand /goal vs /loop vs Stop hook

| Outil | Prochain turn démarre quand | S'arrête quand |
|---|---|---|
| `/goal` | le turn précédent finit | un modèle confirme la condition |
| `/loop` | un intervalle de temps s'écoule | toi, ou Claude juge le travail fini |
| Stop hook | le turn précédent finit | ton script/prompt décide |

- Tâche à état final vérifiable (migration, build, refacto jusqu'à budget) → **`/goal`**
- Polling périodique / veille / heartbeat → **`/loop`** (cf `loop-template.md`)
- Logique d'éval déterministe custom et récurrente → **Stop hook**

## Usages concrets {{USER_NAME}}

- {{GAME_PROJECT}} : `tous les tests pipeline passent et le render MP4 existe` pendant un fix
- Portfolio : `npm run build exits 0 et 0 erreur TS` (PAS `npm run dev` — lesson Mac)
- {{CLIENT_EDU}} : audit repo read-only `chaque page du Sheet a un statut`
- Mémoire MBA : `le PDF V1.X build sans erreur et fait 97 pages`

## Non-interactif

```bash
claude -p "/goal CHANGELOG.md a une entrée pour chaque PR mergée cette semaine"
```
Ctrl+C pour stopper avant complétion. `/goal clear` pour annuler en session. Un goal actif survit à `--resume`/`--continue` (mais timer + compteurs reset).

## Garde-fous

- Toujours une borne de sortie dans la condition (`ou stop après N turns`) pour éviter une boucle infinie coûteuse.
- Auto mode (`--permission-mode auto`) + `/goal` = complémentaires : auto enlève les prompts par-outil, /goal enlève les prompts par-turn. Combinés = vraiment autonome, mais à n'utiliser que sur tâche bornée et de confiance.
- Requiert workspace trusté (l'évaluateur fait partie du système de hooks).
