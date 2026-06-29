#!/bin/bash
# dev-ram-guard.sh — Hook PreToolUse (Bash) ANTI-LAG.
#
# Cause origine : 29/05/2026, ~6× `npm run dev` (Next 16 Turbopack) + ~4×
# Playwright chromium lancés en background sans toujours tuer le précédent
# → accumulation de workers → saturation RAM Mac 16 Go → 1h perdue par {{USER_NAME}}.
#
# Rôle : empêcher l'ACCUMULATION de serveurs dev / navigateurs headless.
# Règle = UN SEUL dev/preview/chromium à la fois. Si un tourne déjà et
# qu'on tente d'en lancer un second → BLOQUE (exit 2) avec message.
#
# Conçu pour être ULTRA léger (grep + pgrep, pas de python) car exécuté
# avant CHAQUE commande Bash. Fail-OPEN : toute erreur interne → exit 0
# (on n'empêche jamais une commande à cause d'un bug du hook).

input=$(cat 2>/dev/null) || exit 0
[ -z "$input" ] && exit 0

# 1. Les commandes de NETTOYAGE passent toujours (sinon on ne peut plus
#    se débloquer). pkill / kill / kill-dev-zombies / killall.
if printf '%s' "$input" | grep -qE 'pkill|killall|kill-dev-zombies|kill[[:space:]]+-9'; then
  exit 0
fi

# 1bis. Les commandes de DIAGNOSTIC/LECTURE passent toujours, même si elles
#    contiennent le texte "next dev" (ex: `pgrep -f "next dev"`, `ps aux | grep`).
#    Ce sont des inspections, pas des lancements. Extrait le 1er mot de la
#    commande (après un éventuel `cd ... &&`) et l'autorise si c'est un outil
#    de lecture. Évite les faux positifs qui bloquaient les diagnostics.
firstcmd=$(printf '%s' "$input" | sed -E 's/^[[:space:]]*cd[[:space:]]+[^&;|]*(&&|;)?[[:space:]]*//' | grep -oE '^[[:space:]]*[A-Za-z0-9_/.-]+' | tr -d ' ' | xargs basename 2>/dev/null)
case "$firstcmd" in
  pgrep|grep|ps|cat|echo|curl|git|wc|ls|head|tail|top|awk|sed|stat|find|sleep|date|memory_pressure|printf|which|test)
    exit 0 ;;
esac

# 2. Détecte un lancement dev / preview / navigateur headless lourd.
if printf '%s' "$input" | grep -qiE 'next[[:space:]]+dev|run[[:space:]]+dev|(pnpm|yarn|bun)[[:space:]]+dev|vercel[[:space:]]+dev|playwright|puppeteer|headless_shell|chromium'; then
  # Combien de serveurs dev / navigateurs headless tournent DÉJÀ ?
  running=$(pgrep -f 'next dev|next-server|next/dist/bin/next|headless_shell|ms-playwright' 2>/dev/null | wc -l | tr -d ' ')
  running=${running:-0}
  if [ "$running" -gt 0 ]; then
    {
      echo "🛑 ANTI-LAG GUARD — commande bloquée."
      echo ""
      echo "$running process dev/navigateur-headless tournent DÉJÀ."
      echo "Lancer un second saturerait la RAM (incident 29/05 : 1h perdue)."
      echo ""
      echo "Règle : UN SEUL dev/preview/chromium à la fois."
      echo "→ Nettoie d'abord :  ~/scripts/kill-dev-zombies.sh"
      echo "→ Puis relance ta commande, OU utilise :  ~/scripts/dev-safe.sh <dir>"
    } >&2
    exit 2
  fi

  # RAM dispo suffisante ? Next 16 Turbopack a besoin de marge. Si le %
  # de RAM libre système est trop bas, lancer un dev fait laguer le Mac
  # entier (incident 29/05). On bloque sous 15% libre. Fail-open si
  # memory_pressure indispo.
  freepct=$(/usr/bin/memory_pressure -Q 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1)
  if [ -n "$freepct" ] && [ "$freepct" -lt 15 ]; then
    {
      echo "🛑 ANTI-LAG GUARD — commande bloquée (RAM basse)."
      echo ""
      echo "RAM libre système : ${freepct}% (seuil mini 15%)."
      echo "Lancer un dev/preview Turbopack maintenant ferait laguer le Mac."
      echo ""
      echo "→ Ferme des apps (onglets Chrome, Adobe, Codex…) d'abord."
      echo "→ OU teste le portfolio toi-même quand la RAM est dégagée."
      echo "→ Vérif build sans serveur :  npx tsc --noEmit  (léger, déjà vert)."
    } >&2
    exit 2
  fi
fi

exit 0
