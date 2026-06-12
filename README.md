# dotagents

Opinionated `.agents` setup — curated skills, sub-agents, and references for Claude Code. Drop them into any project to get consistent, high-quality AI assistance tuned to how I work.

## Repository Structure

```
dotagents/
├── .claude/
│   └── commands/
│       └── <command-name>.md   # Slash command definitions
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
| [maestro](skills/maestro/) | Author, run, and debug Maestro UI test flows for mobile and web. Activate for `.yaml` flows, `maestro test`/`cloud`/`studio`, or E2E tests targeting Android/iOS/web via Maestro. Requires `maestro` CLI on PATH. |
| [seniorgo](skills/seniorgo/) | Senior Go developer — code review, refactoring, testing, performance. Effective Go 2026 guidelines. Requires Go 1.22+ |

More skills coming.

## Installation

Install everything into `~/.claude` (requires `jq`):

```bash
make install
```

Idempotent — safe to run repeatedly. It:

- symlinks `skills/*` into `~/.claude/skills/`
- symlinks `.claude/commands/*.md` into `~/.claude/commands/`
- symlinks `.claude/statusline-command.sh` into `~/.claude/`
- deep-merges `config/settings.json` into `~/.claude/settings.json` (statusline, sound hooks, default mode, plugin marketplace, notifications, permission skips, cleanup period, ...). Repo values win on conflict, `permissions.allow` entries are unioned, and the previous file is backed up to `settings.json.bak`.

Each step is also available standalone: `make install-skills`, `install-commands`, `install-statusline`, `install-settings`.

## Usage

Symlink or copy into your project's `.claude/skills/` directory:

```bash
# symlink approach
ln -s /path/to/dotagents/skills/seniorgo .claude/skills/seniorgo
```

Or add as git submodule:

```bash
git submodule add https://github.com/kanthorlabs/dotagents.git .agents
```

## Commands

Slash commands live in `.claude/commands/`. Symlink or copy the directory into your project:

```bash
ln -s /path/to/dotagents/.claude/commands .claude/commands
```

| Command | Description |
|---------|-------------|
| `/debate` | Run an answer through an adversarial debate engine, then merge valid critiques back in. Requires `KANTHOR_DEBATE_ENGINE=opencode\|codex`. READ-ONLY: no filesystem or state changes. |

### `/debate` usage

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
