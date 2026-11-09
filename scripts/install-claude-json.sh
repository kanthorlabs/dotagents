#!/usr/bin/env bash
# Renders .claude/config/claude.json (placeholders -> absolute paths), then deep-merges
# it into Claude Code's global config: $HOME/.claude.json, or $CLAUDE_DIR/.claude.json for a custom profile. Repo values win on
# conflict. A .bak is written before merging.
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
if [ "$CLAUDE_DIR" = "$HOME/.claude" ]; then
	CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
else
	CLAUDE_JSON="${CLAUDE_JSON:-$CLAUDE_DIR/.claude.json}"
fi

command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }

rendered=$(mktemp) && merged=$(mktemp)
trap 'rm -f "$rendered" "$merged"' EXIT
mkdir -p "$(dirname "$CLAUDE_JSON")"

sed -e "s|{{DOTAGENTS}}|$ROOT|g" -e "s|{{HOME}}|$HOME|g" -e '/^[[:space:]]*\/\//d' "$ROOT/.claude/config/claude.json" > "$rendered"

if [ -f "$CLAUDE_JSON" ]; then
	jq -e 'type == "object"' "$CLAUDE_JSON" >/dev/null 2>&1 \
		|| { echo "error: $CLAUDE_JSON is not a valid JSON object — fix or remove it first"; exit 1; }
	cp "$CLAUDE_JSON" "$CLAUDE_JSON.bak"
	jq -s '.[0] * .[1]' "$CLAUDE_JSON" "$rendered" > "$merged" \
		|| { echo "error: merge failed — $CLAUDE_JSON left untouched"; exit 1; }
	mv "$merged" "$CLAUDE_JSON"
	echo "claude.json merged into $CLAUDE_JSON (backup: .claude.json.bak)"
else
	mv "$rendered" "$CLAUDE_JSON"
	echo "claude.json created $CLAUDE_JSON"
fi
