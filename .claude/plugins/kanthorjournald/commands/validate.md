---
description: Validate whether what AI Coding did this turn matches the user's request
allowed-tools: Read, Glob, Grep, Bash
---

Validate the latest turn's work against the user's original request for this turn.

1. Try to Read `~/.kanthorlabs/kanthorjournald/current-session.txt`. If present, the journal is at `~/.kanthorlabs/kanthorjournald/journals/<contents>.md`.
2. If the file doesn't exist OR the resolved journal is missing, fall back to the newest match from Glob `~/.kanthorlabs/kanthorjournald/journals/*.md` (sort by mtime, pick latest).
3. Read that journal file and locate the **latest** `## Turn` section.
4. Re-read the user's prompt that triggered that turn (the `**User asked:**` line in the journal pins it).
5. For each item in `Decisions off-spec`, `Changes beyond ask`, `Tradeoffs`, `Assumptions`, `Deferred / TODO`:
   - Cross-check against the actual code in the working tree (Read / Grep) — not just the journal text. The journal is a claim; the code is truth.
   - Confirm the item is acceptable given the user's prompt OR flag it as a mismatch.
6. If any code drifted from spec, call it out explicitly with file:line references. Do NOT auto-fix unless the user asks.

Output format (markdown):

```
## Validation — <session-id>, latest turn

**User asked:** <one-line restatement from journal>

**✅ Matches spec**
- <item> — <one-line confirmation>

**⚠️ Needs human review**
- <item> — <why it might not match what the user wanted> (file:line if applicable)

**❌ Drifted from spec**
- <item> — <what diverged> (file:line)
```

If the journal is empty or has no turns yet, say so plainly — don't fabricate.
If a section has no entries, omit it from the output (don't print empty headers).
