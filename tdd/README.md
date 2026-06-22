# TDD Orchestration Skeleton

A **language-agnostic** skeleton for a four-role, test-driven implementation
workflow. It captures the *mechanics* that do not change between projects —
the orchestration loop, the role contracts, the escalation rules, the
append-only discussion protocol — and leaves every language / platform / tool
detail as a **named extension point** a project fills in.

This skeleton was extracted from a Swift/SwiftUI project's working TDD
pipeline. Nothing language-specific survives in the skeleton itself; the Swift
specifics live in `examples/swift/PROFILE.md` as a worked instantiation.

## What this skeleton actually is (read this before adopting)

Calling it "language-agnostic TDD" is true but undersells what it commits you
to. More precisely, it is an **opinionated four-role TDD *orchestration*
framework** that assumes a specific host and a specific planning grammar.
Removing the Swift parts does not make those assumptions disappear — they are
baked into the mechanics, so adopt them eyes-open:

- **Host assumptions** (not just "any language"): a **git** repo (worktrees,
  diff-based lane checks), a **POSIX shell** (`cat >>`, `grep`, `awk`, `/tmp`),
  and an **agent harness** that can dispatch named sub-agents and run a
  `/work`-style command. Port to a non-git VCS or a non-shell environment and
  these need re-implementing, not just re-profiling.
- **Planning grammar** (a DSL, not universal TDD): the workflow presumes work
  is authored as **EPIC → Story → `### Task`**, each Task carrying
  `Action — RED:` / `Action — GREEN:` / `Action — REFACTOR:` blocks and each
  EPIC a `## Verification Gate`. The orchestrator and agents parse these by
  convention. If your planning artifacts don't use this grammar, you must adopt
  it (or rewrite the parsing) — it is the contract, not an implementation
  detail. A project's `PROFILE.md` fills the *slots*; it does **not** redefine
  this grammar.

### Opinionated policies vs pluggable slots

Two different kinds of "fixed" live in the skeleton, and it helps to know which
is which:

- **Deliberate policy invariants** — kept fixed on purpose because they are the
  spine of *this* methodology, not because they are universal: test-engineer
  always opens; the software-engineer never runs tests and the test-engineer
  never touches production (anti-collusion); one `END:` per turn; reviewer
  auto-routes `action:YES` findings exactly once per cycle; the GREEN-only
  pass-through path. Other shops run TDD without these. If you disagree with one,
  you are forking the methodology — that is allowed, but it is a deliberate
  change, not a profile setting.
- **Pluggable slots** — genuinely project-specific, filled by `PROFILE.md`
  (idiom checklist, gotcha files, lane predicate, build/test commands, review
  dimensions, sketch mode, UI locator contract).

### A known fragility

Lifecycle state is **prose + grep markers in an append-only file**, not a
structured event log. This is faithful to the working original and is robust as
long as marker lines stay unambiguous (the strict turn/marker formats in each
persona exist for exactly this reason). It is, however, the most likely thing to
break under malformed appends, duplicated `IMPLEMENTATION_READY_FOR_REVIEW:`
lines, or partial writes. A project that wants stronger guarantees should
replace the markers with a minimal structured event format — out of scope for
this extraction, noted so you adopt the trade-off knowingly.

## The four roles

| Role | File | Owns | Never does |
|---|---|---|---|
| **orchestrator** (`/work`) | `commands/work.md` | dispatching turns, counting failures, routing review findings, lifecycle state | write production/test code, judge a turn |
| **test-engineer** | `agents/test-engineer.md` | writing the failing test (RED), confirming GREEN, signalling ready | write production code, prescribe *how* to implement |
| **software-engineer** | `agents/software-engineer.md` | making the test pass (GREEN) + the named REFACTOR | write/run tests, broaden scope |
| **reviewer-engineer** | `agents/reviewer-engineer.md` | read-only review against cited sources, blocker/suggestion verdict | edit any file, make uncited findings |

The orchestrator never participates in a turn; the two engineers never talk to
each other except through the append-only **discussion file**; the reviewer
only reads. This separation is the whole point — it is what makes each role's
output auditable and what lets the orchestrator drive the loop mechanically.

## The canonical cycle

```
test-engineer writes failing test (RED)
   → software-engineer makes it pass + refactor (GREEN)
      → test-engineer confirms GREEN, opens next test — or signals READY
         → reviewer-engineer gate (auto-route fixable findings back once)
            → human review: PASS closes the cycle, FAIL routes blockers back
```

Escalation runs in parallel: when one task fails the configured number of
attempts, the orchestrator stops and hands it to the human.

## How a project instantiates the skeleton

The skeleton files contain two kinds of extension point:

- **`{{TOKEN}}`** — a single value or short phrase (a directory, a command, a
  framework name). Substituted literally.
- **`{{> SLOT}}`** — a named section the project supplies in full (an idiom
  checklist, a review dimension, a gotcha-file list). The skeleton states what
  the slot is *for*; the profile supplies the body.

`PROFILE.template.md` is the contract: it lists **every** token and slot with a
description of what to put there. To adopt the skeleton:

1. Copy `PROFILE.template.md` to your project as `PROFILE.md` and fill in every
   token and slot. Leaving one blank is a setup error — the skeleton names what
   it needs and refuses to guess.
2. Render the skeleton files with your profile (mentally, by hand, or by a
   substitution script) into your agent/command files
   (e.g. `.claude/commands/work.md`, `.claude/agents/*.md`).
3. The rendered files are what your harness actually runs. The skeleton +
   profile are the *source*; keep them so the next project — or the next
   language port — re-derives cleanly.

`examples/swift/PROFILE.md` is a complete worked profile: rendering the
skeleton with it reproduces the behavior of the project this skeleton was
extracted from.

## What is deliberately NOT in the skeleton

These are project decisions, not workflow mechanics, so they live only in the
profile:

- Any language, framework, build tool, or test runner.
- Directory layout, module/target names, file-naming conventions.
- The number and names of build **variants** (platforms, configurations). The
  skeleton supports 1..N variants generically; a single-variant project simply
  defines one.
- Concrete review-dimension content (e.g. a language's concurrency rules), the
  gotcha/memory files, and the security checklist.
- Whether the project has a non-test **sketch** phase (UI-visual review) at
  all — that is an optional mode the profile enables.

## Files

```
tdd/
  README.md                    ← you are here
  PROFILE.template.md          ← the contract: every token + slot to fill
  commands/
    work.md                    ← orchestrator skeleton
  agents/
    test-engineer.md           ← test-engineer skeleton
    software-engineer.md       ← software-engineer skeleton
    reviewer-engineer.md       ← reviewer-engineer skeleton
  examples/
    swift/
      PROFILE.md               ← worked profile (reproduces the source project)
      README.md                ← how the Swift project composes skeleton + profile
  baking/
    BAKING.md                  ← common: how to bake a runnable pipeline (any language) + lessons L1–L8
    BAKING-flutter-dart.md     ← Flutter/Dart profile + bake steps
    BAKING-python.md           ← Python profile + bake steps
```

## To bake a runnable, language-specific pipeline

`README.md` (this file) explains *what the skeleton is*. To turn it into a
runnable `.claude/` for a target project, follow **`baking/BAKING.md`** (the
common procedure + the hard-won lessons L1–L8), then the per-language guide
(`baking/BAKING-flutter-dart.md`, `baking/BAKING-python.md`). They fill the
profile slots for the stack and list the exact steps + a verification checklist.
