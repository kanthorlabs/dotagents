#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/config/opencode"
printf '{"hostname":"0.0.0.0","port":27798,"password":"secret"}\n' > "$tmp/config/opencode/service.json"

fake="$tmp/opencode2-real"
cat > "$fake" <<'EOF'
#!/bin/bash
printf '%s\n' "$@"
EOF
chmod 755 "$fake"

wrapper="$tmp/opencode2"
{
  printf '#!/bin/bash\nset -eo pipefail\n\nreal=%q\n' "$fake"
  /usr/bin/awk '
    /^config="\$\{XDG_CONFIG_HOME:-\$HOME\/\.config\}\/opencode\/service\.json"$/ { capture=1 }
    capture && /^EOF$/ { exit }
    capture { print }
  ' "$ROOT/scripts/setup-opencode2.sh"
} > "$wrapper"
chmod 755 "$wrapper"

assert_args() {
  local name="$1"
  local expected="$2"
  shift 2
  local actual
  actual="$(XDG_CONFIG_HOME="$tmp/config" "$wrapper" "$@")"
  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: %s\nexpected:\n%s\nactual:\n%s\n' "$name" "$expected" "$actual" >&2
    return 1
  fi
}

assert_args 'auth login' $'auth\nlogin\n--server\nhttp://127.0.0.1:27798' auth login
assert_args 'auth login target' $'auth\nlogin\n--server\nhttp://127.0.0.1:27798\nanthropic' auth login anthropic
assert_args 'auth list' $'auth\nlist\n--server\nhttp://127.0.0.1:27798' auth list
assert_args 'auth logout' $'auth\nlogout\n--server\nhttp://127.0.0.1:27798\nanthropic' auth logout anthropic
assert_args 'run' $'run\n--server\nhttp://127.0.0.1:27798\nprompt' run prompt
assert_args 'default TUI' $'--server\nhttp://127.0.0.1:27798'
assert_args 'TUI flags' $'--server\nhttp://127.0.0.1:27798\n--continue' --continue
mkdir "$tmp/project"
assert_args 'TUI directory' $'--server\nhttp://127.0.0.1:27798\n'"$tmp/project" "$tmp/project"
assert_args 'auth help' $'auth\n--help' auth --help
assert_args 'upgrade passthrough' 'upgrade' upgrade
assert_args 'unknown passthrough' 'future-command' future-command
assert_args 'passthrough argument named run' $'plugin\nadd\nrun' plugin add run
assert_args 'explicit server' $'auth\nlogin\n--server\nhttp://example.test' auth login --server http://example.test
assert_args 'standalone' $'auth\nlogin\n--standalone' auth login --standalone

printf 'setup-opencode2 wrapper tests passed\n'
