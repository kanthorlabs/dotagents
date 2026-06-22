---
description: Drive an implementation cycle for one EPIC — TDD (lock) by default, dispatching test-engineer / software-engineer in alternation until IMPLEMENTATION_READY_FOR_REVIEW; or --sketch (Phase A) dispatching only software-engineer turns gated by human visual review. Runs serial (all variants) by default, or variant-scoped in an isolated git worktree (--variant) so variants can be built in parallel, with a --join step to merge and gate all. Escalates to the human when one Task fails its attempt limit. Lifecycle state lives in the discussion file; the orchestrator writes no frontmatter or status board.
argument-hint: <epic-file-path> [--variant <name>] [--base <ref>] [--sketch] [--join] [--max-turns N]
allowed-tools: Bash, Read, Agent
---

# /work — orchestrate a TDD implementation cycle

Arguments: `$ARGUMENTS`

You are the **orchestrator**. You own everything the test-engineer / software-engineer cannot do on their own:

- **TDD dispatch** — alternating `test-engineer` and `software-engineer` turns until `IMPLEMENTATION_READY_FOR_REVIEW:` lands in the discussion file or the turn cap fires.
- **Escalation to the human** — counting `ATTEMPT-FAILED:` lines per Task; when one Task has failed **{{ATTEMPT_LIMIT}}** attempts, stopping the loop and handing it to the human.
- **Reviewer auto-fix routing** — after the reviewer-engineer gate, auto-routing every `action:YES` finding back through the TDD loop **once** per review cycle; only `action:NO` findings reach the human.
- **Final review handoff** — after implementation and the reviewer auto-fix pass, pausing for the **human operator's** review (`HUMAN_REVIEW: PASS|FAIL`). If the human fails it, routing their `BLOCKER:` lines back through the TDD loop.
- **Discussion-file seed** — the one-time header write.

Lifecycle state lives **only in the discussion file** — there is no separate status board and the EPIC/Story files carry no frontmatter to flip. An EPIC is "in progress" once its discussion file exists and "done" once that file contains `HUMAN_REVIEW: PASS`.

You do **not** commit; the human reviews and commits. You do **not** write to the discussion file after seeding it — subagents own every subsequent append via the race-safe `cat >>` protocol in their personas. (The one exception: the auto-review routing block the orchestrator appends in Step 6b.) You do **not** edit production sources, test files, or the locked EPIC/Story files — the engineers and the planning phase own those.

A "turn" is one logical handoff, not one keystroke. A subagent may make many tool calls inside a single Task invocation (read context, edit sources / test files, build, append) and produce one substantive entry in the discussion file. Granularity below that belongs in version-control commits, not in the discussion file.

The canonical TDD cycle:
- `test-engineer` opens with either a failing test (RED) for the next unimplemented Task, or a GREEN-ONLY pass-through for Tasks that have no `Action — RED:` block. Tasks are `### Task` headings in the Story files — there are no checkboxes; progress is tracked from the discussion file. If the project has UI/E2E tests, the TE registers element locators per `{{> UI_LOCATOR_CONTRACT}}` before writing the test.
- `software-engineer` makes that test green by editing production sources (RED flow), or implements the forwarded Task(s) directly from the Story spec (GREEN-ONLY flow).
- `test-engineer` runs the test (GREEN), then either opens the next RED or — when every Task is green and the EPIC's Verification Gate runs clean on every in-scope target — appends `IMPLEMENTATION_READY_FOR_REVIEW:`. For GREEN-ONLY Tasks, the TE runs a build-only check instead of a test.

After the TDD loop completes (`IMPLEMENTATION_READY_FOR_REVIEW:` detected), the orchestrator runs the **reviewer-engineer gate** and auto-routes its `action:YES` findings back through the TDD loop (once per cycle), leaving only `action:NO` findings for the human. It then **pauses for the human operator's review**. The human reviews the implementation and records the verdict in the discussion file as `HUMAN_REVIEW: PASS` or `HUMAN_REVIEW: FAIL` (with `BLOCKER:` lines). On `PASS`, the EPIC is done. On `FAIL`, the orchestrator routes the `BLOCKER:` lines back through the TDD loop until the next `IMPLEMENTATION_READY_FOR_REVIEW:`.

Separately, while the TDD loop runs, the orchestrator counts `ATTEMPT-FAILED: <task-id>` lines emitted by the engineers. When any single Task accumulates **{{ATTEMPT_LIMIT}}** failed attempts, the orchestrator stops the loop and escalates that Task to the human — the implementation cannot self-resolve it.

## Variants & scopes

This project's build variants and their dependency order are defined in the profile:

{{> VARIANTS_AND_SCOPES}}

Throughout, **scope** is either one variant name (variant mode) or `all` (serial mode, every variant in dependency order).

## Execution modes

`/work` runs in one of four modes, chosen by flags:

- **serial** (default — no `--variant`, no `--join`): one cycle over the whole EPIC in the main working tree, Tasks in dependency order. This is the original behavior, and the "Step N" spine below describes it.
- **variant** (`--variant <name>`): one cycle scoped to a single variant's Stories, running inside a dedicated **git worktree** so two variant cycles can run at once without sharing a working tree, a build cache, or the lane-check snapshot. Independent variants touch disjoint dirs and disjoint build targets, so they parallelize cleanly **once their shared dependency variant is done**.
- **sketch** (`--sketch`, Phase A): no TDD loop and no test-engineer. The software-engineer is dispatched turn after turn until it appends `IMPLEMENTATION_READY_FOR_REVIEW:` with Phase A proof. The reviewer-engineer then reviews with the narrowed Phase A scope and the loop pauses for the human's **visual review**. Requires the sketch capability (profile); mutually exclusive with `--join`. See `{{> SKETCH_MODE}}` for what it produces. If the profile disables sketch mode, abort.
- **join** (`--join`): not a TDD cycle — merges the finished variant branches into one tree and runs the EPIC's full Verification Gate on **every** target, the cross-variant attestation a single-variant cycle cannot give. See "Join mode" near the end. Never run `--join` on a sketch-only branch — there is nothing to gate until the flow's lock epic (Phase B) is done.

**The dependency-first rule (binding for variant mode).** Dependent variants rely on a shared base variant (per `VARIANTS_AND_SCOPES`). Run the base variant first, get it to `HUMAN_REVIEW: PASS`, and commit/merge it to a base ref. Only then launch the dependent variants in parallel, each with `--base <that-ref>`. Running a dependent variant against a base whose shared layer is incomplete surfaces as `OPEN:`/`ATTEMPT-FAILED:` blockers (missing seams) — the system working, not a bug, but a wasted cycle.

In variant and join modes every path in the steps below is rooted at the worktree `<root>` (Step 1b), not the main repo. In serial mode `<root>` is the repo root.

## Step 1 — Parse arguments

From `$ARGUMENTS`:
- **First positional** = EPIC file path (required). If missing or empty, print usage and stop.
- **`--variant <name>`** = scope this cycle to one variant and run it in a worktree (variant mode). Omit for serial mode. Capture as `VARIANT` (empty in serial mode); the "scope" label is `VARIANT` in variant mode, `all` in serial mode. If the value is not one of the profile's variants, abort with usage **before** any worktree is created.
- **`--base <ref>`** = git ref the worktree branches off (variant/join modes). Default `HEAD`. For parallel dependent-variant runs, point this at the committed base variant.
- **`--sketch`** = Phase A sketch mode. Capture as `SKETCH=true`. Mutually exclusive with `--join` (abort with usage if both). Requires the sketch capability + whatever variant the profile says sketch runs on — abort otherwise.
- **`--join`** = run join mode instead of a TDD cycle. Mutually exclusive with `--variant`; if both are given, abort with usage.
- **`--max-turns N`** = override turn cap. Default `{{DEFAULT_TURN_CAP}}`. `0` means unlimited (use with care).

If `--join` is set, skip Steps 2–7 and go to **Join mode**. Otherwise continue.

## Step 1b — Working root & worktree (variant mode)

Resolve `REPO_ROOT=$(git rev-parse --show-toplevel)` once.

**Serial mode** (`VARIANT` empty): `<root>` = `REPO_ROOT`; skip the rest of this step.

**Variant mode**: the cycle runs in an isolated worktree so it cannot collide with a concurrent variant cycle. Derive:

```bash
WT_BRANCH="work/<epic-slug>-$VARIANT"
WT_PATH="$REPO_ROOT/../{{REPO_NAME}}-worktrees/<epic-slug>-$VARIANT"   # sibling of the repo — OUTSIDE it, so build tooling never ingests the worktree
```

- If `WT_PATH` already exists (resuming) → reuse it; do not recreate.
- Else create it off the base ref:

  ```bash
  git -C "$REPO_ROOT" worktree add -b "$WT_BRANCH" "$WT_PATH" "<base-ref>" \
    || git -C "$REPO_ROOT" worktree add "$WT_PATH" "$WT_BRANCH"
  ```

Set `<root>` = `WT_PATH`. **Every path in the steps below resolves under `<root>`, not the main repo.** The worktree is a full checkout at the base commit. It is **not** auto-removed — the human merges the branch and runs `git worktree remove` after review (Step 8).

## Step 2 — Pre-flight checks (abort with a clear message on any failure)

All path checks below resolve under `<root>`.

1. The EPIC file exists and is readable.
2. The path is under `{{PLAN_EPICS_DIR}}` (sanity guard — refuse arbitrary paths).
3. `{{AGENT_DIR}}test-engineer.md` exists.
4. `{{AGENT_DIR}}software-engineer.md` exists.
5. `{{AGENT_DIR}}reviewer-engineer.md` exists.
6. `{{DISCUSSION_DIR}}` exists (create it with `mkdir -p` if not).
7. **No double review on resume.** If the discussion file (Step 3) already exists and its latest `HUMAN_REVIEW:` line is `PASS`, this cycle is already done — report `already closed` and stop without dispatching.
8. **Variant mode only.** `VARIANT` is a profile variant, and the base ref resolves (`git -C "$REPO_ROOT" rev-parse --verify <base-ref>`). If a dependent variant is run with `--base HEAD`, warn (do not abort): the base variant may not be frozen — prefer running it first and pointing `--base` at that committed ref.

## Step 3 — Derive the discussion file path

From the EPIC file path, extract the basename without `.md` as `<epic-slug>`. Compute today's date in UTC as `<YYYY-MM-DD>`. The discussion file path is rooted under `<root>` and, in variant mode, suffixed with the variant so parallel cycles never share a file:

```
serial:   <root>/{{DISCUSSION_DIR}}<YYYY-MM-DD>-<epic-slug>.md
variant:  <root>/{{DISCUSSION_DIR}}<YYYY-MM-DD>-<epic-slug>-<VARIANT>.md
```

If the discussion file does not exist, capture the current HEAD as the cycle's base ref (`BASE_REF=$(git -C '<root>' rev-parse HEAD)`) and seed the file with a single shell write (`cat > '<discussion-file>' <<'WORK_EOF' ... WORK_EOF`). This is the **only** time the orchestrator writes the discussion file. Header content:

```
---
epic: <epic-file-relative-path>
opened: <YYYY-MM-DD>
cycle: <tdd, or "sketch" when SKETCH=true>
scope: <VARIANT, or "all" in serial mode>
opener: <test-engineer, or "software-engineer" when SKETCH=true>
base-ref: <BASE_REF>
---

# Implementation cycle — <epic-slug>

Pulled from EPIC: `<epic-file-relative-path>`.

Verification gate (binding, from the EPIC's `## Verification Gate` section):
> <the prose under the EPIC's "## Verification Gate" heading, verbatim>

TDD protocol:
1. test-engineer writes the next failing test (RED) — or a GREEN-ONLY pass-through for Tasks without `Action — RED:`.
2. software-engineer makes the test green (RED flow) or implements the Task spec directly (GREEN-ONLY flow).
3. test-engineer confirms GREEN (or runs a build-only check for GREEN-ONLY), then either opens the next Task or runs the full Verification Gate on every in-scope target and appends IMPLEMENTATION_READY_FOR_REVIEW.
```

(If the discussion file already exists, leave it alone — you are resuming a prior cycle.)

## Step 4 — Environment pre-flight (once)

{{> ENV_PREFLIGHT}}

If the pre-flight is required for the scope and fails, **stop immediately** — do not enter the dispatch loop. Ask the human to resolve it, then re-run `/work`. Otherwise store whatever it captured for use in every Step 5f dispatch prompt.

## Step 5 — The dispatch loop

Initialize `turn_count = 0`. Sweep any stale draft temps left by an aborted prior run (the orchestrator owns these — see 5e/5g.1): `rm -f '<root>'/{{DRAFT_DIR}}.*-response-*.md`. Then repeat:

### 5a. Stop on max-turns
If `max_turns > 0` and `turn_count >= max_turns`: report `max-turns reached (<N>)` and jump to Step 8 (do **not** close the lifecycle — the work isn't done).

### 5b. Stop on IMPLEMENTATION_READY_FOR_REVIEW

Only a ready marker **newer than the last review failure** counts — otherwise a stale marker from before a review failure (a human `HUMAN_REVIEW: FAIL` or an orchestrator-emitted `AUTO_REVIEW: FAIL` from Step 6b) would bounce the cycle straight back to Step 6 without running the blocker regressions.

```bash
FAIL_LINE=$(grep -nE '^(HUMAN_REVIEW: FAIL|AUTO_REVIEW: FAIL)' '<discussion-file>' | tail -1 | cut -d: -f1)
awk -v s="${FAIL_LINE:-0}" 'NR>s && /^IMPLEMENTATION_READY_FOR_REVIEW:/' '<discussion-file>'
```

If that prints any line: report `implementation ready for review` and jump to Step 6 (final review phase).

### 5c. Read the tail marker

```bash
grep -E '^END:[[:space:]]+(TEST-ENGINEER|SOFTWARE-ENGINEER)[[:space:]]*$' '<discussion-file>' \
  | tr -d '\r' \
  | tail -n 1 \
  | sed -E 's/^END:[[:space:]]+//; s/[[:space:]]+$//'
```

Capture the result as `tail_actor` (may be empty if no marker exists yet).

### 5d. Decide next role

**Sketch mode (`SKETCH=true`):** `next = software-engineer`, always — there is no alternation and the test-engineer is never dispatched. Each SE turn implements the next sketch story; the loop exits via 5b when the SE appends `IMPLEMENTATION_READY_FOR_REVIEW:` after the last story's Phase A proof.

**TDD mode:**
- `tail_actor` empty → `next = test-engineer` (test engineer always opens; matches `opener: test-engineer` in the header)
- `tail_actor` is `TEST-ENGINEER` → `next = software-engineer`
- `tail_actor` is `SOFTWARE-ENGINEER` → `next = test-engineer`
- Anything else → abort with `"unrecognized tail state: <tail_actor>"` for human review

### 5e. Mint the turn id, capture `tail_before` and a changed-file snapshot
Save the raw tail line (or `<none>` if `tail_actor` was empty). Used after the Task call to verify the subagent actually wrote.

Mint this turn's id and the draft-file path. The orchestrator computes them **once here** and reuses them for create (5f) and delete (5g.1), so the draft temp is always cleaned by its **exact** name regardless of what the agent does. **The timestamp is minted here, by `/work`, never inside the agent** — an agent that recomputed `date` across its separate Bash calls would produce a name `/work` could not later delete:

```bash
TS=$(date -u +%Y%m%d-%H%M%S)                                       # minted once per turn by /work (UTC)
TURN_ID=<epic-slug>-<scope>-$TS-t<turn_count>                      # epic+scope+timestamp+turn — unique across cycles, runs, and parallel worktrees
DRAFT_FILE=<root>/{{DRAFT_DIR}}.<next>-response-$TURN_ID.md        # <next> = test-engineer | software-engineer
```

Also snapshot the set of changed files in `<root>` so Step 5g.1 can attribute this turn's edits and reject out-of-lane writes:

```bash
git -C '<root>' status --porcelain -uall | cut -c4- | sort > '/tmp/work-<epic-slug>-<scope>-before-<turn>'
```

`-uall` is required so git lists each new file individually instead of collapsing it into a directory path; `sort` is required because Step 5g.1 feeds these snapshots to `comm`, which assumes sorted input.

### 5f. Dispatch the subagent
Call the Agent tool with `subagent_type` equal to `next` (`test-engineer` or `software-engineer`) and this prompt verbatim, substituting `<root>`, `<EPIC_FILE>` (= `<root>/<epic-relative-path>`), `<DISCUSSION_FILE>`, `<SCOPE>`, `<DRAFT_FILE>` (from 5e), and `<ENV>` (whatever Step 4 captured):

```
Continue the TDD implementation cycle for EPIC <EPIC_FILE>.

Working root: <root>            # ALL paths below resolve under this root. In variant mode this is an isolated git worktree, NOT the main repo.
Discussion file: <DISCUSSION_FILE>
Scope: <SCOPE>                  # if not "all", work ONLY this variant's Stories and run ONLY its target.
Environment: <ENV>             # whatever the pre-flight captured, or "n/a"
Build cache: keep each worktree's build cache isolated outside the repo (see the profile's build-cache rule) so it never pollutes the git-status lane check.

SINGLE-TURN CONTRACT (OVERRIDES everything below):
- ONE turn = ONE role = ONE append (ONE "END: <ROLE>") = ONE `cat >>`, then STOP and return your one-sentence summary.
- Do NOT switch/impersonate the other role.
- Do NOT spawn or dispatch any sub-agent.
- Append "IMPLEMENTATION_READY_FOR_REVIEW:" ONLY when this turn IS it (test-engineer, every in-scope Task already green).

Follow your discussion-channel protocol exactly:
1. Read the EPIC file and the discussion file for full context. The EPIC's `## Verification Gate` is binding. The discussion file's last turn (if any) tells you what was just done.
2. Do the work your persona owns this turn:
   - If you are test-engineer: identify the next unimplemented in-scope Task, write its failing test under the exact verify path the Task names, then run the test using the project's test command and capture the failing assertion line. Honor the scope (Tasks in dependency order for "all"; only the named variant's Stories otherwise). When a Task has no `Action — RED:` block (GREEN-only), write a GREEN-ONLY pass-through turn listing the Task(s) for the software-engineer; do not write tests for them; after the SE's turn, run a build-only check. When every in-scope Task is green, run the in-scope Verification Gate and prepare an IMPLEMENTATION_READY_FOR_REVIEW turn if green.
   - If you are software-engineer: read the most recent TEST-ENGINEER turn, identify the failing test and the seam it imports, and edit production sources to make that test green with the smallest correct change. If the last TEST-ENGINEER turn is a GREEN-ONLY pass-through, read the Story file path and Task IDs from the turn and implement all listed Tasks' GREEN+REFACTOR specs from the Story file. Stay in the scope's source dir. Never edit the test targets. If an in-scope test needs a base-variant seam that does not exist yet, do NOT create it outside your scope — flag OPEN:. Do not run tests.
3. Draft your turn into exactly this file: <DRAFT_FILE>
4. Append your turn to the discussion file via shell:  cat '<DRAFT_FILE>' >> '<DISCUSSION_FILE>'
5. Re-read the tail of the discussion file and verify the final non-blank line is exactly "END: <YOUR_ROLE>".
6. Do NOT delete <DRAFT_FILE> — /work removes it by its exact name after this turn.
7. STOP and return your one-sentence summary.

Do NOT use an editor on the discussion file — only shell append.
Do NOT edit files outside your lane AND scope (see the lane table in your persona).
Do NOT edit the EPIC or Story files — those are locked by planning. Do NOT touch the build/project config files (see the always-forbidden list in your persona).

If you are test-engineer and you have just confirmed that every in-scope Task is green AND the in-scope Verification Gate runs green end-to-end, append an IMPLEMENTATION_READY_FOR_REVIEW turn (still ending with END: TEST-ENGINEER). /work greps "^IMPLEMENTATION_READY_FOR_REVIEW:" to stop the TDD loop and hand the cycle to the human for review.
```

**When `SKETCH=true`, append the sketch-mode paragraph from `{{> SKETCH_MODE}}`** (and ignore the test-engineer branches above — only the software-engineer is ever dispatched). The sketch paragraph instructs the SE to work the sketch stories one per turn against stub data, produce the proof artifacts, and append `IMPLEMENTATION_READY_FOR_REVIEW:` after the last story.

Also append, for both modes:

```
If this turn is a failed attempt at the active Task — you raised an "OPEN:" blocker (missing copy, a missing seam, an unimplementable acceptance criterion), or (test-engineer) a confirm-GREEN turn found the test still red — add an "ATTEMPT-FAILED: <task-id> — <reason>" line just above your END marker. /work counts these per Task: {{ATTEMPT_LIMIT}} failed attempts on the same Task escalates it to the human.

Return one short sentence summarizing what you wrote.
```

### 5g. Verify the subagent wrote
Re-read the tail (same pipeline as 5c) and also check for any new `^IMPLEMENTATION_READY_FOR_REVIEW:` line. Compare with `tail_before`:
- If the tail is unchanged AND no new `IMPLEMENTATION_READY_FOR_REVIEW:` line appeared → abort with `"subagent <next> returned but discussion file unchanged"`. Leave the file as-is for human review.

### 5g.1 Lane ownership check (git diff)

Lane boundaries are stated in the personas but nothing enforces them. Compute the files this turn changed (in `<root>`) and reject any write outside `next`'s lane **for the active scope** — a cheap backstop, concurrency-safe because each cycle's `<root>` is a separate worktree.

```bash
git -C '<root>' status --porcelain -uall | cut -c4- | sort > '/tmp/work-<epic-slug>-<scope>-after-<turn>'
TURN_FILES=$(comm -13 '/tmp/work-<epic-slug>-<scope>-before-<turn>' '/tmp/work-<epic-slug>-<scope>-after-<turn>')
```

The lane predicate — which paths each role may touch **per scope** — comes from the profile. A simple **prefix table** works only when source and tests live in disjoint top-level dirs; ecosystems that **co-locate** tests with source (`foo.go`+`foo_test.go`, `__tests__/` siblings, golden/snapshot/fixture files, generated contracts) need a **predicate script** instead. The profile supplies whichever fits:

{{> LANE_OWNERSHIP}}

Both roles may also write `{{DRAFT_DIR}}` and their own `{{MEMORY_DIR}}<role>/` journal dir (under `<root>`). In sketch mode the software-engineer may additionally write the proof-artifact dir named in `{{> SKETCH_MODE}}`.

If any path in `TURN_FILES` fails the active role+scope predicate (or hits an always-forbidden path) → abort with `"lane violation: <role>/<scope> changed <path>"` and leave the tree for human review. (`<DRAFT_FILE>` itself lives under `{{DRAFT_DIR}}` and so is always in-lane.)

Otherwise the turn is clean. Delete this turn's draft temp by its **exact** path — the orchestrator owns this cleanup: `rm -f '<DRAFT_FILE>'`. Then remove the two `/tmp` snapshot files.

### 5h. Escalation — one Task fails its attempt limit → Human

After verifying the subagent wrote, check whether this turn was a **failed attempt** at the active Task. Engineers mark a failed attempt with a greppable line `ATTEMPT-FAILED: <task-id> — <reason>`.

```bash
LAST_FAIL=$(grep '^ATTEMPT-FAILED:' '<discussion-file>' | tail -1)
```

If `LAST_FAIL` is empty → no failed attempt this turn — skip to 5i.

Otherwise extract its `<task-id>` (everything between `ATTEMPT-FAILED:` and the ` — ` em-dash delimiter) and count how many failed attempts that same Task has accumulated **in the current review cycle**. Splitting on the em-dash only — not on any hyphen — is load-bearing: task-ids contain hyphens, so a `[—-]` split would truncate them. Scoping the count to lines after the last review-fail boundary stops a Task that already went green in an earlier cycle from inheriting stale failures and false-escalating:

```bash
TASK_ID=$(printf '%s\n' "$LAST_FAIL" | sed -E 's/^ATTEMPT-FAILED:[[:space:]]*//; s/[[:space:]]*—.*$//')
FAIL_LINE=$(grep -nE '^(HUMAN_REVIEW: FAIL|AUTO_REVIEW: FAIL)' '<discussion-file>' | tail -1 | cut -d: -f1)
FAIL_COUNT=$(awk -v s="${FAIL_LINE:-0}" 'NR>s' '<discussion-file>' | grep -F "ATTEMPT-FAILED: $TASK_ID —" | wc -l | tr -d ' ')
```

- If `FAIL_COUNT < {{ATTEMPT_LIMIT}}` → log `attempt <FAIL_COUNT>/{{ATTEMPT_LIMIT}} failed for task <TASK_ID>` and continue to 5i.
- If `FAIL_COUNT >= {{ATTEMPT_LIMIT}}` → the Task is stuck. **Stop the loop and escalate to the human operator** — print the failed-attempt lines, the discussion file path, and instructions to resolve the blocker and re-run `/work`. Jump to Step 8 with `reason=human-escalation`.

(A Task that flips to GREEN simply stops emitting `ATTEMPT-FAILED:` lines, so only a Task that never goes green reaches the limit.)

### 5i. Increment and continue
`turn_count += 1`. Loop back to 5a.

## Step 6 — Human review handoff

Reached when Step 5b detects `^IMPLEMENTATION_READY_FOR_REVIEW:`. All Tasks are green and the verification gate has passed. Final review is the **human operator's**, recorded as a `HUMAN_REVIEW:` line.

### 6a. Check for the human verdict

```bash
grep -E '^HUMAN_REVIEW: (PASS|FAIL)' '<discussion-file>' | tail -1
```

- Latest line is `HUMAN_REVIEW: PASS` → jump to Step 7 (close lifecycle).
- Latest line is `HUMAN_REVIEW: FAIL` → jump to Step 6d (review failure routing).
- No `HUMAN_REVIEW:` line yet → proceed to Step 6b (reviewer-engineer pre-gate).

### 6b. Reviewer-engineer review gate + auto-routing of `action:YES` findings

The reviewer-engineer IS the code review. Every finding it returns is tagged `action:YES` (must be applied) or `action:NO` (no-op / informational). The orchestrator auto-routes the `action:YES` findings straight back through the TDD loop — **once** per review cycle — and surfaces only the `action:NO` findings to the human.

**First, has the auto-fix pass already run this review cycle?** It fires at most once between human verdicts:

```bash
LAST_HUMAN=$(grep -n '^HUMAN_REVIEW:' '<discussion-file>' | tail -1 | cut -d: -f1)
AUTO_DONE=$(awk -v s="${LAST_HUMAN:-0}" 'NR>s && /^AUTO_REVIEW: FAIL/' '<discussion-file>')
```

- If `AUTO_DONE` is **non-empty** → the `action:YES` findings were already routed and fixed this cycle. **Do not re-dispatch the reviewer.** Read back the recorded `action:NO` findings (`awk -v s="${LAST_HUMAN:-0}" 'NR>s && /^INFO: /' '<discussion-file>'`), present them to the human, and skip to Step 6c.
- If `AUTO_DONE` is **empty** → dispatch the reviewer now.

Extract the base ref and compute the changed files:

```bash
BASE_REF=$(grep '^base-ref:' '<discussion-file>' | head -1 | sed 's/^base-ref:[[:space:]]*//')
CHANGED_FILES=$(git -C '<root>' diff --name-only "$BASE_REF"..HEAD)
```

Dispatch one `reviewer-engineer` agent (substituting `<root>`, `<EPIC_FILE>`, `<DISCUSSION_FILE>`, `<SCOPE>`, `<BASE_REF>`, `<CHANGED_FILES>`, and the phase):

```
Review the implementation for EPIC <EPIC_FILE>.

Working root: <root>
EPIC file: <EPIC_FILE>
Discussion file: <DISCUSSION_FILE>
Scope: <SCOPE>
Phase: <"A (sketch) — apply the Phase A review scope from the profile" when SKETCH=true, else "B (lock) — all dimensions">
Base ref: <BASE_REF>
Changed files (review ONLY these — do not review unchanged files):
<CHANGED_FILES>

Follow your per-review workflow exactly. Read the gotcha files first, then the EPIC/Story files, then the changed source and test files. Cross-reference against all review dimensions and produce your structured verdict.
```

**Parse the reviewer's verdict** into two lists by each finding's `action:` tag: `YES` = apply, `NO` = informational.

- **If any `action:YES` finding exists** → auto-route them through the TDD loop (single pass). Append **one** routing block to the discussion file — the lone post-seed write the orchestrator makes. Each `action:YES` becomes a `BLOCKER:` the test-engineer turns into a regression; each `action:NO` is recorded as `INFO:` so it survives to the human pause:

  ```bash
  cat >> '<discussion-file>' <<'WORK_EOF'
  AUTO_REVIEW: FAIL — routing <N> action:YES finding(s) to the TDD loop; <M> action:NO finding(s) recorded for the human.
  BLOCKER: <action:YES finding 1 — name + one-line description>
  INFO: <action:NO finding 1 — name + one-line description>
  WORK_EOF
  ```

  Then print the routed blockers, reset `turn_count` to 0, and **jump back to Step 5**. When the loop next reaches `IMPLEMENTATION_READY_FOR_REVIEW:`, the `AUTO_DONE` guard fires and the cycle proceeds to the human pause with only the `action:NO` findings.

- **If no `action:YES` finding exists** → print the reviewer's full verdict, present any `action:NO` findings, and proceed to Step 6c.

### 6c. Pause for human confirmation

The reviewer's verdict is the review. Stop the loop and present it to the human for confirmation. Do **not** close the lifecycle.

```
REVIEW COMPLETE — <EPIC_SLUG> [scope: <SCOPE>]

Any action:YES findings were auto-routed through the TDD loop and fixed; only the action:NO findings (above) were left unapplied. All in-scope Tasks are green and the in-scope verification gate passed.

Record your decision in the discussion file (append, do not edit) and re-run /work with the same flags:
  - To accept:    append `HUMAN_REVIEW: PASS`
  - To send back: append `HUMAN_REVIEW: FAIL` followed by one `BLOCKER: <issue>` line per finding to fix

Discussion file: <DISCUSSION_FILE>

Next (variant mode): once every dependent variant cycle reads PASS and is committed, run `/work <epic> --join --base <base-ref>` to merge and gate all variants together.
```

**Sketch mode (`SKETCH=true`)** — use the sketch pause message from `{{> SKETCH_MODE}}` instead (it points the human at the proof artifacts and the feedback dir). Jump to Step 8 with `reason=awaiting-human-review`.

### 6d. Review failure routing

When the human recorded `HUMAN_REVIEW: FAIL`:

1. Collect all `BLOCKER:` lines that follow the failing verdict.
2. Print them to the user.
3. Reset `turn_count` to 0.
4. Jump back to Step 5. The test engineer turns testable blockers into failing regression tests; the software engineer fixes them. When the TE signals `IMPLEMENTATION_READY_FOR_REVIEW:` again, Step 6 re-runs.

Note: if the human fails review {{ATTEMPT_LIMIT}} times in one `/work` invocation, stop with `lifecycle=review-loop-limit` and let the human intervene directly.

## Step 7 — Close

Reached when Step 6a confirms `HUMAN_REVIEW: PASS`. That line **is** the closing record — there is no frontmatter or status board to update.

- **Serial mode**: the EPIC is done. Report closed, continue to Step 8 with `lifecycle=closed`.
- **Variant mode**: only this *scope* is done — the EPIC is not closed until `--join` gates every variant. Report `<SCOPE> scope closed`, remind the human to commit the worktree branch so `--join` and the other variants' `--base` can see it, and continue to Step 8 with `lifecycle=closed` (for this scope).

## Join mode (`--join`)

Entered from Step 1 when `--join` is set. Join does not run a TDD loop — it integrates the finished variant branches and runs the EPIC's full Verification Gate on **every** target.

### J1. Pre-flight
- `REPO_ROOT=$(git rev-parse --show-toplevel)`.
- Every dependent variant branch exists: `work/<epic-slug>-<variant>` for each. If any is missing, abort naming it.
- Each variant's discussion file has a latest `HUMAN_REVIEW: PASS`. If any has not passed, abort: `"join refused: <variant> has not passed human review"`.

### J2. Build the join worktree and merge
```bash
JOIN_BRANCH="work/<epic-slug>-join"
JOIN_PATH="$REPO_ROOT/../{{REPO_NAME}}-worktrees/<epic-slug>-join"
git -C "$REPO_ROOT" worktree add -b "$JOIN_BRANCH" "$JOIN_PATH" "<base-ref>"
git -C "$JOIN_PATH" merge --no-ff <all variant branches>
```
If the merge reports conflicts → stop and hand to the human. Conflicts should be rare (variants edit disjoint dirs); a conflict in the shared layer means both variants diverged it and a human must reconcile.

### J3. Gate every target
Set `<root>` = `JOIN_PATH`. Run the env pre-flight (Step 4). Seed a join discussion file (`scope: join`, `opener: test-engineer`). Dispatch **one** test-engineer turn (the Step 5f prompt with scope `all`) plus:

> Do not write new tests. Run the EPIC's full `## Verification Gate` on EVERY target. Append a turn reporting each target's exit code; if all are green append `IMPLEMENTATION_READY_FOR_REVIEW:`, otherwise name the failing target/test and end the turn.

### J4. Hand to human
- Both/all gates green → pause for human review like Step 6c (verdict in the join discussion file). On `HUMAN_REVIEW: PASS` the EPIC is done — the human merges the join branch and removes the worktrees. `reason=join-ready`.
- A gate is red → report the failing target/test. The human routes the fix to the relevant `--variant` cycle (re-run it, re-PASS, re-join). Do not fix it in the join worktree. `reason=join-gate-failed`.

Then go to Step 8.

## Step 8 — Exit

When the run ends, print a one-line summary:
- `done · mode=<serial|variant:<V>|join> · turns=<N> · reason=<...> · human_review=<PASS|FAIL|pending> · lifecycle=<opened|closed> · root=<root>`

`lifecycle=opened` means the discussion file was seeded this run; `closed` means a `HUMAN_REVIEW: PASS` was confirmed. Then print a short bullet list of what happened this run.

**Worktree cleanup (variant/join modes).** Never auto-remove a worktree. When the human has merged a branch:

```bash
git -C "$REPO_ROOT" worktree remove ../{{REPO_NAME}}-worktrees/<epic-slug>-<scope>
git -C "$REPO_ROOT" branch -d work/<epic-slug>-<scope>    # only after it is merged
```

## Notes for the orchestrator (you)

- Use `Bash` for `grep`/`sed`/`tail`/`awk`/path checks and the one-time seed. Use `Read` for the EPIC's `## Verification Gate`. Use `Agent` for subagent dispatch. The orchestrator touches the discussion file only via the Step 3 seed and the Step 6b auto-review block.
- Do not summarize, judge, or editorialize turns between dispatches. You dispatch; you do not participate.
- Test engineer always opens. The first dispatch is always `test-engineer` if the file is fresh (software-engineer in sketch mode).
- If the user interrupts, stop cleanly. Each subagent's append is atomic, and the orchestrator holds no other mutable state.
- **Parallel discipline (variant mode).** base variant first → commit → dependent variant cycles with `--base <base-ref>` in their own worktrees → `--join`. Each cycle is fully isolated. Never run two cycles of the *same* variant concurrently.
- **GREEN-only Task flow.** Some Tasks have no `Action — RED:` block. The cycle is compressed: TE writes a GREEN-ONLY pass-through → SE implements GREEN+REFACTOR → TE runs a build-only check (no test) and advances.
- **Sketch mode summary.** SE-only turns through the sketch stories (5d never alternates), SE is the discussion-file opener, env pre-flight may be skipped (per profile), the lane check additionally allows the proof-artifact dir, and the exit is the same `IMPLEMENTATION_READY_FOR_REVIEW:` marker → reviewer with Phase A scope → human visual review.
