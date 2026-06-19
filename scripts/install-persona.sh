#!/usr/bin/env bash
# Injects AGENTS.md at the top of $CLAUDE_DIR/CLAUDE.md, wrapped in managed markers.
# Idempotent: any previously injected block (matched by fixed-string markers) is
# stripped before the fresh copy is prepended, so re-running never duplicates.
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR"
target="$CLAUDE_DIR/CLAUDE.md"
begin="<!-- BEGIN dotagents persona (managed by make install-persona) -->"
end="<!-- END dotagents persona -->"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

{ printf '%s\n' "$begin"; cat "$ROOT/AGENTS.md"; printf '%s\n\n' "$end"; } > "$tmp"
if [ -f "$target" ]; then
	awk -v b="$begin" -v e="$end" 'index($0,b){d=1} !d{print} index($0,e){d=0}' "$target" >> "$tmp"
fi
cp "$tmp" "$target"
echo "persona    injected at top of $target"
