# dotagents

Opinionated `.agents` setup — curated skills, sub-agents, and references for Claude Code. Drop them into any project to get consistent, high-quality AI assistance tuned to how I work.

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
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md        # Skill definition & core rules
│       ├── references/     # Deferred reference docs (loaded on-demand)
│       └── scripts/        # Helper scripts (lint, test, etc.)
├── LICENSE
└── README.md
```

## Skills

| Skill | Description |
|-------|-------------|
| `/debate` | Run an answer through an adversarial debate engine, then merge valid critiques back in. Requires `KANTHOR_DEBATE_ENGINE=opencode\|codex\|pi`. READ-ONLY: no filesystem or state changes. |

More skills coming.

## Installation

Install everything into `~/.claude` (requires `jq`):

```bash
make install
```

Idempotent — safe to run repeatedly. It:

- symlinks `skills/*` into `~/.claude/skills/` and `~/.agents/skills/` (OpenCode scans both trees, so one skill serves both hosts)
- symlinks `.claude/statusline-command.sh` into `~/.claude/`
- deep-merges `.claude/config/settings.json` into `~/.claude/settings.json` (statusline, sound hooks, default mode, plugin marketplace, notifications, permission skips, cleanup period, ...). Repo values win on conflict, `permissions.allow` entries are unioned, and the previous file is backed up to `settings.json.bak`.
- deep-merges `.claude/config/claude.json` into `~/.claude.json` (Claude Code's global config — IDE auto-install and other keys that do not live in `settings.json`). Repo values win on conflict, and the previous file is backed up to `.claude.json.bak`.
- registers `.claude/plugins` as a marketplace and installs every plugin it declares via the `claude` CLI (skipped if the CLI is missing — Claude Code then auto-installs from the merged settings on next launch)

- deep-merges `.opencode/config/opencode.jsonc` into `~/.config/opencode/opencode.jsonc` (OpenCode's global config — the `external_directory` allow rules the skills need). Repo values win on conflict, and the previous file is backed up to `opencode.jsonc.bak`.

Each step is also available standalone: `make install-skills`, `install-statusline`, `install-settings`, `install-claude-json`, `install-opencode-json`, `install-plugins`.

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
2. The debate engine (`opencode --agent plan` or `codex exec --sandbox read-only`) challenges the answer.
3. Claude merges valid critiques into a final `<original + deltas>` response.
4. Unmerged comments appear in a "Worth noting" list.

Pass `--verbose` to also see the original answer and raw engine output.

**Hard-fail conditions:** `KANTHOR_DEBATE_ENGINE` unset or invalid; engine binary missing; read-only mode unavailable; engine exits non-zero or returns empty output.

## Adding New Skills

Each skill lives in `skills/<name>/` with:

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition with frontmatter (name, description, compatibility, loading strategy) and core rules |
| `references/` | Deferred deep-dive docs, loaded only when relevant |
| `scripts/` | Helper scripts for linting, testing, etc. |

## License

MIT — see [LICENSE](LICENSE).
