#!/usr/bin/env bash
# mcp-health-check.sh — Lightweight MCP auto-reconnect hook
# Tracks MCP failures and attempts reconnect via `claude mcp restart`
set -euo pipefail

CACHE_FILE="$HOME/.claude/mcp-health-cache.json"
input=$(cat)

# Extract tool name from hook input
tool_name=$(echo "$input" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('tool_name',''))" 2>/dev/null || echo "")

# Only care about MCP tools
if [[ "$tool_name" != mcp__* ]]; then
  exit 0
fi

# Extract server name (mcp__SERVERNAME__toolname -> SERVERNAME)
server_name=$(echo "$tool_name" | sed 's/^mcp__//;s/__.*$//')

# On PostToolUseFailure: mark server unhealthy and attempt reconnect
if [[ "${CLAUDE_HOOK_EVENT_NAME:-}" == "PostToolUseFailure" ]]; then
  # Log the failure
  now=$(date +%s)
  python3 -c "
import json, os
cache_file = '$CACHE_FILE'
try:
    cache = json.load(open(cache_file))
except:
    cache = {}
server = '$server_name'
entry = cache.get(server, {'failures': 0, 'last_failure': 0})
entry['failures'] = entry.get('failures', 0) + 1
entry['last_failure'] = $now
cache[server] = entry
os.makedirs(os.path.dirname(cache_file), exist_ok=True)
json.dump(cache, open(cache_file, 'w'))
" 2>/dev/null

  # Attempt reconnect (fire and forget)
  if command -v claude &>/dev/null; then
    claude mcp restart "$server_name" 2>/dev/null &
  fi
fi

exit 0
