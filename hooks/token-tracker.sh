#!/bin/bash
# Token tracker v2 (17/05/2026) — vrai tracking + alerte Telegram si seuil dépassé
# Triggered by Stop hook (fire-and-forget, exit immédiat, parse en background)
# Dépendances : ccusage (npm -g), jq, curl

# Background subshell — ne bloque pas le hook Stop
(
  export PATH="$HOME/.nvm/versions/node/v22.22.2/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

  LOG_FILE="$HOME/.claude/token-usage.log"
  THRESHOLD_DAILY_USD=200
  THRESHOLD_DAILY_TOKENS_M=500
  BOT_TOKEN=$(security find-generic-password -s "claude-telegram-bot" -a "user" -w 2>/dev/null)
  CHAT_ID=$(security find-generic-password -s "claude-telegram-chatid" -a "user" -w 2>/dev/null)

  TODAY=$(date +%Y-%m-%d)
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  JSON=$(ccusage daily --json 2>/dev/null)
  if [ -z "$JSON" ]; then
    echo "[$TIMESTAMP] ccusage failed" >> "$LOG_FILE"
    exit 0
  fi

  LINE=$(echo "$JSON" | jq -r ".daily[] | select(.period == \"${TODAY}\") | \"\(.totalTokens) \(.totalCost)\"" 2>/dev/null)
  if [ -z "$LINE" ]; then
    echo "[$TIMESTAMP] no data for ${TODAY} yet" >> "$LOG_FILE"
    exit 0
  fi

  TOKENS=$(echo "$LINE" | awk '{print $1}')
  COST=$(echo "$LINE" | awk '{print $2}')
  TOKENS_M=$((TOKENS / 1000000))
  COST_INT=$(echo "$COST" | cut -d. -f1)

  echo "[$TIMESTAMP] daily=${TODAY} tokens=${TOKENS} (${TOKENS_M}M) cost=\$${COST}" >> "$LOG_FILE"

  osascript -e "display notification \"${TOKENS_M}M tokens / \$${COST_INT} aujourd'hui\" with title \"Claude — Fin tâche\"" 2>/dev/null

  ALERT_FLAG="$HOME/.claude/.token-alert-${TODAY}"
  if [ ! -f "$ALERT_FLAG" ]; then
    ALERT=""
    if [ "$COST_INT" -ge "$THRESHOLD_DAILY_USD" ] 2>/dev/null; then
      ALERT="ALERTE Claude jour : \$${COST} (seuil ${THRESHOLD_DAILY_USD}\$). ${TOKENS_M}M tokens."
    elif [ "$TOKENS_M" -ge "$THRESHOLD_DAILY_TOKENS_M" ] 2>/dev/null; then
      ALERT="ALERTE Claude jour : ${TOKENS_M}M tokens (seuil ${THRESHOLD_DAILY_TOKENS_M}M). \$${COST}."
    fi

    if [ -n "$ALERT" ] && [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
      curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${ALERT}" >/dev/null 2>&1
      touch "$ALERT_FLAG"
      echo "[$TIMESTAMP] ALERT envoyée Telegram" >> "$LOG_FILE"
    fi
  fi
) > /dev/null 2>&1 &
disown 2>/dev/null
exit 0
