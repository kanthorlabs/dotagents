#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${STATE_DIR:-$HOME/.kanthorlabs/state}"

usage() {
  echo "usage: stats.sh <statements> <catches> <merged> <pushbacks>" >&2
  exit 64
}

[ $# -eq 4 ] || usage
for value in "$@"; do
  [[ "$value" =~ ^[0-9]+$ ]] || usage
done

statements="$1"
catches="$2"
merged="$3"
pushbacks="$4"
engine="${KANTHOR_DEBATE_ENGINE:-}"

[ -n "$engine" ] || { echo "error: KANTHOR_DEBATE_ENGINE is unset" >&2; exit 1; }
(( merged + pushbacks == catches )) \
  || { echo "error: merged + pushbacks ($((merged + pushbacks))) must equal catches ($catches)" >&2; exit 1; }

mkdir -p "$STATE_DIR"
printf '{"timestamp":"%s","engine":"%s","statements":%d,"catches":%d,"merged":%d,"pushbacks":%d}\n' \
  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$engine" \
  "$statements" "$catches" "$merged" "$pushbacks" \
  >> "$STATE_DIR/debate.jsonl"
