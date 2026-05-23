---
description: Compact all past-session journals for this project into one brief file, moving the originals to .trash/
allowed-tools: Read, Write, Bash
model: claude-sonnet-4-6
---

Replace the project's accumulated session journals with a single brief file, while preserving the originals in a trash dir so the operation is reversible.

## Procedure

1. Run this Bash one-liner to compute the current project key:
   ```
   python3 -c 'import os,hashlib; c=os.getcwd(); print(os.path.basename(c.rstrip("/"))+"-"+hashlib.md5(c.encode()).hexdigest())'
   ```
   Call the output `<project-key>`. Define `JDIR=~/.kanthorlabs/kanthorjournald/journals/<project-key>`.

2. Resolve the **current session id** so we can exclude it from compaction (deleting the active journal would break the running append hook):
   ```
   cat "$JDIR/current-session.txt" 2>/dev/null
   ```
   Call the output `<current-id>`. If the file is missing or empty, **abort** with a clear message — do not guess.

3. Build the list of journals to compact (exclude current session and any prior compaction artifacts? No — include prior `compacted-*.md` files so the brief stays cumulative):
   ```
   ls -tr "$JDIR"/*.md 2>/dev/null
   ```
   From that list, drop the entry whose basename is `<current-id>.md`. Call the remainder `<to-compact>`.

   - If `<to-compact>` is empty, say so plainly and stop (nothing to compact).

4. Read every file in `<to-compact>` in full.

5. Produce a compacted brief over the union of all those files. Two parts:

   **Part A — 80/20 findings** (same risk lens as `/brief`, ~20% of items carrying ~80% of review risk):
   - silently changed behavior the user didn't ask for
   - picked one design over another without user input
   - introduced an assumption that could be wrong
   - deferred work the user might assume was done
   - chose a library/version/config without user steering

   Collapse recurring findings across sessions to one line, citing where they appeared (e.g. `sess-a:t2, sess-b:t1,4`).

   **Part B — Full tradeoff & assumption log** (learning corpus, NOT 80/20-filtered):
   - Preserve EVERY distinct entry from the `### Tradeoffs` and `### Assumptions` sections of every turn.
   - Only collapse exact or near-exact duplicates across turns/sessions; cite all locations.
   - Do NOT drop a tradeoff or assumption because it looks minor — these are the signal future runs learn from. If compaction loses these, compaction is broken.

6. Compute `STAMP=$(date -u +%Y%m%dT%H%M%SZ)`. Write the brief to `$JDIR/compacted-$STAMP.md` using this template:

   ```
   # Compacted brief — <project-key>
   _Generated <STAMP> UTC_
   _Sources: <M> session journals (<N> turns total)_
   _Source files (now in .trash/<STAMP>/):_
   - <basename-1>.md
   - <basename-2>.md
   - ...

   ## Journal brief — <project-key> (80/20 findings + full tradeoff/assumption log, compacted across <M> sessions / <N> turns)

   **🔴 Needs review (highest risk)**
   - <item> — _<why>_ (<sess>:t<n>)

   **🟡 Worth confirming**
   - <item> — _<why>_ (<sess>:t<n>)

   **🔀 Tradeoffs picked** _(full log — learning corpus)_
   - <picked X over Y> — _<why>_ (<sess>:t<n>)
   - ...

   **❓ Assumptions filled in** _(full log — learning corpus)_
   - <assumption> (<sess>:t<n>)
   - ...

   **🟢 Skipped from brief**
   - <count> low-risk items across <M> sessions / <N> turns
   ```

7. Move the originals into a timestamped trash subdir (reversible — do **not** `rm`):
   ```
   mkdir -p "$JDIR/.trash/$STAMP"
   ```
   Then, for each file in `<to-compact>`, run:
   ```
   mv "<file>" "$JDIR/.trash/$STAMP/"
   ```
   (Run as individual `mv`s or one batched command — either is fine.)

8. Print a final summary to the user:
   - Path of the new `compacted-<STAMP>.md`
   - Count of files moved
   - Path of the trash dir (e.g. `~/.kanthorlabs/kanthorjournald/journals/<project-key>/.trash/<STAMP>/`)
   - Reminder that the trash dir can be purged manually with `rm -rf` when confirmed safe

## Guardrails

- **Never** touch `$JDIR/current-session.txt` or `$JDIR/<current-id>.md`.
- **Never** use `rm` on journal files — only `mv` into `.trash/`.
- If any step fails (missing project key, missing current-session.txt, no files to compact, write error), abort before the move step so no journals are touched.
- The `.trash/` dir itself is excluded from future briefs/compactions because it's a directory; `*.md` glob at the dir level won't descend into it.
