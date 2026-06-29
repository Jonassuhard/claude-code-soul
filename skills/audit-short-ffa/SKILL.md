---
name: audit-short-ffa
description: Audit pré-publication YouTube d'un short {{GAME_PROJECT}} format 4-way FFA (1V1V1V1). Score viralité 0-100 + verdict GO/WARN/NO-GO + recommandations basées sur algo YouTube Shorts 2026 + forensic du channel {{YT_CHANNEL}} (5 métriques pondérées : durée 35%, iconic personas 30%, action density 20%, hook variance 15%, bonus multi_fighter visible). Seuils FFA différents du 1v1 : durée cible 45-75s (pas 25-45), action density seuil 18 (pas 14), iconic ≥3/4 pour PASS. Use when about to upload a FFA short, or when user asks "audit ce short FFA" / "score viralité FFA" pour un .mp4 4-way.
---

# Skill : audit-short-ffa

Audit pré-publication d'un short {{GAME_PROJECT}} format **4-way FFA** (1V1V1V1).
Score 0-100 + verdict GO/WARN/NO-GO + recommandations actionnables.

## Pourquoi des seuils différents du 1v1

- **Durée cible 45-75s** (pas 25-45s) : 4 fighters = besoin de temps pour que chacun agisse. <30s = massacre unilatéral (bug batch 21 Football GOAT 13s → NO-GO).
- **Action density ≥18** (pas ≥14) : 4 fighters devraient produire plus de mouvement qu'un duel.
- **Iconic ≥3/4** (pas ≥2/2) : FFA a besoin de plus d'icônes pour maximiser l'audience de plusieurs fandoms.

## Prérequis

```bash
cd ~/Desktop/battle-engine
source .venv/bin/activate
# Deps : cv2, imagehash, pytesseract (déjà installés)
```

## Invoquer

```bash
cd ~/Desktop/battle-engine
source .venv/bin/activate
python3 pipeline/audit_cli.py --preset ffa /path/to/video.mp4
# Avec matchup explicite (recommandé pour FFA, souvent 4 fighters) :
python3 pipeline/audit_cli.py --preset ffa /path/to/video.mp4 --matchup goku,mario,sonic,pikachu
```

**Exit code** : 0 si GO ou WARN, 1 si NO-GO.

## Métriques et poids

| Métrique | Poids | PASS | WARN | FAIL |
|---|---|---|---|---|
| `duration_s` | 35% | 45-75s | 30-44s ou 76-90s | <30s ou >90s |
| `iconic_score` | 30% | ≥3/4 icônes | 2/4 | ≤1/4 |
| `action_density` | 20% | ≥18 | 12-17 | <12 |
| `hook_variance_t2` | 15% | ≤900 | 901-1500 | >1500 |

**Icônes** : Mario, Pikachu, Sonic, Goku, Steve (Minecraft).

**Bonus** : +5 pts si ≥3 fighters distincts visibles à t=1.5s (connected components).

**Hard gates NO-GO** : résolution != 1080x1920, black_frame_ratio > 10%, freeze_ratio > 15%, durée > 90s.

## Interpréter le score

| Score | Verdict | Action |
|---|---|---|
| 60-100 | GO — top tier probable | Uploader |
| 40-59 | WARN — mid tier | Envisager re-render ou uploader quand même |
| 0-39 | NO-GO — sous-performance attendue | Re-render avec autre seed ou changer matchup |

## Que faire si NO-GO

1. **duration_s FAIL (<30s)** : Massacre unilatéral probable (1 fighter trop fort). Re-render impératif. Équilibrer les stats ou choisir des fighters plus proches en puissance.
2. **duration_s FAIL (>90s)** : Exclu de l'algorithme Shorts. Réduire HP ou utiliser comme long format uniquement.
3. **iconic_score FAIL (<2)** : Remplacer 2+ persos par Mario/Pikachu/Sonic/Goku/Steve. Pour FFA l'audience attend des icônes gaming reconnues.
4. **action_density FAIL (<12)** : FFA statique. 4 fighters bloqués ou pas assez agressifs. Re-render avec autre seed.
5. **hook_variance_t2 FAIL (>1500)** : Bug d'intro FFA. Spawn incorrect des 4 fighters. Re-render.

## Exemple output JSON (Football GOAT 13s — NO-GO réel)

```json
{
  "score": 12,
  "verdict": "NO-GO — sous-performance attendue, refaire",
  "preset": "ffa",
  "metrics": {
    "duration_s": 12.6,
    "resolution": "1080x1920",
    "hook_variance_t2": 1036.1,
    "action_density": 6.44,
    "iconic_score": 0,
    "matchup": ["cristiano_ronaldo", "kylian_mbappe", "lionel_messi", "neymar"]
  },
  "contributions": {
    "duration_s": {"value": 12.6, "verdict": "FAIL", "contribution": 0.0},
    "iconic_score": {"value": 0.0, "verdict": "FAIL", "contribution": 0.0},
    "action_density": {"value": 6.44, "verdict": "FAIL", "contribution": 0.0},
    "hook_variance_t2": {"value": 1036.1, "verdict": "WARN", "contribution": 7.5}
  },
  "recommendations": [
    "FFA trop court (<30s). Re-render impératif.",
    "Moins de 2 personnages iconiques. Remplacer par Mario/Pikachu/Sonic/Goku/Steve.",
    "FFA statique (< 12). Re-render."
  ]
}
```

## Calibration (24/05/2026)

- Batch 21 FFA : vidéos 13-16s toutes NO-GO (score ≤15)
- Batch 21 FFA réussies (27-29s, icônes gaming) : GO (score ≥70)
- Signal forensic FFA : la durée est le discriminant #1 (delta top vs bottom = 35+ pts)

## OUTPUT CONTRACT
Respecte `~/.claude/rules/output-contract.md`. Identique à `audit-short-1v1` mais seuils FFA.

**Attendu** : JSON stdout + exit code

**Checks spécifiques FFA** :
- [ ] JSON parseable, champs `score/verdict/preset=ffa/metrics/contributions/recommendations`
- [ ] Seuils FFA appliqués : durée 45-75s PASS, iconic ≥3/4 PASS, action_density ≥18 PASS
- [ ] Bonus multi_fighter visible t=2s : +5 si ≥3 fighters distincts détectés
- [ ] Si durée < 30s ou > 90s : NO-GO obligatoire
- [ ] Si 4 fighters fournis : matchup champ contient 4 items

**Format réponse** : `LIVRABLE: audit FFA / SCORE: X / VERDICT: GO|WARN|NO-GO / DURÉE: Ys (target 45-75) / ICONIC: A/4 / FIGHTERS VIS T2: B / NEXT: <upload | re-render | re-match>`

**Anti-hallucination** : Si seuls 3 fighters détectés sur 4 attendus : flag `INCOMPLETE: connected_components < 4 fighters` (bug spawn probable).
