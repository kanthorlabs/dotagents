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

## 0. Validate environment (hard-fail)

ALWAYS assert that `KANTHOR_DEBATE_ENGINE` exists and is one of the valid
values below. Its value decides which engine runs the debate, and each MUST be
invoked in read-only mode:

- `opencode` → `opencode run --agent plan <DEBATE_ARGUMENTS>` (hardened, see below)
- `codex`    → `codex exec --sandbox read-only --ask-for-approval never <DEBATE_ARGUMENTS>`

**MUST** also validate the selected engine binary exists and is executable
(`command -v <engine>`).

If `KANTHOR_DEBATE_ENGINE` is unset/empty, is not in `{opencode, codex}`, or
the engine binary is missing or not executable: **return an error to the user
and STOP.** Do not fall back, do not proceed.

## 1. Claude's turn (read-only)

Receive the prompt as `$ARGUMENTS` (after stripping the optional leading
`--verbose` flag). Claude takes its turn and generates a response based on the
prompt. Call this `<CLAUDE_RESPONSE>`.

This turn is READ-ONLY: Claude may read files and reason, but MUST NOT edit or
create files, or run any mutating command. It is producing text only.

## 2. Call the debate engine (read-only, hard-enforced)

Based on `KANTHOR_DEBATE_ENGINE`, call the corresponding engine with
`<DEBATE_ARGUMENTS>`. `<DEBATE_ARGUMENTS>` is the following block (the ```
fences are NOT part of it; they only delimit it here):

```
User prompt: $ARGUMENTS
Claude response: <CLAUDE_RESPONSE>
Act as an adversarial but fair debater. Challenge Claude's response using clear reasoning. Focus on flawed assumptions, gaps, risks, tradeoffs, and stronger alternatives. Do not simply agree or repeat the answer. If Claude's position is genuinely sound, attack it at its strongest point and concede only what you must. End with your strongest counter-position.
```

**PASSING RULE:** Write this block to a temp file and pass it as a SINGLE
quoted argument — e.g. `"$(cat "$TMP")"` — or via stdin if the engine supports
it. Never interpolate it unquoted onto the command line; it contains newlines,
quotes, and user text that would break parsing or allow injection. Prefer a
real file write over a heredoc, since a heredoc delimiter can collide with user
content.

**READ-ONLY ENFORCEMENT (per engine):**

- `codex`: invoke as
  `codex exec --sandbox read-only --ask-for-approval never "$(cat "$TMP")"`.
  In `read-only` mode the engine can read files but cannot write anywhere
  (including /tmp). Do NOT use `--full-auto`, `--yolo`, or
  `--dangerously-bypass-approvals-and-sandbox` — any of these breaks the
  guarantee and MUST be treated as a hard-fail condition.

- `opencode`: use the built-in read-only `plan` agent:
  `opencode run --format json --agent plan "$(cat "$TMP")"`.
  Plan mode disables file edits. A plain `opencode run` (no `--agent`) is NOT
  read-only — permissions default to "allow" — and MUST NOT be used.

If the chosen engine does not support a verifiable read-only mode, or the
read-only flag/agent is rejected: **return an error to the user and STOP.**

Call the engine's output `<DEBATE_RESPONSE>`.

If the engine exits non-zero, times out, or returns empty output: **return an
error to the user (include the engine's stderr if available) and STOP.** Do not
return an un-debated answer.

## 3. Claude's FINAL turn — merge (read-only)

Review `<DEBATE_RESPONSE>` and decide, comment by comment, what to incorporate.
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

## Error handling (hard-fail)

All failures stop execution and return an error to the user. No fallbacks, no
silent degradation.

- `KANTHOR_DEBATE_ENGINE` unset, empty, or not in `{opencode, codex}`:
  error with the valid values, STOP.
- Engine binary not found or not executable: error, STOP.
- Read-only mode unavailable, rejected, or bypassed (e.g. a `--yolo` /
  `danger-full-access` codex flag, or an opencode invocation without
  `--agent plan`): error, STOP.
- Engine exits non-zero, times out, or returns empty output: error
  (include engine stderr if available), STOP.