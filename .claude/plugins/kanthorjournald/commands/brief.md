---
description: 80/20 brief of the current session's decision journal (entire session, all turns)
allowed-tools: Read, Glob, Bash
model: claude-sonnet-4-6
---

Resolve the current session's journal file, then produce an 80/20 brief covering the **entire session** (all `## Turn` sections, not just the latest).

1. Run this Bash one-liner to compute the current project key:
   ```
   python3 -c 'import os,hashlib; c=os.getcwd(); print(os.path.basename(c.rstrip("/"))+"-"+hashlib.md5(c.encode()).hexdigest())'
   ```
   Call the output `<project-key>`.
2. Try to Read `~/.kanthorlabs/kanthorjournald/journals/<project-key>/current-session.txt`. If present, the journal is at `~/.kanthorlabs/kanthorjournald/journals/<project-key>/<contents>.md`.
3. If the file doesn't exist OR the resolved journal is missing, fall back to the newest match from Glob `~/.kanthorlabs/kanthorjournald/journals/<project-key>/*.md` (sort by mtime, pick latest).
4. Read that journal file in full — every `## Turn` section.

Then produce an **80/20 brief over the whole session**: surface the ~20% of journal items that carry ~80% of human-review risk. Drop trivia (boilerplate "- none", obvious choices, well-scoped renames). Keep anything that:

- silently changed behavior the user didn't ask for
- picked one design over another without user input
- introduced an assumption that could be wrong
- deferred work the user might assume was done
- chose a library/version/config without user steering

When the same concern recurs across turns, collapse to one line and note the turn count. Prefer items that compound across the session over single-turn nits.

Output format (markdown, ≤250 words total):

```
## Journal brief — <session-id> (80/20, whole session, <N> turns)

**🔴 Needs review (highest risk)**
- <one-line item> — _<why it matters in <10 words>_ (turn <n> or "turns 2,4")

**🟡 Worth confirming**
- <one-line item> — _<why>_ (turn <n>)

**🟢 Skipped from brief**
- <count> low-risk items across <N> turns (boilerplate, none-entries, obvious tradeoffs)
```

If the journal is empty or only has the header (no turns yet), say so plainly — don't fabricate.
