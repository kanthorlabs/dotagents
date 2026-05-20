---
description: Merge kanthorjournald permissions into ~/.claude/settings.json (review + approve once)
allowed-tools: Read, Write, Edit
---

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

> kanthorjournald permissions installed. Restart Claude Code (or run
> `/reload-plugins`) for them to take effect. Verify with
> `/kanthorjournald:status`.

If anything fails (parse error, unexpected structure), do NOT overwrite —
show the user the current `permissions` block and the exact lines to add
manually, then stop.
