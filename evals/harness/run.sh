#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: run.sh <suite> <run-name> [repeats] [skill-path]" >&2
  exit 2
fi

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
suite="$(cd "$here/../$1" && pwd)"
out="$suite/runs/$2"
repeats="${3:-3}"
skill="${4:-$repo/$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["skill"])' "$suite/suite.json")}"

if [ ! -f "$skill" ]; then
  echo "skill file not found: $skill" >&2
  exit 2
fi

export EVAL_SUITE="$suite"
export EVAL_CASES="${EVAL_CASES:-cases}"
export PYTHONPATH="$here${PYTHONPATH:+:$PYTHONPATH}"

mkdir -p "$out"
python3 "$here/generate.py" "$skill" "$out" "$repeats"
for step in $(python3 -c 'import json, sys; print(" ".join(json.load(open(sys.argv[1]))["steps"]))' "$suite/suite.json"); do
  python3 "$suite/$step" "$out"
done
python3 "$here/report.py" "$out"
