# LOOP TEMPLATE — Anti-runaway, anti-empty-loop

Référencé quand tu lances un `/loop` (intervalle fixe ou dynamique) ou quand tu structures un workflow nuit autonome.

**Cause origine** : nuit 25/05/2026, 7 loops Opus parallèles ont brûlé ~4h de quota sans livrable. Cause = prompts sans critère DONE explicite, sans checks intermédiaires, sans bornes de sortie.

---

## 1. Avant de lancer un `/loop` autonome

Demande-toi (et écris la réponse dans le prompt initial) :

| Question | Format de la réponse |
|---|---|
| **Quel est le livrable final ?** | Path absolu d'un fichier + format attendu. Pas "un rapport", mais `~/Desktop/X/RAPPORT_2026-MM-DD.md` avec 5 sections. |
| **Quel est le critère DONE ?** | Assertion testable. Ex: `test -f <path> && grep -c "^## " <path> ≥ 5`. Pas "quand c'est bien". |
| **Quel est le critère STOP fail-safe ?** | Heure limite OU N itérations max OU les deux. Ex: "stoppe à 08:00 OU après 6 itérations sans progression". |
| **Comment je sais que j'ai progressé** entre 2 itérations ? | Métrique observable. Ex: "nb commits git augmenté", "fichier de log a +N lignes", "wc -w sur le draft a augmenté". |
| **Si je suis bloqué, je fais quoi ?** | Stratégie. Ex: "écris INCOMPLETE avec cause + besoin, stoppe le loop". Pas "réessaye indéfiniment". |

Si tu n'as pas de réponse claire aux 5 questions → **ne lance pas le loop**. Tu vas brûler du quota.

---

## 2. Structure d'un prompt `/loop` propre

```
/loop <intervalle> <consigne>

OBJECTIF:
<one-liner livrable final attendu>

LIVRABLE:
- Path: <absolu>
- Format: <markdown / json / code / ...>
- Sections obligatoires: <liste>

CRITÈRE DONE (testable):
- [ ] <assertion 1 vérifiable via Bash>
- [ ] <assertion 2>
- [ ] <assertion 3>

CRITÈRE STOP FAIL-SAFE:
- Si heure ≥ <HH:MM> → STOP (récap final, pas de wakeup)
- OU si <N> itérations sans progression sur la métrique <X> → STOP
- OU si livrable atteint avant l'heure → STOP

À CHAQUE ITÉRATION:
1. Date + état actuel des assertions (PASS X/N)
2. Action incrémentale (ajout commit, écriture section, fix bug, etc.)
3. Append journal dans <path-log>
4. Si DONE → écris résumé final, pas de ScheduleWakeup
5. Si pas DONE et pas STOP → ScheduleWakeup(intervalle, même prompt)

SI BLOQUÉ:
Écris dans le log :
INCOMPLETE:
- Manque: <quoi>
- Cause: <pourquoi>
- Besoin: <ce qui débloquerait>
Puis STOP (pas de wakeup).
```

---

## 3. Quand `/loop` Claude Code est le BON outil

✓ Tâche **incrémentale** où chaque itération ajoute quelque chose de testable (paragraphes mémoire, commits code, sections rapport)
✓ Tu **restes devant le Mac** ou tu sais que Claude Code reste actif (ex: nuit avec Mac qui ne dort pas)
✓ Tu as un **critère DONE clair** atteignable en N itérations finies
✓ La tâche a besoin du **contexte de session** (skills, MCPs, conversation history)

## 4. Quand `/loop` n'est PAS le bon outil

✗ Watch / monitoring 24/7 d'un service externe → **LaunchAgent macOS indépendant** (cf. `com.user.night-monitor`, fait survivre les crashes Claude)
✗ Tâche qui dort (« checke dans 2h ») et Mac peut dormir → **launchd `RunAtLoad: false` + `StartCalendarInterval`**
✗ Polling d'API avec rate limit → **cron job + script Python autonome**
✗ Tu fermes ton terminal avant la fin → **ScheduleWakeup ne refire pas si la session est fermée**

---

## 5. Heuristiques de cadence (`delaySeconds`)

Reprises de la doc `ScheduleWakeup`, adaptées au profil {{USER_NAME}} :

| Use case | Délai | Pourquoi |
|---|---|---|
| Polling CI / build / deploy externe | **60-270s** | Cache prompt reste warm (<5 min) |
| Polling 5-20 min (test slow) | **270s × N** | Sleep 5 min = cache miss anyway, viser 4×270s plutôt qu'1×300s |
| Idle tick autonome (tâche async qui prend des heures) | **1200-1800s** | 20-30 min, économise le cache, l'humain peut interrompre |
| Watcher nuit (1× par heure) | **3600s** | Max autorisé, économie max |

**Ne jamais sleep 300s exactement** : pire choix (cache miss sans amortir).

---

## 6. Pattern de récupération d'erreur

À chaque itération, après l'action, vérifier :

```bash
# Did we actually make progress ?
PROGRESS_METRIC=$(<commande qui retourne un compteur>)
PREVIOUS=$(<lire depuis log de la dernière itération>)

if [ "$PROGRESS_METRIC" -le "$PREVIOUS" ]; then
  STUCK_COUNTER=$((STUCK_COUNTER + 1))
  if [ "$STUCK_COUNTER" -ge 3 ]; then
    echo "INCOMPLETE: stuck 3 iterations sans progression"
    # STOP — pas de wakeup
    exit 0
  fi
else
  STUCK_COUNTER=0
fi
```

---

## 7. Antipatterns observés (à éviter)

| Antipattern | Cause origine | Fix |
|---|---|---|
| Prompt vague "continue le travail" | Aucun critère DONE | Lister 3-5 assertions testables avant lancement |
| Pas de path de livrable explicite | Confusion sur "où sortir" | Toujours déclarer 1 ou N paths absolus |
| ScheduleWakeup sans condition stop | Boucle infinie | Heure max + max itérations |
| Mac qui dort pendant le loop | Pas de fallback | LaunchAgent macOS pour les watchers nuit |
| 7 loops parallèles sans monitor | Aucun voit l'autre | 1 watcher LaunchAgent indépendant qui check les 7 dossiers cibles |
| "Pipeline OK" sans vérifier les outputs | Cascade hallucination | Vérifier `test -f` sur chaque livrable promis |
| Pas de récap final | User réveille et galère | Toujours écrire un brief réveil `~/Desktop/<projet>/BRIEF_REVEIL_<date>.md` |

---

## 8. Pour les loops nuit autonomes {{USER_NAME}}

Pattern validé (cf. `~/.claude/rules/scheduled-tasks.md`) :

1. Lance N sessions Claude Code dans N terminaux (1 par tâche)
2. Dans chaque : `/loop 1h <prompt structuré selon ce template>`
3. Setup un **LaunchAgent macOS séparé** qui check les N dossiers cibles toutes les 30 min
4. Alerte Telegram via creds Keychain si silence > 90-120 min sur un dossier
5. Watcher se désactive seul à l'heure cible + envoie récap final

Le LaunchAgent est ta **vraie assurance** contre les crashes Claude / Mac dormi / sessions fermées. Le `/loop` Claude est juste l'exécution.

---

## 9. Checklist avant de lancer

- [ ] Livrable path absolu déclaré
- [ ] 3-5 assertions DONE testables (Bash-runnable)
- [ ] Critère STOP heure ET critère STOP itérations
- [ ] Métrique de progression observable
- [ ] Stratégie INCOMPLETE clairement définie
- [ ] Si nuit : LaunchAgent indépendant configuré en parallèle
- [ ] BRIEF_REVEIL pré-créé avec ce qui sera mis à jour
- [ ] Tu sais ce que tu vas faire au réveil avec le livrable (vérifier / pousser / acter)

Si une case manque : **ne lance pas, complète d'abord**.
