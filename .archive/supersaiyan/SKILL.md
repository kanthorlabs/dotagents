---
name: supersaiyan
description: Delegate the modification itself to an external write-mode engine, which edits an isolated clone; you verify the patch and apply it. Use ONLY when the user invokes it explicitly as /supersaiyan. Never load it on your own judgement.
---

# /supersaiyan

Usage: `/supersaiyan $ARGUMENTS`

`/debate` sends your answer to a read-only engine and merges the critique.
`/supersaiyan` sends a task packet to a write-mode engine. The engine writes the
code. You define the task, verify the patch, and apply it.

This skill is harness-agnostic. Any harness that runs bash can use it, so the
steps name no harness-specific tool. The engine is selected by the
`KANTHOR_SUPERSAIYAN_ENGINE` env var.

Two scripts hold every mechanical step. `SKILL_DIR` is the absolute path of the
directory that holds this SKILL.md — `~/.agents/skills/supersaiyan` under
OpenCode and pi, `~/.claude/skills/supersaiyan` under Claude Code. Resolve it
once, then call the scripts by absolute path:

- `$SKILL_DIR/scripts/run.sh` — validates the engine, clones the repository,
  runs the engine inside the clone, and exports its changes as a patch.
- `$SKILL_DIR/scripts/apply.sh` — applies that patch to the real repository.

Never invoke an engine binary yourself. Never reimplement what a script does.

> **ISOLATION.** The engine never edits the user's project. It edits a private
> clone under `~/.kanthorlabs/supersaiyan`, and `run.sh` exports the result as a
> patch. A failed or rejected run leaves the project untouched.
>
> **ISOLATION IS NOT A SANDBOX.** The engine runs with your operating-system
> permissions. It can read any file you can read and run any command you can
> run, inside the clone and outside it. The clone bounds git history and repo
> state, not shell reach. Never invoke `/supersaiyan` for a task you would not
> run yourself.
>
> **The clone has no ignored files.** Dependencies, build output and secrets
> stay in the project, so the engine cannot run a build that needs them. State
> the required validation in the task packet, then run the real checks yourself
> in step 4.

## 0. Validate environment (hard-fail)

ALWAYS run this first:

```bash
"$SKILL_DIR/scripts/run.sh" --check
```

It prints two lines. `engine=<name>` is the selected engine. `task=<path>` is an
empty private file under `~/.kanthorlabs/supersaiyan` — step 1 writes the task
packet into it.

A non-zero exit means `KANTHOR_SUPERSAIYAN_ENGINE` is unset, is not in
`{opencode2, pi}`, names a missing binary, git is missing, or a supersaiyan run
is already active. **Return the error to the user and STOP.** Do not fall back,
do not edit the files yourself instead.

If `engine` names the engine you are running in, you delegate to your own
engine. Report this in one line to the user, then continue.

## 1. Write the task packet

Inspect the repository first. Read the files the task touches, and the house
rules the repository defines (`AGENTS.md`, `CLAUDE.md`, or the equivalent).

Then write the packet to the `task` path from step 0, with these five fields:

```
Objective: <one sentence, the outcome the user asked for>
Paths: <the files and directories that matter, with what each one holds>
Acceptance criteria: <checkable statements that define done>
Constraints: <what must not change, and the house rules that apply>
Required validation: <the exact commands that prove the work>
```

Rules for the packet:

- Give the engine the user's actual goal, not your implementation plan. The
  engine writes the code.
- Name every file the engine must not touch. The engine sees the whole clone.
- Copy the house rules that change the code style. The clone carries the
  repository files, so a rules file inside the repository reaches the engine,
  but a rules file outside it does not.
- Never put credentials in the packet. It persists on disk.

Use a real file write. Never put the packet on a command line — it contains
newlines, quotes and user text that break parsing or allow injection.

## 2. Run the engine (write mode, isolated)

```bash
"$SKILL_DIR/scripts/run.sh" "<task-path>" "<repo-dir>"
```

`run.sh` refuses a repository that is not a git work tree, and a work tree with
uncommitted changes — a dirty tree makes the engine's contribution
indistinguishable from the user's own work. It records the baseline commit,
clones the repository, checks the clone out at the baseline, and runs the engine
there with write access (`opencode2 run`, or `pi --print --no-session` with
`edit`, `write` and `bash` allowed and project-local extensions, skills and
prompt templates disabled). A watchdog polls the run and kills the whole process
group at 3600s.

On success it prints `engine`, `baseline`, `repo`, `clone`, `patch`, the changed
files, and the engine reply. Exit codes:

- `0` — the patch exists. Continue with step 3.
- `1` — the run failed: non-zero exit, a watchdog kill, or an empty patch (the
  engine changed nothing). The script prints a `SUPERSAIYAN RUN FAILED` report
  on stderr and the project stays untouched. **Return that report to the user
  and STOP.**
- `64` — the call is wrong. Fix the call.

## 3. Verify the patch (before it lands)

Read the patch file. Judge it against the packet, not against the engine's own
report:

- Does every acceptance criterion hold?
- Does the patch touch a file the constraints forbid?
- Does it add a dependency, a credential, or a comment the house rules reject?
- Does it add a generated byproduct — a cache, a build output, a lock file the
  task did not ask for? The engine runs the validation inside the clone, and
  every file it leaves behind that the repository does not ignore enters the
  patch.
- Does it delete or rewrite work that the task did not cover?

Reject the patch when any answer is wrong. A rejection needs no cleanup: report
the reason to the user, name the patch and clone paths, and STOP. You may
rewrite the packet and rerun step 2 once the user agrees.

## 4. Apply, then run the real checks

```bash
"$SKILL_DIR/scripts/apply.sh" "<patch-path>" "<repo-dir>"
```

`apply.sh` refuses a dirty work tree and a repository that moved from the
baseline. It applies the patch as unstaged changes, then prints the applied
files, the revert command, and the clone cleanup command. It never stages and
never commits.

Now run the `Required validation` commands in the real repository, plus the
project's own checks. Report the outcome:

- The checks pass — report the applied files and the validation output. Leave
  the changes unstaged. The user commits.
- The checks fail — run the printed revert command, report the failure with the
  output, and STOP. Never fix the engine's work silently in the same turn; the
  user decides between a rerun and your own edit.

## 5. Retention

The task packet, the engine reply, the engine stderr, the patch, the baseline
record and the clone stay under `~/.kanthorlabs/supersaiyan`. They hold project
source and the task text, so they are private files (mode 600). Report the
cleanup command in your final message, and never run it yourself:

```bash
rm -rf <clone> <task-path>*
```

## Error handling (hard-fail)

All failures stop execution and return an error to the user. No fallbacks, no
silent degradation.

- `run.sh --check` exits non-zero: return its `error:` line, STOP.
- `run.sh` exits 1: return its `SUPERSAIYAN RUN FAILED` report, STOP.
- The patch fails your step 3 review: report the reason, STOP.
- `apply.sh` exits non-zero: return its `error:` line, STOP.
- The validation of step 4 fails: revert, report, STOP.
- Never implement the task yourself as a fallback. `/supersaiyan` delegates the
  modification by definition.
