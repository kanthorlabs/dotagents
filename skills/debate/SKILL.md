---
name: debate
description: Run your answer through an adversarial, READ-ONLY debate engine, then merge valid critiques back in. Use ONLY when the user invokes it explicitly as /debate. Never load it on your own judgement.
---

# /debate

Usage: `/debate [--verbose] $ARGUMENTS`

Run your answer to a prompt through an external adversarial debate engine,
then do a final pass that merges valid critiques back into the answer. The
debate engine is selected by the `KANTHOR_DEBATE_ENGINE` env var.

Two scripts hold every mechanical step. `SKILL_DIR` is the absolute path of the
directory that holds this SKILL.md — `~/.claude/skills/debate` under Claude
Code, `~/.agents/skills/debate` under OpenCode and pi. Resolve it once, then
call the scripts by absolute path:

- `$SKILL_DIR/scripts/run.sh` — validates the engine, invokes it read-only,
  guards the run with a watchdog, and validates the reply.
- `$SKILL_DIR/scripts/stats.sh` — appends one statistics line.

Never invoke an engine binary yourself. Never reimplement what a script does.

> **READ-ONLY GUARANTEE.** `/debate` is a critique tool, not an edit tool.
> Neither your turns nor the debate engine may modify the filesystem, run
> mutating commands, make network changes, or alter any state. The only
> permitted operations are reading and reasoning. `run.sh` enforces the engine
> side: it selects the read-only invocation and it refuses an args file outside
> `~/.kanthorlabs/debate`.
>
> **ONE EXCEPTION:** the temp files of step 2, and the statistics append of
> step 4. Both write outside the user's project. Nothing else may be written.

## 0. Validate environment (hard-fail)

ALWAYS run this first, before you answer:

```bash
"$SKILL_DIR/scripts/run.sh" --check
```

It prints two lines. `engine=<name>` is the selected engine. `args=<path>` is
an empty private file under `~/.kanthorlabs/debate` — step 2 writes the debate
block into it.

A non-zero exit means `KANTHOR_DEBATE_ENGINE` is unset, is not in
`{opencode2, pi}`, or names a missing binary. **Return the error to the user
and STOP.** Do not fall back, do not proceed.

If `engine` names the engine you are running in, the debate runs the same
engine as the answer, so the critique is weak. Report this in one line to the
user, then continue.

## 1. Your turn (read-only)

Receive the prompt as `$ARGUMENTS` (after stripping the optional leading
`--verbose` flag). Take your turn and generate a response based on the prompt.
Call this `<ASSISTANT_RESPONSE>`.

This turn is READ-ONLY: you may read files and reason, but MUST NOT edit or
create files, or run any mutating command. You produce text only.

Count the **statements** in `<ASSISTANT_RESPONSE>`. A statement is one discrete,
checkable claim or recommendation. Count the claim, not the sentence: one claim
that spans three sentences is one statement, and a restatement of an earlier
claim is not a new statement. Call this count `<STAT_STATEMENTS>`. Step 5
records it.

## 2. Call the debate engine (read-only, hard-enforced)

Write `<DEBATE_ARGUMENTS>` to the `args` path from step 0. `<DEBATE_ARGUMENTS>`
is the following block (the ``` fences are NOT part of it; they only delimit it
here):

```
User prompt: $ARGUMENTS
Assistant response: <ASSISTANT_RESPONSE>
Act as an adversarial but fair debater. Challenge the assistant's response using clear reasoning. Focus on flawed assumptions, gaps, risks, tradeoffs, and stronger alternatives. Do not simply agree or repeat the answer. If the assistant's position is genuinely sound, attack it at its strongest point and concede only what you must. End with your strongest counter-position.
```

**INLINE FILE CONTENT:** If `<ASSISTANT_RESPONSE>` discusses specific files,
append their verbatim content to the block (delimited, with a note that no file
reads are needed). Engines run with permissions auto-rejected in
non-interactive mode; a debater that tries to read a file outside the project
dir gets `rejected permission` and exits 0 with an error instead of a debate.

Use a real file write. Never put the block on a command line — it contains
newlines, quotes, and user text that break parsing or allow injection. Prefer a
file write over a heredoc, since a heredoc delimiter can collide with user
content.

Then run the engine:

```bash
"$SKILL_DIR/scripts/run.sh" "<args-path>"
```

The script selects the read-only invocation for the engine (`opencode2 run
--agent plan`, or `pi --print --no-session --tools read,grep,find,ls`), feeds
the block on stdin, polls the run every 5s, kills a silent run at 900s and any
run at 1800s, and validates the reply (exit code, completion marker, minimum
1000 bytes, engine-failure signatures). Its stdout is `<DEBATE_RESPONSE>`. The
full reply stays in `<args>-reply.txt` and the engine stderr in
`<args>-stderr.txt`.

Exit codes:

- `0` — `<DEBATE_RESPONSE>` is on stdout. Continue with step 3.
- `1` — the run failed. The script prints a `DEBATE ENGINE FAILED` report on
  stderr. **Return that report to the user and STOP.** Do not merge, do not
  return an un-debated answer.
- `64` — the call is wrong. Fix the call.

Exit 0 with a `warning: engine-failure signature matched` line on stderr needs
your judgement: a debate that *mentions* permissions is fine, a reply that *is*
an error message is a failed run. Treat a failed run as exit 1 and STOP.

## 3. Your FINAL turn — merge (read-only)

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
- Because the same model that wrote the answer is judging criticism of it,
  bias slightly toward accepting valid criticism to offset self-defense.

Produce `<ASSISTANT_DEBATE_MERGED_RESPONSE>` as **ORIGINAL-PLUS-DELTAS**: keep
`<ASSISTANT_RESPONSE>` intact and integrate accepted comments as explicit
additions/corrections, rather than rewriting from scratch.

Count the debate comments while you classify them. A **catch** is one distinct
objection the engine argues — count the objection, not the paragraph. Assign
every catch to exactly one bucket:

- `<STAT_MERGED>` — catches you accepted into `<ASSISTANT_DEBATE_MERGED_RESPONSE>`.
- `<STAT_PUSHBACKS>` — catches you set aside. These are the "Worth noting"
  items of step 5.

`<STAT_CATCHES>` is the total. The invariant
`<STAT_MERGED> + <STAT_PUSHBACKS> == <STAT_CATCHES>` MUST hold, and `stats.sh`
rejects a run that breaks it. A catch you merged in part counts as merged.

## 4. Record statistics

Run this after step 3, before you return the step 5 output — a tool call after
the final response is impossible:

```bash
"$SKILL_DIR/scripts/stats.sh" <STAT_STATEMENTS> <STAT_CATCHES> <STAT_MERGED> <STAT_PUSHBACKS>
```

Rules:

- Run it only for a run that reaches step 5. A run that hard-fails records
  nothing — a failed engine produces no measurable debate.
- Run it once per run. Never rewrite or delete earlier lines.
- This step MUST NOT fail the command. If the script fails, report the failure
  to the user in one line and keep the step 5 output.

`merged` is the count of valid catches. `pushbacks` is the count of rejected
catches. `merged / catches` is the engine's hit rate.

## 5. Output

**DEFAULT** — return `<ASSISTANT_DEBATE_MERGED_RESPONSE>` plus a "Worth noting"
list of the debate comments you did NOT merge:

```
<ASSISTANT_DEBATE_MERGED_RESPONSE>

Worth noting:
- <DEBATE_ENGINE_COMMENTS_NOT_MERGED_1>
- <DEBATE_ENGINE_COMMENTS_NOT_MERGED_2>
```

**If `--verbose` was passed** — prepend the original answer and the raw engine
output before the default block:

```
--- Original response ---
<ASSISTANT_RESPONSE>

--- Debate engine output ---
<DEBATE_RESPONSE>
```

## Error handling (hard-fail)

All failures stop execution and return an error to the user. No fallbacks, no
silent degradation.

- `run.sh --check` exits non-zero: return its `error:` line, STOP.
- `run.sh <args-file>` exits 1: return its `DEBATE ENGINE FAILED` report, STOP.
- A signature warning that you judge to be an engine error, not a debate:
  return the warning and the reply excerpt, STOP.
