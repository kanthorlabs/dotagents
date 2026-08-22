#!/usr/bin/env bash
# Renders .opencode/config/opencode.jsonc (placeholders -> absolute paths), then
# deep-merges it into $OPENCODE_DIR/opencode.jsonc (OpenCode's global config).
# Repo values win on conflict. A .bak is written before merging.
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
OPENCODE_JSON="$OPENCODE_DIR/opencode.jsonc"

command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }

rendered=$(mktemp) && merged=$(mktemp)
trap 'rm -f "$rendered" "$merged"' EXIT

sed -e "s|{{DOTAGENTS}}|$ROOT|g" -e "s|{{HOME}}|$HOME|g" -e '/^[[:space:]]*\/\//d' "$ROOT/.opencode/config/opencode.jsonc" > "$rendered"

mkdir -p "$OPENCODE_DIR"

if [ -f "$OPENCODE_JSON" ]; then
	jq -e 'type == "object"' "$OPENCODE_JSON" >/dev/null 2>&1 \
		|| { echo "error: $OPENCODE_JSON is not a valid JSON object — fix or remove it first"; exit 1; }
	cp "$OPENCODE_JSON" "$OPENCODE_JSON.bak"
	jq -s '.[0] * .[1]' "$OPENCODE_JSON" "$rendered" > "$merged" \
		|| { echo "error: merge failed — $OPENCODE_JSON left untouched"; exit 1; }
	mv "$merged" "$OPENCODE_JSON"
	echo "opencode.jsonc merged into $OPENCODE_JSON (backup: opencode.jsonc.bak)"
else
	mv "$rendered" "$OPENCODE_JSON"
	echo "opencode.jsonc created $OPENCODE_JSON"
fi
