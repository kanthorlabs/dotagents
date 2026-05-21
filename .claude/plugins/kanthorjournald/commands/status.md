---
description: Show kanthorjournald enable status and journals (id + absolute path)
allowed-tools: Read, Glob, Bash
model: claude-haiku-4-5-20251001
argument-hint: "[--all]"
---

Report kanthorjournald state. **Default = current project only.** Pass `--all` (via `$ARGUMENTS`) to list every project.

ARGS: `$ARGUMENTS`

1. Run this Bash one-liner to compute the current project key (basename + md5 of absolute cwd):

   ```
   python3 -c 'import os,hashlib; c=os.getcwd(); print(os.path.basename(c.rstrip("/"))+"-"+hashlib.md5(c.encode()).hexdigest()); print(c)'
   ```

   First line of output is `<project-key>`. Second line is the current `<cwd>`. Keep both for the output.

2. Try to Read `~/.kanthorlabs/kanthorjournald/state.json`. If missing, treat as `{"global_enabled": true, "disabled_sessions": []}`.

3. **If `$ARGUMENTS` contains `--all`:**
   - Glob `~/.kanthorlabs/kanthorjournald/journals/*/*.md` (only matches project-scoped journals; legacy flat files at the root are intentionally excluded).
   - Group results by their parent directory (= project key).

4. **Otherwise (default — current project):**
   - Glob `~/.kanthorlabs/kanthorjournald/journals/<project-key>/*.md`.

5. Output format (markdown):

   **Default scope:**
   ```
   === kanthorjournald status ===

   Enabled (global): YES (default)    # or "NO (disabled)"

   Per-session disabled ids:
     - <id>                            # or "  (none)"

   Project: <cwd>
   Project key: <project-key>
   Sessions:
     - <session-id>
         <absolute path>
   ```

   **`--all` scope:**
   ```
   === kanthorjournald status (all projects) ===

   Enabled (global): YES (default)

   Per-session disabled ids:
     - <id>

   Projects:
     <project-key>
       - <session-id>
           <absolute path>
     <project-key>
       - <session-id>
           <absolute path>
   ```

If lists are empty, print `  (none)` / `  (none yet)`. Do not re-summarize after the block.
