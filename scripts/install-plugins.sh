#!/usr/bin/env bash
# Registers the repo marketplace and installs every plugin it declares, via the
# claude CLI (both commands are no-ops when already done). Without the CLI this
# is skipped — the settings merge already declares extraKnownMarketplaces +
# enabledPlugins, so Claude Code auto-installs them on the next launch.
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

command -v claude >/dev/null 2>&1 \
	|| { echo "plugins    skipped: claude CLI not found (auto-installs from settings on next launch)"; exit 0; }
command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }

marketplace=$(jq -r '.name' "$ROOT/.claude/plugins/.claude-plugin/marketplace.json")
claude plugin marketplace add "$ROOT/.claude/plugins"
for plugin in $(jq -r '.plugins[].name' "$ROOT/.claude/plugins/.claude-plugin/marketplace.json"); do
	claude plugin install --scope user "$plugin@$marketplace"
done
