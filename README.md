# dotagents

Opinionated `.agents` setup — curated skills, sub-agents, and references for Claude Code. Drop them into any project to get consistent, high-quality AI assistance tuned to how I work.

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
| [seniorgo](skills/seniorgo/) | Senior Go developer — code review, refactoring, testing, performance. Effective Go 2026 guidelines. Requires Go 1.22+ |

More skills coming.

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

## Adding New Skills

Each skill lives in `skills/<name>/` with:

| File | Purpose |
|------|---------|
| `SKILL.md` | Skill definition with frontmatter (name, description, compatibility, loading strategy) and core rules |
| `references/` | Deferred deep-dive docs, loaded only when relevant |
| `scripts/` | Helper scripts for linting, testing, etc. |

## License

MIT — see [LICENSE](LICENSE).
