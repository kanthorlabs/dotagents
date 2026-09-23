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
node --test "$ROOT/opencode.test.mjs"
printf 'all passed\n'
