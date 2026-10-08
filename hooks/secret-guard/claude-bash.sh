#!/usr/bin/env bash
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

response="$(jq -ce '.tool_response | objects' 2>/dev/null)" || exit 0
findings=""
output="$(mktemp)" || output=""
trap 'rm -f "$output"' EXIT
if [ -n "$output" ] && printf '%s' "$response" | jq -r '[.stdout, .stderr] | map(strings) | join("\n")' > "$output"; then
  findings="$("$(dirname "${BASH_SOURCE[0]}")/scan.sh" "$output")" && exit 0
fi
if [ -n "$findings" ]; then
  reason="secret-guard: command output contains possible sensitive data: $(printf '%s' "$findings" | paste -sd ';' - | sed 's/;/; /g'). Output redacted."
else
  reason="secret-guard: output redacted because the scan failed."
fi

printf '%s' "$response" | jq --arg reason "$reason" '{hookSpecificOutput: {
  hookEventName: "PostToolUse",
  updatedToolOutput: (. + {stdout: $reason, stderr: ""})
}}'
