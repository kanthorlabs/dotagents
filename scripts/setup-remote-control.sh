#!/usr/bin/env bash
set -euo pipefail

usage() { echo "usage: $0 install|uninstall"; exit 1; }

action="${1:-}"
label="com.kanthorlabs.claude-remote-control"
unit="claude-remote-control.service"
workdir="${REMOTE_CONTROL_DIR:-$HOME/Projects}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

if [ "$CLAUDE_DIR" = "$HOME/.claude" ]; then
	claude_json="$HOME/.claude.json"
	profile_env=""
else
	claude_json="$CLAUDE_DIR/.claude.json"
	profile_env="CLAUDE_CONFIG_DIR=\"$CLAUDE_DIR\" "
	suffix="-$(basename "$CLAUDE_DIR" | sed 's/^\.//')"
	label="$label$suffix"
	unit="claude-remote-control$suffix.service"
fi
log_name="${label#com.kanthorlabs.}.log"

require_trusted_workdir() {
	command -v jq >/dev/null 2>&1 || { echo "error: jq is required"; exit 1; }
	[ -d "$workdir" ] || { echo "error: missing $workdir"; exit 1; }
	local trusted
	trusted=$(jq -r --arg d "$workdir" '.projects[$d].hasTrustDialogAccepted // false' "$claude_json" 2>/dev/null || echo false)
	[ "$trusted" = "true" ] || { echo "error: $workdir is not trusted; run 'cd $workdir && ${profile_env}claude' once and accept the trust dialog"; exit 1; }
}

resolve_claude() {
	command -v claude 2>/dev/null || { echo "error: claude is not on PATH" >&2; exit 1; }
}

install_launchd() {
	local claude_bin="$1"
	local plist="$HOME/Library/LaunchAgents/$label.plist"
	local log="$HOME/Library/Logs/$log_name"
	mkdir -p "$(dirname "$plist")" "$(dirname "$log")"
	cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$label</string>
	<key>ProgramArguments</key>
	<array>
		<string>$claude_bin</string>
		<string>remote-control</string>
	</array>
	<key>WorkingDirectory</key>
	<string>$workdir</string>
	<key>EnvironmentVariables</key>
	<dict>
		<key>PATH</key>
		<string>$PATH</string>
$([ -n "$profile_env" ] && printf '\t\t<key>CLAUDE_CONFIG_DIR</key>\n\t\t<string>%s</string>\n' "$CLAUDE_DIR")
	</dict>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>ThrottleInterval</key>
	<integer>30</integer>
	<key>StandardOutPath</key>
	<string>$log</string>
	<key>StandardErrorPath</key>
	<string>$log</string>
</dict>
</plist>
EOF
	launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
	launchctl bootstrap "gui/$(id -u)" "$plist"
	echo "launchd    $label -> $plist (log: $log)"
}

uninstall_launchd() {
	local plist="$HOME/Library/LaunchAgents/$label.plist"
	launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
	rm -f "$plist"
	echo "launchd    removed $label"
}

install_systemd() {
	local claude_bin="$1"
	local service="$HOME/.config/systemd/user/$unit"
	mkdir -p "$(dirname "$service")"
	cat > "$service" <<EOF
[Unit]
Description=Claude Code Remote Control
After=network-online.target

[Service]
WorkingDirectory=$workdir
Environment="PATH=$PATH"
$([ -n "$profile_env" ] && printf 'Environment="CLAUDE_CONFIG_DIR=%s"\n' "$CLAUDE_DIR")
ExecStart=$claude_bin remote-control
Restart=always
RestartSec=30

[Install]
WantedBy=default.target
EOF
	systemctl --user daemon-reload
	systemctl --user enable --now "$unit"
	systemctl --user restart "$unit"
	echo "systemd    $unit -> $service (log: journalctl --user -u $unit)"
}

uninstall_systemd() {
	local service="$HOME/.config/systemd/user/$unit"
	systemctl --user disable --now "$unit" 2>/dev/null || true
	rm -f "$service"
	systemctl --user daemon-reload
	echo "systemd    removed $unit"
}

case "$(uname -s)-$action" in
	Darwin-install) require_trusted_workdir; install_launchd "$(resolve_claude)" ;;
	Darwin-uninstall) uninstall_launchd ;;
	Linux-install) require_trusted_workdir; install_systemd "$(resolve_claude)" ;;
	Linux-uninstall) uninstall_systemd ;;
	*-install|*-uninstall) echo "error: unsupported OS $(uname -s)"; exit 1 ;;
	*) usage ;;
esac
