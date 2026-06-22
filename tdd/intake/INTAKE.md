# TDD-Pipeline Intake — Generic (always load this)

**Purpose:** collect exactly enough project information to fill every `{{TOKEN}}` /
`{{> SLOT}}` in `../PROFILE.template.md` and bake a runnable four-role TDD
pipeline. Rule: an unanswered **[REQUIRED]** question is a bake error — the
skeleton refuses to guess.

**How to load:** read **this file (always)** + the **one** language pack that
matches the project's primary stack — `INTAKE-python.md`, `INTAKE-go.md`, or
`INTAKE-flutter-dart.md`. Do not load the others. The language pack *refines* the
answers to Section A; it does not replace them.

---

## Intake mechanics

### Three layers
- **Pass 0** — project context & risk (lifecycle, risk class, architecture).
  Shapes the *answers* to the slots; not itself slot-mapped.
- **A. Generic** — slot-mapped questions, every project (this file).
- **B. Language pack** — Python / Go / Flutter refinements (the language file).

### Every question carries 5 fields
`Q:` the prompt · `Why:` the artifact decision it drives · `Shape:` accepted
answer form · `Default:` value if the user doesn't know · `Feeds:` profile slot ·
`[REQUIRED|OPTIONAL]`. Defaults are *proposals to confirm*, not baked answers.

### Answer classification
Tag every captured answer as one of: **fact** (user-provided), **default**
(inferred, needs confirm), **policy** (hard project rule), **open** (undecided →
blocks generation until resolved). This stops an inferred default silently
becoming a locked rule.

### Completeness gate ("enough information")
Generation may proceed only when: every `[REQUIRED]` question is a **fact** or a
**confirmed default**, and no `open` remains on a *gating* slot
(`VARIANTS_AND_SCOPES`, `LANE_OWNERSHIP`, `BUILD_AND_TEST_COMMANDS`). Unknown
handling: `[OPTIONAL]` unknown → take the documented default and mark it;
`[REQUIRED]` unknown → ask one targeted follow-up, then block. An answer like
"we use pytest" without the layout/lane decision is **insufficient** — name what
is still missing.

---

## Pass 0 — Project context & risk

Establish *what kind of project this is and what must never break* before
mapping tokens — it changes test depth, review strictness, fixture policy, and
the security checklist. (Token-mapping is still the deliverable; Pass 0 informs
the answers.)

- **0.1 Lifecycle class** — Q: greenfield, legacy-with-coverage-gaps, prototype,
  regulated/compliance, production-critical, internal tooling, or OSS library? ·
  Why: sets test depth + review strictness + whether characterization/contract
  tests precede strict TDD · Feeds: `PROJECT_CONTEXT`, `REVIEW_DIMENSIONS` ·
  **[REQUIRED]**
- **0.2 Unacceptable failures** — Q: which failure classes are intolerable —
  data loss, money movement, privacy leak, race/corruption, offline-sync, a11y
  regression, perf cliff, compat break? · Why: drives the security/data-handling
  BLOCKER list and the error-handling idiom · Feeds: `REVIEW_DIMENSIONS`,
  `IDIOM_CHECKLIST` · **[REQUIRED]**
- **0.3 Architecture & dependency inventory** — Q: language/framework
  **versions**, package manager, generated-code tooling, DB/migration tooling,
  API protocol, auth model, external integrations? · Why: feeds context, gotcha
  files, the generated-file lane rule, and build commands · Feeds:
  `PROJECT_CONTEXT`, `GOTCHA_FILES`, `LANE_OWNERSHIP`, `BUILD_AND_TEST_COMMANDS` ·
  **[REQUIRED]**

---

## A. Generic categories (every project)

*(Each tagged with the profile slot it feeds `→` and the lesson it de-risks `⚠`.
Apply the 5-field template above.)*

### A1. Project identity & hard constraints → `{{> PROJECT_CONTEXT}}`
1. What is this — library / service / CLI / GUI / monorepo?
2. Hard tech constraints every engineer must honor (allowed deps, "no X" rules,
   sync vs async)?
3. Existing `CLAUDE.md` / contributing guide / gotcha files to derive values
   from? (paste paths.)

### A2. Repo paths & constants → tokens
4. Repo dir name?
5. Plan dirs (epics/stories/feedback) or create the convention?
6. Confirm/override discussion/draft/memory/agent dirs.

### A3. Planning-grammar fit (gate, not slot) ⚠ host assumption
7. Work authored as **EPIC → Story → `### Task`** with `Action — RED/GREEN/REFACTOR:`
   + `## Verification Gate`?
8. git + POSIX shell + sub-agent-dispatching harness?

> **Caveat.** A "no" **STOPs** — that is the skeleton's documented contract
> ("you are forking the methodology"), not a defect to paper over. **But**
> lifecycle (0.1) reshapes *test strategy within* the grammar: legacy →
> characterization tests before RED; spike-first/exploratory work → a throwaway
> spike Task before the real RED; migrations → a contract/migration test.
> Capture which applies; it changes A10, not A3.

### A4. Variant / build-target topology → `{{> VARIANTS_AND_SCOPES}}`, `{{> VARIANT_VALUES}}`, `{{> JOIN_GATE_TARGETS}}`, *Multi-variant* flag
9. How many independently-buildable targets (name each as typed after
   `--variant`)?
10. Dependency order?
11. Files shared across variants + conflict policy (default: human reconciles)?
12. Ownership disjoint enough for parallel worktrees?

### A5. Source & test layout → `{{> SOURCE_AND_TEST_LAYOUT}}`
13. Prod source dir(s) per variant?
14. Unit + UI/E2E dirs?
15. Module/import + new-file naming convention?

### A6. Lane ownership ⚠ L2 → `{{> LANE_OWNERSHIP}}`
16. **Tests co-located with source** (`foo_test.go`, `test_x.py` beside module)
    or disjoint dir? → disjoint = prefix table; co-located / cross-cutting
    generated files = **predicate script** `scripts/lane-check.sh`.
17. Paths **always forbidden to both** (locked plan, build/project config,
    lockfiles, generated files)?

> This slot **already answers** "may agents modify tests / prod / generated /
> docs?" — make the always-forbidden list explicit (it covers docs/config if you
> want them off-limits).

### A7. Build / test / verify commands ⚠ L1 → `{{> BUILD_AND_TEST_COMMANDS}}`
18. Command that **produces the handoff artifact** (build, or lint/typecheck for
    interpreted)?
19. Run-unit + run-UI/E2E commands?
20. **verify-handoff** script → machine-readable PASS/FAIL (not a grep); what is
    PASS?
21. Build-cache isolation for parallel worktrees?
22a. Do these handoff/verify commands **mirror the CI required checks** (so
    local-green ≠ CI-red can't happen)? Provide exact local *and* CI commands +
    expected runtime.
22b. Flaky-test policy (retry / quarantine / hard-fail)? — a deterministic
    verify-handoff is load-bearing for L1.

> Out of scope (no profile slot consumes them): release cadence, rollback,
> artifact publishing, environment parity — that is a CI tool's concern.

### A8. Environment preflight ⚠ L8 → `{{> ENV_PREFLIGHT}}`
23. Resource booted **once** (emulator/sim/db/browser) + what to capture, or
    `None.`?
24. Gate needs a real window (macOS `windows:0` TCC failure)?

### A9. Code idioms → `{{> IDIOM_CHECKLIST}}`
25. Allowed patterns, persistence/concurrency/access-control rules, **DI seam
    style** tests fake through?
26. Error-handling (no silent swallow; logger vs print)?

### A10. Test conventions → `{{> TEST_CONVENTIONS}}`, `{{> GATE_LABEL_EXAMPLES}}`, `{{LOCATOR_DEFN_LABEL}}`
27. Unit vs UI/E2E framework + imports?
27a. Which test *types* apply and where do they live — integration, **contract**,
    snapshot/**golden**, **property**, fuzz, **benchmark/perf**, **a11y**,
    **migration**?
27b. Fixture/seed ownership and blast-radius policy (who owns shared fixtures;
    sort-order/count changes ripple to position-dependent tests)?
28. Mock/fake lib + Fake-vs-Mock convention?
29. **RED-test edge policy** ⚠ L3 — pin edge + observable mechanism (whitespace,
    ordering, *which* side-effecting API), not just happy-path/signature;
    property testing available?
30. Concrete gate-line labels (build target / scheme names)?

### A11. Review dimensions & security → `{{> REVIEW_DIMENSIONS}}`
31. Concurrency/safety rules; security/data-handling **BLOCKER** list (drive from
    0.2); simplicity rules incl. allowed-components-only?
32. Dimensions skipped in sketch phase?

### A12. Gotcha files → `{{> GOTCHA_FILES}}`
33. Existing pitfall files + **when** to read each; else seed `<lang>-gotchas.md`.

### A13. Optional modes → flags + `{{> SKETCH_MODE}}` / `{{> UI_LOCATOR_CONTRACT}}` / `{{> COPY_SOURCING}}`
34. **Sketch phase?** needs all 5 (stories · proof artifact · comparator ·
    constraints+dims · shipped-file regression guard) — else `Not applicable` &
    `--sketch` errors.
35. **UI/E2E?** → locator-registry contract.
36. **Locked copy?** → canonical source + verify-before-assert.

### A14. Orchestration tuning → `{{DEFAULT_TURN_CAP}}` (128), `{{ATTEMPT_LIMIT}}` (3), frontmatter pins
37. Turn cap + attempt limit?
38. Per-agent `model:`/`effort:` pin for SE/TE/reviewer?
39. Acceptable build + unit-test runtime, and full-suite/E2E runtime? · Why: a
    slow E2E suite shouldn't run every turn — it gates whether E2E is per-turn or
    join-only, and informs the turn cap.

### A15. Validation integrity ⚠ L7 / L9
40. Reference answer unreachable from the agent's git history? First bake →
    adversarial review gate; re-bake → diff committed `.claude/`.

---

## How to use
1. **Pass 0** (lifecycle/risk/architecture) → **A** top-to-bottom (STOP at A3 if
   grammar/host fails) → now load and run the **matching language pack**.
2. Tag each answer **fact / default / policy / open**; apply the **completeness
   gate** before generating.
3. Confirmed answers populate `PROFILE.md` 1:1 → `render.py` → first bake =
   adversarial-review gate, re-bake = diff committed `.claude/` (L9).
