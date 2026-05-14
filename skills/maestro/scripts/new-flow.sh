#!/usr/bin/env bash
# new-flow.sh — scaffold a Maestro flow from a template.
#
# Usage:
#   new-flow.sh <name> mobile <appId>           # mobile flow
#   new-flow.sh <name> web    <url>             # web flow
#
# Examples:
#   new-flow.sh login mobile com.example.app
#   new-flow.sh signup web    https://example.com
#
# Writes <name>.yaml in the current directory.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $(basename "$0") <name> <mobile|web> <appId-or-url>" >&2
  exit 64
fi

NAME=$1
KIND=$2
ID=$3

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
TEMPLATES="$SCRIPT_DIR/../assets/templates"
OUT="${NAME}.yaml"

if [[ -e "$OUT" ]]; then
  echo "refuse: $OUT already exists" >&2
  exit 1
fi

case "$KIND" in
  mobile)
    sed "s|com.example.app|${ID}|g" \
      "$TEMPLATES/flow-mobile.yaml" > "$OUT"
    ;;
  web)
    sed "s|https://example.com|${ID}|g" \
      "$TEMPLATES/flow-web.yaml" > "$OUT"
    ;;
  *)
    echo "kind must be 'mobile' or 'web' (got: $KIND)" >&2
    exit 64
    ;;
esac

echo "wrote $OUT"
