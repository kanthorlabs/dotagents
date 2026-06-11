#!/bin/sh
# Claude Code status line
# Segments: project path | git branch | model | ctx used | 5h limit | 7d limit

input=$(cat)

# --- colours (ANSI, will be dimmed by the terminal) ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

C_PATH="\033[38;5;75m"    # steel blue  — project dir
C_GIT="\033[38;5;214m"   # amber       — git branch
C_MODEL="\033[38;5;141m" # lavender    — model name
C_CTX="\033[38;5;79m"    # teal        — context %
C_5H="\033[38;5;210m"    # salmon      — 5-hour limit
C_7D="\033[38;5;183m"    # lilac       — 7-day limit
C_SEP="\033[38;5;240m"   # grey        — separators

SEP=" ${C_SEP}|${RESET} "

# --- project path (basename of project_dir, falling back to cwd) ---
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // empty')
if [ -n "$project_dir" ]; then
  proj=$(basename "$project_dir")
else
  proj="?"
fi

# --- git branch (via worktree first, then live git) ---
branch=$(echo "$input" | jq -r '.worktree.branch // empty')
if [ -z "$branch" ]; then
  # try a live git call; skip lock to stay non-blocking
  branch=$(git -C "$project_dir" --no-optional-locks branch --show-current 2>/dev/null)
fi

# --- model display name ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# --- context used % ---
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- rate limits ---
five_h=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage  // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage  // empty')

# --- assemble segments ---
out=""

# project + branch
if [ -n "$branch" ]; then
  out="${C_PATH}${BOLD}${proj}${RESET}${C_SEP}:${RESET}${C_GIT}${branch}${RESET}"
else
  out="${C_PATH}${BOLD}${proj}${RESET}"
fi

# model
if [ -n "$model" ]; then
  out="${out}${SEP}${C_MODEL}${model}${RESET}"
fi

# context used
if [ -n "$ctx_used" ]; then
  ctx_int=$(printf '%.0f' "$ctx_used")
  out="${out}${SEP}${C_CTX}ctx: ${ctx_int}%${RESET}"
fi

# 5-hour limit (show remaining = 100 - used)
if [ -n "$five_h" ]; then
  five_rem=$(printf '%.0f' "$(echo "100 - $five_h" | bc)")
  out="${out}${SEP}${C_5H}5h: ${five_rem}%${RESET}"
fi

# 7-day limit (show remaining)
if [ -n "$seven_d" ]; then
  seven_rem=$(printf '%.0f' "$(echo "100 - $seven_d" | bc)")
  out="${out}${SEP}${C_7D}7d: ${seven_rem}%${RESET}"
fi

printf "%b\n" "$out"
