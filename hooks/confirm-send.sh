#!/bin/bash
# =============================================================
# SECURITY HOOK: Touch ID + 30min session + escalating lockout
# =============================================================
# - Touch ID required for sensitive actions
# - Once validated, 30 min free pass before re-asking
# - 3 attempts with 10s timeout each
# - After 3 fails: 2 min lockout + photo + alerts
# - After 6 fails: 10 min lockout + photo + alerts
# =============================================================

STATE_FILE="$HOME/.claude/hooks/.touchid-state"
SESSION_FILE="$HOME/.claude/hooks/.touchid-session"
PHOTO_DIR="$HOME/.claude/hooks/security-photos"
TOUCHID_BIN="$HOME/.claude/hooks/touchid-confirm"
LOCKOUT_FILE="$HOME/.claude/hooks/.touchid-lockout"

# Session duration in seconds (30 minutes)
SESSION_DURATION=1800

# Alert config (fill in your values)
TELEGRAM_BOT_TOKEN=$(security find-generic-password -s "claude-telegram-bot" -a "user" -w 2>/dev/null)
TELEGRAM_CHAT_ID=$(security find-generic-password -s "claude-telegram-chatid" -a "user" -w 2>/dev/null)
ALERT_EMAIL="user@example.com"
ALERT_PHONE="${ALERT_PHONE}"

mkdir -p "$PHOTO_DIR"

# ---- Check if session is still valid (30 min window) ----
NOW=$(date +%s)
if [ -f "$SESSION_FILE" ]; then
    SESSION_UNTIL=$(cat "$SESSION_FILE" 2>/dev/null || echo 0)
    if [ "$NOW" -lt "$SESSION_UNTIL" ]; then
        # Session active, let it through
        exit 0
    fi
fi

# ---- Check lockout ----
FAIL_COUNT=0
if [ -f "$STATE_FILE" ]; then
    FAIL_COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

if [ -f "$LOCKOUT_FILE" ]; then
    LOCKOUT_UNTIL=$(cat "$LOCKOUT_FILE" 2>/dev/null || echo 0)
    if [ "$NOW" -lt "$LOCKOUT_UNTIL" ]; then
        REMAINING=$(( (LOCKOUT_UNTIL - NOW) / 60 ))
        echo '{"error": "LOCKED OUT: '"$REMAINING"' min remaining."}'
        exit 2
    else
        rm -f "$LOCKOUT_FILE"
    fi
fi

# ---- Attempt Touch ID (3 tries, 10s each) ----
AUTH_SUCCESS=false

for ATTEMPT in 1 2 3; do
    "$TOUCHID_BIN" "Action sensible — Touch ID ($ATTEMPT/3)" &
    TOUCHID_PID=$!
    ( sleep 10 && kill $TOUCHID_PID 2>/dev/null ) &
    TIMER_PID=$!
    wait $TOUCHID_PID 2>/dev/null
    TOUCHID_EXIT=$?
    kill $TIMER_PID 2>/dev/null
    wait $TIMER_PID 2>/dev/null
    if [ $TOUCHID_EXIT -eq 0 ]; then
        AUTH_SUCCESS=true
        echo "0" > "$STATE_FILE"
        # Start 30 min session
        echo "$((NOW + SESSION_DURATION))" > "$SESSION_FILE"
        break
    fi
    echo "Touch ID attempt $ATTEMPT/3 failed." >&2
done

if [ "$AUTH_SUCCESS" = true ]; then
    exit 0
fi

# ---- All 3 attempts failed ----
FAIL_COUNT=$((FAIL_COUNT + 3))
echo "$FAIL_COUNT" > "$STATE_FILE"

# Set lockout
if [ "$FAIL_COUNT" -ge 6 ]; then
    echo "$((NOW + 600))" > "$LOCKOUT_FILE"
elif [ "$FAIL_COUNT" -ge 3 ]; then
    echo "$((NOW + 120))" > "$LOCKOUT_FILE"
fi

# Take screenshot + attempt webcam photo
SCREENSHOT_PATH="$PHOTO_DIR/screen_$(date +%Y%m%d_%H%M%S).png"
PHOTO_PATH="$PHOTO_DIR/intruder_$(date +%Y%m%d_%H%M%S).jpg"
screencapture -x "$SCREENSHOT_PATH" 2>/dev/null
# Webcam photo via Terminal.app (bypasses sandbox)
osascript -e "tell application \"Terminal\" to do script \"/opt/homebrew/bin/imagesnap -q $PHOTO_PATH\"" 2>/dev/null
# Wait for webcam photo to be saved
for i in 1 2 3 4 5 6 7 8; do
    [ -f "$PHOTO_PATH" ] && break
    sleep 1
done
# If webcam failed, fallback to screenshot
[ ! -f "$PHOTO_PATH" ] && PHOTO_PATH="$SCREENSHOT_PATH"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
ALERT_MSG="ALERTE SECURITE Claude Code: $FAIL_COUNT tentatives Touch ID echouees a $TIMESTAMP sur $(hostname)."

# Telegram
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" -d text="$ALERT_MSG" > /dev/null 2>&1
    # Send screenshot
    if [ -f "$SCREENSHOT_PATH" ]; then
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto" \
            -F chat_id="$TELEGRAM_CHAT_ID" -F photo="@$SCREENSHOT_PATH" -F caption="Screenshot - $TIMESTAMP" > /dev/null 2>&1
    fi
    # Send webcam photo
    if [ -f "$PHOTO_PATH" ] && [ "$PHOTO_PATH" != "$SCREENSHOT_PATH" ]; then
        /usr/bin/curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto" \
            -F chat_id="$TELEGRAM_CHAT_ID" -F photo="@$PHOTO_PATH" -F caption="Webcam intruder - $TIMESTAMP" > /dev/null 2>&1
    fi
fi

# Gmail via Mail.app
if [ "$ALERT_EMAIL" != "__GMAIL_ADDRESS__" ]; then
    osascript -e "
        tell application \"Mail\"
            set newMsg to make new outgoing message with properties {subject:\"ALERTE SECURITE Claude Code\", content:\"$ALERT_MSG\", visible:false}
            tell newMsg
                make new to recipient at end of to recipients with properties {address:\"$ALERT_EMAIL\"}
            end tell
            send newMsg
        end tell
    " > /dev/null 2>&1 &
fi

# iMessage
if [ "$ALERT_PHONE" != "__IMESSAGE_PHONE__" ]; then
    osascript -e "
        tell application \"Messages\"
            set targetService to 1st account whose service type = iMessage
            set targetBuddy to participant \"$ALERT_PHONE\" of targetService
            send \"$ALERT_MSG\" to targetBuddy
        end tell
    " > /dev/null 2>&1 &
fi

echo '{"error": "BLOCKED: Touch ID failed 3x. Lockout active. Alerts sent."}'
exit 2
