#!/usr/bin/env bash
# UserPromptSubmit hook: inject journaling instruction into Claude's context.
# Skips if globally disabled OR session disabled.
set -euo pipefail

DATA_DIR="${HOME}/.kanthorlabs/kanthorjournald"
STATE_FILE="${DATA_DIR}/state.json"
JOURNAL_DIR="${DATA_DIR}/journals"
mkdir -p "${JOURNAL_DIR}"

INPUT="$(cat)"

SESSION_ID="$(printf '%s' "${INPUT}" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
if [[ -z "${SESSION_ID}" ]]; then
  SESSION_ID="unknown-$(date +%s)"
fi

# Record current session id so /kanthorjournald:off-session can find it.
printf '%s' "${SESSION_ID}" > "${DATA_DIR}/current-session.txt"

# Extract prompt text (best-effort) and skip if it's a kanthorjournald slash command.
PROMPT_TRIMMED="$(printf '%s' "${INPUT}" | python3 -c 'import sys,json
try:
  d=json.load(sys.stdin); p=d.get("prompt","")
  print(p.lstrip())
except Exception:
  print("")' 2>/dev/null || true)"

case "${PROMPT_TRIMMED}" in
  /kanthorjournald*)
    exit 0
    ;;
esac

# Read state.json (default: enabled, no session disables)
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

JOURNAL_FILE="${JOURNAL_DIR}/${SESSION_ID}.md"

if [[ ! -f "${JOURNAL_FILE}" ]]; then
  {
    echo "# Decision Journal — session ${SESSION_ID}"
    echo
    echo "_Created $(date -u +'%Y-%m-%dT%H:%M:%SZ')_"
    echo
  } > "${JOURNAL_FILE}"
fi

ADDITIONAL=$(cat <<EOF
[kanthorjournald active] Append a Decision Journal entry to \`${JOURNAL_FILE}\` for this turn.

Record EVERY item the human should review:
- Decisions made that were NOT in the user spec
- Files/APIs/behaviors changed beyond literal request
- Tradeoffs picked (perf vs simplicity, etc.)
- Assumptions filled in for ambiguous requirements
- Skipped or deferred work, TODOs left behind
- Library/version/config choices not specified by user

Format each turn as a new section:

\`\`\`
## Turn @ <UTC timestamp>
**User asked:** <one-line restatement>

### Decisions off-spec
- <decision> — why
### Changes beyond ask
- <change> — why
### Tradeoffs
- <picked X over Y> — why
### Assumptions
- <assumption>
### Deferred / TODO
- <item>
\`\`\`

Use the Edit/Write tool to append. If category empty, write "- none". Do this BEFORE finishing the turn. Be brief.
EOF
)

ADDITIONAL_CTX="${ADDITIONAL}" python3 <<'PY'
import json, os
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": os.environ["ADDITIONAL_CTX"]
  }
}))
PY
