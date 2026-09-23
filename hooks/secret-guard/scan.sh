#!/usr/bin/env bash
set -uo pipefail

file_path="${1:-}"
[ -n "$file_path" ] && [ -f "$file_path" ] && [ -r "$file_path" ] || exit 0

findings=()

scan() {
  local label="$1" case_flag="$2" regex="$3" lines
  lines="$(grep -nIE $case_flag -e "$regex" -- "$file_path" 2>/dev/null | cut -d: -f1 | head -5 | paste -sd, -)"
  [ -n "$lines" ] && findings+=("$label (lines $lines)")
}

local_host='@(tcp\(|unix\()?(localhost|127\.0\.0\.1|192\.168\.[0-9]{1,3}\.[0-9]{1,3})$'

scan_dsn() {
  local label="$1" regex="$2" lines
  lines="$(grep -noIE -e "$regex" -- "$file_path" 2>/dev/null | grep -vE "$local_host" | cut -d: -f1 | uniq | head -5 | paste -sd, -)"
  [ -n "$lines" ] && findings+=("$label (lines $lines)")
}

scan 'AWS access key ID' '' '\b(AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}\b'
scan 'AWS secret access key' -i 'aws_?secret_?(access_?)?key["'\'']?[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9/+=]{40}'
scan 'AWS session token' -i 'aws_?session_?token["'\'']?[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9/+=]{100,}'
scan_dsn 'URL or DSN with password' '[A-Za-z][A-Za-z0-9+.-]*://[^/[:space:]:@"'\'']+:[^/[:space:]@"'\''$<]+@[^/[:space:]:?#"'\''),]+'
scan_dsn 'Go MySQL DSN with password' '[^/[:space:]:@"'\'']+:[^/[:space:]@"'\''$<]+@(tcp|unix)\([^):[:space:]]+'
scan 'Private key' '' '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'
scan 'GitHub token' '' '\b(gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{60,})\b'
scan 'Slack token' '' '\bxox[abprs]-[A-Za-z0-9-]{10,}'
scan 'Stripe live key' '' '\b(sk|rk)_live_[A-Za-z0-9]{24,}'
scan 'Google API key' '' '\bAIza[A-Za-z0-9_-]{35}'
scan 'Anthropic or OpenAI API key' '' '\bsk-(ant-|proj-)?[A-Za-z0-9_-]{32,}'
scan 'JSON Web Token' '' '\beyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
scan 'Password or secret literal' -i '(password|passwd|secret|api_?key|access_?token|auth_?token)["'\'']?[[:space:]]*[:=][[:space:]]*["'\''][^"'\''[:space:]$<{][^"'\''[:space:]]{7,}["'\'']'
scan 'Password or secret in env file' '' '^[[:space:]]*(export[[:space:]]+)?[A-Z0-9_]*(PASSWORD|PASSWD|SECRET|TOKEN|API_KEY|PRIVATE_KEY)=["'\'']?[^[:space:]$"'\''{<]{8,}'

[ "${#findings[@]}" -eq 0 ] && exit 0

printf '%s\n' "${findings[@]}"
exit 1
