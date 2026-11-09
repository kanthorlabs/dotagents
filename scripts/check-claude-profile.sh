#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

command -v claude >/dev/null 2>&1 || { echo "error: claude is not on PATH"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }

if [ "$CLAUDE_DIR" = "$HOME/.claude" ]; then
	login="claude auth login"
else
	login="CLAUDE_CONFIG_DIR=\"$CLAUDE_DIR\" claude auth login"
fi
[ -d "$CLAUDE_DIR" ] || { echo "error: missing profile $CLAUDE_DIR; run '$login' first"; exit 1; }

if [ "$CLAUDE_DIR" = "$HOME/.claude" ]; then
	status=$(env -u CLAUDE_CONFIG_DIR claude auth status 2>/dev/null || true)
else
	status=$(CLAUDE_CONFIG_DIR="$CLAUDE_DIR" claude auth status 2>/dev/null || true)
fi

[ "$(jq -r '.loggedIn // false' <<<"$status" 2>/dev/null)" = "true" ] \
	|| { echo "error: profile $CLAUDE_DIR is not logged in; run '$login' first"; exit 1; }
[ "$(jq -r '.configDirectory' <<<"$status")" = "$CLAUDE_DIR" ] \
	|| { echo "error: claude resolved $(jq -r '.configDirectory' <<<"$status"), expected $CLAUDE_DIR"; exit 1; }
echo "profile    $CLAUDE_DIR logged in as $(jq -r '.email // .authMethod' <<<"$status")"
