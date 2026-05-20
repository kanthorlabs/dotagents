---
description: Prepare kanthorjournald data dir and merge permissions into ~/.claude/settings.json (review + approve once)
allowed-tools: Read, Write, Edit, Bash
---

One-time setup for kanthorjournald. Two things to do, in order:

## Step 1 — Prepare data assets

Create the data directory tree so hooks and slash commands have somewhere to
read/write from day one (without depending on the first prompt to trigger
`mkdir -p` inside the hook):

1. Run `mkdir -p ~/.kanthorlabs/kanthorjournald/journals`.
2. If `~/.kanthorlabs/kanthorjournald/state.json` does not exist, Write it
   with the default:
   ```json
   {
     "global_enabled": true,
     "disabled_sessions": []
   }
   ```
   Do NOT overwrite an existing `state.json` — the user may have
   per-session disables in it.
3. Confirm the layout to the user:
   ```
   ~/.kanthorlabs/kanthorjournald/
   ├── state.json
   └── journals/
   ```

## Step 2 — Merge permissions into `~/.claude/settings.json`

Merge kanthorjournald's required permissions into the user's Claude Code
settings, so future sessions don't prompt for journal-file access.

The required allow entries are:

```
Read(~/.kanthorlabs/kanthorjournald/**)
Edit(~/.kanthorlabs/kanthorjournald/**)
Write(~/.kanthorlabs/kanthorjournald/**)
```

Do this carefully:

1. Read `~/.claude/settings.json`.
   - If the file does not exist, prepare to Write a new file with content:
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
2. If the file exists:
   - If there is no top-level `permissions` key, Edit the file to add one
     containing the 3 entries above.
   - If `permissions.allow` already exists, Edit it to insert only the
     entries that are not already present (dedupe by exact string match).
     Preserve existing entries, key order, indentation, and any trailing
     comments.
3. Before writing, show the user the **diff** you intend to apply (the
   added lines only). Then apply it.
4. Claude Code will trigger a sensitive-file approval prompt on
   `~/.claude/settings.json`. Tell the user up front: "Approve the prompt
   to apply. Choose 'allow always' if you want to re-run this command
   later without re-prompting."

After writing, tell the user:

> kanthorjournald installed (data dir prepared + permissions merged).
> Restart Claude Code (or run `/reload-plugins`) for them to take effect.
> Verify with `/kanthorjournald:status`.

If anything fails (parse error, unexpected structure), do NOT overwrite —
show the user the current `permissions` block and the exact lines to add
manually, then stop. The data-dir step is safe to leave in place even if
permission merging is skipped.
