---
description: 80/20 brief of the project's decision journals across ALL sessions (every journal, every turn)
allowed-tools: Read, Glob, Bash
model: claude-sonnet-4-6
---

Resolve every journal file for the current project, then produce an 80/20 brief covering **all sessions** (every `## Turn` section in every journal).

1. Run this Bash one-liner to compute the current project key:
   ```
   python3 -c 'import os,hashlib; c=os.getcwd(); print(os.path.basename(c.rstrip("/"))+"-"+hashlib.md5(c.encode()).hexdigest())'
   ```
   Call the output `<project-key>`.
2. List every journal file for this project, sorted by mtime ascending (oldest → newest) so the brief reads chronologically. Use this portable Bash command (works on macOS + Linux; do NOT use `tac`, which is GNU-only):
   ```
   ls -tr ~/.kanthorlabs/kanthorjournald/journals/<project-key>/*.md
   ```
   (`ls -tr` = sort by mtime, reversed → oldest first. If you prefer Glob, sort the results yourself afterwards.)
3. Read each journal file in full — every `## Turn` section across every session.
4. Tag each item with its session id (the journal filename's stem, e.g. `6567a487`) and turn number so cross-session items can be collapsed.

Then produce an **80/20 brief over the whole project**: surface the ~20% of journal items that carry ~80% of human-review risk. Drop trivia (boilerplate "- none", obvious choices, well-scoped renames). Keep anything that:

- silently changed behavior the user didn't ask for
- picked one design over another without user input
- introduced an assumption that could be wrong
- deferred work the user might assume was done
- chose a library/version/config without user steering

When the same concern recurs — within a session or across sessions — collapse to one line and note where it appeared (e.g. `sessions 6567a487 t2, ab12cd34 t1,4`). Prefer items that compound across sessions over single-turn nits.

**Apply the same 80/20 filter to Tradeoffs and Assumptions.** Don't list every entry from `### Tradeoffs` and `### Assumptions` — surface only the ~20% that are most worth a human's attention:

- **Tradeoffs**: keep ones that picked a non-obvious side, locked in a hard-to-reverse choice, or could cause regret later. Drop micro-tradeoffs (naming, formatting, "either is fine" choices).
- **Assumptions**: keep ones the user might disagree with, that the model couldn't verify, or that, if wrong, would break the change. Drop assumptions that are trivially true or already confirmed by the user.

Output format (markdown):

```
## Journal brief — <project-key> (80/20, all sessions, <M> sessions / <N> turns)

**🔴 Needs review (highest risk)**
- <one-line item> — _<why it matters in <10 words>_ (<session>:t<n> or "<sess-a>:t2, <sess-b>:t1,4")

**🟡 Worth confirming**
- <one-line item> — _<why>_ (<session>:t<n>)

**🔀 Tradeoffs worth a second look**
- <picked X over Y> — _<why it matters>_ (<session>:t<n>)

**❓ Assumptions worth a second look**
- <assumption> — _<why it matters>_ (<session>:t<n>)

**🟢 Skipped from brief**
- <count> low-risk items across <M> sessions / <N> turns (boilerplate, none-entries, obvious renames, micro-tradeoffs, trivial assumptions)
```

If no journals exist for the project, or every journal has only its header (no turns yet), say so plainly — don't fabricate.
