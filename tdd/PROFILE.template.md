# Project Profile — TEMPLATE

Copy this file into your project as `PROFILE.md` and fill in **every** token
and slot below. The skeleton files (`commands/work.md`, `agents/*.md`)
reference these by name; rendering the skeleton with this profile produces the
agent/command files your harness runs.

> Rule: a blank token or slot is a setup error. The skeleton names exactly what
> it needs and will not guess a language, a build command, or a directory.

---

## 1. Path & constant tokens

Single values, substituted literally wherever `{{TOKEN}}` appears.

| Token | What it is | Example |
|---|---|---|
| `{{REPO_NAME}}` | repo dir name, used to derive sibling worktree paths | `myapp` |
| `{{PLAN_EPICS_DIR}}` | dir holding EPIC files (the unit `/work` operates on) | `.agents/plan/v2/epics/` |
| `{{PLAN_STORIES_DIR}}` | dir holding Story files (Tasks live here) | `.agents/plan/v2/stories/` |
| `{{PLAN_FEEDBACK_DIR}}` | dir holding human feedback consumed by authoring | `.agents/plan/v2/feedback/` |
| `{{DISCUSSION_DIR}}` | append-only discussion/history files, one per cycle | `.agents/debate/history/` |
| `{{DRAFT_DIR}}` | where engines stage per-turn draft + build-check temp files | `.agents/debate/` |
| `{{MEMORY_DIR}}` | per-role decision-journal dirs + gotcha files | `.agents/memory/` |
| `{{AGENT_DIR}}` | where the three agent persona files live | `.claude/agents/` |
| `{{DEFAULT_TURN_CAP}}` | default max turns per cycle before the loop yields | `128` |
| `{{ATTEMPT_LIMIT}}` | failed attempts on one Task before escalating to human | `3` |
| `{{LOCATOR_DEFN_LABEL}}` | the test-engineer turn-format section label for newly declared UI locators — keep it consistent with whatever `{{> UI_LOCATOR_CONTRACT}}` calls them | `TestID identifiers defined` |
| `{{ENV_HANDOFF_LABEL}}` | the dispatch-prompt label for the env value the pre-flight captured (so the hand-off is concrete, not opaque) | `Pre-booted simulator UDID` |

> Workflow **marker strings are NOT tokens** — they are protocol constants and
> stay literal in every rendering: `END:`, `IMPLEMENTATION_READY_FOR_REVIEW:`,
> `ATTEMPT-FAILED:`, `HUMAN_REVIEW:`, `AUTO_REVIEW:`, `BLOCKER:`, `INFO:`,
> `OPEN:`. Do not rename them — the orchestrator greps for them verbatim.

---

## 2. Slots

Each slot is a full section the skeleton drops in by name (`{{> SLOT}}`). The
heading says what the slot is *for*; write the body for your project.

### `{{> GATE_LABEL_EXAMPLES}}`
The concrete per-target gate-line labels the test-engineer uses when reporting
the Verification Gate (e.g. the build/test target or scheme names), so the
turn format names real targets instead of a generic "per-target gate lines".
Supplied as a slot because the labels carry backticks/asterisks.

### `{{> JOIN_GATE_TARGETS}}`
The exact set of targets/schemes the join gate must run the full Verification
Gate over — the cross-variant attestation. Name each build target/scheme
explicitly (don't leave "every target" ambiguous). Slot, not token, for the
backtick-bearing command fragments.

### `{{> VARIANT_VALUES}}`
The pipe-separated enum of this project's variant names exactly as a user types
them after `--variant` (e.g. `shared|ios|macos`, or `app` for a single-variant
project). The skeleton substitutes it into the `/work` argument-hint and the
flag documentation so the command self-documents its accepted values instead of
a generic `<name>`. Supplied as a slot (not a token) because the `|` separators
would be read as column delimiters in a Markdown token table. Must agree with the
variants defined in `{{> VARIANTS_AND_SCOPES}}`.

### `{{> SE_FRONTMATTER}}` / `{{> TE_FRONTMATTER}}` / `{{> RV_FRONTMATTER}}`
The per-agent YAML frontmatter lines the harness reads to register each
sub-agent — supplied as a slot (not a token) because the `description` is a long
line that may contain `|`, `:` and backticks that a Markdown token table cannot
hold. Each body is the literal frontmatter block for that role: a project-facing
`description:` line, the pinned `model:` (and `effort:` where the harness honors
it), and any other harness-specific keys. The skeleton wraps each with the
literal `name:` and `tools:` lines, so do **not** repeat those here. Omitting the
model pin means the agent runs on the harness default — usually not what you
want, so set it explicitly.

### `{{> PROJECT_CONTEXT}}`
One short paragraph: what the project is, and the **hard tech constraints**
every engineer must honor (allowed dependencies, frameworks, "no X" rules).
Each agent file opens with this so a fresh dispatch has bearings.

### `{{> VARIANTS_AND_SCOPES}}`
Define the **variant axis** — the independent build targets a cycle can be
scoped to. For each variant: its name, the dirs it owns, its build target /
scheme, and its **dependency order** (which variants must be done first). State
the build-isolation guarantee that lets independent variants run in parallel
worktrees, **and the merge strategy** for join mode — name the files that are
shared across variants (package manifests, lockfiles, generated schemas,
integration tests) and the policy when two variants touch one (the default is
"conflict → human reconciles"). Parallel worktrees + join is only clean when
variant ownership is genuinely disjoint; if it is not, say so here. A
single-variant project defines exactly one (e.g. `app`) and the
parallel/worktree machinery collapses to a no-op.

### `{{> SOURCE_AND_TEST_LAYOUT}}`
The directory + module map: where production source lives per variant, where
unit tests live, where UI/E2E tests live, module/import names, and the
file-naming convention for new source and test files.

### `{{> LANE_OWNERSHIP}}`
The **lane predicate**: which paths each role may touch, **per scope**. The
orchestrator git-diffs the worktree after every turn and rejects out-of-lane
writes; the agents self-police against the same rule. Must cover the
test-engineer's lane and the software-engineer's lane, for every scope in
`VARIANTS_AND_SCOPES` plus the `all` (serial) scope, and the paths **always
forbidden** to both (the locked plan files, the project/build config files).

Supply **one** of:
- a **prefix table** — only valid when production source and tests live in
  disjoint top-level dirs (a pure prefix can then separate the two lanes); or
- a **predicate script** (`scripts/lane-check.sh <role> <scope> <path>` →
  exit 0 = in-lane) — required when tests are **co-located** with source
  (`foo.go`+`foo_test.go`, `__tests__/` siblings) or when generated files,
  snapshots, fixtures, schemas, or contracts cross-cut directories, where a
  prefix rule cannot tell the two roles apart.

### `{{> BUILD_AND_TEST_COMMANDS}}`
The exact commands:
- **produce the handoff artifact** — for a compiled language this is "build";
  for an interpreted one it may be a lint/typecheck/import-smoke step. The
  software-engineer runs it before every handoff; the orchestrator may run it
  in the env pre-flight.
- **run unit tests** and **run UI/E2E tests** (used by test-engineer),
- **verify the handoff artifact / outcome** — a script (NOT a fragile grep)
  that returns a machine-readable PASS/FAIL, which the test-engineer re-runs to
  independently confirm the software-engineer's claim (the **handoff
  verification gate**; see the skeleton). If the language has no build step,
  this verifies the typecheck/lint/import-smoke outcome instead — the invariant
  is *independent re-verification of the claimed artifact*, not "compilation".
State any rule about build-cache isolation so parallel worktrees don't collide.

### `{{> ENV_PREFLIGHT}}`
Machine-level resources the orchestrator must boot **once** before the loop
(e.g. an emulator/simulator/db) and pass into every dispatch. Include the
command and what to capture. Write `None.` if the project needs none.

### `{{> GOTCHA_FILES}}`
Index of the project's accumulated-pitfall files under `{{MEMORY_DIR}}` and,
for each, **when** an agent must read it (e.g. "before writing concurrency
code", "before any UI test"). These are the agents' mandatory checklists.

### `{{> IDIOM_CHECKLIST}}`  *(software-engineer)*
The language/framework idiom rules the software-engineer applies on every edit:
allowed patterns, persistence rules, concurrency rules, access-control
defaults, dependency-injection seam style. The opinionated core of "clean code"
for this stack.

### `{{> TEST_CONVENTIONS}}`  *(test-engineer)*
Unit-vs-UI framework conventions, what each may import, suite/file structure,
file-naming, and a pointer to where the reusable test patterns live. Include
any per-framework launch/setup requirement.

### `{{> UI_LOCATOR_CONTRACT}}`  *(optional — UI/E2E projects)*
If the project drives a UI in tests, define the **locator registry** contract:
where stable element identifiers are declared, who declares them
(test-engineer), who consumes them (software-engineer), the naming format, and
the rule that tests never inline literal locators. Write `Not applicable.` if
there are no UI/E2E tests.

### `{{> COPY_SOURCING}}`  *(optional — products with locked user-facing copy)*
The rule for sourcing user-facing strings (where the canonical copy lives, how
to verify a string before asserting/hard-coding it, what to do when it's
missing). Write `Not applicable.` if the project has no locked copy.

### `{{> REVIEW_DIMENSIONS}}`  *(reviewer-engineer)*
The concrete review dimensions, replacing the skeleton's generic list. Keep the
skeleton's structure (each finding cites a source) but fill in the
language/stack specifics: the concurrency/safety rules to check, the security &
data-handling checklist, the simplicity rules (including any "allowed
components only" constraint), and which dimensions are skipped in the optional
sketch phase.

### `{{> SKETCH_MODE}}`  *(optional — projects with a pre-test review phase)*
A **Phase A** lets the software-engineer build output against stub data gated by
human review instead of tests. Because it is a sanctioned **test-bypass**, it is
only safe if you define all five of: (1) which stories it covers; (2) the
concrete **proof artifact** the SE produces (screenshots, a rendered report, a
recorded API response — not "looks right"); (3) the **comparator / acceptance
method** the reviewer + human apply to that artifact; (4) the constraints that
hold during Phase A and which review dimensions stay in-scope; (5) a
**shipped-file regression guard** — because the gate is artifact-only, it does
not cover the blast radius of a change to a file the shipped product already
exercises. Require sketch changes to live in new standalone surfaces, OR, when a
sketch must edit a shipped non-preview file, mandate that the locked test suite
run and pass for the affected area (reported in the proof artifact, checked by
the reviewer and the human) — otherwise a sketch can silently regress the
shipped path. Without a concrete artifact and acceptance method this is just
permission to skip tests — write `Not applicable — all work is test-gated.`
instead, and the orchestrator's `--sketch` flag then errors.

---

## 3. Optional capability flags

State `yes`/`no`; the skeleton branches on these.

| Capability | Question |
|---|---|
| Multi-variant parallelism | More than one build variant that can run in parallel worktrees? |
| Sketch phase | Is `{{> SKETCH_MODE}}` enabled (a non-test visual-review phase)? |
| UI/E2E tests | Does the project have UI/E2E tests (enables `{{> UI_LOCATOR_CONTRACT}}`)? |
| Locked copy | Does the project have locked user-facing copy (enables `{{> COPY_SOURCING}}`)? |
