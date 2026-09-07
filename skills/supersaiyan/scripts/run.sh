#!/usr/bin/env bash
set -euo pipefail
umask 077

SUPERSAIYAN_DIR="${SUPERSAIYAN_DIR:-$HOME/.kanthorlabs/supersaiyan}"
SUPERSAIYAN_TIMEOUT="${SUPERSAIYAN_TIMEOUT:-3600}"
SUPERSAIYAN_POLL="${SUPERSAIYAN_POLL:-5}"
SUPERSAIYAN_GRACE="${SUPERSAIYAN_GRACE:-5}"

usage() {
  cat >&2 <<'USAGE_EOF'
usage: run.sh --check
       run.sh <task-file> <repo-dir>

--check      validate KANTHOR_SUPERSAIYAN_ENGINE and the engine binary, then
             print the engine name and a task file to write the task packet to
<task-file>  run the engine on the task packet inside an isolated clone of
             <repo-dir>, then export its changes as a patch
USAGE_EOF
  exit 64
}

engine="${KANTHOR_SUPERSAIYAN_ENGINE:-}"
case "$engine" in
  opencode2 | pi) ;;
  '') echo "error: KANTHOR_SUPERSAIYAN_ENGINE is unset — valid values: opencode2, pi" >&2; exit 1 ;;
  *) echo "error: KANTHOR_SUPERSAIYAN_ENGINE=$engine is invalid — valid values: opencode2, pi" >&2; exit 1 ;;
esac
command -v "$engine" >/dev/null 2>&1 \
  || { echo "error: $engine is not found or not executable" >&2; exit 1; }
[ -z "${KANTHOR_SUPERSAIYAN_ACTIVE:-}" ] \
  || { echo "error: a supersaiyan run is already active — nested delegation is refused" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }

mkdir -p "$SUPERSAIYAN_DIR"
run_dir="$(cd "$SUPERSAIYAN_DIR" && pwd -P)"

if [ "${1:-}" = --check ]; then
  [ $# -eq 1 ] || usage
  printf 'engine=%s\n' "$engine"
  printf 'task=%s\n' "$(mktemp "$run_dir/task-$(date -u +'%Y%m%d%H%M%S')-XXXXXX")"
  exit 0
fi

[ $# -eq 2 ] || usage
task="$1"
repo="$2"

[ -f "$task" ] && [ ! -L "$task" ] \
  || { echo "error: task file is missing or is a symlink: $task" >&2; exit 1; }
[ -s "$task" ] || { echo "error: task file is empty: $task" >&2; exit 1; }
task_dir="$(cd "$(dirname "$task")" && pwd -P)"
[ "$task_dir" = "$run_dir" ] \
  || { echo "error: task file must live in $run_dir, not $task_dir" >&2; exit 1; }
task="$task_dir/$(basename "$task")"

[ -d "$repo" ] || { echo "error: repo dir does not exist: $repo" >&2; exit 1; }
repo="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$repo" ] || { echo "error: $2 is not a git work tree" >&2; exit 1; }
[ -z "$(git -C "$repo" status --porcelain)" ] \
  || { echo "error: $repo has uncommitted changes — commit or stash them first" >&2; exit 1; }
baseline="$(git -C "$repo" rev-parse HEAD)"

tree="$task-tree"
reply="$task-reply.txt"
errlog="$task-stderr.txt"
patch="$task.patch"
[ ! -e "$tree" ] || { echo "error: run directory already exists: $tree" >&2; exit 1; }

case "$engine" in
  opencode2) engine_command=(opencode2 run) ;;
  pi) engine_command=(pi --print --no-session --no-approve --no-extensions --no-skills --no-prompt-templates --tools read,grep,find,ls,edit,write,bash) ;;
esac

fail() {
  {
    printf 'SUPERSAIYAN RUN FAILED — %s, exit %s\n' "$engine" "$rc"
    printf 'Reason: %s\n' "$1"
    printf 'Baseline: %s\n' "$baseline"
    printf 'Isolated clone: %s\n' "$tree"
    printf 'Engine reply excerpt:\n'
    head -n 10 "$reply" 2>/dev/null || true
    if [ -s "$errlog" ]; then
      printf 'Engine stderr tail:\n'
      tail -n 10 "$errlog"
    fi
    printf 'The project is untouched. Inspect the clone, then remove it:\n'
    printf '  rm -rf %s\n' "$tree"
  } >&2
  exit 1
}

git clone --quiet --local --no-hardlinks "$repo" "$tree"
git -C "$tree" checkout --quiet --detach "$baseline"

rc=0
set -m
(
  cd "$tree"
  KANTHOR_SUPERSAIYAN_ACTIVE=1 "${engine_command[@]}" < "$task" > "$reply" 2> "$errlog"
) &
pid=$!
set +m
trap 'kill -TERM -- -"$pid" 2>/dev/null || true' EXIT INT TERM
elapsed=0
while kill -0 "$pid" 2>/dev/null; do
  if [ "$elapsed" -ge "$SUPERSAIYAN_TIMEOUT" ]; then
    kill -TERM -- -"$pid" 2>/dev/null || true
    sleep "$SUPERSAIYAN_GRACE"
    kill -KILL -- -"$pid" 2>/dev/null || true
    break
  fi
  sleep "$SUPERSAIYAN_POLL"
  elapsed=$((elapsed + SUPERSAIYAN_POLL))
done
wait "$pid" || rc=$?
kill -TERM -- -"$pid" 2>/dev/null || true
trap - EXIT INT TERM

[ "$rc" -eq 0 ] || fail "non-zero exit (the watchdog kills a run that passes $SUPERSAIYAN_TIMEOUT seconds)"

git -C "$tree" add -A
git -C "$tree" diff --binary "$baseline" > "$patch"
[ -s "$patch" ] || fail 'the engine changed nothing — no patch to apply'
printf '%s\n' "$baseline" > "$task.baseline"

printf 'engine=%s\n' "$engine"
printf 'baseline=%s\n' "$baseline"
printf 'repo=%s\n' "$repo"
printf 'clone=%s\n' "$tree"
printf 'patch=%s\n' "$patch"
printf 'changed files:\n'
git -C "$tree" diff --stat "$baseline"
printf 'engine reply:\n'
cat "$reply"
