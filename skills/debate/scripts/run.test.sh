#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="$ROOT/run.sh"
STATS="$ROOT/stats.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/debate" "$work/state"
export PATH="$work/bin:$PATH"
export DEBATE_DIR="$work/debate"
export STATE_DIR="$work/state"
export KANTHOR_DEBATE_ENGINE=pi
export DEBATE_POLL=1
failures=0

stub() {
  printf '#!/usr/bin/env bash\n%s\n' "$1" > "$work/bin/pi"
  chmod 755 "$work/bin/pi"
}

body() {
  local file="$work/debate/debate-test.txt"
  printf 'debate body\n' > "$file"
  printf '%s\n' "$file"
}

check() {
  local name="$1" want="$2" got="$3"
  if [ "$want" = "$got" ]; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s — want %s, got %s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

rc_of() {
  local rc=0
  "$@" >"$work/out" 2>"$work/err" || rc=$?
  printf '%s\n' "$rc"
}

check 'engine unset rejected' 1 "$(env -u KANTHOR_DEBATE_ENGINE bash -c 'rc=0; "$1" --check >/dev/null 2>&1 || rc=$?; echo $rc' bash "$RUN")"
check 'engine invalid rejected' 1 "$(KANTHOR_DEBATE_ENGINE=bogus bash -c 'rc=0; "$1" --check >/dev/null 2>&1 || rc=$?; echo $rc' bash "$RUN")"
check 'no argument is a usage error' 64 "$(rc_of "$RUN")"

stub 'cat >/dev/null; echo debate'
check 'check succeeds' 0 "$(rc_of "$RUN" --check)"
args="$(sed -n 's/^args=//p' "$work/out")"
check 'check allocates in the debate dir' "$(cd "$work/debate" && pwd -P)" "$(cd "$(dirname "$args")" && pwd -P)"
check 'check reports the engine' 'engine=pi' "$(sed -n '1p' "$work/out")"
check 'allocated args file is private' 600 "$(stat -f '%OLp' "$args")"
check 'check expands the name template' '' "$(printf '%s' "$args" | grep -o XXXXXX || true)"
"$RUN" --check >"$work/out" 2>&1
check 'check allocates a unique name' unique "$([ "$args" != "$(sed -n 's/^args=//p' "$work/out")" ] && echo unique || echo collision)"

check 'args file outside the debate dir rejected' 1 "$(printf 'x\n' > "$work/outside.txt"; rc_of "$RUN" "$work/outside.txt")"
check 'empty args file rejected' 1 "$(rc_of "$RUN" "$args")"

long="$(head -c 1200 /dev/zero | tr '\0' 'a')"
stub "cat >/dev/null; printf '%s\n' '$long'"
check 'valid reply succeeds' 0 "$(rc_of "$RUN" "$(body)")"
check 'stdout holds the reply' "$long" "$(cat "$work/out")"
check 'stdout drops the marker' '' "$(grep -c '=== END ===' "$work/out" | tr -d ' ' | sed 's/^0$//')"
check 'reply file keeps the marker' '=== END ===' "$(tail -n 1 "$work/debate/debate-test.txt-reply.txt")"

stub "cat >/dev/null; printf '%s\n' '$long'; echo noise >&2"
check 'stderr stays out of the reply' 0 "$(rc_of "$RUN" "$(body)")"
check 'stderr goes to its own file' 'noise' "$(cat "$work/debate/debate-test.txt-stderr.txt")"
check 'reply excludes stderr' "$long" "$(cat "$work/out")"

stub "cat >/dev/null; printf '%s' '$long'"
check 'reply without a trailing newline succeeds' 0 "$(rc_of "$RUN" "$(body)")"
check 'marker stays on its own line' '=== END ===' "$(tail -n 1 "$work/debate/debate-test.txt-reply.txt")"

stub 'cat >/dev/null; echo tiny'
check 'short reply fails' 1 "$(rc_of "$RUN" "$(body)")"
check 'short reply reports the reason' 1 "$(grep -c 'reply too short' "$work/err")"

stub 'cat >/dev/null; echo boom; exit 3'
check 'non-zero exit fails' 1 "$(rc_of "$RUN" "$(body)")"
check 'non-zero exit is reported' 1 "$(grep -c 'DEBATE ENGINE FAILED — pi, exit 3' "$work/err")"

stub "cat >/dev/null; echo 'rejected permission for read'; printf '%s\n' '$long'"
check 'signature warns and succeeds' 0 "$(rc_of "$RUN" "$(body)")"
check 'signature is reported' 1 "$(grep -c 'engine-failure signature matched' "$work/err")"

stub 'cat >/dev/null; sleep 5'
check 'empty stall is killed' 1 "$(DEBATE_TIMEOUT=1 rc_of "$RUN" "$(body)")"
check 'stall reports exit 143' 1 "$(grep -c 'exit 143' "$work/err")"

stub "cat >/dev/null; printf '%s\n' '$long'; sleep 5"
check 'partial stall hits the absolute deadline' 1 "$(DEBATE_TIMEOUT=1 DEBATE_MAX=2 rc_of "$RUN" "$(body)")"

check 'stats appends a line' 0 "$(rc_of "$STATS" 3 2 1 1)"
check 'stats line is valid JSON' 1 "$(grep -c '"engine":"pi","statements":3,"catches":2,"merged":1,"pushbacks":1' "$work/state/debate.jsonl")"
check 'stats rejects a broken invariant' 1 "$(rc_of "$STATS" 3 2 2 1)"
check 'stats rejects a non-integer' 64 "$(rc_of "$STATS" 3 2 x 1)"
check 'stats rejects a missing count' 64 "$(rc_of "$STATS" 3 2 1)"
check 'stats rejects an unset engine' 1 "$(env -u KANTHOR_DEBATE_ENGINE bash -c 'rc=0; STATE_DIR="$2" "$1" 1 1 1 0 >/dev/null 2>&1 || rc=$?; echo $rc' bash "$STATS" "$work/state")"
check 'stats writes one line per run' 1 "$(wc -l < "$work/state/debate.jsonl" | tr -d ' ')"

[ "$failures" -eq 0 ] || { printf '%s test(s) failed\n' "$failures" >&2; exit 1; }
printf 'all tests passed\n'
