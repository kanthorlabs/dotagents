#!/usr/bin/env bash
set -euo pipefail
umask 077

SUPERSAIYAN_DIR="${SUPERSAIYAN_DIR:-$HOME/.kanthorlabs/supersaiyan}"

usage() {
  echo "usage: apply.sh <patch-file> <repo-dir>" >&2
  exit 64
}

[ $# -eq 2 ] || usage
patch="$1"
repo="$2"

command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }
mkdir -p "$SUPERSAIYAN_DIR"
run_dir="$(cd "$SUPERSAIYAN_DIR" && pwd -P)"

[ -f "$patch" ] && [ ! -L "$patch" ] \
  || { echo "error: patch file is missing or is a symlink: $patch" >&2; exit 1; }
[ -s "$patch" ] || { echo "error: patch file is empty: $patch" >&2; exit 1; }
patch_dir="$(cd "$(dirname "$patch")" && pwd -P)"
[ "$patch_dir" = "$run_dir" ] \
  || { echo "error: patch file must live in $run_dir, not $patch_dir" >&2; exit 1; }
patch="$patch_dir/$(basename "$patch")"

baseline_file="${patch%.patch}.baseline"
[ -s "$baseline_file" ] \
  || { echo "error: baseline record is missing: $baseline_file" >&2; exit 1; }
baseline="$(cat "$baseline_file")"

[ -d "$repo" ] || { echo "error: repo dir does not exist: $repo" >&2; exit 1; }
repo="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$repo" ] || { echo "error: $2 is not a git work tree" >&2; exit 1; }
[ -z "$(git -C "$repo" status --porcelain)" ] \
  || { echo "error: $repo has uncommitted changes — the patch applies to a clean tree only" >&2; exit 1; }
head="$(git -C "$repo" rev-parse HEAD)"
[ "$head" = "$baseline" ] \
  || { echo "error: $repo moved from the baseline $baseline to $head — rerun the task" >&2; exit 1; }

git -C "$repo" apply --binary --check "$patch" \
  || { echo "error: the patch does not apply cleanly to $repo" >&2; exit 1; }
git -C "$repo" apply --binary "$patch"

printf 'repo=%s\n' "$repo"
printf 'baseline=%s\n' "$baseline"
printf 'patch=%s\n' "$patch"
printf 'applied files:\n'
git -C "$repo" status --porcelain
printf 'revert with (the tree was clean before the patch, so this restores %s):\n' "$baseline"
printf '  git -C %s checkout -- . && git -C %s clean -fd\n' "$repo" "$repo"
printf 'remove the isolated clone with:\n'
printf '  rm -rf %s\n' "${patch%.patch}-tree"
