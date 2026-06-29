#!/bin/bash
# setup.sh — claude-code-soul installer
# Reads .env, substitutes {{XXX}} placeholders, installs to ~/.claude/
# Usage: ./setup.sh [--dry-run]

set -euo pipefail

# ===== Helpers =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

CLAUDE_DIR="$HOME/.claude"

red()    { printf "\033[31m%s\033[0m\n" "$1"; }
green()  { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }
blue()   { printf "\033[34m%s\033[0m\n" "$1"; }

# ===== 1. Check prerequisites =====
blue "==> Checking prerequisites..."

if [[ ! -d "$CLAUDE_DIR" ]]; then
  red "ERROR: ~/.claude/ does not exist. Install Claude Code CLI first:"
  red "       https://docs.claude.com/en/docs/claude-code"
  exit 1
fi

if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
  red "ERROR: .env not found. Copy .env.example to .env and fill in your variables."
  exit 1
fi

# ===== 2. Load .env =====
blue "==> Loading .env..."
set -a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/.env"
set +a

if [[ -z "${USER_NAME:-}" ]]; then
  red "ERROR: USER_NAME is required in .env"
  exit 1
fi

green "    USER_NAME=$USER_NAME"

# ===== 3. Backup existing files =====
BACKUP_DIR="$CLAUDE_DIR/_soul-backup-$(date +%Y%m%d-%H%M%S)"
if ! $DRY_RUN; then
  blue "==> Backing up existing files to $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"/{skills,agents,hooks,rules}
  for f in soul.md CLAUDE.md; do
    [[ -f "$CLAUDE_DIR/$f" ]] && cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/" || true
  done
fi

# ===== 4. Substitute placeholders =====
substitute() {
  local src="$1"
  local dst="$2"
  # Replace {{VAR}} with $VAR from env. If env var is empty, leave placeholder.
  local content
  content=$(cat "$src")
  for var in USER_NAME USER_AGE USER_LOCATION USER_PRIMARY_HATS \
             WORKSPACE EXT_DRIVE \
             GAME_PROJECT YT_CHANNEL PROJECT_APP PROJECT_EDU_APP \
             CLIENT_EDU CLIENT_WP CLIENT_WP_DIR CLIENT_LOCAL \
             CLIENT_CONTACT CLIENT_LOCAL_CONTACT CLIENT_LOCAL_HANDLE CITY \
             TUTOR EMPLOYEE_ID FAMILY_MEMBER \
             TELEGRAM_CHAT_ID DISCORD_GUILD_ID DISCORD_APP_ID DATABASE; do
    val="${!var:-}"
    [[ -n "$val" ]] && content="${content//\{\{$var\}\}/$val}"
  done
  if $DRY_RUN; then
    echo "[dry-run] would write $dst"
  else
    mkdir -p "$(dirname "$dst")"
    printf "%s\n" "$content" > "$dst"
  fi
}

# ===== 5. Install skills =====
blue "==> Installing 12 skills..."
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  name=$(basename "$skill_dir")
  for f in "$skill_dir"**/*.md "$skill_dir"*.js; do
    [[ -f "$f" ]] || continue
    rel="${f#$skill_dir}"
    substitute "$f" "$CLAUDE_DIR/skills/$name/$rel"
  done
done

# ===== 6. Install agents =====
blue "==> Installing 4 agents..."
for f in "$SCRIPT_DIR"/agents/*.md; do
  substitute "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# ===== 7. Install hooks =====
blue "==> Installing 8 hooks..."
for f in "$SCRIPT_DIR"/hooks/*.sh; do
  substitute "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
  $DRY_RUN || chmod +x "$CLAUDE_DIR/hooks/$(basename "$f")"
done

# ===== 8. Install rules =====
blue "==> Installing 6 rules..."
mkdir -p "$CLAUDE_DIR/rules"
for f in "$SCRIPT_DIR"/rules/*.md "$SCRIPT_DIR"/rules/*.template; do
  [[ -f "$f" ]] || continue
  base=$(basename "$f")
  # personality.md.template → personality.md when copied
  dst_name="${base%.template}"
  substitute "$f" "$CLAUDE_DIR/rules/$dst_name"
done

# ===== 9. Install soul.md =====
blue "==> Installing soul.md..."
substitute "$SCRIPT_DIR/soul.md.template" "$CLAUDE_DIR/soul.md"

# ===== 10. Print next steps =====
green ""
green "==> Done."
green ""
yellow "Next steps:"
echo "  1. Add this line to ~/.claude/CLAUDE.md (near the top):"
echo "       @soul.md"
echo "  2. Add the rules imports if not present:"
echo "       @rules/personality.md"
echo "       @rules/workflow.md"
echo "  3. Test a skill: in Claude Code, run /claude-council \"should I publish a public repo?\""
echo ""
$DRY_RUN || echo "Backup of overwritten files saved to: $BACKUP_DIR"
