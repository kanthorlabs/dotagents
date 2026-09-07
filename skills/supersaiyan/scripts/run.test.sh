#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN="$ROOT/run.sh"
APPLY="$ROOT/apply.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/ss" "$work/plain"
export PATH="$work/bin:$PATH"
export SUPERSAIYAN_DIR="$work/ss"
export SUPERSAIYAN_POLL=1
export SUPERSAIYAN_GRACE=1
export KANTHOR_SUPERSAIYAN_ENGINE=pi
git_quiet() { git -c user.email=t@t -c user.name=t "$@"; }
failures=0

repo="$work/repo"
mkdir -p "$repo"
git -C "$repo" init -q
printf 'base\n' > "$repo/tracked.txt"
git -C "$repo" add -A
git_quiet -C "$repo" commit -qm base
baseline="$(git -C "$repo" rev-parse HEAD)"

stub() {
  printf '#!/usr/bin/env bash\ncat >/dev/null\n%s\n' "$1" > "$work/bin/pi"
  chmod 755 "$work/bin/pi"
}

newtask() {
  local file
  file="$(mktemp "$work/ss/task-XXXXXX")"
  printf 'implement the thing\n' > "$file"
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

check 'engine unset rejected' 1 "$(env -u KANTHOR_SUPERSAIYAN_ENGINE bash -c 'rc=0; "$1" --check >/dev/null 2>&1 || rc=$?; echo $rc' bash "$RUN")"
check 'engine invalid rejected' 1 "$(KANTHOR_SUPERSAIYAN_ENGINE=bogus bash -c 'rc=0; "$1" --check >/dev/null 2>&1 || rc=$?; echo $rc' bash "$RUN")"
check 'nested run rejected' 1 "$(KANTHOR_SUPERSAIYAN_ACTIVE=1 rc_of "$RUN" --check)"
check 'no argument is a usage error' 64 "$(rc_of "$RUN")"
check 'one argument is a usage error' 64 "$(rc_of "$RUN" "$(newtask)")"

stub 'true'
check 'check succeeds' 0 "$(rc_of "$RUN" --check)"
task="$(sed -n 's/^task=//p' "$work/out")"
check 'check allocates in the run dir' "$(cd "$work/ss" && pwd -P)" "$(cd "$(dirname "$task")" && pwd -P)"
check 'check expands the name template' '' "$(printf '%s' "$task" | grep -o XXXXXX || true)"
check 'allocated task file is private' 600 "$(stat -f '%OLp' "$task")"

printf 'x\n' > "$work/outside-task"
check 'task file outside the run dir rejected' 1 "$(rc_of "$RUN" "$work/outside-task" "$repo")"
check 'empty task file rejected' 1 "$(rc_of "$RUN" "$task" "$repo")"
check 'non-git repo dir rejected' 1 "$(rc_of "$RUN" "$(newtask)" "$work/plain")"

printf 'dirty\n' > "$repo/dirty.txt"
check 'dirty repo rejected' 1 "$(rc_of "$RUN" "$(newtask)" "$repo")"
rm -f "$repo/dirty.txt"

stub 'true'
check 'empty diff fails' 1 "$(rc_of "$RUN" "$(newtask)" "$repo")"
check 'empty diff is reported' 1 "$(grep -c 'changed nothing' "$work/err")"

stub 'exit 3'
check 'non-zero exit fails' 1 "$(rc_of "$RUN" "$(newtask)" "$repo")"
check 'non-zero exit is reported' 1 "$(grep -c 'SUPERSAIYAN RUN FAILED — pi, exit 3' "$work/err")"

stub 'printf "added\n" > added.txt; printf "changed\n" > tracked.txt; printf "\x00\x01\x02" > blob.bin; echo done'
task="$(newtask)"
check 'successful run succeeds' 0 "$(rc_of "$RUN" "$task" "$repo")"
patch="$task.patch"
check 'patch holds the new file' 1 "$(grep -cE '^\+\+\+ b/added\.txt$' "$patch")"
check 'patch holds the tracked change' 1 "$(grep -cE '^\+\+\+ b/tracked\.txt$' "$patch")"
check 'patch holds the binary file' 1 "$(grep -c 'GIT binary patch' "$patch")"
check 'run records the baseline' "$baseline" "$(cat "$task.baseline")"
check 'run leaves the project clean' '' "$(git -C "$repo" status --porcelain)"
check 'run reports the engine reply' 1 "$(grep -c '^done$' "$work/out")"
check 'clone stays for inspection' yes "$([ -d "$task-tree" ] && echo yes || echo no)"

cp "$patch" "$work/copy.patch"
check 'apply refuses a patch outside the run dir' 1 "$(rc_of "$APPLY" "$work/copy.patch" "$repo")"
printf 'dirty\n' > "$repo/dirty.txt"
check 'apply refuses a dirty repo' 1 "$(rc_of "$APPLY" "$patch" "$repo")"
rm -f "$repo/dirty.txt"
printf 'drift\n' > "$repo/drift.txt"
git -C "$repo" add -A
git_quiet -C "$repo" commit -qm drift
check 'apply refuses a moved HEAD' 1 "$(rc_of "$APPLY" "$patch" "$repo")"
git -C "$repo" reset -q --hard "$baseline"

check 'apply succeeds' 0 "$(rc_of "$APPLY" "$patch" "$repo")"
check 'apply lands the new file' 'added' "$(cat "$repo/added.txt")"
check 'apply lands the tracked change' 'changed' "$(cat "$repo/tracked.txt")"
check 'apply lands the binary file' 3 "$(wc -c < "$repo/blob.bin" | tr -d ' ')"
check 'apply prints the revert command' 1 "$(grep -c 'clean -fd' "$work/out")"
printf 'byproduct\n' > "$repo/added.txt"
git -C "$repo" checkout -- .
git -C "$repo" clean -qfd
check 'revert restores the project' '' "$(git -C "$repo" status --porcelain)"
check 'revert restores the tracked file' 'base' "$(cat "$repo/tracked.txt")"

stub 'printf "committed\n" > committed.txt; git add -A; git -c user.email=t@t -c user.name=t commit -qm engine; echo committed'
task="$(newtask)"
check 'engine commit still yields a patch' 0 "$(rc_of "$RUN" "$task" "$repo")"
check 'patch holds the committed file' 1 "$(grep -cE '^\+\+\+ b/committed\.txt$' "$task.patch")"

stub 'printf "staged\n" > staged.txt; git add staged.txt; echo staged'
task="$(newtask)"
check 'staged-only change yields a patch' 0 "$(rc_of "$RUN" "$task" "$repo")"
check 'patch holds the staged file' 1 "$(grep -cE '^\+\+\+ b/staged\.txt$' "$task.patch")"

stub "bash -c 'sleep 6; touch \"$work/orphan.txt\"' & sleep 30"
check 'stalled run is killed' 1 "$(SUPERSAIYAN_TIMEOUT=1 rc_of "$RUN" "$(newtask)" "$repo")"
sleep 8
check 'watchdog kills the whole process group' no "$([ -e "$work/orphan.txt" ] && echo yes || echo no)"

[ "$failures" -eq 0 ] || { printf '%s test(s) failed\n' "$failures" >&2; exit 1; }
printf 'all tests passed\n'
