#!/usr/bin/env bash
# Configures a global git ignore file and points core.excludesfile at it.
# The pattern list lives in assets/git/gitignore_global. Idempotent: each line is
# appended only if an exact-match line is not already present in the target, so
# re-running adds nothing and never touches the user's own entries.
set -euo pipefail

command -v git >/dev/null 2>&1 || { echo "error: git is required"; exit 1; }

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source_list="$ROOT/assets/git/gitignore_global"
target="${GITIGNORE_GLOBAL:-$HOME/.gitignore_global}"

[ -f "$source_list" ] || { echo "error: missing $source_list"; exit 1; }

touch "$target"

# Ensure the target ends with a newline so appends don't glue onto the last line.
if [ -s "$target" ] && [ -n "$(tail -c1 "$target")" ]; then
	printf '\n' >> "$target"
fi

added=0
while IFS= read -r line || [ -n "$line" ]; do
	[ -z "$line" ] && continue
	if ! grep -Fxq -- "$line" "$target"; then
		printf '%s\n' "$line" >> "$target"
		echo "gitignore  + $line"
		added=$((added + 1))
	fi
done < "$source_list"

# Point git at the global ignore file (idempotent — sets the same value).
git config --global core.excludesfile "$target"

echo "gitignore  $added new pattern(s) added to $target"
echo "gitignore  core.excludesfile -> $(git config --global core.excludesfile)"
