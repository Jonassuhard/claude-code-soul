#!/bin/bash
# MCP cleanup hook (19/05/2026) — kill MCP processes orphelins en fin de session
# Triggered by SessionEnd
# Empêche l'accumulation de zombies entre sessions Claude Code (cause secondaire du lag 19/05)

(
  export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
  LOG_FILE="$HOME/.claude/mcp-cleanup.log"
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Liste des MCP processes connus pour rester orphelins après session end
  # (filtre strict : commande exacte, pas substring path)
  PATTERNS=(
    "chrome-devtools-mcp"
    "excalidraw-mcp"
    "server-filesystem"
    "@modelcontextprotocol/server-filesystem"
    "bun .*plugins/cache.*telegram.*server.ts"
  )

  KILLED=0
  for pattern in "${PATTERNS[@]}"; do
    PIDS=$(pgrep -f "$pattern" 2>/dev/null)
    for pid in $PIDS; do
      # Skip si le process est encore parent d'une session active (PPID = claude)
      PARENT_CMD=$(ps -p $(ps -p $pid -o ppid= 2>/dev/null | tr -d ' ') -o command= 2>/dev/null | head -c 60)
      if echo "$PARENT_CMD" | grep -q "claude"; then
        continue
      fi
      kill $pid 2>/dev/null && KILLED=$((KILLED + 1))
    done
  done

  if [ $KILLED -gt 0 ]; then
    echo "[$TIMESTAMP] killed $KILLED MCP zombies" >> "$LOG_FILE"
  fi
) > /dev/null 2>&1 &
disown 2>/dev/null
exit 0
