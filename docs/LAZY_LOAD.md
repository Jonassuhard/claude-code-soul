# Lazy-load — MCP & agents à la demande

> Pattern pour ne pas charger 15 MCP servers + 4 LaunchAgents au démarrage de chaque session.

---

## Le problème

Stack typique d'un power user Claude Code :

- 15 MCP servers (Gmail, Calendar, Figma, GitHub, Semrush, Telegram, etc.)
- 4-7 LaunchAgents macOS (daemons cron, watchers, schedulers)
- 270 skills (la majorité jamais invoqués dans une session donnée)
- 14-20 agents (idem)

Si tout est chargé au start :
- ~30 KB de descriptions MCP dans le contexte
- 4-7 processus daemon en arrière-plan (RAM 100-300 MB)
- Listing skill bloated qui dilue le routing

Économie possible : ~30 KB par session + 200 MB RAM + 0 daemons inutiles si tu ne fais que du code ce jour-là.

---

## Le pattern lazy-load

### Côté MCP

Au lieu d'avoir tous tes MCP dans `~/.claude/.mcp.json`, tu les mets dans un vault :

```bash
~/.claude/mcp-vault.json   # Tous tes MCP (jamais lu par Claude Code)
~/.claude/.mcp.json        # Seulement ceux activés (lu au start)
```

Un wrapper `mcp` shell te permet de switch :

```bash
mcp list                   # Liste les MCP dispo dans le vault
mcp on gmail               # Active "gmail" (copie du vault vers .mcp.json)
mcp on gmail figma         # Active plusieurs d'un coup
mcp off all                # Désactive tout (vide .mcp.json)
mcp profile dev            # Charge un preset "dev" (gh + figma + filesystem)
```

### Côté LaunchAgents

Tu stockes les `.plist` dans un dossier "désactivé" :

```bash
~/Library/LaunchAgents/             # Actifs (chargés au login)
~/Library/LaunchAgents.disabled/    # Vault (jamais lus par launchd)
```

Wrapper `agent` :

```bash
agent list                          # Liste tous les LaunchAgents (actifs + vault)
agent on career-ops-daily           # Active = mv vers ~/Library/LaunchAgents + launchctl load
agent off career-ops-daily          # Désactive = launchctl unload + mv vers .disabled
agent run career-ops-daily          # One-shot manuel
```

### Côté Claude Code

Les skills et agents ne sont pas vraiment "lazy-loadés" au sens MCP — Claude lit tous les frontmatters au start (juste `name` + `description`). Mais le **corps** d'un skill n'est lu qu'à invocation. Donc :

- Garde des `description` claires et courtes (sinon ton listing bloat)
- Les skills non utilisés peuvent rester dans `~/.claude/skills/` sans coût significatif
- Les agents inutilisés idem dans `~/.claude/agents/`

---

## Implémentation minimale du wrapper `mcp`

```bash
# Dans ~/.zshrc ou ~/.bashrc

mcp() {
  local VAULT="$HOME/.claude/mcp-vault.json"
  local ACTIVE="$HOME/.claude/.mcp.json"

  case "${1:-list}" in
    list)
      jq -r '.mcpServers | keys[]' "$VAULT" | sort
      ;;
    on)
      shift
      for name in "$@"; do
        # Extrait le bloc du vault, merge dans .mcp.json
        jq --arg n "$name" --slurpfile vault "$VAULT" \
          '.mcpServers[$n] = $vault[0].mcpServers[$n]' \
          "$ACTIVE" > "$ACTIVE.tmp" && mv "$ACTIVE.tmp" "$ACTIVE"
        echo "✓ $name activé"
      done
      ;;
    off)
      if [[ "$2" == "all" ]]; then
        echo '{"mcpServers": {}}' > "$ACTIVE"
      else
        shift
        for name in "$@"; do
          jq --arg n "$name" 'del(.mcpServers[$n])' "$ACTIVE" > "$ACTIVE.tmp" && mv "$ACTIVE.tmp" "$ACTIVE"
          echo "✓ $name désactivé"
        done
      fi
      ;;
    profile)
      local profile="$2"
      case "$profile" in
        dev)    mcp on gh figma filesystem ;;
        seo)    mcp on semrush gsc filesystem ;;
        social) mcp on gmail telegram canva ;;
        *)      echo "Profile inconnu: $profile" ;;
      esac
      ;;
    *)
      echo "Usage: mcp {list|on|off|profile} [args]"
      ;;
  esac
}
```

Format `~/.claude/mcp-vault.json` :

```json
{
  "mcpServers": {
    "gmail": {
      "command": "uvx",
      "args": ["mcp-server-gmail"],
      "env": { "GMAIL_CREDS_PATH": "..." }
    },
    "figma": { ... },
    "gh": { ... }
  }
}
```

---

## Implémentation minimale du wrapper `agent`

```bash
agent() {
  local ACTIVE="$HOME/Library/LaunchAgents"
  local VAULT="$HOME/Library/LaunchAgents.disabled"

  case "${1:-list}" in
    list)
      echo "== Actifs =="
      ls "$ACTIVE"/com.user.*.plist 2>/dev/null | xargs -n1 basename
      echo ""
      echo "== Vault =="
      ls "$VAULT"/com.user.*.plist 2>/dev/null | xargs -n1 basename
      ;;
    on)
      local name="com.user.${2}.plist"
      if [[ -f "$VAULT/$name" ]]; then
        mv "$VAULT/$name" "$ACTIVE/"
        launchctl load "$ACTIVE/$name"
        echo "✓ $name activé"
      else
        echo "Non trouvé dans vault: $name"
      fi
      ;;
    off)
      local name="com.user.${2}.plist"
      if [[ -f "$ACTIVE/$name" ]]; then
        launchctl unload "$ACTIVE/$name"
        mv "$ACTIVE/$name" "$VAULT/"
        echo "✓ $name désactivé"
      fi
      ;;
    run)
      local name="com.user.${2}.plist"
      launchctl start "$name"
      ;;
  esac
}
```

---

## Profils recommandés

| Contexte | Profile à charger |
|---|---|
| Code sprint | `mcp profile dev` (gh + figma + filesystem) |
| Audit SEO | `mcp profile seo` (semrush + gsc + filesystem) |
| Veille | `mcp on firecrawl context7` |
| Communications | `mcp profile social` (gmail + telegram + canva) |
| Tests browser | `mcp on playwright chrome-devtools` |

L'idée : 3-5 MCP par session, pas 15. Tu décides au lancement de la session.

---

## Trade-offs

| Avantage | Coût |
|---|---|
| Économie tokens contexte (~30 KB) | Friction setup avant chaque session (1 commande `mcp on X`) |
| Économie RAM (200 MB+) | Mental load : se rappeler quel MCP activer |
| Listing skills plus propre | Risque d'oublier d'activer un MCP nécessaire |
| Latence start Claude Code réduite | Tu dois maintenir le `mcp-vault.json` |

Pour un usage occasionnel (< 1h par jour), pas besoin. Pour un usage intensif (4-8h par jour), gain net.

---

## Mesurer le gain

Avant lazy-load :
```bash
claude --debug 2>&1 | grep "MCP servers loaded" | head -1
# → "MCP servers loaded: 15 servers, 142 tools, ~28 KB descriptions"
```

Après :
```bash
mcp off all && claude --debug 2>&1 | grep "MCP servers loaded" | head -1
# → "MCP servers loaded: 0 servers, 0 tools, 0 KB descriptions"

mcp on gh figma && claude --debug 2>&1 | grep "MCP servers loaded" | head -1
# → "MCP servers loaded: 2 servers, ~18 tools, ~4 KB descriptions"
```

Gain ≈ 24 KB par session sur un setup standard. Sur 50 sessions/mois, c'est 1.2 MB de contexte économisé (+ la qualité de routing).
