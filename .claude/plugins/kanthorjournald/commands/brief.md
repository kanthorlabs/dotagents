---
description: 80/20 brief of the current session's decision journal
allowed-tools: Read, Glob
---

Resolve the current session's journal file, then produce an 80/20 brief.

1. Try to Read `~/.kanthorlabs/kanthorjournald/current-session.txt`. If present, the journal is at `~/.kanthorlabs/kanthorjournald/journals/<contents>.md`.
2. If the file doesn't exist OR the resolved journal is missing, fall back to the newest match from Glob `~/.kanthorlabs/kanthorjournald/journals/*.md` (sort by mtime, pick latest).
3. Read that journal file.

Then produce an **80/20 brief**: surface the ~20% of journal items that carry ~80% of human-review risk. Drop trivia (boilerplate "- none", obvious choices, well-scoped renames). Keep anything that:

- silently changed behavior the user didn't ask for
- picked one design over another without user input
- introduced an assumption that could be wrong
- deferred work the user might assume was done
- chose a library/version/config without user steering

Output format (markdown, ≤200 words total):

```
## Journal brief — <session-id> (80/20)

**🔴 Needs review (highest risk)**
- <one-line item> — _<why it matters in <10 words>_

**🟡 Worth confirming**
- <one-line item> — _<why>_

**🟢 Skipped from brief**
- <count> low-risk items (boilerplate, none-entries, obvious tradeoffs)
```

If the journal is empty or only has the header (no turns yet), say so plainly — don't fabricate.
