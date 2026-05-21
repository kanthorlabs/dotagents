# kanthorjournald

Claude Code plugin that forces the coding assistant to journal every off-spec
decision, tradeoff, assumption, and deferred TODO into a per-session markdown
file. Both the human-review brief and the correctness validation are
**user-invoked** commands that operate over the **entire session**, not just
the latest turn.

## What it does

1. **`UserPromptSubmit` hook** — injects an instruction telling Claude to
   append a journal section to
   `~/.kanthorlabs/kanthorjournald/journals/<project-key>/<session-id>.md`
   before finishing the turn. `<project-key>` is `<basename(cwd)>-<md5(cwd)>`,
   so journals are scoped per working directory.
2. **`/kanthorjournald:brief`** — user-invoked 80/20 summary of the
   **whole session's** journal (all turns), surfacing the items most worth
   a human's attention.
3. **`/kanthorjournald:validate`** — user-invoked command that checks the
   **whole session's** work against the user's requests turn-by-turn,
   cross-referencing the actual code (not just the journal text).
4. **Toggle controls** — slash commands flip state files under
   `~/.kanthorlabs/kanthorjournald/state.json`.

> Data lives **outside `~/.claude/`** because Claude Code's sensitive-file
> guard blocks writes/deletes under that tree, including the journal file
> Claude itself must append to.

## Slash commands

Plugin commands are namespaced. Use the `/kanthorjournald:` prefix:

| Command | Effect |
|---|---|
| `/kanthorjournald:install` | One-time setup: provision `~/.kanthorlabs/kanthorjournald/` (data dir + default `state.json`) and merge required permissions into `~/.claude/settings.json` |
| `/kanthorjournald:status` | Show global + per-session state and list journals for the **current project**. Pass `--all` to list every project. |
| `/kanthorjournald:brief` | 80/20 summary of the whole session's journal (all turns) |
| `/kanthorjournald:validate` | Validate whether the whole session's work matches the user's requests |
| `/kanthorjournald:off-global` | Disable journaling for all sessions |
| `/kanthorjournald:on-global` | Re-enable journaling globally (default) |
| `/kanthorjournald:off-session` | Disable journaling for the current session only |

Default = on.

## Install

This repo doubles as a **local plugin marketplace** rooted at
`.claude/plugins/`. Pick one method:

### Option A — one-shot session (no install)

Launch a session with the plugin auto-loaded:

```bash
claude --plugin-dir /Users/tuanatelsa/Projects/kanthorlabs/dotagents/.claude/plugins/kanthorjournald
```

Hooks + commands are active only for that session. Good for iteration.

### Option B — persistent install via local marketplace (recommended)

Inside any Claude Code session:

```
/plugin marketplace add /Users/tuanatelsa/Projects/kanthorlabs/dotagents/.claude/plugins
/plugin install kanthorjournald@claude.kanthorlabs.com
```

The first command registers the marketplace defined at
`.claude/plugins/.claude-plugin/marketplace.json`. The second installs the
plugin from it. After that, every new Claude Code session loads it
automatically.

Verify with:

```
/plugin
```

→ opens the plugin manager. Your plugin should be in the **Installed** tab.

After editing hook scripts or command files, reload without restarting:

```
/reload-plugins
```

### Provision assets + pre-approve permissions (one command)

Plugins can't ship auto-applied permissions or pre-create files outside the
plugin tree (security boundary). The install command handles both.

**Recommended — run the install command** (after `/plugin install`):

```
/kanthorjournald:install
```

This does two things, in order:

1. **Prepares the data tree** — creates `~/.kanthorlabs/kanthorjournald/journals/`
   and, if missing, writes a default `state.json`:
   ```json
   { "global_enabled": true, "disabled_sessions": [] }
   ```
   An existing `state.json` is left untouched (the command is idempotent).
2. **Merges permissions** — reads `~/.claude/settings.json`, shows you the
   diff it will add, then merges these entries into `permissions.allow`:
   ```
   Read(~/.kanthorlabs/kanthorjournald/**)
   Edit(~/.kanthorlabs/kanthorjournald/**)
   Write(~/.kanthorlabs/kanthorjournald/**)
   ```
   Claude Code's sensitive-file guard will fire on `~/.claude/settings.json` —
   review the proposed edit and approve. Pick "allow always" if you want to
   re-run the command later without re-prompting.

**Manual alternative** — create the dir yourself and paste the permissions
into `~/.claude/settings.json`:

```bash
mkdir -p ~/.kanthorlabs/kanthorjournald/journals
```

```json
{
  "permissions": {
    "allow": [
      "Read(~/.kanthorlabs/kanthorjournald/**)",
      "Edit(~/.kanthorlabs/kanthorjournald/**)",
      "Write(~/.kanthorlabs/kanthorjournald/**)"
    ]
  }
}
```

Merge with existing `permissions.allow` if present. `**` recursively matches
all nested paths; `~/` anchors at home. No Bash grants needed — slash
commands operate via Claude's Read/Edit/Write/Glob tools against a single
state file `state.json` in that directory. Hooks themselves run as
subprocesses outside the tool-permission system.

## Test

Smoke-test hooks directly on dummy input:

```bash
echo '{"session_id":"test-123","hook_event_name":"UserPromptSubmit","prompt":"x"}' \
  | .claude/plugins/kanthorjournald/hooks/on-user-prompt.sh
# → JSON with hookSpecificOutput.additionalContext
```

Journal file should appear at
`~/.kanthorlabs/kanthorjournald/journals/<project-key>/test-123.md`
where `<project-key>` = `<basename(cwd)>-<md5(cwd)>`.

Then in a real Claude Code session:

```
> implement a function that adds two numbers
# Claude appends a journal section before finishing.
# Run /kanthorjournald:brief to see an 80/20 summary across the whole session.
# Run /kanthorjournald:validate to cross-check the whole session's work against requests.

> /kanthorjournald:status
> /kanthorjournald:off-session
> /kanthorjournald:off-global
> /kanthorjournald:on-global
```

## Troubleshooting

- **Commands don't appear** — confirm `/plugin` shows it installed; if not,
  re-run `/plugin marketplace add` with the path to `.claude/plugins`
  (the parent dir that holds `.claude-plugin/marketplace.json`), then
  `/plugin install`. Symlinks + `enabledPlugins` in `settings.json` do
  **not** work — that key is not how Claude Code discovers plugins.
- **Hooks don't fire** — run `/reload-plugins`; check
  `~/.claude/plugins/data/kanthorjournald/journals/` for new files after
  sending a prompt.
- **`${CLAUDE_PLUGIN_ROOT}` not expanded** — your CLI may be older; replace
  with absolute paths in `hooks/hooks.json`.

## Data layout

```
~/.kanthorlabs/kanthorjournald/
├── state.json                                # { global_enabled, disabled_sessions[] }
└── journals/
    └── <project-key>/                        # <basename(cwd)>-<md5(absolute cwd)>
        ├── current-session.txt               # latest session_id for THIS project
        └── <session-id>.md                   # the journal itself
```

`<project-key>` scopes journals per working directory so concurrent Claude
Code sessions in different projects don't stomp on each other. The md5 of
the absolute path disambiguates two projects that share a basename
(e.g. `~/work/api` vs `~/personal/api`).

## Repo layout

```
.claude/plugins/
├── .claude-plugin/
│   └── marketplace.json                      # marketplace manifest (this repo)
└── kanthorjournald/
    ├── .claude-plugin/plugin.json            # plugin manifest
    ├── hooks/
    │   ├── hooks.json
    │   └── on-user-prompt.sh
    ├── commands/
    │   ├── install.md        → /kanthorjournald:install
    │   ├── status.md         → /kanthorjournald:status
    │   ├── brief.md          → /kanthorjournald:brief
    │   ├── validate.md       → /kanthorjournald:validate
    │   ├── off-global.md     → /kanthorjournald:off-global
    │   ├── on-global.md      → /kanthorjournald:on-global
    │   └── off-session.md    → /kanthorjournald:off-session
    └── README.md
```
