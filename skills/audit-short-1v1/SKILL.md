---
name: audit-short-1v1
description: Audit pré-publication YouTube d'un short {{GAME_PROJECT}} 1v1. Score viralité 0-100 + verdict GO/WARN/NO-GO + recommandations basées sur algo YouTube Shorts 2026 + forensic du channel {{YT_CHANNEL}} (5 métriques pondérées : durée 35%, iconic personas 30%, action density 20%, hook variance 15%, bonus winner overlay). Use when about to upload a 1v1 short, or when user asks "audit ce short" / "est-ce que cette vidéo va marcher" / "score viralité" pour un .mp4 1v1.
---

# Skill : audit-short-1v1

Audit pré-publication d'un short {{GAME_PROJECT}} format **1v1**.
Score 0-100 + verdict GO/WARN/NO-GO + recommandations actionnables.

## Prérequis

```bash
cd ~/Desktop/battle-engine
source .venv/bin/activate
# Deps : cv2 (deja), imagehash, pytesseract (deja installés)
# Tesseract binary : /opt/homebrew/bin/tesseract (deja present)
```

## Invoquer

```bash
cd ~/Desktop/battle-engine
source .venv/bin/activate
python3 pipeline/audit_cli.py --preset 1v1 /path/to/video.mp4
# Avec matchup explicite (optionnel, sinon parsé du nom de fichier) :
python3 pipeline/audit_cli.py --preset 1v1 /path/to/video.mp4 --matchup mario,pikachu
```

**Exit code** : 0 si GO ou WARN, 1 si NO-GO.

## Métriques et poids

| Métrique | Poids | PASS | WARN | FAIL |
|---|---|---|---|---|
| `duration_s` | 35% | 25-45s | 18-24s ou 46-60s | <18s ou >60s |
| `iconic_score` | 30% | ≥2 icônes | 1 icône | 0 icône |
| `action_density` | 20% | ≥14 | 8-13 | <8 |
| `hook_variance_t2` | 15% | ≤734 | 735-1200 | >1200 |

**Icônes** : Mario, Pikachu, Sonic, Goku, Steve (Minecraft).

**Bonus** : +5 pts si overlay winner détecté (OCR sur les 5 dernières frames).

**Hard gates NO-GO** : résolution != 1080x1920, black_frame_ratio > 10%, freeze_ratio > 15%, durée > 90s.

## Interpréter le score

| Score | Verdict | Action |
|---|---|---|
| 60-100 | GO — top tier probable | Uploader |
| 40-59 | WARN — mid tier | Envisager re-render ou uploader quand même |
| 0-39 | NO-GO — sous-performance attendue | Re-render avec autre seed ou changer matchup |

**Floor 55** : si une métrique est critique (FAIL avec poids élevé), le score est capé à 55 même si les autres sont PASS.

## Que faire si NO-GO

1. **duration_s FAIL (>60s)** : Re-render avec autre seed. Réduire HP de 20% pour finish plus rapide.
2. **iconic_score FAIL (0)** : Remplacer 1 perso par Mario/Pikachu/Sonic/Goku/Steve. +67% vues en moyenne sur le channel.
3. **action_density FAIL (<8)** : Combat statique. Vérifier hitboxes ou augmenter agressivité IA. Re-render.
4. **hook_variance_t2 FAIL (>1200)** : Intro corrompue ou bug de spawn à t=1.5s. Re-render impératif.
5. **freeze_ratio FAIL** : Frames figées. Bug Godot probable. Re-render.

## Exemple output JSON

```json
{
  "score": 100,
  "verdict": "GO — top tier probable",
  "preset": "1v1",
  "hard_gate": null,
  "floor_triggered": false,
  "metrics": {
    "duration_s": 35.57,
    "resolution": "1080x1920",
    "hook_variance_t2": 0.0,
    "action_density": 20.57,
    "black_frame_ratio": 0.0,
    "freeze_ratio": 0.0,
    "winner_text_present": true,
    "multi_fighter_visible_t2": 5,
    "iconic_score": 2,
    "matchup": ["mario", "pikachu"]
  },
  "contributions": {
    "duration_s": {"value": 35.57, "verdict": "PASS", "contribution": 35.0},
    "iconic_score": {"value": 2.0, "verdict": "PASS", "contribution": 30.0},
    "action_density": {"value": 20.57, "verdict": "PASS", "contribution": 20.0},
    "hook_variance_t2": {"value": 0.0, "verdict": "PASS", "contribution": 15.0}
  },
  "bonus": {"winner_overlay": "+5"},
  "recommendations": []
}
```

## Calibration (24/05/2026)

Calibré sur 111 vidéos {{YT_CHANNEL}}.
- Seuils forensic (Pearson) : hook_variance -0.734, duration -0.513, action_density +0.184, iconic +0.264.
- Sweet spot duration 1v1 : 27-35s (batch 18-20 successful).
- Personages iconiques both = avg 723 views, none = 477 views.

## OUTPUT CONTRACT
Respecte `~/.claude/rules/output-contract.md`.

**Attendu** : JSON output stdout (format exemple ci-dessus) + exit code 0/1 selon verdict

**Checks** :
- [ ] JSON sortie parseable : `python3 -c "import json,sys; json.loads(sys.stdin.read())"` ≤ exit 0
- [ ] Champs obligatoires : `score`, `verdict`, `preset`, `metrics`, `contributions`, `recommendations`
- [ ] `score` ∈ [0, 100]
- [ ] `verdict` ∈ {"GO — top tier probable", "WARN — mid tier", "NO-GO — sous-performance attendue, refaire"}
- [ ] Exit code 0 si score ≥ 40, exit 1 si < 40
- [ ] Si NO-GO : `recommendations` non vide avec action concrète par métrique FAIL
- [ ] Hard gates checkés (résolution, freeze, black, durée)

**Format réponse** : `LIVRABLE: audit 1v1 / SCORE: X / VERDICT: GO|WARN|NO-GO / METRICS: dur=A iconic=B action=C var=D / RECO: <liste si NO-GO> / NEXT: <upload | re-render seed Y | changer matchup>`

**Anti-hallucination** : Si le script Python a échoué : `INCOMPLETE: audit_cli.py failed (<erreur>)`. Si la vidéo n'est pas 1080×1920 : hard gate NO-GO immédiat.
