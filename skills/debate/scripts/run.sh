#!/usr/bin/env bash
set -euo pipefail
umask 077

DEBATE_DIR="${DEBATE_DIR:-$HOME/.kanthorlabs/debate}"
DEBATE_TIMEOUT="${DEBATE_TIMEOUT:-900}"
DEBATE_MAX="${DEBATE_MAX:-1800}"
DEBATE_POLL="${DEBATE_POLL:-5}"
DEBATE_MIN_BYTES="${DEBATE_MIN_BYTES:-1000}"
MARKER='=== END ==='
SIGNATURES='rejected permission|permission denied|rate limit|not logged in|unauthorized|invalid api key'

usage() {
  cat >&2 <<'USAGE_EOF'
usage: run.sh --check
       run.sh <args-file>

--check      validate KANTHOR_DEBATE_ENGINE and the engine binary, then print
             the engine name and an empty args file to write the debate block to
<args-file>  run the engine read-only on the block, then print the reply
USAGE_EOF
  exit 64
}

engine="${KANTHOR_DEBATE_ENGINE:-}"
case "$engine" in
  opencode2 | pi) ;;
  '') echo "error: KANTHOR_DEBATE_ENGINE is unset — valid values: opencode2, pi" >&2; exit 1 ;;
  *) echo "error: KANTHOR_DEBATE_ENGINE=$engine is invalid — valid values: opencode2, pi" >&2; exit 1 ;;
esac
command -v "$engine" >/dev/null 2>&1 \
  || { echo "error: $engine is not found or not executable" >&2; exit 1; }

[ $# -eq 1 ] || usage

mkdir -p "$DEBATE_DIR"
debate_dir="$(cd "$DEBATE_DIR" && pwd -P)"

if [ "$1" = --check ]; then
  printf 'engine=%s\n' "$engine"
  printf 'args=%s\n' "$(mktemp "$debate_dir/debate-$(date -u +'%Y%m%d%H%M%S')-XXXXXX")"
  exit 0
fi

args="$1"
[ -f "$args" ] && [ ! -L "$args" ] \
  || { echo "error: args file is missing or is a symlink: $args" >&2; exit 1; }
[ -s "$args" ] || { echo "error: args file is empty: $args" >&2; exit 1; }
args_dir="$(cd "$(dirname "$args")" && pwd -P)"
[ "$args_dir" = "$debate_dir" ] \
  || { echo "error: args file must live in $debate_dir, not $args_dir" >&2; exit 1; }

args="$args_dir/$(basename "$args")"
reply="$args-reply.txt"
errlog="$args-stderr.txt"

case "$engine" in
  opencode2) engine_command=(opencode2 run --agent plan) ;;
  pi) engine_command=(pi --print --no-session --tools read,grep,find,ls) ;;
esac

fail() {
  {
    printf 'DEBATE ENGINE FAILED — %s, exit %s\n' "$engine" "$rc"
    printf 'Reason: %s\n' "$1"
    printf 'Reply excerpt:\n'
    head -n 10 "$reply" 2>/dev/null || true
    if [ -s "$errlog" ]; then
      printf 'Engine stderr tail:\n'
      tail -n 10 "$errlog"
    fi
    if [ "$engine" = opencode2 ]; then
      log="$(ls -t "$HOME/.local/share/opencode/log"/*.log 2>/dev/null | head -n 1 || true)"
      if [ -n "$log" ]; then
        printf 'Engine log tail (%s):\n' "$log"
        tail -n 10 "$log"
      fi
    fi
  } >&2
  exit 1
}

"${engine_command[@]}" < "$args" > "$reply" 2> "$errlog" &
pid=$!
trap 'kill "$pid" 2>/dev/null || true' EXIT INT TERM
elapsed=0
while kill -0 "$pid" 2>/dev/null; do
  if [ "$elapsed" -ge "$DEBATE_TIMEOUT" ] && [ ! -s "$reply" ]; then
    kill "$pid" 2>/dev/null || true
    break
  fi
  if [ "$elapsed" -ge "$DEBATE_MAX" ]; then
    kill "$pid" 2>/dev/null || true
    break
  fi
  sleep "$DEBATE_POLL"
  elapsed=$((elapsed + DEBATE_POLL))
done
rc=0
wait "$pid" || rc=$?
trap - EXIT INT TERM
if [ -s "$reply" ] && [ -n "$(tail -c 1 "$reply")" ]; then
  printf '\n' >> "$reply"
fi
printf '%s\n' "$MARKER" >> "$reply"

[ "$rc" -eq 0 ] || fail "non-zero exit (the watchdog kills a stalled run and reports 143)"
[ "$(tail -n 1 "$reply")" = "$MARKER" ] || fail 'marker missing — the engine did not complete'
bytes=$(( $(wc -c < "$reply") - ${#MARKER} - 1 ))
[ "$bytes" -ge "$DEBATE_MIN_BYTES" ] \
  || fail "reply too short ($bytes bytes, minimum $DEBATE_MIN_BYTES)"

matches="$(grep -niE "$SIGNATURES" "$reply" || true)"
if [ -n "$matches" ]; then
  {
    printf 'warning: engine-failure signature matched — judge whether the reply is a debate or an error:\n'
    printf '%s\n' "$matches"
  } >&2
fi

sed '$d' "$reply"
