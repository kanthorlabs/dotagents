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
| `/debate` | Run an answer through an adversarial debate engine, then merge valid critiques back in. Requires `KANTHOR_DEBATE_ENGINE=opencode2\|pi`. READ-ONLY: no filesystem or state changes. |
| `/supersaiyan` | Delegate the modification to a write-mode engine, which edits an isolated clone; the caller verifies the patch and applies it. Requires `KANTHOR_SUPERSAIYAN_ENGINE=opencode2\|pi`. Harness-agnostic: any harness that runs bash. |

More skills coming.

## Claude Code Plugins

| Plugin | Description |
|--------|-------------|
| `pi-orchestrator` | Lets Claude orchestrate persistent Pi coding workers through MCP. |

Use `/pi <task>` for explicit delegation. Pi must be installed and authenticated.

## Installation

Install everything into `~/.claude` (requires `jq`):

```bash
make install
```

Idempotent — safe to run repeatedly. It:

- symlinks `skills/*` into `~/.claude/skills/` and `~/.agents/skills/` (OpenCode scans both trees, so one skill serves both hosts)
- symlinks the plugin command into `~/.claude/commands/pi.md` for the exact `/pi` alias
- symlinks `.claude/statusline-command.sh` into `~/.claude/`
- deep-merges `.claude/config/settings.json` into `~/.claude/settings.json` (statusline, sound hooks, default mode, plugin marketplace, notifications, permission skips, cleanup period, ...). Repo values win on conflict, `permissions.allow` entries are unioned, and the previous file is backed up to `settings.json.bak`.
- deep-merges `.claude/config/claude.json` into `~/.claude.json` (Claude Code's global config — IDE auto-install and other keys that do not live in `settings.json`). Repo values win on conflict, and the previous file is backed up to `.claude.json.bak`.
- registers `.claude/plugins` as a marketplace and installs every plugin it declares via the `claude` CLI (skipped if the CLI is missing — Claude Code then auto-installs from the merged settings on next launch)

- deep-merges `.opencode/config/opencode.jsonc` into `~/.config/opencode/opencode.jsonc` (OpenCode's global config — the `external_directory` allow rules the skills need). Repo values win on conflict, and the previous file is backed up to `opencode.jsonc.bak`.

Each step is also available standalone: `make install-skills`, `install-commands`, `install-statusline`, `install-settings`, `install-claude-json`, `install-opencode-json`, `install-plugins`.

## OpenCode 2 Server Setup

On macOS, run the setup script:

```bash
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
launchctl kickstart -k "gui/$(id -u)/ai.opencode.opencode2"
```

Set `OPENCODE2_PROJECTS_DIR`, `OPENCODE2_PORT`, or `OPENCODE2_HOSTNAME` to override their defaults.
Set `OPENCODE2_PATH_FILE` to select another shared file.
Set `OPENCODE2_SKIP_INSTALL=1` to reuse an installed CLI.

The server accepts LAN traffic because it binds all interfaces. Install and connect Tailscale separately for remote access.

## Validation

Run plugin validation, the debate script tests, and deterministic bridge tests:

```bash
make test
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

Export `KANTHOR_SUPERSAIYAN_ENGINE` in the shell that runs the harness. Add the name to `OPENCODE2_ENV_VARS` before `scripts/setup-opencode2.sh` when the OpenCode 2 service must also see it.

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
