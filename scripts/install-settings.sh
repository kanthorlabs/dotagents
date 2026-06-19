#!/usr/bin/env bash
# Renders config/settings.json (placeholders -> absolute paths), then deep-merges
# it into $CLAUDE_DIR/settings.json. Repo values win on conflict; permissions.allow
# is a union so locally added entries survive. A .bak is written before merging.
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }
mkdir -p "$CLAUDE_DIR"

rendered=$(mktemp) && merged=$(mktemp)
trap 'rm -f "$rendered" "$merged"' EXIT

sed -e "s|{{DOTAGENTS}}|$ROOT|g" -e "s|{{HOME}}|$HOME|g" "$ROOT/config/settings.json" > "$rendered"

if [ -f "$CLAUDE_DIR/settings.json" ]; then
	jq -e 'type == "object"' "$CLAUDE_DIR/settings.json" >/dev/null 2>&1 \
		|| { echo "error: $CLAUDE_DIR/settings.json is not a valid JSON object — fix or remove it first"; exit 1; }
	cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
	jq -s '((.[0].permissions.allow // []) + (.[1].permissions.allow // []) | unique) as $allow
		| .[0] * .[1] | .permissions.allow = $allow' \
		"$CLAUDE_DIR/settings.json" "$rendered" > "$merged" \
		|| { echo "error: merge failed — $CLAUDE_DIR/settings.json left untouched"; exit 1; }
	mv "$merged" "$CLAUDE_DIR/settings.json"
	echo "settings   merged into $CLAUDE_DIR/settings.json (backup: settings.json.bak)"
else
	mv "$rendered" "$CLAUDE_DIR/settings.json"
	echo "settings   created $CLAUDE_DIR/settings.json"
fi
