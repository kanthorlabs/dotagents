#!/usr/bin/env bash
# UserPromptSubmit hook: inject journaling instruction into Claude's context.
# Skips if globally disabled OR session disabled.
set -euo pipefail

DATA_DIR="${HOME}/.kanthorlabs/kanthorjournald"
STATE_FILE="${DATA_DIR}/state.json"
JOURNAL_ROOT="${DATA_DIR}/journals"
mkdir -p "${JOURNAL_ROOT}"

INPUT="$(cat)"

# Extract session_id, cwd, prompt-trimmed, and a per-project key (basename + md5
# of absolute cwd) in one pass. shlex.quote keeps eval safe.
eval "$(printf '%s' "${INPUT}" | python3 -c '
import json, sys, os, time, hashlib, shlex
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
sid = d.get("session_id") or f"unknown-{int(time.time())}"
cwd = d.get("cwd") or os.getcwd()
prompt = (d.get("prompt") or "").lstrip()
project_key = os.path.basename(cwd.rstrip("/")) + "-" + hashlib.md5(cwd.encode("utf-8")).hexdigest()
print(f"SESSION_ID={shlex.quote(sid)}")
print(f"CWD={shlex.quote(cwd)}")
print(f"PROMPT_TRIMMED={shlex.quote(prompt)}")
print(f"PROJECT_KEY={shlex.quote(project_key)}")
')"

PROJECT_DIR="${JOURNAL_ROOT}/${PROJECT_KEY}"
mkdir -p "${PROJECT_DIR}"

# Per-project current-session marker (concurrent CC sessions in different
# projects each track their own).
printf '%s' "${SESSION_ID}" > "${PROJECT_DIR}/current-session.txt"

# Skip injection if the prompt is a kanthorjournald slash command.
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

JOURNAL_FILE="${PROJECT_DIR}/${SESSION_ID}.md"

if [[ ! -f "${JOURNAL_FILE}" ]]; then
  {
    echo "# Decision Journal — session ${SESSION_ID}"
    echo
    echo "_Project: ${CWD}_"
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

**Tool flow (IMPORTANT):** Claude Code's Edit tool refuses to edit a file you haven't Read in this session ("File has not been read yet"). To append safely:
1. **Read** the journal file first with the Read tool (small, idempotent).
2. Then use **Edit** (match the last existing line as \`old_string\` and append the new section), **or** use **Bash** with \`cat >> '${JOURNAL_FILE}' <<'JOURNAL_EOF' ... JOURNAL_EOF\` to append without Read.
Do NOT use Write — it overwrites the file and would erase previous turns.

If category empty, write "- none". Do this BEFORE finishing the turn. Be brief.
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
