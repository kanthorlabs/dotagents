#!/usr/bin/env bash
# Start Chrome with remote debugging on a dedicated user data directory.
#
# Chrome 136+ refuses --remote-debugging-port when the default user data
# directory is used. The refusal is silent: a window opens and no port listens.
# A dedicated --user-data-dir is mandatory.
#
# Link mode (-l) symlinks a real profile into the debug directory, so the debug
# browser uses the real logins, extensions, and settings in place. Chrome follows
# the symlink and writes through to the real profile.
#
# WARNING: a symlinked profile must never be open in two browser instances at the
# same time. Chrome puts its singleton lock in the user data directory, not in the
# profile, so two instances on two data directories will both write one profile and
# corrupt it. This script refuses to launch while another Chrome holds the profile.
#
# The linked profile is remembered: the symlink itself is the state. Later runs
# reuse it with no arguments. A new -l unlinks the old profile and links the new one.
#
# Usage:
#   chrome-debug.sh                       # reuse the remembered profile, then launch
#   chrome-debug.sh -L                    # list the real chrome profiles and exit
#   chrome-debug.sh -l "Tuan@ELSA"        # link by display name or by folder name
#   chrome-debug.sh -F                    # fresh private profile, link nothing
#   chrome-debug.sh -p 9333               # another port
#   chrome-debug.sh -P QA                 # slot name inside the debug dir
#   chrome-debug.sh -d /path/to/dir       # another debug directory
#   chrome-debug.sh -k                    # kill the debug instance and exit
#   chrome-debug.sh -s                    # status only, no launch

set -euo pipefail

PORT=9222
PROFILE="Default"
DATA_DIR="${CHROME_DEBUG_DIR:-$HOME/.cache/chrome-debug}"
ACTION=start
URL=""
LINK=""
FRESH=no

while getopts ":p:P:d:u:l:FLksh" opt; do
  case "$opt" in
    p) PORT=$OPTARG ;;
    P) PROFILE=$OPTARG ;;
    d) DATA_DIR=$OPTARG ;;
    u) URL=$OPTARG ;;
    l) LINK=$OPTARG ;;
    F) FRESH=yes ;;
    L) ACTION=listprofiles ;;
    k) ACTION=kill ;;
    s) ACTION=status ;;
    h) sed -n '2,32p' "$0"; exit 0 ;;
    *) echo "unknown option: -$OPTARG" >&2; exit 2 ;;
  esac
done

case "$(uname -s)" in
  Darwin)
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    REAL_UDD="$HOME/Library/Application Support/Google/Chrome"
    ;;
  Linux)
    CHROME="$(command -v google-chrome || command -v google-chrome-stable || command -v chromium || true)"
    REAL_UDD="$HOME/.config/google-chrome"
    ;;
  *) echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

[ -x "$CHROME" ] || { echo "chrome not found at: $CHROME" >&2; exit 1; }

# always exits 0 so that `set -e` does not kill an assignment on "no listener"
port_owner() { lsof -nP -iTCP:"$PORT" -sTCP:LISTEN -t 2>/dev/null | head -1 || true; }

# ---- real profile discovery -------------------------------------------------
# Chrome stores the human names in Local State under profile.info_cache. The folder
# name ("Profile 12") is meaningless to a person; the display name ("Tuan@ELSA") is
# the one to show. Emits "folder<TAB>display name<TAB>size" per line.
list_profiles() {
  python3 - "$REAL_UDD" <<'PY' || true
import json, os, sys
udd = sys.argv[1]
try:
    cache = json.load(open(os.path.join(udd, "Local State")))["profile"]["info_cache"]
except Exception:
    cache = {}
# info_cache lists the real user profiles only. "Guest Profile" and "System Profile"
# are internal directories and never appear there, so they are filtered out.
for folder in sorted(cache):
    path = os.path.join(udd, folder)
    if not os.path.isdir(path) or not os.path.exists(os.path.join(path, "Preferences")):
        continue
    name = cache[folder].get("name", folder)
    mb = sum(
        os.path.getsize(os.path.join(r, f))
        for r, _, fs in os.walk(path)
        for f in fs
        if os.path.exists(os.path.join(r, f))
    ) // (1024 * 1024)
    print("%s\t%s\t%dM" % (folder, name, mb))
PY
}

show_profiles() {
  echo "Chrome profiles in $REAL_UDD:"
  list_profiles | while IFS=$'\t' read -r folder name size; do
    printf '  %-14s  %-24s %s\n' "$folder" "$name" "$size"
  done
}

# accept either the folder name or the display name; echo the folder name
resolve_profile() {
  local want="$1" folder name
  while IFS=$'\t' read -r folder name _; do
    [ "$want" = "$folder" ] && { echo "$folder"; return 0; }
    [ "$want" = "$name" ]   && { echo "$folder"; return 0; }
  done < <(list_profiles)
  return 1
}

display_name_of() {
  local folder="$1" f n
  while IFS=$'\t' read -r f n _; do
    [ "$f" = "$folder" ] && { echo "$n"; return 0; }
  done < <(list_profiles)
  echo "$folder"
}

# resolve the profile path the debug browser will really use
target_profile() {
  local p="$DATA_DIR/$PROFILE"
  if [ -L "$p" ]; then readlink "$p"; else echo "$p"; fi
}

# pids of chrome *browser* processes. Renderers, GPU, and utility processes all
# carry --type=, so that flag is the discriminator on both macOS and Linux.
browser_pids() {
  pgrep -f "Google Chrome|google-chrome|chromium" 2>/dev/null | while read -r pid; do
    ps -o command= -p "$pid" 2>/dev/null | grep -q -- "--type=" && continue
    echo "$pid"
  done || true
}

# Refuse to share a profile with a running browser, because that corrupts it.
#
# The test is ownership of the *user data directory*, not open file handles. A daily
# Chrome with every window closed holds no profile files, yet it still owns the
# directory and opens the profile the moment a window appears. Handles are a snapshot.
# Ownership is the real condition.
guard_shared_profile() {
  local link="$DATA_DIR/$PROFILE"
  [ -L "$link" ] || return 0                # a private profile cannot be shared
  local prof parent holder="" cmd
  prof=$(readlink "$link")
  parent=$(dirname "$prof")

  for pid in $(browser_pids); do
    cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
    [ -n "$cmd" ] || continue
    case "$cmd" in
      *"--user-data-dir=$DATA_DIR"*) continue ;;          # our own debug browser
      *"--user-data-dir=$parent"*)   holder=$pid; break ;; # explicit owner
    esac
    # no --user-data-dir at all means this browser owns the default directory
    if [ "$parent" = "$REAL_UDD" ] && ! printf '%s' "$cmd" | grep -q -- "--user-data-dir="; then
      holder=$pid; break
    fi
  done

  [ -z "$holder" ] && return 0
  cat >&2 <<EOF
REFUSED: Chrome (pid $holder) already owns the data directory of this profile:
  profile: $prof
  owned by: $parent
The profile is a symlink, so both browsers would write the same files and corrupt
cookies, history, and Local Storage. Chrome puts its singleton lock in the data
directory, not in the profile, so it cannot detect this by itself.

Quit that Chrome completely (Cmd-Q, not just closing the windows), then retry.
Command line of pid $holder:
  $(ps -o command= -p "$holder" 2>/dev/null | cut -c1-160)
EOF
  exit 1
}

status() {
  local pid; pid=$(port_owner)
  if [ -n "$pid" ]; then
    echo "port $PORT: LISTENING (pid $pid)"
    ps -o command= -p "$pid" 2>/dev/null | cut -c1-200
  else
    echo "port $PORT: not listening"
  fi
  echo "debug dir: $DATA_DIR"
  local slot="$DATA_DIR/$PROFILE"
  if [ -L "$slot" ]; then
    local folder; folder=$(basename "$(readlink "$slot")")
    echo "  linked profile: $folder ($(display_name_of "$folder"))"
    echo "  source: $(readlink "$slot")"
  elif [ -d "$slot" ]; then
    echo "  private profile: $PROFILE (not linked)"
  else
    echo "  no profile chosen yet"
  fi
}

case "$ACTION" in
  listprofiles) show_profiles; exit 0 ;;
  status) status; exit 0 ;;
  kill)
    if ! pkill -f -- "--user-data-dir=$DATA_DIR"; then
      echo "no instance on $DATA_DIR"; exit 0
    fi
    # chrome exits asynchronously; wait for the port to be released
    for _ in $(seq 1 20); do
      [ -z "$(port_owner)" ] && break
      sleep 0.5
    done
    if [ -n "$(port_owner)" ]; then
      echo "killed the process but port $PORT is still held by pid $(port_owner)" >&2
      exit 1
    fi
    echo "killed instance on $DATA_DIR, port $PORT released"
    exit 0
    ;;
esac

mkdir -p "$DATA_DIR"
SLOT="$DATA_DIR/$PROFILE"

# -l: link a real profile. A new -l replaces whatever is linked now.
if [ -n "$LINK" ]; then
  FOLDER=$(resolve_profile "$LINK") || {
    echo "no chrome profile matches: $LINK" >&2
    echo >&2
    show_profiles >&2
    exit 1
  }
  SRC="$REAL_UDD/$FOLDER"
  if [ -e "$SLOT" ] && [ ! -L "$SLOT" ]; then
    echo "$SLOT is a real directory, not a link." >&2
    echo "it holds a private profile. remove it, or pick another slot with -P." >&2
    exit 1
  fi
  if [ -L "$SLOT" ]; then
    OLD=$(basename "$(readlink "$SLOT")")
    if [ "$OLD" != "$FOLDER" ]; then
      echo "unlinked $OLD ($(display_name_of "$OLD"))"
    fi
    rm -f "$SLOT"
  fi
  ln -s "$SRC" "$SLOT"
  # Local State holds the os_crypt key that decrypts the cookies. Copy it, do not
  # link it: the debug browser must not rewrite the real one.
  cp -f "$REAL_UDD/Local State" "$DATA_DIR/Local State"
  echo "linked $FOLDER ($(display_name_of "$FOLDER"))"

# no -l: reuse the remembered choice, or make the user choose
elif [ -L "$SLOT" ]; then
  FOLDER=$(basename "$(readlink "$SLOT")")
  echo "using remembered profile: $FOLDER ($(display_name_of "$FOLDER"))"
elif [ -d "$SLOT" ]; then
  : # a private profile already exists in this slot
elif [ "$FRESH" = yes ]; then
  echo "using a fresh private profile in $SLOT"
else
  COUNT=$(list_profiles | wc -l | tr -d ' ')
  echo "No profile is chosen for the debug browser yet." >&2
  echo >&2
  show_profiles >&2
  echo >&2
  if [ "$COUNT" -gt 1 ]; then
    echo "$COUNT profiles found. Ask the user which one to use, then run:" >&2
  else
    echo "Confirm the profile with the user, then run:" >&2
  fi
  echo "  $0 -l \"<display name or folder>\"" >&2
  echo "Or use a fresh empty profile instead:" >&2
  echo "  $0 -F" >&2
  exit 2
fi

guard_shared_profile

# A second launch on the same data dir forwards to the running process and drops
# the flags. Detect that instead of pretending the launch worked.
if pgrep -f -- "--user-data-dir=$DATA_DIR" >/dev/null 2>&1; then
  if [ -n "$(port_owner)" ]; then
    echo "already running on $DATA_DIR, port $PORT is live"
    status
    exit 0
  fi
  echo "chrome runs on $DATA_DIR but port $PORT is not listening." >&2
  echo "flags are dropped on a second launch. run: $0 -k -d '$DATA_DIR'" >&2
  exit 1
fi

if [ -n "$(port_owner)" ]; then
  echo "port $PORT is owned by another process:" >&2
  ps -o pid=,command= -p "$(port_owner)" | cut -c1-200 >&2
  echo "pick another port with -p, or stop that process." >&2
  exit 1
fi

"$CHROME" \
  --remote-debugging-port="$PORT" \
  --user-data-dir="$DATA_DIR" \
  --profile-directory="$PROFILE" \
  --no-first-run \
  --no-default-browser-check \
  ${URL:+"$URL"} >/dev/null 2>&1 &

for _ in $(seq 1 20); do
  [ -n "$(port_owner)" ] && break
  sleep 0.5
done

if [ -z "$(port_owner)" ]; then
  echo "chrome started but port $PORT never opened." >&2
  echo "check that --user-data-dir is not the default chrome directory." >&2
  exit 1
fi

status
echo
echo "next: call mcp__chrome-devtools__list_pages to confirm the MCP server attached."
