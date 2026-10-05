#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="$ROOT/claude.sh"
SCAN="$ROOT/scan.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

check() {
  local name="$1" want="$2" got="$3"
  if [ "$want" = "$got" ]; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s — want %s, got %s\n' "$name" "$want" "$got"
    failures=$((failures + 1))
  fi
}

decision_for() {
  local file="$work/sample"
  printf '%s\n' "$1" > "$file"
  jq -n --arg p "$file" '{tool_name: "Read", tool_input: {file_path: $p}}' \
    | "$GUARD" \
    | jq -r '.hookSpecificOutput.permissionDecision // empty'
}

check 'AWS access key ID denies' deny "$(decision_for "key = AKIA""IOSFODNN7EXAMPLE")"
check 'AWS secret access key denies' deny "$(decision_for "aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfi""CYEXAMPLEKEY")"
check 'Postgres DSN with password denies' deny "$(decision_for "DATABASE_URL=postgres://app:s3cr""et@db.internal:5432/app")"
check 'Go MySQL DSN with password denies' deny "$(decision_for "dsn := \"app:s3cr""et@tcp(db.internal:3306)/app\"")"
check 'DSN on a public IP denies' deny "$(decision_for "mysql://app:s3cr""et@10.0.0.5:3306/app")"
check 'DSN on a lookalike local host denies' deny "$(decision_for "postgres://app:s3cr""et@localhost.evil.com/app")"
check 'DSN on a 192.168 prefix host name denies' deny "$(decision_for "postgres://app:s3cr""et@192.168.1.10.evil.com/app")"
check 'local and remote DSN on one line denies' deny "$(decision_for "a=postgres://app:s3cr""et@localhost/app b=postgres://app:s3cr""et@db.internal/app")"
check 'private key denies' deny "$(decision_for "-----BEGIN RSA PRIVATE ""KEY-----")"
check 'GitHub token denies' deny "$(decision_for "token: gh""p_0123456789abcdefghijABCDEFGHIJ012345")"
check 'Anthropic key denies' deny "$(decision_for "sk-""ant-api03-0123456789abcdefghijABCDEFGHIJ")"
check 'password literal denies' deny "$(decision_for "password = \"hunter2""hunter2\"")"
check 'env file secret denies' deny "$(decision_for "export STRIPE_SECRET=abcdef""123456")"

check 'debug secret literal allows' '' "$(decision_for 'const SECRET = "debug_fixture-value";')"
check 'test secret literal allows' '' "$(decision_for "const SECRET = 'test_fixture-value';")"
check 'JSON fixture value allows' '' "$(decision_for '{"api_key":"test_fixture-value"}')"
check 'debug env value allows' '' "$(decision_for 'export SERVICE_SECRET=debug_fixture-value')"
check 'test quoted env value allows' '' "$(decision_for 'SERVICE_TOKEN="test_fixture-value"')"
check 'test DSN password allows' '' "$(decision_for 'postgres://app:test_fixture-value@db.internal/app')"
check 'debug Go DSN password allows' '' "$(decision_for 'app:debug_fixture-value@tcp(db.internal:3306)/app')"
check 'fixture named variable with ordinary value denies' deny "$(decision_for 'test_secret = "ordinary-value";')"
check 'uppercase prefix denies' deny "$(decision_for 'secret = "TEST_fixture-value";')"
check 'embedded prefix denies' deny "$(decision_for 'secret = "ordinary-test_fixture";')"
check 'prefix after a colon in the value denies' deny "$(decision_for 'secret = "ordinary:test_fixture";')"
check 'prefix after an equals sign in the value denies' deny "$(decision_for 'SERVICE_SECRET=ordinary=debug_fixture')"
check 'fixture and ordinary literal on one line denies' deny "$(decision_for 'secret = "test_fixture-value"; password = "ordinary-value";')"
check 'fixture and ordinary JSON value on one line denies' deny "$(decision_for '{"secret":"debug_fixture-value","password":"ordinary-value"}')"
check 'fixture env and ordinary literal on one line denies' deny "$(decision_for 'SERVICE_SECRET=test_fixture-value password="ordinary-value"')"
check 'fixture and ordinary DSN on one line denies' deny "$(decision_for 'postgres://app:test_fixture@db/app postgres://app:ordinary-value@db/app')"
check 'fixture DSN username with ordinary password denies' deny "$(decision_for 'postgres://test_user:ordinary-value@db/app')"
check 'fixture Go DSN username with ordinary password denies' deny "$(decision_for 'debug_user:ordinary-value@tcp(db.internal:3306)/app')"

check 'E2E env password allows' '' "$(decision_for "E2E_PASSWORD=hunter2""hunter2")"
check 'TEST exported env secret allows' '' "$(decision_for "export TEST_STRIPE_SECRET=abcdef""123456")"
check 'DEBUG quoted env secret allows' '' "$(decision_for 'DEBUG_API_KEY="ordinary value 12345"')"
check 'TEST single-quoted env password allows' '' "$(decision_for "TEST_PASSWORD='hunter2""hunter2'")"
check 'E2E env DSN allows' '' "$(decision_for "E2E_DATABASE_URL=postgres://app:s3cr""et@db.internal/app")"
check 'TEST env token allows' '' "$(decision_for "TEST_GITHUB_TOKEN=gh""p_0123456789abcdefghijABCDEFGHIJ012345")"
check 'indented DEBUG env secret allows' '' "$(decision_for "  DEBUG_SECRET=abcdef""123456")"
check 'YAML map env password allows' '' "$(decision_for "  E2E_PASSWORD: hunter2""hunter2")"
check 'YAML map quoted env secret allows' '' "$(decision_for "TEST_API_KEY: \"abcdef""123456\"")"
check 'YAML map single-quoted env DSN allows' '' "$(decision_for "DEBUG_DATABASE_URL: 'postgres://app:s3cr""et@db.internal/app'")"
check 'YAML list env secret allows' '' "$(decision_for "      - TEST_STRIPE_SECRET=abcdef""123456")"
check 'YAML list env token allows' '' "$(decision_for "- E2E_GITHUB_TOKEN=gh""p_0123456789abcdefghijABCDEFGHIJ012345")"
check 'YAML map ordinary secret denies' deny "$(decision_for "  STRIPE_SECRET: \"abcdef""123456\"")"
check 'YAML list ordinary secret denies' deny "$(decision_for "  - STRIPE_SECRET=\"abcdef""123456\"")"
check 'YAML map without a space after the colon denies' deny "$(decision_for "TEST_PASSWORD:\"hunter2""hunter2\"")"
check 'YAML map env and ordinary map on next line denies' deny "$(decision_for "$(printf 'TEST_SECRET: x\nSTRIPE_SECRET: "abcdef''123456"')")"
check 'lowercase env prefix denies' deny "$(decision_for "test_SECRET=\"abcdef""123456\"")"
check 'embedded env prefix denies' deny "$(decision_for "APP_TEST_SECRET=abcdef""123456")"
check 'prefix in a code literal denies' deny "$(decision_for "TEST_PASSWORD = \"hunter2""hunter2\"")"
check 'E2E env and ordinary literal on one line denies' deny "$(decision_for "export E2E_SECRET=x password=\"hunter2""hunter2\"")"
check 'E2E env and ordinary env on next line denies' deny "$(decision_for "$(printf 'E2E_SECRET=abcdef''123456\nSTRIPE_SECRET=abcdef''123456')")"

check 'JSON Web Token allows' '' "$(decision_for "token = eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U")"
check 'plain source allows' '' "$(decision_for "func main() { fmt.Println(\"hello\") }")"
check 'DSN on localhost allows' '' "$(decision_for "postgres://app:s3cr""et@localhost:5432/app")"
check 'DSN on 127.0.0.1 allows' '' "$(decision_for "redis://default:s3cr""et@127.0.0.1:6379/0")"
check 'DSN on 192.168 network allows' '' "$(decision_for "mongodb://app:s3cr""et@192.168.1.20/app")"
check 'Go MySQL DSN on 127.0.0.1 allows' '' "$(decision_for "app:s3cr""et@tcp(127.0.0.1:3306)/app")"
check 'Go MySQL DSN on localhost allows' '' "$(decision_for "app:s3cr""et@tcp(localhost)/app")"
check 'DSN without password allows' '' "$(decision_for "postgres://app@db.internal:5432/app")"
check 'DSN with env placeholder allows' '' "$(decision_for "postgres://app:\${DB_PASSWORD}@db.internal/app")"
check 'password from env lookup allows' '' "$(decision_for "password = os.getenv(\"DB_PASSWORD\")")"
check 'password literal placeholder allows' '' "$(decision_for "export OPENCODE_SERVER_PASSWORD=\"\$password\"")"
check 'code constant named like a token allows' '' "$(decision_for "TOKEN_ROW = re.compile(r\"^abc\")")"
check 'env file reference allows' '' "$(decision_for "DB_PASSWORD=\${VAULT_DB_PASSWORD}")"
check 'DSN with angle placeholder allows' '' "$(decision_for "mysql://app:<password>@db/app and app:<password>@tcp(db)/app")"
mkdir "$work/failing-bin"
printf '#!/bin/sh\nexit 2\n' > "$work/failing-bin/sed"
chmod +x "$work/failing-bin/sed"
printf 'hello\n' > "$work/scan-fails"
check 'scan failure denies' deny "$(jq -n --arg p "$work/scan-fails" '{tool_input: {file_path: $p}}' \
  | PATH="$work/failing-bin:$PATH" "$GUARD" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecision // empty')"
check 'missing file allows' '' "$(jq -n '{tool_input: {file_path: "/nonexistent/file"}}' | "$GUARD")"
check 'invalid input allows' '' "$(printf 'not json' | "$GUARD")"

reason="$(printf 'user=AKIA''IOSFODNN7EXAMPLE\n' > "$work/leak" \
  && jq -n --arg p "$work/leak" '{tool_input: {file_path: $p}}' | "$GUARD" \
  | jq -r '.hookSpecificOutput.permissionDecisionReason')"
check 'reason omits the secret value' absent "$(printf '%s' "$reason" | grep -q 'IOSFODNN7' && echo present || echo absent)"
check 'reason names the line' present "$(printf '%s' "$reason" | grep -q 'lines 1' && echo present || echo absent)"

printf 'aws_key=AKIA''IOSFODNN7EXAMPLE\n' > "$work/scan-hit"
printf 'hello\n' > "$work/scan-clean"
check 'scan exits 1 on a finding' 1 "$(rc=0; "$SCAN" "$work/scan-hit" >/dev/null || rc=$?; echo $rc)"
check 'scan prints one finding per line' 'AWS access key ID (lines 1)' "$("$SCAN" "$work/scan-hit" || true)"
check 'scan exits 0 on a clean file' 0 "$(rc=0; "$SCAN" "$work/scan-clean" >/dev/null || rc=$?; echo $rc)"
check 'scan exits 0 without an argument' 0 "$(rc=0; "$SCAN" >/dev/null || rc=$?; echo $rc)"

[ "$failures" -eq 0 ] || { printf '%s failure(s)\n' "$failures"; exit 1; }
node --test "$ROOT/opencode.test.mjs" "$ROOT/pi.test.mjs"
printf 'all passed\n'
