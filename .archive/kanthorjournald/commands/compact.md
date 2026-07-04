---
description: Compact all past-session journals for this project into one brief file, moving the originals to .trash/
allowed-tools: Read, Write, Bash, Glob, Grep
model: claude-sonnet-4-6
---

Replace the project's accumulated session journals with a single brief file, while preserving the originals in a trash dir so the operation is reversible.

## Parameters

- `--max-files <N>` — maximum number of past-session journals to include in this compaction run (default: `10`). Selects the **N most-recent** eligible files (by mtime, excluding the current session and `.trash/`). If fewer than N eligible files exist, compact all of them.
- `--compacted-only` — instead of raw session journals, select only existing `compacted-*.md` files as candidates. Use this to merge previous compaction briefs into a single cumulative brief. Mutually exclusive with the default raw-session mode.

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

3. Build the list of journals to compact from the full `*.md` listing:
   ```
   ls -tr "$JDIR"/*.md 2>/dev/null
   ```
   Then filter based on the active mode:

   - **Default (raw-session mode):** drop the entry whose basename is `<current-id>.md` AND any entry whose basename starts with `compacted-`. Only raw session journals remain.
   - **`--compacted-only` mode:** keep ONLY entries whose basename starts with `compacted-`. Drop everything else (including `<current-id>.md`).

   Call the remainder `<candidates>`.

   Apply the `--max-files` limit: take only the **last N entries** of `<candidates>` (most recent by mtime). Call the result `<to-compact>`.

   - If `<to-compact>` is empty, say so plainly and stop (nothing to compact).
   - If `--max-files` was not supplied by the user, use `N=10`.

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

5b. **Self-validation pass against the current project state** (advisory — failures here NEVER abort the archive). Use Grep/Glob/Read plus `git log --oneline -20` and `git diff` to check the *current* working tree (the journals span older sessions; the project has moved on). In `--compacted-only` mode, run this pass fresh — do NOT trust any verdicts embedded in prior briefs.

   **A. Validate each 🔴 Needs review and 🟡 Worth confirming item.** Assign exactly one of three states; never default uncertainty to "valid":

   - **valid** — there is positive current-tree evidence the concern is still live. Keep the item; append `_still valid because <evidence: file:line or commit>_` and a `→ Recommend:` line: a **first triage action** the user can finish in **<1 hour and ≤2 steps** (e.g. write a repro test, add a guard, open an issue). The recommendation is the first de-risking step, NOT necessarily the full fix.
   - **invalid** — there is positive evidence the concern is resolved, moot, or was never applied. **Remove it from the brief entirely** (it must not appear in 🔴/🟡 or anywhere in the file). Record it as a one-line note **for the terminal summary only** (step 8), with the evidence.
   - **unverified** — neither valid nor invalid can be proven from the tree. **Keep it**, marked `_unverified against current tree; needs human confirmation_`, with a `→ Recommend:` confirmation action (<1hr, ≤2 steps). Never silently drop an unverified item and never relabel it "valid".

   If this pass cannot run (tool error, no working tree, etc.): skip validation, write the brief unchanged, and label the 🔴/🟡 sections `⚠️ not validated against current project state` so the output never *implies* validation happened.

   **B. Validate each 🔀 Tradeoff and ❓ Assumption for fit with the current project.** Keep EVERY entry in the Part B full log regardless (the learning-corpus invariant from step 5 still holds). Additionally classify each against concrete signals — existing repo rules in `AGENTS.md`, patterns repeated across journals, current architecture/test/build/dependency config, and any tree/journal evidence of rework or a bug it caused:

   - **fits the project / good recurring pattern** → emit a **promote-to-rule** suggestion: the target file and the exact rule text to add.
   - **misfit that led to wrong behavior** (cite the evidence) → emit a **prohibit-rule** suggestion: target file + exact `Never …` / `Don't …` text.
   - **neither** → no suggestion.

   Rule target: default to `AGENTS.md` (this project's rules). Suggest `~/.claude/CLAUDE.md` only when the user would want the rule machine-wide — do not assume it.

   **Every rule candidate MUST use the format `<name>: <rule>`** — a short kebab-case `<name>` (searchable handle) followed by the one-line imperative `<rule>` the user can hand to the AI verbatim. Naming each rule makes the candidates greppable and lets them graduate into a runbook once enough accumulate. Example: `commit-trailer: Always end commit messages with the Claude-Session trailer.`

6. Compute `STAMP=$(date -u +%Y%m%dT%H%M%SZ)`. Write the brief to `$JDIR/compacted-$STAMP.md` using this template (the 🔴/🟡 items below already reflect the step 5b filtering — `invalid` items are NOT written to the file; rule candidates ARE):

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
   - <item> — _still valid because <evidence: file:line/commit>_ (<sess>:t<n>)
     → Recommend: <first triage action — ≤2 steps, <1hr; not necessarily the full fix>

   **🟡 Worth confirming**
   - <item> — _unverified against current tree; needs human confirmation_ (<sess>:t<n>)
     → Recommend: <≤2 steps, <1hr confirmation action>

   **🔀 Tradeoffs picked** _(full log — learning corpus)_
   - <picked X over Y> — _<why>_ (<sess>:t<n>)
   - ...

   **❓ Assumptions filled in** _(full log — learning corpus)_
   - <assumption> (<sess>:t<n>)
   - ...

   **📐 Rule candidates** _(suggestions — NOT rules; a human must apply them; format `<name>: <rule>`)_
   - Promote: add to AGENTS.md → "<name>: <exact one-line rule>"   (from <sess>:t<n>)
   - Prohibit: add to AGENTS.md → "<name>: Never <exact behavior>"  (caused <wrong behavior>, <sess>:t<n>)

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
   - Count of files compacted / moved (and total eligible if `--max-files` limited the run, e.g. `"3 of 7 eligible files (--max-files 3)"`)
   - Path of the trash dir (e.g. `~/.kanthorlabs/kanthorjournald/journals/<project-key>/.trash/<STAMP>/`)
   - Reminder that the trash dir can be purged manually with `rm -rf` when confirmed safe
   - If not all eligible files were included, note how many remain and suggest re-running to compact them
   - **Self-validation results** (from step 5b — terminal only; do not write these into any file):

     ```
     **✅ Validated — action recommended**
     - <item> → <≤2-step, <1hr first triage action>

     **❔ Unverified — needs human confirmation**
     - <item> → <confirmation action>

     **📝 Invalidated notes** (<count>)   ← discarded from the brief; surfaced here only
     - <item> — no longer valid because <evidence>

     **📐 Rule candidates** _(format `<name>: <rule>`)_
     - Promote: AGENTS.md → "<name>: <exact rule>"
     - Prohibit: AGENTS.md → "<name>: Never <…>"
     ```

     Omit any sub-section that has no entries (don't print empty headers). If the step 5b pass was skipped, say so plainly here instead.

## Guardrails

- **Destructive journal ops are blocked by the `guard-journals.sh` PreToolUse hook** (defense-in-depth, every session): deletes under the journals dir, and overwrite/move/delete of the live journal or `current-session.txt`. **Appends to the current journal stay allowed** (that's the plugin's job). The hook is best-effort, not a sandbox — the real guarantee is the reversible `mv`-to-`.trash/` design below.
  - Never `rm` journal files — only `mv` into `.trash/`.
  - Never overwrite/move/delete `$JDIR/current-session.txt` or the live `$JDIR/<current-id>.md`.
- If any step fails (missing project key, missing current-session.txt, no files to compact, write error), abort before the move step so no journals are touched. **Exception:** the step 5b self-validation pass is advisory — if it fails, do NOT abort; write the brief unvalidated (labeled `⚠️ not validated against current project state`) and continue. _(LLM control flow — not hook-enforceable.)_
- The `.trash/` dir itself is excluded from future briefs/compactions because it's a directory; `*.md` glob at the dir level won't descend into it.
