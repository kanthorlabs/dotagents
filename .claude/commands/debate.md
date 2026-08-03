---
description: Run your answer through an adversarial, READ-ONLY debate engine, then merge valid critiques back in.
---

# /debate

Usage: `/debate [--verbose] $ARGUMENTS`

Run Claude's answer to a prompt through an external adversarial debate engine,
then have Claude do a final pass that merges valid critiques back into the
answer. The debate engine is selected by the `KANTHOR_DEBATE_ENGINE` env var.

> **READ-ONLY GUARANTEE.** `/debate` is a critique tool, not an edit tool.
> Neither Claude's turns nor the debate engine may modify the filesystem, run
> mutating commands, make network changes, or alter any state. The only
> permitted operations are reading and reasoning. This MUST be enforced at the
> engine invocation level (below). If read-only cannot be guaranteed for the
> selected engine, **hard-fail** — do not run the debate.
>
> **ONE EXCEPTION:** the temp files of step 2, and the statistics append of
> step 5. Both write outside the user's project. Nothing else may be written.

## 0. Validate environment (hard-fail)

ALWAYS assert that `KANTHOR_DEBATE_ENGINE` exists and is one of the valid
values below. Its value decides which engine runs the debate, and each MUST be
invoked in read-only mode:

- `opencode` → `opencode run --agent plan < <DEBATE_ARGUMENTS_FILE>` (stdin REQUIRED, see below)
- `codex`    → `codex exec --sandbox read-only --ask-for-approval never <DEBATE_ARGUMENTS>`
- `pi`       → `pi --print --no-session --tools read,grep,find,ls < <DEBATE_ARGUMENTS_FILE>` (stdin REQUIRED, see below)

**MUST** also validate the selected engine binary exists and is executable
(`command -v <engine>`).

If `KANTHOR_DEBATE_ENGINE` is unset/empty, is not in `{opencode, codex, pi}`, or
the engine binary is missing or not executable: **return an error to the user
and STOP.** Do not fall back, do not proceed.

## 1. Claude's turn (read-only)

Receive the prompt as `$ARGUMENTS` (after stripping the optional leading
`--verbose` flag). Claude takes its turn and generates a response based on the
prompt. Call this `<CLAUDE_RESPONSE>`.

This turn is READ-ONLY: Claude may read files and reason, but MUST NOT edit or
create files, or run any mutating command. It is producing text only.

Count the **statements** in `<CLAUDE_RESPONSE>`. A statement is one discrete,
checkable claim or recommendation. Count the claim, not the sentence: one claim
that spans three sentences is one statement, and a restatement of an earlier
claim is not a new statement. Call this count `<STAT_STATEMENTS>`. Step 5
records it.

## 2. Call the debate engine (read-only, hard-enforced)

Based on `KANTHOR_DEBATE_ENGINE`, call the corresponding engine with
`<DEBATE_ARGUMENTS>`. `<DEBATE_ARGUMENTS>` is the following block (the ```
fences are NOT part of it; they only delimit it here):

```
User prompt: $ARGUMENTS
Claude response: <CLAUDE_RESPONSE>
Act as an adversarial but fair debater. Challenge Claude's response using clear reasoning. Focus on flawed assumptions, gaps, risks, tradeoffs, and stronger alternatives. Do not simply agree or repeat the answer. If Claude's position is genuinely sound, attack it at its strongest point and concede only what you must. End with your strongest counter-position.
```

**PASSING RULE:** Write this block to a temp file named
`debate-<YYYYMMDDHHmmss>.txt` under the system temp directory — i.e.
`TMP="$(mktemp -d)/debate-$(date -u +'%Y%m%d%H%M%S').txt"`. How it reaches the
engine is per-engine:

- `opencode`: stdin is REQUIRED — `opencode run --agent plan < "$TMP"`.  
  Passing the block as a long argv reproducibly hangs `opencode run` right
  after bootstrap (no session, no model request, empty reply forever).
- `codex`: pass as a SINGLE quoted argument — `"$(cat "$TMP")"`.  
- `pi`: stdin is REQUIRED — `pi --print --no-session --tools read,grep,find,ls < "$TMP"`.  
  `--tools read,grep,find,ls` restricts pi to read-only built-ins (`bash`, `edit`, `write`
  are excluded). `--no-session` makes the run ephemeral (no saved state).

Never interpolate the block unquoted onto the command line; it contains
newlines, quotes, and user text that would break parsing or allow injection.
Prefer a real file write over a heredoc, since a heredoc delimiter can collide
with user content.

**INLINE FILE CONTENT:** If `<CLAUDE_RESPONSE>` discusses specific files, append
their verbatim content to the block (delimited, with a note that no file reads
are needed). Engines run with permissions auto-rejected in non-interactive
mode; a debater that tries to Read a file outside the project dir gets
`rejected permission` and exits 0 with an error instead of a debate.

**READ-ONLY ENFORCEMENT (per engine):**

- `codex`: invoke as
  `codex exec --sandbox read-only "$(cat "$TMP")"`.  
  In `read-only` mode the engine can read files but cannot write anywhere
  (including /tmp). Do NOT use `--full-auto`, `--yolo`, or
  `--dangerously-bypass-approvals-and-sandbox` — any of these breaks the
  guarantee and MUST be treated as a hard-fail condition.

- `opencode`: use the built-in read-only `plan` agent, fed via stdin:
  `opencode run --agent plan < "$TMP"`.  
  Plan mode disables file edits. A plain `opencode run` (no `--agent`) is NOT
  read-only — permissions default to "allow" — and MUST NOT be used.

- `pi`: invoke as
  `pi --print --no-session --tools read,grep,find,ls < "$TMP"`.  
  `--tools read,grep,find,ls` is a strict allowlist — only the four read-only
  built-ins are available; `bash`, `edit`, and `write` are not loaded.
  `--no-session` keeps the run ephemeral with no saved state. Do NOT omit
  `--tools` or substitute `--no-tools` — a pi run without the allowlist has
  `bash`, `edit`, and `write` available and is NOT read-only.

If the chosen engine does not support a verifiable read-only mode, or the
read-only flag/agent is rejected: **return an error to the user and STOP.**

**REPLY FILE + STALL WATCHDOG:** Redirect the engine's stdout into a reply temp
file in the same temp directory as the input file:
`REPLY="${TMP%.*}-reply.txt"` (produces
`debate-<YYYYMMDDHHmmss>-reply.txt`). Run the engine in the background with a
watchdog: a healthy engine streams its first bytes within seconds, so a reply
still empty after 300s is the known post-bootstrap hang — kill it so the run
fails loudly instead of sitting silent:

```bash
<engine command> > "$REPLY" 2>&1 &
PID=$!
( sleep 300; [ -s "$REPLY" ] || kill "$PID" 2>/dev/null ) & WD=$!
wait "$PID"; RC=$?
kill "$WD" 2>/dev/null
echo '=== END ===' >> "$REPLY"
```

A watchdog kill surfaces as non-zero `$RC` (typically 143) and feeds the
existing hard-fail path. Call the contents of `$REPLY` `<DEBATE_RESPONSE>`.

**Completion check:** Before reading `$REPLY`, verify the file exists AND its
last line is exactly `=== END ===`. If the marker is missing the engine did not
finish — treat as a failed run. When consuming `<DEBATE_RESPONSE>`, strip the
`=== END ===` marker line so it does not leak into the merged output.

**VALIDATION GATE (mandatory):** exit 0 + marker + non-empty is NOT success —
an engine can fail *inside* a clean exit (e.g. a rejected file-read permission
produces exit 0 and a short error message as the entire "debate"). Before
consuming `<DEBATE_RESPONSE>`, assert ALL of:

1. `RC` is 0.
2. `$REPLY` is at least 1000 bytes excluding the marker line — a real
   adversarial debate is never a few hundred bytes.
3. `$REPLY` does not match engine-failure signatures:
   `grep -niE 'rejected permission|permission denied|rate limit|not logged in|unauthorized|invalid api key' "$REPLY"`.
   If a signature matches, read the surrounding lines and judge: a debate that
   *mentions* permissions is fine; a reply that *is* an error message is a
   failed run.

If any assertion fails: **STOP and raise the error to the user** in this
format — do not merge, do not return an un-debated answer:

```
DEBATE ENGINE FAILED — <engine>, exit <RC>
Reason: <stall killed by watchdog | reply too short (<N> bytes) | error content | non-zero exit>
Reply excerpt:
<first ~10 lines of $REPLY>
Engine log tail (if available):
<last ~10 lines of the engine's newest log, e.g. ~/.local/share/opencode/log/*.log>
```

## 3. Claude's FINAL turn — merge (read-only)

Review `<DEBATE_RESPONSE>` in `debate-<YYYYMMDDHHmmss>-reply.txt` and decide, comment by comment, what to incorporate.
This turn is also READ-ONLY: produce text only, edit nothing. There is no hard
accept/reject rule — validity depends on the user's actual intent and context.
Use this strategy:

- Judge each comment by: does accepting it make the answer more correct, more
  complete, or safer FOR WHAT THE USER ACTUALLY ASKED?
- Lean toward incorporating a comment when it: corrects a factual/logical
  error; fills a gap that matters to the user's goal; surfaces a risk or
  tradeoff the user would care about; or offers an alternative that is
  genuinely better given the user's constraints.
- Set aside (but still report) comments that are out of scope, optimize for
  something the user didn't ask for, are speculative without grounding, or
  merely restate the original answer.
- When uncertain, prefer noting it as a caveat over silently merging or
  silently dropping it.
- Because the same Claude that wrote the answer is judging criticism of it,
  bias slightly toward accepting valid criticism to offset self-defense.

Produce `<CLAUDE_DEBATE_MERGED_RESPONSE>` as **ORIGINAL-PLUS-DELTAS**: keep
`<CLAUDE_RESPONSE>` intact and integrate accepted comments as explicit
additions/corrections, rather than rewriting from scratch.

Count the debate comments while you classify them. A **catch** is one distinct
objection the engine argues — count the objection, not the paragraph. Assign
every catch to exactly one bucket:

- `<STAT_MERGED>` — catches you accepted into `<CLAUDE_DEBATE_MERGED_RESPONSE>`.
- `<STAT_PUSHBACKS>` — catches you set aside. These are the "Worth noting"
  items of step 4.

`<STAT_CATCHES>` is the total. The invariant
`<STAT_MERGED> + <STAT_PUSHBACKS> == <STAT_CATCHES>` MUST hold. A catch you
merged in part counts as merged.

## 4. Output

**DEFAULT** — return `<CLAUDE_DEBATE_MERGED_RESPONSE>` plus a "Worth noting"
list of the debate comments you did NOT merge:

```
<CLAUDE_DEBATE_MERGED_RESPONSE>

Worth noting:
- <DEBATE_ENGINE_COMMENTS_NOT_MERGED_1>
- <DEBATE_ENGINE_COMMENTS_NOT_MERGED_2>
```

**If `--verbose` was passed** — prepend the original answer and the raw engine
output before the default block:

```
--- Original response ---
<CLAUDE_RESPONSE>

--- Debate engine output ---
<DEBATE_RESPONSE>
```

## 5. Record statistics

After you return the step 4 output, append ONE JSON line to
`~/.kanthorlabs/state/debate.jsonl`. Substitute the four counts and run:

```bash
mkdir -p ~/.kanthorlabs/state
printf '{"timestamp":"%s","engine":"%s","statements":%d,"catches":%d,"merged":%d,"pushbacks":%d}\n' \
  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$KANTHOR_DEBATE_ENGINE" \
  <STAT_STATEMENTS> <STAT_CATCHES> <STAT_MERGED> <STAT_PUSHBACKS> \
  >> ~/.kanthorlabs/state/debate.jsonl
```

Rules:

- Write the line only for a run that reached step 4. A run that hard-fails
  records nothing — a failed engine produces no measurable debate.
- Write exactly one line per run. Never rewrite or delete earlier lines.
- This step MUST NOT fail the command. If the append fails, report the failure
  to the user in one line and keep the step 4 output.

`merged` is the count of valid catches. `pushbacks` is the count of rejected
catches. `merged / catches` is the engine's hit rate.

## Error handling (hard-fail)

All failures stop execution and return an error to the user. No fallbacks, no
silent degradation.

- `KANTHOR_DEBATE_ENGINE` unset, empty, or not in `{opencode, codex, pi}`:
  error with the valid values, STOP.
- Engine binary not found or not executable: error, STOP.
- Read-only mode unavailable, rejected, or bypassed (e.g. a `--yolo` /
  `danger-full-access` codex flag, or an opencode invocation without
  `--agent plan`): error, STOP.
- Engine exits non-zero, times out, or returns empty output: error
  (include engine stderr if available), STOP.
- Watchdog killed a stalled engine (empty reply after 300s): error
  ("debate engine stalled — killed by watchdog"), STOP.
- Validation gate failed (reply too short, or reply content is an engine
  error despite exit 0): error using the DEBATE ENGINE FAILED format, STOP.
- Reply file missing or `=== END ===` marker absent: error
  ("debate engine did not complete"), STOP.