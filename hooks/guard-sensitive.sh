#!/bin/bash
# =============================================================
# GUARD SENSITIVE ACTIONS — Touch ID sur suppressions d'apps + computer-use
# =============================================================
# Declenche confirm-send.sh (Touch ID + session 30 min globale) pour :
#  1. Toute commande Bash qui peut supprimer une application
#  2. Tout tool MCP computer-use sauf les lectures safe (screenshot, etc.)
# Les autres tool calls passent silencieusement (exit 0).
# =============================================================

CONFIRM_HOOK="$HOME/.claude/hooks/confirm-send.sh"
AUDIT_LOG="$HOME/.claude/hooks/.guard-audit.log"

# Lire le payload JSON fourni par Claude Code sur stdin
PAYLOAD=$(cat 2>/dev/null)
TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name // empty' 2>/dev/null)
TOOL_INPUT_JSON=$(echo "$PAYLOAD" | jq -c '.tool_input // {}' 2>/dev/null)

# --- Detection : suppression d'application ---
is_app_deletion() {
    local cmd
    cmd=$(echo "$TOOL_INPUT_JSON" | jq -r '.command // empty' 2>/dev/null)
    [ -z "$cmd" ] && return 1

    # rm qui cible une .app (avec ou sans sudo, n'importe ou)
    echo "$cmd" | grep -qE '(^|[^a-zA-Z_])rm[[:space:]]+([^|;]*[[:space:]])?-[A-Za-z]*[rRf][A-Za-z]*[[:space:]]+[^|;]*\.app([[:space:]/"'\'']|$)' && return 0
    echo "$cmd" | grep -qE 'sudo[[:space:]]+rm[[:space:]]+[^|;]*\.app([[:space:]/"'\'']|$)' && return 0

    # rm qui cible /Applications/ explicitement (meme sans extension)
    echo "$cmd" | grep -qE '(^|[^a-zA-Z_])rm[[:space:]]+[^|;]*/[Aa]pplications/' && return 0

    # Homebrew uninstall / remove
    echo "$cmd" | grep -qE '(^|[^a-zA-Z_])brew[[:space:]]+(uninstall|rm|remove|cask[[:space:]]+uninstall)' && return 0

    # Mac App Store uninstall
    echo "$cmd" | grep -qE '(^|[^a-zA-Z_])mas[[:space:]]+uninstall' && return 0

    # AppleScript qui demande au Finder de trash une app
    echo "$cmd" | grep -qiE 'osascript.*tell[[:space:]]+application[[:space:]]+"Finder".*(delete|move[[:space:]]+to[[:space:]]+trash)' && return 0

    # mv d'une .app vers trash / /dev/null
    echo "$cmd" | grep -qE 'mv[[:space:]]+[^|;]*\.app[[:space:]]+[^|;]*(\.Trash|/dev/null)' && return 0

    return 1
}

# --- Detection : computer-use non-read-only ---
is_computer_use_write() {
    case "$TOOL_NAME" in
        # Lectures / setup safe — pas de Touch ID
        mcp__computer-use__screenshot) return 1 ;;
        mcp__computer-use__list_granted_applications) return 1 ;;
        mcp__computer-use__cursor_position) return 1 ;;
        mcp__computer-use__read_clipboard) return 1 ;;
        mcp__computer-use__request_access) return 1 ;;
        mcp__computer-use__request_teach_access) return 1 ;;
        # Toute autre tool computer-use = prise de controle => Touch ID
        mcp__computer-use__*) return 0 ;;
    esac
    return 1
}

REASON=""
if is_app_deletion; then
    REASON="Suppression d'application"
elif is_computer_use_write; then
    REASON="Prise de controle (computer-use): $TOOL_NAME"
fi

if [ -z "$REASON" ]; then
    exit 0
fi

# Audit log
mkdir -p "$(dirname "$AUDIT_LOG")"
echo "$(date '+%Y-%m-%d %H:%M:%S') | $TOOL_NAME | $REASON | $(echo "$TOOL_INPUT_JSON" | head -c 200)" >> "$AUDIT_LOG"

# Delegue a confirm-send.sh (qui gere Touch ID + session 30 min globale)
if [ ! -x "$CONFIRM_HOOK" ]; then
    echo '{"permissionDecision": "deny", "permissionDecisionReason": "Guard hook introuvable ou non executable"}' >&2
    exit 2
fi

"$CONFIRM_HOOK"
EXIT=$?

if [ $EXIT -ne 0 ]; then
    echo "{\"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"$REASON bloquee (Touch ID non valide).\"}" >&2
    exit 2
fi

exit 0
