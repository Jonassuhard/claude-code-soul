# Anti-patterns IA — Liste exhaustive

> À utiliser en passe d'audit après rédaction. Chaque pattern détecté = à corriger.

## 1. Patterns de structure

### Triplets symétriques
- « Pas de X. Pas de Y. Pas de Z. »
- « Plus de X, plus de Y, plus de Z. »
- « X, Y, Z. »

**Solution** : casser le rythme. Mélanger longueurs et types de phrases.

### Conclusion-résumé par paragraphe
L'IA termine chaque paragraphe par une phrase qui résume ce qui vient d'être dit.

**Solution** : terminer par une question implicite, une transition, ou une affirmation tranchée qui ne reprend pas le contenu.

### Headers symétriques répétés
« Côté X / Côté Y / Côté Z » répété 4 fois dans le doc.

**Solution** : varier les structures de titre. Mixer « Comment X », « X et Y », « Le cas de X ».

### Listes à puces partout
L'IA met une liste pour toute énumération de 3+ éléments.

**Solution** : prose narrative. Si 4 destinations à citer, écrire une phrase qui les nomme.

### Paragraphes identiques en longueur et structure
L'IA construit chaque paragraphe sur le même modèle (intro / dev / conclu).

**Solution** : variation visible. Certains paragraphes 3 lignes, d'autres 12. Certains commencent par une affirmation, d'autres par une question, d'autres par un fait.

---

## 2. Patterns de ponctuation

### Deux-points en cascade
« Le sujet est clair : X. Pour Y : Z. »

**Solution** : reformuler avec « car », « parce que », « puisque », « du coup ».

### Tirets cadratins partout
« Le problème — et c'est récurrent — concerne X. »

**Solution** : parenthèses, virgules, ou reformulation en deux phrases.

### Slashes pour relier deux concepts
« Une approche méthode/process. »

**Solution** : « une approche méthode et process » ou « une approche à la fois méthode et process ».

### Bolds en rafale
3+ bolds par paragraphe.

**Solution** : max 1 bold en prose par paragraphe. Bolds réservés aux concepts pivots du texte entier.

### Emojis structurels
🔹 ✅ ❌ 🎯 dans le corps du texte.

**Solution** : bannir. Si vraiment besoin de marquer une distinction, utiliser des mots.

---

## 3. Vocabulaire IA générique

### Adjectifs creux à supprimer
incontournable · révolutionnaire · passionnant · véritablement · pleinement · parfaitement · totalement · vraiment · particulièrement · notablement

### Verbes IA à reformuler
plonger · propulser · élever · tirer parti de · exploiter · optimiser (verbe creux) · redéfinir · façonner · témoigner de

### Noms IA à éviter
paysage (numérique) · tapisserie · synergie · myriade · pléthore · écosystème (usage gratuit)

### Adverbes inflationnistes
« véritablement essentiel » → essentiel
« parfaitement adapté » → adapté
« pleinement intégré » → intégré

---

## 4. Connecteurs mécaniques

À supprimer ou remplacer :
- en effet → (supprimer)
- de plus → et surtout
- par ailleurs → (supprimer)
- en outre → aussi
- il convient de noter que → (supprimer)
- force est de constater → (supprimer)
- il est important de souligner → j'insiste sur
- néanmoins / toutefois → mais
- ainsi en début de phrase → (supprimer)
- dorénavant → désormais (sobre)
- à cet égard → (supprimer)
- en somme / en définitive → (supprimer)
- indéniablement / incontestablement → (supprimer)
- fondamentalement → (supprimer)
- qui plus est → et
- il va sans dire → (supprimer)
- dans un monde en constante évolution → aujourd'hui
- en conclusion / pour résumer → (supprimer la conclusion artificielle)

---

## 5. Patterns de phrase

### Question rhétorique d'engagement
« Vous êtes-vous déjà demandé… ? »

**Solution** : commencer par une affirmation factuelle.

### Hedge-then-assert (hésitation puis affirmation)
« On pourrait dire que X. Mais en réalité, X est central. »

**Solution** : affirmer directement.

### Voix passive par défaut
« Les stratégies sont mises en place par l'équipe. »

**Solution** : actif. « L'équipe met en place les stratégies. »

### Problème/Solution mécanique
« Le défi ? X. La solution ? Y. »

**Solution** : narration intégrée. « Face à X, nous avons opté pour Y. »

### Boucle « Despite challenges »
« Malgré X, faces challenges… Despite these challenges, nous avons… »

**Solution** : enlever cette boucle. Affirmer directement la réussite ou la difficulté.

---

## 6. Patterns de signification inflationnée

L'IA ajoute « significatif » / « important » / « notable » partout pour gonfler la perception.

❌ « Cette mission notable a permis un apprentissage significatif et un impact important. »
✅ « Cette mission m'a appris X. Concrètement Y. »

---

## 7. Patterns de prudence excessive

L'IA met des hedges partout pour ne pas se mouiller :
« il semble que », « il est possible que », « cela pourrait suggérer », « dans une certaine mesure », « relativement », « plutôt ».

**Solution** : assumer. Si on n'est pas sûr, dire « je n'ai pas mesuré » plutôt que multiplier les hedges.

---

## 8. Patterns de promotion

L'IA termine en mode brochure marketing :
« Cette approche unique offre des avantages compétitifs majeurs. »
« Une solution sur-mesure pour répondre aux enjeux d'aujourd'hui. »

**Solution** : factualiser. « Cette approche a permis X. Limite : Y. »

---

## 9. Patterns de personnalité absente

L'IA ne s'engage jamais. Tout est neutre, équilibré, sans point de vue.

**Solution** : prendre position. « Je considère que X » / « À mon sens, Y est secondaire ».

---

## 10. Test ultime : lisibilité humaine

Question à se poser sur chaque paragraphe :
> *Est-ce qu'un humain compétent et un peu fatigué écrirait exactement ça ?*

Si la réponse est « non, c'est trop poli, trop équilibré, trop bien construit » → c'est de l'IA. Casser.

---

## 11. Sycophancy ChatGPT — interdit absolu

Phrases à supprimer immédiatement :
- « Excellente question ! »
- « C'est un point très intéressant. »
- « Vous avez tout à fait raison. »
- « Une réflexion approfondie. »
- « Cela mérite d'être souligné. »

**Solution** : aller directement au fond. Pas de validation préalable du lecteur.

---

## 12. Le test du copier-coller

Si tu peux copier un paragraphe et le coller dans n'importe quel autre mémoire/article sans rien changer → c'est trop générique. Réécrire avec des éléments **propres au cas {{USER_NAME}}/{{CLIENT_EDU}}**.

Exemples d'ancrage spécifique :
- Citer un chiffre {{CLIENT_EDU}} (5 600 étudiants, 95 % insertion)
- Citer un retour anonymisé (référent technique, appui éditorial)
- Citer une situation (ToDo 13-17 avril, FAQ bourses)
- Citer une donnée audit (Site Health 63 %, PageSpeed 48)
