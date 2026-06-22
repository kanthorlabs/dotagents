# Baking a TDD pipeline from the skeleton — common procedure

"Baking" = turning the language-agnostic skeleton (`../`) into a **runnable,
language-specific** four-role TDD pipeline dropped into a target project's
`.claude/`. You do it once per language/stack. This file is the
language-agnostic procedure; the per-language guides (`BAKING-flutter-dart.md`,
`BAKING-python.md`) fill in the stack specifics.

The pipeline's four roles, the loop, and the contract live in `../README.md` —
read it first. This file is the *how-to-instantiate*, not the *what-it-is*.

---

## 0. Prerequisites (the skeleton's host assumptions)

The skeleton is "language-agnostic" but **not** host- or process-agnostic. The
target environment must provide:

- **git** — worktrees (parallel variants) and `git status`/`git diff` (lane
  ownership check).
- **a POSIX shell** — `cat >>`, `grep`, `awk`, `/tmp` (the discussion-file
  protocol and orchestrator steps).
- **an agent harness** that can dispatch named sub-agents and run a
  `/work`-style command (Claude Code, or equivalent).
- **the planning grammar** — work must be authored as **EPIC → Story →
  `### Task`**, each Task carrying `Action — RED:` / `Action — GREEN:` /
  `Action — REFACTOR:` and each EPIC a `## Verification Gate`. This is a
  convention you adopt, not something the profile changes.

If any is missing, you are porting the framework, not just baking a profile.

---

## 1. Steps to bake

### Step 1 — locate the skeleton (do NOT vendor it into the target)
This `tdd/` skeleton has **one home** — this repo. Don't copy it into the target
project; that just re-creates the duplication you're trying to avoid. Run the
renderer against this skeleton in place and write only the baked `.claude/` into
the target. The target repo keeps **only** the runnable `.claude/` — not the
skeleton, not the filled `PROFILE.md`, and no skeleton-provenance metadata. The
target stays unaware it was baked: as far as it's concerned `.claude/` is just
its TDD pipeline. A re-bake renders the *current* skeleton and diffs against the
target's existing `.claude/` (the diff is the reference — no stored provenance
needed).

### Step 2 — fill `PROFILE.md`
Copy `PROFILE.template.md` → `PROFILE.md` and fill **every** token and slot. The
template lists them all with descriptions. A blank token/slot is a bake error —
the skeleton refuses to guess a language, a command, or a directory. Derive the
values from the **target project's own conventions** (its `CLAUDE.md`, gotcha
files, build setup); use the per-language guide here as a worked model.

The slots that carry the most stack-specific weight, in rough order:
1. `{{> VARIANTS_AND_SCOPES}}` — how many build targets, their dependency order, merge strategy.
2. `{{> SOURCE_AND_TEST_LAYOUT}}` — dirs, modules, file naming.
3. `{{> LANE_OWNERSHIP}}` — **prefix table OR predicate script** (see lesson L2).
4. `{{> BUILD_AND_TEST_COMMANDS}}` — produce-artifact, run-tests, **verify-handoff** (see lesson L1).
5. `{{> IDIOM_CHECKLIST}}`, `{{> TEST_CONVENTIONS}}`, `{{> REVIEW_DIMENSIONS}}`.
6. `{{> GOTCHA_FILES}}`, `{{> UI_LOCATOR_CONTRACT}}`, `{{> COPY_SOURCING}}`, `{{> SKETCH_MODE}}`.

### Step 3 — render skeleton + profile → the runnable files
Substitute every `{{TOKEN}}` (literal value) and expand every `{{> SLOT}}`
(profile section body) in `commands/work.md` and `agents/*.md`, writing the
results to the target's `.claude/commands/work.md` and `.claude/agents/*.md`.
Use the bundled renderer: `python3 render.py <skeleton-dir> <PROFILE.md>
<target>/.claude` — it substitutes every token/slot and **aborts on any
unresolved `{{...}}`** (so a missing profile entry fails loudly, not silently).
By hand works too. **Marker strings stay literal** (`END:`, `IMPLEMENTATION_READY_FOR_REVIEW:`,
`ATTEMPT-FAILED:`, `HUMAN_REVIEW:`, `AUTO_REVIEW:`, `BLOCKER:`, `INFO:`,
`OPEN:`) — never tokenize them; the orchestrator greps them verbatim.

### Step 4 — wire the project's scripts
Create the scripts the profile's `{{> BUILD_AND_TEST_COMMANDS}}` references:
- a **produce-artifact** command (build, or lint/typecheck/import-smoke for an
  interpreted language),
- **run-unit-tests** and **run-ui/e2e-tests**,
- a **verify-handoff** check returning machine-readable PASS/FAIL,
- (if the lane predicate is a script) `scripts/lane-check.sh <role> <scope> <path>`.

### Step 5 — author the gotcha files
Seed `{{MEMORY_DIR}}<lang>-gotchas.md` (and a test/UI gotcha file if applicable)
with the stack's known pitfalls. Start small; the engineers append to them.

### Step 6 — smoke-test the bake
Author one tiny throwaway EPIC (one Story, one RED Task) and run `/work` on it
end to end. Confirm: TE opens RED → SE GREEN → TE confirms → reviewer gate →
human pause. If the loop completes and the lane check / verify-handoff fire,
the bake is wired correctly. Delete the throwaway epic.

---

## 2. Lessons baked in (apply these in every language)

These come from running the skeleton against a real project and root-causing the
weirdness. They are stack-independent and **must** survive the bake.

- **L1 — "handoff verification", not "build proof".** The test-engineer
  independently re-verifies the artifact the software-engineer claims. For a
  compiled language that's a build; for an interpreted one it's a
  typecheck/lint/import-smoke. Make `verify-handoff` return a machine-readable
  PASS/FAIL — never a fragile grep.

- **L2 — lane ownership: prefix table only if dirs are disjoint.** If the stack
  **co-locates tests with source** (`foo.go`+`foo_test.go`, `__tests__/`
  siblings, `module_test.py` next to `module.py`), a prefix rule cannot separate
  the two roles' lanes — supply a **predicate script** instead. Getting this
  wrong lets an engineer write outside its lane undetected.

- **L3 — a RED test must prove *sensitivity*, and pin *edge + mechanism*.** Two
  implementations with identical signatures can diverge behaviorally
  (whitespace/newline handling, raw-vs-trimmed, ordering determinism, *which*
  side-effecting API is called). The RED test must assert the edge cases and the
  observable mechanism with concrete vectors — not just the happy path or the
  type signature. (Found repeatedly: loose RED tests let divergent code pass.)

- **L4 — never let the agent skip RED.** Dispatching the software-engineer with
  no failing test first ("just implement it") breaks the core invariant and
  voids the cycle. Every GREEN turn answers a specific RED (or a GREEN-only
  pass-through the test-engineer explicitly forwarded).

- **L5 — let the agent find the next Task.** The persona derives the next
  unimplemented Task from the discussion file. Do **not** hard-name the Task in
  the dispatch ("GREEN for Task SB0.1") — that steers the agent and hides
  task-discovery bugs. Use `/work`'s canonical dispatch, not a hand-rolled one.

- **L6 — run the real `/work`, not a hand-driven loop.** Hand-dispatching skips
  the orchestrator's turn-id minting, draft cleanup, lane check, 3-strike
  escalation, and reviewer auto-routing — exactly the safety machinery that
  makes the loop trustworthy.

- **L7 — VALIDATION INTEGRITY (critical for cross-language verification).** When
  you verify a bake by re-implementing an *already-solved* task and comparing to
  the reference solution, the agent must **not be able to read the reference
  answer**. If the reference lives in the same git history (a later commit, a
  sibling branch, a `git stash`), the agent can `git show`/`git log` it and
  **copy** instead of re-deriving — silently invalidating the verification.
  Either run from a checkout with the reference **absent from history**, or add
  an explicit prohibition to the dispatch prompt + a lane/command guard. (This
  was the prime suspect behind suspiciously near-verbatim "re-derivations".)

- **L8 — GUI/screenshot/UI-test hosts have a TCC/window-server failure mode.**
  On macOS, apps can launch but report `windows: 0` (and screenshots/UI tests
  silently fail) when Automation/Accessibility/window-server state degrades —
  often mid-session after many launches. It looks like code or Screen Recording
  but is neither; the fix is reboot + re-grant the runner's Automation +
  Accessibility. Bake a host-preflight check into the env step for any stack
  whose gate needs a real window.

- **L9 — the fidelity gate is a diff against the existing `.claude/`, not trust
  in the profile.** Generalizing the skeleton silently drops stack-specific
  detail at the boundary (model pins, flag enums, gate/locator labels, test
  budgets, concurrency rules all vanished in the original Swift bake and had to
  be re-found). The profile is bake *scratch*; the durable cache of correct
  decisions is the committed `.claude/` itself. So a **re-bake** must diff the
  freshly rendered `.claude/` against the prior committed one and reconcile every
  delta — that is what catches the drops. Corollary: don't persist a `PROFILE.md`
  as a second source of truth beside `.claude/` (it's duplication that goes
  stale); re-derive it each bake and throw it away. **First-bake caveat:** a
  greenfield bake has no baseline to diff, so the gate there is an adversarial
  review (e.g. a `/debate`-compare) — the diff-gate only protects re-bakes.

---

## 3. Bake verification checklist

Before trusting a baked pipeline:

- [ ] Every `{{TOKEN}}`/`{{> SLOT}}` is filled; no `{{...}}` remains in the rendered `.claude/` files (`render.py` enforces this).
- [ ] Re-bake: the freshly rendered `.claude/` was diffed against the prior committed `.claude/` and every delta reconciled; first bake (no baseline): an adversarial review stood in for the diff (L9).
- [ ] `verify-handoff` returns machine-readable PASS/FAIL (L1).
- [ ] Lane predicate correctly separates the two roles for THIS layout (L2) — test it with a path from each lane.
- [ ] The smoke epic (Step 6) completed: RED→GREEN→confirm→reviewer→human pause.
- [ ] A deliberately loose RED test is caught (write one that passes on first run; the persona should flag it) (L3).
- [ ] If verifying against a reference solution: the reference is unreachable from the agent's git history / explicitly forbidden (L7).
- [ ] If the gate needs a window: the host-preflight check passes (L8).
- [ ] `/work` (real orchestrator) drives it — not a hand-rolled loop (L5/L6).
