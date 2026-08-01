#!/usr/bin/env bash
# validate.sh — sanity-check a Maestro flow file.
#
# Layered checks (no `--dry-run` — Maestro CLI does not provide one):
#   1. YAML parse via python (or yq if python missing).
#   2. Header sanity: exactly one of `appId:` or `url:` at the root.
#   3. Optional smoke: if MAESTRO_DEVICE is set and `maestro` is on PATH,
#      runs `maestro --device "$MAESTRO_DEVICE" test <flow>` against a
#      live device. Skipped otherwise.
#
# `skills-ref validate ./<skill-dir>` validates the SKILL.md frontmatter
# and naming — not flow correctness. Use this script for the latter.
#
# Usage:
#   validate.sh <flow.yaml> [<flow2.yaml> ...]
#   MAESTRO_DEVICE=emulator-5554 validate.sh tests/login.yaml

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $(basename "$0") <flow.yaml> [...]" >&2
  exit 64
fi

fail=0
for flow in "$@"; do
  echo "▶ $flow"

  if [[ ! -f "$flow" ]]; then
    echo "  ✗ file not found"
    fail=1
    continue
  fi

  # 1. YAML parse — try yq first (no extra deps), then python+pyyaml.
  parsed=0
  if command -v yq &>/dev/null; then
    if yq eval-all '.' "$flow" >/dev/null 2>&1; then
      parsed=1
    else
      echo "  ✗ yq parse failed"
      fail=1
      continue
    fi
  elif command -v python3 &>/dev/null && python3 -c 'import yaml' 2>/dev/null; then
    if python3 - "$flow" <<'PY' 2>/dev/null
import sys, yaml
with open(sys.argv[1]) as f:
    list(yaml.safe_load_all(f))
PY
    then
      parsed=1
    else
      echo "  ✗ python yaml parse failed"
      fail=1
      continue
    fi
  fi
  if [[ $parsed -eq 1 ]]; then
    echo "  ✓ YAML parse OK"
  else
    echo "  ⚠ no yq or python3+pyyaml — skipping YAML parse (install yq: 'brew install yq')"
  fi

  # 2. Header sanity
  has_appid=0; has_url=0
  # Match only the root-level key (no leading whitespace) before the `---`.
  # Read up to first '---' line.
  while IFS= read -r line; do
    [[ "$line" == "---" ]] && break
    [[ "$line" =~ ^appId: ]] && has_appid=1
    [[ "$line" =~ ^url: ]]   && has_url=1
  done < "$flow"

  total=$((has_appid + has_url))
  if [[ $total -ne 1 ]]; then
    echo "  ✗ header must contain exactly one of 'appId:' (mobile) or 'url:' (web). got appId=$has_appid url=$has_url"
    fail=1
    continue
  fi
  if [[ $has_appid -eq 1 ]]; then
    echo "  ✓ header: mobile (appId)"
  else
    echo "  ✓ header: web (url)"
  fi

  # 3. Optional device smoke
  if [[ -n "${MAESTRO_DEVICE:-}" ]] && command -v maestro &>/dev/null; then
    echo "  ▶ smoke: maestro --device $MAESTRO_DEVICE test $flow"
    if maestro --device "$MAESTRO_DEVICE" test "$flow"; then
      echo "  ✓ smoke pass"
    else
      echo "  ✗ smoke fail"
      fail=1
    fi
  else
    echo "  ⊘ smoke skipped (set MAESTRO_DEVICE + install maestro CLI to enable)"
  fi
done

exit $fail
