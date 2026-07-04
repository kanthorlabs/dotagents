---
description: Validate whether AI Coding's work across the entire session matches the user's requests
allowed-tools: Read, Glob, Grep, Bash
model: claude-sonnet-4-6
---

Validate the work done across the **entire session** (every `## Turn` section) against the user's original requests.

1. Run this Bash one-liner to compute the current project key:
   ```
   python3 -c 'import os,hashlib; c=os.getcwd(); print(os.path.basename(c.rstrip("/"))+"-"+hashlib.md5(c.encode()).hexdigest())'
   ```
   Call the output `<project-key>`.
2. Try to Read `~/.kanthorlabs/kanthorjournald/journals/<project-key>/current-session.txt`. If present, the journal is at `~/.kanthorlabs/kanthorjournald/journals/<project-key>/<contents>.md`.
3. If the file doesn't exist OR the resolved journal is missing, fall back to the newest match from Glob `~/.kanthorlabs/kanthorjournald/journals/<project-key>/*.md` (sort by mtime, pick latest).
4. Read that journal file in full and walk **every** `## Turn` section in order.
5. For each turn, anchor on the `**User asked:**` line — that pins the user's request for that turn.
6. For each item in `Decisions off-spec`, `Changes beyond ask`, `Tradeoffs`, `Assumptions`, `Deferred / TODO` across every turn:
   - Cross-check against the actual code in the working tree (Read / Grep) — not just the journal text. The journal is a claim; the code is truth.
   - Confirm the item is acceptable given that turn's prompt OR flag it as a mismatch.
7. Reconcile across turns: if a later turn fixed something flagged in an earlier turn, mark it resolved rather than re-flagging.
8. If any code drifted from spec, call it out explicitly with `file:line` references. Do NOT auto-fix unless the user asks.

Output format (markdown):

```
## Validation — <session-id>, whole session (<N> turns)

**Per-turn user requests**
- Turn 1: <one-line restatement>
- Turn 2: <one-line restatement>
- ...

**✅ Matches spec**
- <item> — <one-line confirmation> (turn <n>)

**⚠️ Needs human review**
- <item> — <why it might not match what the user wanted> (turn <n>, file:line if applicable)

**❌ Drifted from spec**
- <item> — <what diverged> (turn <n>, file:line)
```

If the journal is empty or has no turns yet, say so plainly — don't fabricate.
If a section has no entries, omit it from the output (don't print empty headers).
