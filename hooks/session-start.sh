#!/bin/bash
# Session start hook v2 (08/05/2026) — minimal, anti-doublon
# Évite de re-injecter primer.md et workflow.md déjà chargés via CLAUDE.md.
# Layers utiles uniquement : feedback rules + git context + hindsight + project lessons.
# Backup original : session-start.sh.bak-20260508-*

HINDSIGHT_URL="${HINDSIGHT_URL:-http://localhost:8889}"

echo "## Live Context"
echo ""

# --- L1 SKIP : primer.md déjà auto-importé via @primer.md dans ~/.claude/CLAUDE.md
PRIMER="$HOME/.claude/primer.md"
if [ -f "$PRIMER" ]; then
  PRIMER_LINES=$(wc -l < "$PRIMER" 2>/dev/null | tr -d ' ')
  PRIMER_MTIME=$(stat -f "%Sm" -t "%d/%m %H:%M" "$PRIMER" 2>/dev/null)
  echo "**primer.md** : $PRIMER_LINES lignes, maj $PRIMER_MTIME (déjà importé via CLAUDE.md)"
  echo ""
fi

# --- L2 Lessons projet-spécifiques uniquement (pas global, déjà dans CLAUDE.md règle "read at start")
for LESSONS in \
  "$PWD/tasks/lessons.md" \
  "$PWD/.claude/lessons.md"; do
  if [ -f "$LESSONS" ]; then
    LESSONS_LINES=$(wc -l < "$LESSONS" 2>/dev/null | tr -d ' ')
    if [ "$LESSONS_LINES" -le 100 ]; then
      echo "### Lessons projet ($LESSONS_LINES lignes)"
      cat "$LESSONS"
    else
      echo "### Lessons projet ($LESSONS_LINES lignes — trop long, à compresser)"
      head -50 "$LESSONS"
      echo "... [tronqué — read full file si besoin]"
    fi
    echo ""
    break
  fi
done

# --- L3 Feedback rules (utile, max 5 lignes par fichier)
FEEDBACK_DIR="$HOME/.claude/projects/workspace/memory"
if [ -d "$FEEDBACK_DIR" ]; then
  FEEDBACK_FILES=$(find "$FEEDBACK_DIR" -maxdepth 1 -name "feedback_*.md" 2>/dev/null)
  if [ -n "$FEEDBACK_FILES" ]; then
    echo "### Behavioral Rules"
    for f in $FEEDBACK_FILES; do
      sed -n '/^---$/,/^---$/!p' "$f" | head -3
    done
    echo ""
  fi
fi

# --- L4 SKIP : workflow checklist déjà dans ~/.claude/rules/workflow.md chargé via CLAUDE.md

# --- L5 Git context (compressé)
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  COMMITS=$(git log --oneline -3 2>/dev/null)
  MODIFIED_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  echo "### Git"
  echo "**Branch:** $BRANCH · **Modified files:** $MODIFIED_COUNT"
  echo "**Last 3 commits:**"
  echo "$COMMITS"
  if [ "$MODIFIED_COUNT" -gt 0 ] && [ "$MODIFIED_COUNT" -le 10 ]; then
    echo "**Modified:**"
    git status --short 2>/dev/null
  fi
  echo ""
fi

# --- L6 Hindsight (utile, conservé tel quel)
RECALL_JSON=$(curl -sf -X POST "$HINDSIGHT_URL/v1/default/banks/claude-sessions/memories/recall" \
  -H 'Content-Type: application/json' \
  -d '{"query": "behavioral patterns, corrections, and preferences for Claude Code sessions"}' \
  --max-time 3 \
  2>/dev/null)

if [ -n "$RECALL_JSON" ] && [ "$RECALL_JSON" != "null" ]; then
  PATTERNS=$(echo "$RECALL_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    seen = set()
    for r in data.get('results', [])[:5]:
        t = r.get('text', '')
        if t and t not in seen:
            seen.add(t)
            print(f'- {t}')
except: pass
" 2>/dev/null)

  if [ -n "$PATTERNS" ]; then
    echo "### Hindsight Patterns"
    echo "$PATTERNS"
    echo ""
  fi
fi

exit 0
