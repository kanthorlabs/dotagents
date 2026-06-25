#!/usr/bin/env bash
# PreToolUse: defense-in-depth for kanthorjournald journals.
# ALLOW appends to the live journal (Edit, '>>'); BLOCK overwrite/delete/move of
# the live journal & current-session marker, and deletes under the journals root.
# Best-effort (not a sandbox). Fail OPEN (a guard bug must not brick the session).
set -uo pipefail
JROOT="${HOME}/.kanthorlabs/kanthorjournald/journals"
INPUT="$(cat)"
JROOT="$JROOT" INPUT="$INPUT" python3 <<'PY' || exit 0
import json, os, re, glob, sys
root = os.path.realpath(os.environ["JROOT"])
try:
    d = json.loads(os.environ["INPUT"])
except Exception:
    sys.exit(0)
tool = d.get("tool_name", "")
ti = d.get("tool_input", {}) or {}

markers = set()  # current-session.txt — only written by on-user-prompt.sh, never by a tool
live = set()     # <sid>.md — the active journal; appends allowed, mutation blocked
for m in glob.glob(os.path.join(root, "*", "current-session.txt")):
    markers.add(os.path.realpath(m))
    try:
        sid = open(m).read().strip()
    except Exception:
        sid = ""
    if sid:
        live.add(os.path.realpath(os.path.join(os.path.dirname(m), sid + ".md")))


def deny(reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason}}))
    sys.exit(0)


if tool == "Write":  # Write overwrites -> never allowed on protected files
    p = os.path.realpath(ti.get("file_path", ""))
    if p in markers or p in live:
        deny("kanthorjournald: Write overwrites; append to the live journal with Edit or 'cat >>'. The current-session marker must not be tool-written.")
elif tool == "Edit":  # Edit = sanctioned append path; only the marker is off-limits
    if os.path.realpath(ti.get("file_path", "")) in markers:
        deny("kanthorjournald: current-session.txt must not be edited by a tool.")
elif tool == "Bash":
    cmd = ti.get("command", "")
    destructive = bool(
        re.search(r'(^|[\s;|&(])(rm|unlink|shred)\s', cmd)
        or re.search(r'-delete\b', cmd)
        or re.search(r'truncate\s+-s\s*0', cmd)
    )
    if destructive and ("kanthorjournald/journals" in cmd or root in cmd):
        deny("kanthorjournald: destructive command targeting the journals dir. Use 'mv <journal> .trash/' instead of rm/delete.")
    # overwrite/move/delete of a live file ('>>' append is NOT matched)
    if any(t in cmd for t in (markers | live)):
        if re.search(r'(^|[\s;|&(])(rm|mv|truncate|shred|unlink)\b', cmd) or re.search(r'(?<!>)>(?!>)\s*\S', cmd):
            deny("kanthorjournald: refusing to overwrite/move/delete the live journal or marker; append with '>>'.")
PY
