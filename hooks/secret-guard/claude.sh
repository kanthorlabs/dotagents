#!/usr/bin/env bash
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

file_path="$(jq -r '.tool_input.file_path // empty' 2>/dev/null)" || exit 0
findings="$("$(dirname "${BASH_SOURCE[0]}")/scan.sh" "$file_path")" && exit 0
[ -n "$findings" ] || exit 0

reason="secret-guard: $file_path contains possible sensitive data: $(printf '%s' "$findings" | paste -sd ';' - | sed 's/;/; /g'). Read blocked."

jq -n --arg reason "$reason" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: $reason
}}'
