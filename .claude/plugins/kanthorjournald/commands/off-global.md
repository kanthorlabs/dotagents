---
description: Disable kanthorjournald for ALL future sessions (global off)
allowed-tools: Read, Write, Edit
---

Set global disablement in the kanthorjournald state file.

1. Try to Read `~/.kanthorlabs/kanthorjournald/state.json`.
2. If it exists: parse it, set `"global_enabled": false`, Edit it back. Preserve `disabled_sessions` if present.
3. If it does NOT exist: Write a new file with content:
   ```json
   {
     "global_enabled": false,
     "disabled_sessions": []
   }
   ```

Then tell the user: "kanthorjournald disabled globally. Re-enable with /kanthorjournald:on-global."
