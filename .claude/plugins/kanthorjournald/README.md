# kanthorjournald

Claude Code plugin that forces the coding assistant to journal every off-spec
decision, tradeoff, assumption, and deferred TODO into a per-session markdown
file. At the end of every turn, the assistant is forced to surface a brief of
what it did so the human can review. Correctness validation is a separate,
user-invoked command.

## What it does

1. **`UserPromptSubmit` hook** — injects an instruction telling Claude to
   append a journal section to `~/.kanthorlabs/kanthorjournald/journals/<session-id>.md`
   before finishing the turn.
2. **`Stop` hook** — blocks once per turn, telling Claude to read the latest
   turn section in the journal and print a concise brief of what it did
   (decisions, changes, tradeoffs, assumptions, deferred work). No
   self-validation. Self-loop is prevented via `stop_hook_active`.
3. **`/kanthorjournald:validate`** — user-invoked command that checks the
   latest turn's work against the user's request, cross-referencing the
   actual code (not just the journal text).
4. **Toggle controls** — slash commands flip state files under
   `~/.kanthorlabs/kanthorjournald/state.json`.

> Data lives **outside `~/.claude/`** because Claude Code's sensitive-file
> guard blocks writes/deletes under that tree, including the journal file
> Claude itself must append to.

## Slash commands

Plugin commands are namespaced. Use the `/kanthorjournald:` prefix:

| Command | Effect |
|---|---|
| `/kanthorjournald:install` | One-time setup: merge required permissions into `~/.claude/settings.json` |
| `/kanthorjournald:status` | Show global + per-session state and list journals |
| `/kanthorjournald:brief` | 80/20 summary of the current session's journal |
| `/kanthorjournald:validate` | Validate whether the latest turn's work matches the user's request |
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

### Pre-approve permissions (skip per-session prompts)

Plugins can't ship auto-applied permissions (security boundary). Two ways:

**Recommended — run the install command** (after `/plugin install`):

```
/kanthorjournald:install
```

This reads `~/.claude/settings.json`, shows you the diff it will add, then
merges these entries into `permissions.allow`:

```
Read(~/.kanthorlabs/kanthorjournald/**)
Edit(~/.kanthorlabs/kanthorjournald/**)
Write(~/.kanthorlabs/kanthorjournald/**)
```

Claude Code's sensitive-file guard will fire on `~/.claude/settings.json` —
review the proposed edit and approve. Pick "allow always" if you want to
re-run the command later without re-prompting.

**Manual alternative** — paste this once into `~/.claude/settings.json`:

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

echo '{"session_id":"test-123","hook_event_name":"Stop","stop_hook_active":false}' \
  | .claude/plugins/kanthorjournald/hooks/on-stop.sh
# → JSON {"decision":"block", ...}
```

Journal file should appear at
`~/.kanthorlabs/kanthorjournald/journals/test-123.md`.

Then in a real Claude Code session:

```
> implement a function that adds two numbers
# Claude appends a journal section before finishing.
# On Stop, Claude is forced to print a brief of what it did this turn.
# Run /kanthorjournald:validate to verify the turn's work matches the request.

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
├── current-session.txt                       # latest session_id (for /off-session)
├── .runtime/                                 # hook-internal markers
│   ├── pending-brief-<id>                   # tracks "Stop must block once"
│   └── skip-stop-<id>                        # set when prompt was /kanthorjournald:*
└── journals/
    └── <session-id>.md                       # the journal itself
```

## Repo layout

```
.claude/plugins/
├── .claude-plugin/
│   └── marketplace.json                      # marketplace manifest (this repo)
└── kanthorjournald/
    ├── .claude-plugin/plugin.json            # plugin manifest
    ├── hooks/
    │   ├── hooks.json
    │   ├── on-user-prompt.sh
    │   └── on-stop.sh
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
