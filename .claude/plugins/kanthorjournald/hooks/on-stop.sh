#!/usr/bin/env bash
# Stop hook: force Claude to surface a brief of what it did this turn (from journal).
# Validation is a separate, user-invoked command (/kanthorjournald:validate).
# Avoids infinite loop via stop_hook_active flag + pending-brief marker file.
set -euo pipefail

DATA_DIR="${HOME}/.kanthorlabs/kanthorjournald"
STATE_FILE="${DATA_DIR}/state.json"
JOURNAL_DIR="${DATA_DIR}/journals"
INTERNAL_DIR="${DATA_DIR}/.runtime"
mkdir -p "${JOURNAL_DIR}" "${INTERNAL_DIR}"

INPUT="$(cat)"

SESSION_ID="$(printf '%s' "${INPUT}" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
STOP_ACTIVE="$(printf '%s' "${INPUT}" | sed -n 's/.*"stop_hook_active"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p' | head -n1)"

if [[ -z "${SESSION_ID}" ]]; then
  exit 0
fi

if [[ "${STOP_ACTIVE}" == "true" ]]; then
  rm -f "${INTERNAL_DIR}/pending-brief-${SESSION_ID}"
  exit 0
fi

if [[ -f "${INTERNAL_DIR}/skip-stop-${SESSION_ID}" ]]; then
  rm -f "${INTERNAL_DIR}/skip-stop-${SESSION_ID}"
  exit 0
fi

ENABLED="$(SESSION_ID="${SESSION_ID}" STATE_FILE="${STATE_FILE}" python3 <<'PY'
import json, os
sid = os.environ["SESSION_ID"]
sf = os.environ["STATE_FILE"]
try:
    with open(sf) as f:
        s = json.load(f)
except Exception:
    s = {}
if not s.get("global_enabled", True):
    print("0"); raise SystemExit
if sid in s.get("disabled_sessions", []):
    print("0"); raise SystemExit
print("1")
PY
)"

if [[ "${ENABLED}" != "1" ]]; then
  exit 0
fi

if [[ ! -f "${INTERNAL_DIR}/pending-brief-${SESSION_ID}" ]]; then
  exit 0
fi

JOURNAL_FILE="${JOURNAL_DIR}/${SESSION_ID}.md"
if [[ ! -f "${JOURNAL_FILE}" ]]; then
  rm -f "${INTERNAL_DIR}/pending-brief-${SESSION_ID}"
  exit 0
fi

rm -f "${INTERNAL_DIR}/pending-brief-${SESSION_ID}"

REASON=$(cat <<EOF
[kanthorjournald turn-brief] Be brief. Before stopping, read the latest \`## Turn\` section in \`${JOURNAL_FILE}\` and show the user a concise brief of what you actually did this turn.

Do exactly this:
1. Read only the latest \`## Turn\` section in the journal.
2. Print a short brief to the user covering: Decisions off-spec, Changes beyond ask, Tradeoffs, Assumptions, Deferred / TODO. Skip empty categories (those marked "- none").
3. Keep it tight — one line per item. No validation, no fixing, no judgment about correctness. Just surface what happened so the human can review.
4. If the user wants to verify correctness, mention they can run \`/kanthorjournald:validate\`.

Do NOT re-trigger another brief (this hook only fires once per turn).
EOF
)

REASON_TXT="${REASON}" python3 <<'PY'
import json, os
print(json.dumps({
  "decision": "block",
  "reason": os.environ["REASON_TXT"]
}))
PY
