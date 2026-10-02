# dotagents

Opinionated agent setup with curated skills, Claude Code plugins, sub-agents, and references.

## Quick Start

Install the repo customizations into `~/.claude`:

```bash
make install
```

Want my opinionated configuration on top (persona + global git ignore)? Run:

```bash
make install-persona
```

See [Installation](#installation) for details on what each step does.

## Repository Structure

```
dotagents/
├── .claude/plugins/       # Local Claude Code marketplace
├── hooks/                 # Agent-neutral hook scripts
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md        # Skill definition and core rules
│       ├── references/     # Deferred reference documents
│       └── scripts/        # Helper scripts
├── LICENSE
└── README.md
```

## Skills

| Skill | Description |
|-------|-------------|
| `/coding` | Seven code rules cover linear control flow, bounded loops, resource ownership, small functions, assertions, explicit errors, and zero warnings. |
| `/debate` | Run an answer through an adversarial debate engine, then merge valid critiques back in. Requires `KANTHOR_DEBATE_ENGINE=opencode2\|pi`. READ-ONLY: no filesystem or state changes. |
| `/supersaiyan` | Delegate the modification to a write-mode engine, which edits an isolated clone; the caller verifies the patch and applies it. Requires `KANTHOR_SUPERSAIYAN_ENGINE=opencode2\|pi`. Harness-agnostic: any harness that runs bash. |
| `/explain` | Explain a problem, a bug, a design gap or a proposal with named actors, a numbered timeline and one question. No engine, no script: it shapes the message. |

`/coding` adapts ideas from [*The Power of 10: Rules for Developing Safety-Critical Code*](https://spinroot.com/gerard/pdf/P10.pdf).
Gerard J. Holzmann of NASA/JPL published the paper in *IEEE Computer* in June 2006.

More skills coming.

## Claude Code Plugins

| Plugin | Description |
|--------|-------------|
| `pi-orchestrator` | Lets Claude orchestrate persistent Pi coding workers through MCP. |

Use `/pi <task>` for explicit delegation. Pi must be installed and authenticated.

## Hooks

`hooks/secret-guard/` holds a secret scanner that all agents share:

- `scan.sh <file>` prints one finding per line and exits 1 on a match. It does not depend on an agent.
- `claude.sh` adapts `scan.sh` to the Claude Code hook protocol.
- `opencode.js` denies sensitive OpenCode 2 `read` resources through a permission hook.
- `pi.ts` blocks sensitive Pi `read` calls through the `tool_call` event, without approval.

To support another agent, add an adapter next to `claude.sh` that calls `scan.sh`.

`claude.sh` runs as a `PreToolUse` hook on the `Read` tool.
`opencode.js` checks OpenCode 2 `read` permissions before the file read.
If the file contains possible sensitive data, the hook blocks the read.

The hook detects these categories:

- AWS access key IDs, secret access keys, and session tokens.
- URLs and database DSNs with a password, including Go MySQL `user:<password>@tcp(...)` DSNs.
- Private keys, and GitHub, Slack, Stripe, Google, Anthropic, and OpenAI tokens.
- JSON Web Tokens.
- Password and secret literals in code, and in env files.

The denial message shows the category and the line numbers, not the secret value.
Secret literals, env values and DSN passwords with the exact prefix `debug_` or `test_` are permitted fixture values.
The prefixes are case-sensitive. Each match is checked separately; a fixture does not exempt another secret on the same line.
The hooks do not scan shell output, grep output, or web content.
If `jq` is missing or the input is invalid, the Claude hook allows the read.
Pi blocks reads when the scanner reports an error or exceeds its timeout, in all modes.
The scanner uses patterns; it does not detect every secret or inspect image content.
`make install-settings` registers the Claude hook. `make install-opencode-json` registers the OpenCode hook.
`make install-pi-extensions` registers the Pi hook.
Run `make test-secret-guard` to test the adapters.
Restart the OpenCode 2 service after installation to load the plugin.

## Pi Extensions

`.pi/extensions/secret-guard.ts` loads `hooks/secret-guard/pi.ts`.
The hook scans the full file before each `read`, even when the call requests only selected lines.
Sensitive reads fail in interactive, RPC, JSON, and print modes. The hook never requests approval.

`.pi/extensions/completion-sound.ts` reuses the Claude audio files through macOS `afplay`:

- Non-error completion plays `assets/audio/success.mp3`.
- A final agent error plays `assets/audio/failure.mp3`.
- Aborted responses stay silent.
- Other operating systems skip audio.

The extension uses `agent_settled`, after automatic retries, compaction, and queued work finish.
The final agent response selects the sound, not individual tool exit codes.
Use a pi version with the `agent_settled` event.

The scanner requires Bash, `grep`, `cut`, `uniq`, `head`, and `paste`.
The Pi hook does not require `jq` or Claude Code.
On a machine with Pi and Make, install both extensions for all projects:

```bash
make install-pi-extensions
```

The target creates symlinks in `~/.pi/agent/extensions/`. It also runs through `make install`.
Keep this checkout at its current path. After a move, repeat the install command.
The target respects `PI_CODING_AGENT_DIR`. To override it, pass `PI_DIR=/path/to/agent`.
Run `/reload` in pi, or restart pi.
Without global installation, pi loads these extensions only in this trusted repository.

## Installation

Install the agent customizations (requires `jq`):

```bash
make install
```

Idempotent — safe to run repeatedly. It:

- symlinks `skills/*` into `~/.claude/skills/` and `~/.agents/skills/` (OpenCode scans both trees, so one skill serves both hosts)
- symlinks the plugin command into `~/.claude/commands/pi.md` for the exact `/pi` alias
- symlinks `.claude/statusline-command.sh` into `~/.claude/`
- symlinks the pi audio and secret guard extensions into `~/.pi/agent/extensions/`
- deep-merges `.claude/config/settings.json` into `~/.claude/settings.json` (statusline, sound hooks, default mode, plugin marketplace, notifications, permission skips, cleanup period, ...). Repo values win on conflict, `permissions.allow` entries are unioned, and the previous file is backed up to `settings.json.bak`.
- deep-merges `.claude/config/claude.json` into `~/.claude.json` (Claude Code's global config — IDE auto-install and other keys that do not live in `settings.json`). Repo values win on conflict, and the previous file is backed up to `.claude.json.bak`.
- registers `.claude/plugins` as a marketplace and installs every plugin it declares via the `claude` CLI (skipped if the CLI is missing — Claude Code then auto-installs from the merged settings on next launch)

- deep-merges `.opencode/config/opencode.jsonc` into `~/.config/opencode/opencode.jsonc` (OpenCode's global config — the `external_directory` allow rules and secret guard plugin). Repo values win on conflict, and the previous file is backed up to `opencode.jsonc.bak`.

Each step is also available standalone: `make install-skills`, `install-commands`, `install-statusline`, `install-settings`, `install-claude-json`, `install-opencode-json`, `install-plugins`, `install-pi-extensions`.

## OpenCode 2 Server Setup

On macOS, export both engine variables before setup. This example selects `pi`:

```bash
export KANTHOR_DEBATE_ENGINE=pi
export KANTHOR_SUPERSAIYAN_ENGINE=pi
./scripts/setup-opencode2.sh
```

The script prompts for a password. The Basic Authentication username is `opencode`.

For non-interactive setup, pass the password through the environment:

```bash
OPENCODE2_PASSWORD='<password>' ./scripts/setup-opencode2.sh
```

The script performs these actions:

- installs `@opencode-ai/cli@beta`
- installs the OpenCode configuration and agent skills
- starts the native server on `0.0.0.0:27798`
- sets `~/Projects` as the default directory
- creates a login LaunchAgent
- makes `opencode` and `opencode2` attach through the official `--server` flag
- creates `~/.config/shell/path.sh` and loads it in Zsh and the server
- resolves standalone `.zshrc` `export PATH=` lines into absolute paths
- writes unique resolved lines into the shared file
- lists the original lines and requests confirmation before deletion

Resolution expands `~`, `$HOME`, and exported variables. Existing `$PATH` references remain dynamic.
Non-interactive setup copies unique lines but keeps the original `.zshrc` `PATH` lines.
The scanner ignores comments, prefixed commands, and other environment assignments.

Keep only shell-independent setup in the shared file. Both Bash and Zsh must accept its syntax.

Restart the server after each change:

```bash
opencode2 service restart
```

The wrapper routes `service start`, `service stop`, `service restart`, and `service status` to the same LaunchAgent.
`start` preserves an active process. `restart` replaces it. Both commands print the process ID.
`stop` sends SIGTERM and keeps the LaunchAgent registered for the next `start`.
`status` prints the LaunchAgent details, with its state and process ID when active.
These commands require the LaunchAgent from setup. They accept only help or version flags; other extra arguments fail.
`service get`, `service set`, and `service unset` still use OpenCode's native configuration commands.

Set `OPENCODE2_PROJECTS_DIR`, `OPENCODE2_PORT`, or `OPENCODE2_HOSTNAME` to override their defaults.
Set `OPENCODE2_PATH_FILE` to select another shared file.
Set `OPENCODE2_SKIP_INSTALL=1` to reuse an installed CLI.

The server accepts LAN traffic because it binds all interfaces. Install and connect Tailscale separately for remote access.

## Validation

Run the repository checks, plus the pi extension tests (Node.js 22.18 or later):

```bash
make test
```

Run only the pi extension tests without audio playback or API calls:

```bash
make test-pi-extensions
```

Run the optional real-Pi proof:

```bash
cd .claude/plugins/pi-orchestrator
npm run test:live
```

## Usage

Symlink or copy into your project's `.claude/skills/` directory:

```bash
# symlink approach
ln -s /path/to/dotagents/skills/<name> .claude/skills/<name>
```

Or add as git submodule:

```bash
git submodule add https://github.com/kanthorlabs/dotagents.git .agents
```

## `/debate` usage

```
/debate [--verbose] <your prompt>
```

Flows:
1. Claude answers the prompt (read-only).
2. The debate engine (`opencode2 run --agent plan` or `pi --print --no-session`) challenges the answer.
3. Claude merges valid critiques into a final `<original + deltas>` response.
4. Unmerged comments appear in a "Worth noting" list.

Pass `--verbose` to also see the original answer and raw engine output.

**Hard-fail conditions:** `KANTHOR_DEBATE_ENGINE` unset or invalid; engine binary missing; read-only mode unavailable; engine exits non-zero or returns empty output.

## `/supersaiyan` usage

```
/supersaiyan <your task>
```

Flows:
1. The caller writes a task packet: objective, paths, acceptance criteria, constraints, required validation.
2. `run.sh` refuses a dirty work tree, records the baseline commit, clones the repository, and runs the engine inside the clone with write access.
3. `run.sh` exports every change of the clone as one binary patch. The project stays untouched.
4. The caller reviews the patch against the packet, then `apply.sh` lands it as unstaged changes.
5. The caller runs the project checks and reverts when they fail.

Export both engine variables in the shell that runs the harness. The default setup passes both variables to the OpenCode 2 service. If `OPENCODE2_ENV_ALLOWLIST` or `OPENCODE2_ENV_VARS` is set, include both engine names explicitly.

**Isolation is not a sandbox.** The engine inherits the operating-system permissions of the caller. It can read and run anything the caller can, inside the clone and outside it.

**Hard-fail conditions:** `KANTHOR_SUPERSAIYAN_ENGINE` unset or invalid; engine binary missing; git missing; a nested run; a non-git or dirty target; engine exits non-zero; watchdog kill; empty patch; a repository that moved from the baseline.

## Adding New Skills

Each skill lives in `skills/<name>/` with:

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition with frontmatter (name, description, compatibility, loading strategy) and core rules |
| `references/` | Deferred deep-dive docs, loaded only when relevant |
| `scripts/` | Helper scripts for linting, testing, etc. |

## License

MIT — see [LICENSE](LICENSE).
