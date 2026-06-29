#!/bin/bash
# Hook SessionEnd : rédige les secrets connus dans les transcripts Claude Code
# Créé le 21/05/2026 suite à audit sécurité (clés Anthropic exposées dans .jsonl)
# Doit s'exécuter APRÈS backup-projects.sh (sinon le backup re-pollue)

set +e  # ne pas crash sur erreurs de grep -c

LOG="$HOME/.claude/redact-secrets.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TARGET_DIRS=(
  "$HOME/.claude/projects"
  "$HOME/.claude/projects-backup"
)
HISTORY_FILE="$HOME/.claude/history.jsonl"

# Regex globale pour DÉTECTION (compte avant/après)
DETECT_RE='sk-ant-(api|sid)[0-9]{2}-[A-Za-z0-9_-]{20,}|AIza[A-Za-z0-9_-]{35}|gh[opsu]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{60,}|sk_(live|test)_[A-Za-z0-9]{20,}|gsk_[A-Za-z0-9]{40,}|xox[bpsr]-[0-9]+-[0-9]+[-A-Za-z0-9]*|AKIA[0-9A-Z]{16}'

# Patterns sed -E individuels (pour rédaction)
SED_EXPRS=(
  -e 's/sk-ant-api[0-9]{2}-[A-Za-z0-9_-]{20,}/[REDACTED-SK-ANT-API]/g'
  -e 's/sk-ant-sid[0-9]{2}-[A-Za-z0-9_-]{20,}/[REDACTED-SK-ANT-SID]/g'
  -e 's/AIza[A-Za-z0-9_-]{35}/[REDACTED-GOOGLE-API]/g'
  -e 's/gho_[A-Za-z0-9]{30,}/[REDACTED-GITHUB-OAUTH]/g'
  -e 's/ghp_[A-Za-z0-9]{30,}/[REDACTED-GITHUB-PAT]/g'
  -e 's/ghs_[A-Za-z0-9]{30,}/[REDACTED-GITHUB-SERVER]/g'
  -e 's/github_pat_[A-Za-z0-9_]{60,}/[REDACTED-GITHUB-FINEGRAINED]/g'
  -e 's/sk_live_[A-Za-z0-9]{20,}/[REDACTED-STRIPE-LIVE]/g'
  -e 's/sk_test_[A-Za-z0-9]{20,}/[REDACTED-STRIPE-TEST]/g'
  -e 's/gsk_[A-Za-z0-9]{40,}/[REDACTED-GROQ]/g'
  -e 's/xoxb-[0-9]+-[0-9]+-[A-Za-z0-9]+/[REDACTED-SLACK-BOT]/g'
  -e 's/xoxp-[0-9]+-[0-9]+-[0-9]+-[A-Za-z0-9]+/[REDACTED-SLACK-USER]/g'
  -e 's/AKIA[0-9A-Z]{16}/[REDACTED-AWS-KEY]/g'
)

count_secrets() {
  # Compte les matches sans crash (-c retourne exit 1 si 0)
  local f="$1"
  grep -cE "$DETECT_RE" "$f" 2>/dev/null || true
}

clean_int() {
  # Force entier
  local v="$1"
  printf '%s' "$v" | head -1 | tr -dc '0-9'
}

total_files=0
total_redactions=0

for dir in "${TARGET_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    before=$(clean_int "$(count_secrets "$f")")
    before=${before:-0}
    if [ "$before" -gt 0 ] 2>/dev/null; then
      sed -i '' -E "${SED_EXPRS[@]}" "$f" 2>/dev/null
      after=$(clean_int "$(count_secrets "$f")")
      after=${after:-0}
      redacted=$((before - after))
      total_files=$((total_files + 1))
      total_redactions=$((total_redactions + redacted))
    fi
  done < <(find "$dir" -name "*.jsonl" -type f 2>/dev/null)
done

# Aussi history.jsonl
if [ -f "$HISTORY_FILE" ]; then
  before=$(clean_int "$(count_secrets "$HISTORY_FILE")")
  before=${before:-0}
  if [ "$before" -gt 0 ] 2>/dev/null; then
    sed -i '' -E "${SED_EXPRS[@]}" "$HISTORY_FILE" 2>/dev/null
    after=$(clean_int "$(count_secrets "$HISTORY_FILE")")
    after=${after:-0}
    total_files=$((total_files + 1))
    total_redactions=$((total_redactions + before - after))
  fi
fi

echo "[$DATE] files_touched=$total_files redactions=$total_redactions" >> "$LOG"
exit 0
