---
description: Show kanthorjournald enable status and journals (id + absolute path)
allowed-tools: Read, Glob
---

Report kanthorjournald state without using Bash.

1. Try to Read `~/.kanthorlabs/kanthorjournald/state.json`. If missing, treat as `{"global_enabled": true, "disabled_sessions": []}`.
2. Use Glob with pattern `~/.kanthorlabs/kanthorjournald/journals/*.md` to list journal files.
3. Output exactly this format (markdown):

```
=== kanthorjournald status ===

Enabled (global): YES (default)    # or "NO (disabled)"

Per-session disabled ids:
  - <id>                            # or "  (none)"

Journals:
  - <id>
      <absolute path>
```

If lists are empty, print `  (none)` / `  (none yet)`. Do not re-summarize after the block.
