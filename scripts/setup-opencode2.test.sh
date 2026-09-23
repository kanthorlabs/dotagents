#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/config/opencode" "$tmp/bin"
cat > "$tmp/bin/launchctl" <<'EOF'
#!/bin/bash
printf 'launchctl\n'
printf '%s\n' "$@"
exit "${LAUNCHCTL_EXIT_CODE:-0}"
EOF
chmod 755 "$tmp/bin/launchctl"
export PATH="$tmp/bin:$PATH"
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

assert_failure() {
  local name="$1"
  local expected_status="$2"
  local expected_output="$3"
  shift 3
  local actual
  local status=0
  actual="$(XDG_CONFIG_HOME="$tmp/config" "$wrapper" "$@" 2>&1)" || status=$?
  if [ "$status" -ne "$expected_status" ]; then
    printf 'FAIL: %s: expected exit %s, got %s\n' "$name" "$expected_status" "$status" >&2
    return 1
  fi
  if [ "$actual" != "$expected_output" ]; then
    printf 'FAIL: %s\nexpected:\n%s\nactual:\n%s\n' "$name" "$expected_output" "$actual" >&2
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
service_target="gui/$(id -u)/ai.opencode.opencode2"
start_args=$'launchctl\nkickstart\n-p\n'"$service_target"
stop_args=$'launchctl\nkill\nSIGTERM\n'"$service_target"
restart_args=$'launchctl\nkickstart\n-k\n-p\n'"$service_target"
status_args=$'launchctl\nprint\n'"$service_target"
for service_command in start stop restart status; do
  expected_var="${service_command}_args"
  assert_args "service $service_command" "${!expected_var}" service "$service_command"
  assert_args "service $service_command help" $'service\n'"$service_command"$'\n--help' service "$service_command" --help
  assert_args "service $service_command short help" $'service\n'"$service_command"$'\n-h' service "$service_command" -h
  assert_args "service $service_command version" $'service\n'"$service_command"$'\n--version' service "$service_command" --version
  LAUNCHCTL_EXIT_CODE=23 assert_failure "service $service_command launchctl failure" 23 "${!expected_var}" service "$service_command"
  assert_failure "service $service_command extra flags" 2 "opencode2: service $service_command accepts no extra arguments or flags" service "$service_command" --print-logs
  assert_failure "service $service_command extra arguments" 2 "opencode2: service $service_command accepts no extra arguments or flags" service "$service_command" extra
  assert_failure "service $service_command standalone flag" 2 "opencode2: service $service_command accepts no extra arguments or flags" service "$service_command" --standalone
  assert_failure "service $service_command server flag" 2 "opencode2: service $service_command accepts no extra arguments or flags" service "$service_command" --server http://example.test
done
assert_args 'service configuration passthrough' $'service\nset\nport\n27798' service set port 27798
assert_args 'service get passthrough' $'service\nget\nport' service get port
assert_args 'service unset passthrough' $'service\nunset\nport' service unset port
assert_args 'upgrade passthrough' 'upgrade' upgrade
assert_args 'unknown passthrough' 'future-command' future-command
assert_args 'passthrough argument named run' $'plugin\nadd\nrun' plugin add run
assert_args 'explicit server' $'auth\nlogin\n--server\nhttp://example.test' auth login --server http://example.test
assert_args 'standalone' $'auth\nlogin\n--standalone' auth login --standalone
ln -s "$(basename "$wrapper")" "$tmp/opencode"
wrapper="$tmp/opencode"
assert_args 'opencode alias' $'auth\nlogin\n--server\nhttp://127.0.0.1:27798' auth login
for service_command in start stop restart status; do
  expected_var="${service_command}_args"
  assert_args "opencode alias service $service_command" "${!expected_var}" service "$service_command"
done
rm "$tmp/config/opencode/service.json"
for service_command in start stop restart status; do
  expected_var="${service_command}_args"
  assert_args "service $service_command without client configuration" "${!expected_var}" service "$service_command"
done

printf 'setup-opencode2 wrapper tests passed\n'
