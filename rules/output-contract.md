# OUTPUT CONTRACT — Standard universel agents + skills

Référencé par tous les agents (`~/.claude/agents/*.md`) et skills propriétaires production (`~/.claude/skills/*/SKILL.md`).
**Cause origine** : nuit 25/05/2026, 5/7 loops parallèles ont terminé sans livrable traçable. Solution = forcer chaque agent à déclarer son contrat de sortie + le vérifier.

## Principe

Un agent **n'a pas terminé** tant que :
1. Le ou les **fichiers attendus existent** au path déclaré (vérifiable via `ls`/`stat`)
2. Les **critères de validation** sont passés (assertions testables, pas du déclaratif)
3. La **réponse finale inclut la preuve** (paths absolus, compteurs, smoke test)

## Format obligatoire dans chaque agent/skill

Chaque agent **DOIT** avoir une section `## OUTPUT CONTRACT` qui contient :

```markdown
## OUTPUT CONTRACT

### Fichier(s) attendu(s)
- `<path absolu ou pattern>` — format `<md|json|png|html|...>` — `<contenu attendu en 1 ligne>`

### Checks testables (à exécuter avant de dire "fait")
- [ ] `<commande shell>` retourne `<valeur attendue>`
- [ ] `<assertion 2>`

### Si la tâche a plusieurs modes
Section par mode (création / render / debug / etc.), chacun avec fichiers + checks.

### Format réponse finale (obligatoire)
LIVRABLE: <one-liner du mode exécuté>
FICHIERS:
  - <path1> (<lignes|taille>)
  - <path2>
CHECKS PASS: X/Y
SMOKE TEST: <commande> → <résultat>
PROCHAINE ACTION {{USER_NAME}}: <ce qu'il doit faire ensuite, ou "rien">
```

## Règle anti-hallucination

Si un fichier n'a PAS pu être créé ou si un check fail, **n'écris JAMAIS "fait"**. Écris à la place :

```
INCOMPLETE:
- Manque : <fichier ou check failed précisément>
- Cause : <erreur technique / input manquant / ambiguïté / blocage humain>
- Besoin : <ce qui débloquerait>
```

C'est mieux d'arrêter à 70% du chemin avec un statut clair qu'à 100% avec du vide.

## Vérifications interdites de skipper

- Faire `Edit` sur un fichier **sans le `Read` avant** = halluciné (Edit refusera de toute façon)
- Dire "j'ai écrit le rapport" **sans `ls -la` du path** = halluciné
- Dire "le test passe" **sans coller la sortie de la commande** = halluciné
- Dire "le contenu fait 1200 mots" **sans `wc -w` ou équivalent** = halluciné

## Pourquoi c'est strict

La nuit du 25/05/2026, 5 loops Opus parallèles ont rendu des récaps verbeux sans rien produire de testable. Coût : ~4h Opus brûlées pour rien. Ce contrat évite ça en forçant l'agent à se demander **avant de dire "fait"** : "est-ce que `ls` sur mon livrable retourne quelque chose ?"

## Référencement dans un agent

Dans la section `## OUTPUT CONTRACT` d'un agent, écrire en haut :

> Respecte le standard `~/.claude/rules/output-contract.md`. Spécifiques à cet agent ci-dessous.

Puis détailler les fichiers/checks spécifiques au domaine de l'agent.
