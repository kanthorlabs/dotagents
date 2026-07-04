---
description: Re-enable kanthorjournald globally (default state)
allowed-tools: Read, Write, Edit
model: claude-sonnet-4-6
---

Set global enablement in the kanthorjournald state file.

1. Try to Read `~/.kanthorlabs/kanthorjournald/state.json`.
2. If it exists: parse it, set `"global_enabled": true`, Edit it back. Preserve `disabled_sessions` if present.
3. If it does NOT exist: Write a new file with content:
   ```json
   {
     "global_enabled": true,
     "disabled_sessions": []
   }
   ```

Then tell the user: "kanthorjournald enabled globally."
