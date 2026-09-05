#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.config/opencode}"
OPENCODE2_HOSTNAME="${OPENCODE2_HOSTNAME:-0.0.0.0}"
OPENCODE2_PORT="${OPENCODE2_PORT:-27798}"
OPENCODE2_PROJECTS_DIR="${OPENCODE2_PROJECTS_DIR:-$HOME/Projects}"
OPENCODE2_SKIP_INSTALL="${OPENCODE2_SKIP_INSTALL:-0}"
label="ai.opencode.opencode2"
domain="gui/$(id -u)"
service_json="$OPENCODE_DIR/service.json"
bin_dir="$HOME/.opencode/bin"
wrapper="$bin_dir/opencode2"
server_launcher="$bin_dir/opencode2-server"
plist="$HOME/Library/LaunchAgents/$label.plist"
log_dir="$HOME/.local/share/opencode/log"
shell_rc="${OPENCODE2_SHELL_RC:-$HOME/.zshrc}"

[ "$(uname -s)" = Darwin ] || { echo "error: this setup requires macOS"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "error: npm is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "error: jq is required"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "error: curl is required"; exit 1; }
[[ "$OPENCODE2_PORT" =~ ^[0-9]+$ ]] && (( OPENCODE2_PORT >= 1 && OPENCODE2_PORT <= 65535 )) \
  || { echo "error: OPENCODE2_PORT must be between 1 and 65535"; exit 1; }

if [ -z "${OPENCODE2_PASSWORD:-}" ]; then
  [ -t 0 ] || { echo "error: set OPENCODE2_PASSWORD for non-interactive setup"; exit 1; }
  read -r -s -p "OpenCode 2 password: " OPENCODE2_PASSWORD
  printf '\n'
fi
[ -n "$OPENCODE2_PASSWORD" ] || { echo "error: the password cannot be empty"; exit 1; }

package_root="$(npm root -g)/@opencode-ai/cli"
real=""
for candidate in "$package_root/bin/opencode2.exe" "$package_root/bin/opencode2"; do
  if [ -x "$candidate" ]; then
    real="$candidate"
    break
  fi
done

if [ "$OPENCODE2_SKIP_INSTALL" != 1 ]; then
  if [ -n "$real" ]; then
    target_version="$(npm view '@opencode-ai/cli@beta' version)"
    "$real" upgrade "$target_version" --method npm
  else
    npm install -g '@opencode-ai/cli@beta'
  fi
fi

real=""
for candidate in "$package_root/bin/opencode2.exe" "$package_root/bin/opencode2"; do
  if [ -x "$candidate" ]; then
    real="$candidate"
    break
  fi
done
[ -n "$real" ] || { echo "error: opencode2 executable not found under $package_root/bin"; exit 1; }

mkdir -p "$OPENCODE2_PROJECTS_DIR" "$OPENCODE_DIR" "$bin_dir" "$log_dir" "$HOME/Library/LaunchAgents" "$HOME/.agents/skills"
OPENCODE2_PROJECTS_DIR="$(cd "$OPENCODE2_PROJECTS_DIR" && pwd -P)"

ROOT="$ROOT" OPENCODE_DIR="$OPENCODE_DIR" "$ROOT/scripts/install-opencode-json.sh"
for dir in "$ROOT"/skills/*/; do
  name="$(basename "$dir")"
  ln -sfn "$ROOT/skills/$name" "$HOME/.agents/skills/$name"
done

service_tmp="$(mktemp "$OPENCODE_DIR/service.json.XXXXXX")"
plist_json="$(mktemp)"
plist_tmp="$(mktemp)"
trap 'rm -f "$service_tmp" "$plist_json" "$plist_tmp" /tmp/opencode2-setup-location.json /tmp/opencode2-setup-bootstrap.err' EXIT
if [ -f "$service_json" ]; then
  jq -e 'type == "object"' "$service_json" >/dev/null \
    || { echo "error: $service_json is not a JSON object"; exit 1; }
  cp "$service_json" "$service_json.bak"
  jq --arg hostname "$OPENCODE2_HOSTNAME" --argjson port "$OPENCODE2_PORT" --arg password "$OPENCODE2_PASSWORD" \
    '. + {hostname: $hostname, port: $port, password: $password}' "$service_json" > "$service_tmp"
else
  jq -n --arg hostname "$OPENCODE2_HOSTNAME" --argjson port "$OPENCODE2_PORT" --arg password "$OPENCODE2_PASSWORD" \
    '{hostname: $hostname, port: $port, password: $password}' > "$service_tmp"
fi
mv "$service_tmp" "$service_json"
chmod 600 "$service_json"

{
  printf '#!/bin/bash\nset -eo pipefail\n\nreal=%q\n' "$real"
  cat <<'EOF'
config="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/service.json"

if [[ ! -x "$real" ]]; then
  printf 'opencode2: executable not found: %s\n' "$real" >&2
  exit 127
fi

args=("$@")
for arg in "${args[@]}"; do
  case "$arg" in
    --server|--standalone)
      exec "$real" "$@"
      ;;
  esac
done

command_index=-1
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[$i]}" in
    api|models|stats|export|import|mini|run)
      command_index=$i
      break
      ;;
    upgrade|update|acp|debug|console|auth|mcp|plugin|service|pair|serve)
      exec "$real" "$@"
      ;;
  esac
done

case "${1:-}" in
  --help|-h|--version|-v|--completions)
    exec "$real" "$@"
    ;;
esac

if [[ ! -r "$config" ]]; then
  printf 'opencode2: service configuration not readable: %s\n' "$config" >&2
  exit 1
fi

hostname=$(/usr/bin/jq -er '.hostname' "$config")
port=$(/usr/bin/jq -er '.port' "$config")
password=$(/usr/bin/jq -er '.password' "$config")
case "$hostname" in
  0.0.0.0)
    client_hostname="127.0.0.1"
    ;;
  ::|'[::]')
    client_hostname="[::1]"
    ;;
  *)
    client_hostname="$hostname"
    ;;
esac
server="http://${client_hostname}:${port}"
export OPENCODE_SERVER_PASSWORD="$password"

if (( command_index >= 0 )); then
  before=("${args[@]:0:$((command_index + 1))}")
  if (( command_index + 1 < ${#args[@]} )); then
    after=("${args[@]:$((command_index + 1))}")
    exec "$real" "${before[@]}" --server "$server" "${after[@]}"
  fi
  exec "$real" "${before[@]}" --server "$server"
fi

exec "$real" --server "$server" "$@"
EOF
} > "$wrapper"
chmod 755 "$wrapper"

{
  printf '#!/bin/bash\nset -euo pipefail\n\nreal=%q\n' "$real"
  cat <<'EOF'
config="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/service.json"
hostname=$(/usr/bin/jq -er '.hostname' "$config")
port=$(/usr/bin/jq -er '.port' "$config")
password=$(/usr/bin/jq -er '.password' "$config")
export OPENCODE_SERVER_PASSWORD="$password"
exec "$real" serve --hostname "$hostname" --port "$port"
EOF
} > "$server_launcher"
chmod 700 "$server_launcher"

launch_path="$(dirname "$real"):$bin_dir:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
jq -n \
  --arg label "$label" \
  --arg launcher "$server_launcher" \
  --arg directory "$OPENCODE2_PROJECTS_DIR" \
  --arg home "$HOME" \
  --arg path "$launch_path" \
  --arg stdout "$log_dir/launchd.stdout.log" \
  --arg stderr "$log_dir/launchd.stderr.log" \
  '{
    Label: $label,
    ProgramArguments: [$launcher],
    WorkingDirectory: $directory,
    EnvironmentVariables: {HOME: $home, PATH: $path},
    RunAtLoad: true,
    ProcessType: "Background",
    StandardOutPath: $stdout,
    StandardErrorPath: $stderr
  }' > "$plist_json"
plutil -convert xml1 -o "$plist_tmp" "$plist_json"
mv "$plist_tmp" "$plist"
chmod 600 "$plist"
plutil -lint "$plist" >/dev/null

if [ ! -f "$shell_rc" ]; then
  touch "$shell_rc"
fi
path_line='export PATH="$HOME/.opencode/bin:$PATH"'
if ! grep -Fqx "$path_line" "$shell_rc" >/dev/null 2>&1; then
  printf '\n%s\n' "$path_line" >> "$shell_rc"
fi

if launchctl print "$domain/$label" >/dev/null 2>&1; then
  launchctl bootout "$domain/$label"
  for _ in $(seq 1 40); do
    launchctl print "$domain/$label" >/dev/null 2>&1 || break
    sleep 0.25
  done
fi

bootstrapped=0
for _ in $(seq 1 20); do
  if launchctl bootstrap "$domain" "$plist" 2>/tmp/opencode2-setup-bootstrap.err; then
    bootstrapped=1
    break
  fi
  sleep 0.5
done
[ "$bootstrapped" = 1 ] || { cat /tmp/opencode2-setup-bootstrap.err >&2; exit 1; }

status=""
for _ in $(seq 1 60); do
  status="$(curl -sS -u "opencode:$OPENCODE2_PASSWORD" -o /tmp/opencode2-setup-location.json -w '%{http_code}' "http://127.0.0.1:$OPENCODE2_PORT/api/location" 2>/dev/null || true)"
  [ "$status" = 200 ] && break
  sleep 0.5
done
[ "$status" = 200 ] || { echo "error: OpenCode 2 did not start on port $OPENCODE2_PORT"; exit 1; }
jq -e --arg directory "$OPENCODE2_PROJECTS_DIR" '.directory == $directory' /tmp/opencode2-setup-location.json >/dev/null \
  || { echo "error: OpenCode 2 default directory is incorrect"; exit 1; }
unauthenticated="$(curl -sS -o /dev/null -w '%{http_code}' "http://127.0.0.1:$OPENCODE2_PORT/api/location")"
[ "$unauthenticated" = 401 ] || { echo "error: OpenCode 2 authentication is not active"; exit 1; }
"$wrapper" api GET /api/location | jq -e --arg directory "$OPENCODE2_PROJECTS_DIR" '.directory == $directory' >/dev/null
client_version="$("$real" --version)"
client_version_number="${client_version##* }"
client_version_number="${client_version_number#v}"
server_version="$(curl -fsS -u "opencode:$OPENCODE2_PASSWORD" "http://127.0.0.1:$OPENCODE2_PORT/api/health" | jq -er '.version')"
[ "$server_version" = "$client_version_number" ] \
  || { echo "error: OpenCode 2 server version $server_version does not match client version $client_version"; exit 1; }

printf 'OpenCode 2: %s\n' "$client_version"
printf 'Default directory: %s\n' "$OPENCODE2_PROJECTS_DIR"
printf 'Local URL: http://127.0.0.1:%s\n' "$OPENCODE2_PORT"
printf 'Username: opencode\n'
tailscale_bin="$(command -v tailscale || true)"
if [ -z "$tailscale_bin" ] && [ -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]; then
  tailscale_bin="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi
if [ -n "$tailscale_bin" ]; then
  tailscale_ip="$("$tailscale_bin" ip -4 2>/dev/null | head -1 || true)"
  if [ -n "$tailscale_ip" ]; then
    printf 'Tailscale URL: http://%s:%s\n' "$tailscale_ip" "$OPENCODE2_PORT"
  fi
fi
printf 'Run rehash in an existing shell.\n'
