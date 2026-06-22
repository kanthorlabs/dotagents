# Baking the TDD pipeline for Flutter / Dart

Stack-specific bake. Read `BAKING.md` (common procedure + lessons L1–L8) first;
this fills the profile slots and notes Flutter/Dart specifics. Verify a bake by
re-running a solved feature (mind **L7 — keep the reference answer out of the
agent's reach**).

---

## Profile (`PROFILE.md` values)

### Tokens
| Token | Value |
|---|---|
| `{{REPO_NAME}}` | your Flutter app repo name |
| `{{PLAN_EPICS_DIR}}` | `.agents/plan/epics/` |
| `{{PLAN_STORIES_DIR}}` | `.agents/plan/stories/` |
| `{{PLAN_FEEDBACK_DIR}}` | `.agents/plan/feedback/` |
| `{{DISCUSSION_DIR}}` | `.agents/debate/history/` |
| `{{DRAFT_DIR}}` | `.agents/debate/` |
| `{{MEMORY_DIR}}` | `.agents/memory/` |
| `{{AGENT_DIR}}` | `.claude/agents/` |
| `{{DEFAULT_TURN_CAP}}` | `128` |
| `{{ATTEMPT_LIMIT}}` | `3` |

### Capability flags
| Capability | Value |
|---|---|
| Multi-variant parallelism | **no** — one Flutter codebase builds all platforms; default single variant `app`. (Use variants only if you ship per-flavor: `dev`/`prod`, or a federated plugin's `android`/`ios` platform packages.) |
| Sketch phase | **optional** — enable only if you do visual/golden review of widgets before behavioral tests (see `{{> SKETCH_MODE}}`). Default off. |
| UI/E2E tests | **yes** — `integration_test` + widget tests; optionally Maestro (the `maestro` skill in this repo). |
| Locked copy | project-dependent (l10n ARB strings) — yes if you lock user-facing copy. |

### Slots

**`{{> PROJECT_CONTEXT}}`** — A Flutter app (Dart, null-safe). Built with
[your state mgmt: Riverpod / Bloc / Provider — pick one and forbid the others].
Material/Cupertino widgets; no platform-channel hacks unless a Task names one.
No new pub dependency without justification (stdlib/Flutter-SDK first).

**`{{> VARIANTS_AND_SCOPES}}`** — Single variant `app` (one `lib/` tree builds
all targets). The worktree/parallel/join machinery collapses to a no-op. (If you
genuinely split — e.g. a melos monorepo with packages `core`/`app` — define
`core` (dep) → `app`, owning `packages/core/` and `packages/app/`, and note the
`pubspec.lock` / shared `packages/core/` as the cross-package merge surface.)

**`{{> SOURCE_AND_TEST_LAYOUT}}`** — Production: `lib/` (feature-first:
`lib/<feature>/{data,domain,presentation}/`). Unit + widget tests: `test/`
mirroring `lib/` (`test/<feature>/..._test.dart`). E2E: `integration_test/`.
Module import = `package:<app>/<path>`. File naming `<thing>_test.dart`, one
suite/`group` per file. **Tests live in `test/`, disjoint from `lib/`** — so a
prefix table is valid (see lane slot).

**`{{> LANE_OWNERSHIP}}`** — Prefix table (dirs are disjoint):

| scope | test-engineer may change | software-engineer may change |
|---|---|---|
| `app` (only) | `test/`, `integration_test/` | `lib/` |

Always forbidden to both: `.agents/plan/`, `pubspec.yaml`/`pubspec.lock`,
`android/`/`ios/`/`web/` runner config, `*.g.dart`/`*.freezed.dart` (generated —
regenerate via build_runner, never hand-edit).

**`{{> BUILD_AND_TEST_COMMANDS}}`**
| Purpose | Command |
|---|---|
| produce handoff artifact | `dart analyze` (fast gate) and/or `flutter build <target> --debug` ; tee to `.agents/debate/.analyze.log` |
| run unit/widget tests | `flutter test [test/<path>] --reporter expanded` |
| run E2E | `flutter test integration_test/<flow>_test.dart -d <device>` (or `maestro test .maestro/<flow>.yaml`) |
| verify handoff | `scripts/verify-analyze.sh <log>` → grep `No issues found!` / non-zero analyzer exit → PASS/FAIL |
Build-cache note: `flutter` caches per-project under `.dart_tool/`; a worktree
gets its own — fine. If you enable `build_runner`, run it before analyze.

**`{{> ENV_PREFLIGHT}}`** — For `integration_test`/E2E, boot/select a device
once: `flutter devices` → pick a stable emulator/simulator UDID, pass it as
`-d <id>` to every E2E run. For pure unit/widget tests: `None.` (they run
headless on the Dart VM). **L8 host note:** integration tests on a real
emulator can hit the same window/automation flakiness — preflight that the
device is responsive before the loop.

**`{{> GOTCHA_FILES}}`** — `.agents/memory/dart-flutter-gotchas.md`: read before
async/`setState`/`FutureBuilder` work (rebuild storms, `mounted` checks after
await), `const` constructor correctness, `Key` identity in lists,
`dispose()`/controller leaks, null-safety late-init traps, and your state-mgmt
lib's rules. `.agents/memory/flutter-testing.md`: `pumpAndSettle` vs `pump`,
`tester.pumpWidget` setup, finder flakiness, golden-test platform drift.

**`{{> IDIOM_CHECKLIST}}`** *(software-engineer)*
1. Null-safety: no `!` bang without a proven non-null; prefer `?.`/`??`/pattern matching. No `late` unless initialization is guaranteed before use.
2. State mgmt: use the ONE chosen lib; immutable state (freezed/equatable); no `setState` in a lib-managed widget.
3. Widgets: `const` everywhere possible; small composable widgets over deep build methods; keys only when identity matters.
4. Async: check `if (!mounted) return;` after every `await` before touching context/state; never block the UI isolate — heavy work in `compute()`/isolate.
5. Dependencies: Flutter SDK + chosen state lib only; new pub package needs justification.
6. Errors: no swallowed exceptions; surface failures (a dropped error in persistence = data loss). No `print` — use the project logger.

**`{{> TEST_CONVENTIONS}}`** *(test-engineer)* — Unit/widget tests use
`package:flutter_test` (`testWidgets`, `WidgetTester`, `find`, `expect`,
matchers). E2E uses `package:integration_test`. Mocks via `mocktail` (no
codegen) — Fake = safe defaults, Mock = Story-specified values. One
`group`/suite per file, `test/` mirrors `lib/`. Read `flutter-testing.md` before
any widget/E2E test.

**`{{> UI_LOCATOR_CONTRACT}}`** *(widget/E2E tests)* — Stable locators are
`Key`s. The test-engineer declares them in a `lib/<feature>/keys.dart` (or a
shared `WidgetKeys` registry) as `const Key('<screen>_<area>_<element>')`; tests
query `find.byKey(WidgetKeys.x)`. The software-engineer assigns the **exact**
key onto the widget; never inline a raw `Key('literal')` in a test. For Maestro
flows, the analog is `testID`/semantics labels — keep one registry.

**`{{> COPY_SOURCING}}`** — If copy is locked: source from the l10n ARB
(`lib/l10n/app_en.arb`); assert via the generated `S.of(context).x` key, not a
hard-coded literal. Not locking copy → `Not applicable.`

**`{{> REVIEW_DIMENSIONS}}`** *(reviewer-engineer)* — Keep the skeleton's
cite-a-source structure; dimensions:
1. Correctness — AC match (widget renders the spec'd states; named REFACTOR applied).
2. Null-safety & async — bang-usage, post-`await` `mounted` checks, isolate offloading, controller disposal (BLOCKER on a leak or unguarded context-after-await).
3. Test quality — each test maps to an AC; no `pumpAndSettle` masking a hang; mocks not repeating prod bugs.
4. API design — widget composes/rebuilds cleanly; state exposed immutably.
5. Simplicity — `const` correctness, no over-deep build methods, no speculative abstraction; **chosen-state-lib-only** (a second state mgmt approach is a BLOCKER).
6. Security/privacy — secrets not in `SharedPreferences` plaintext (use `flutter_secure_storage`); no secrets in logs; persistence errors surfaced.
Phase A (if sketch enabled): dimensions 1, 2, 5 only.

**`{{> SKETCH_MODE}}`** *(optional)* — If enabled: proof artifact = **golden
images** (`flutter test --update-goldens` then review the PNGs under
`test/**/goldens/`) or screenshots from a widget harness; comparator = human
golden review against the design; constraints = stub data, chosen widgets only.
If you don't do pre-test visual review → `Not applicable — all work is
test-gated.`

---

## Flutter-specific bake steps (in addition to BAKING.md §1)

1. Scripts: `scripts/verify-analyze.sh` (wrap `dart analyze`, PASS on "No issues found!"), and an E2E runner that pins `-d <device>`.
2. If using codegen (freezed/json_serializable): the SE runs `dart run build_runner build --delete-conflicting-outputs` after editing annotated sources, and `*.g.dart`/`*.freezed.dart` are in the always-forbidden-to-hand-edit list.
3. Seed `dart-flutter-gotchas.md` + `flutter-testing.md`.
4. Smoke epic: one widget + one widget-test Task is the cheapest end-to-end.

## Verification checklist (Flutter)
- [ ] BAKING.md §3 checklist passes.
- [ ] `dart analyze` is the handoff gate and `verify-analyze.sh` returns PASS/FAIL (L1).
- [ ] A widget test keyed via `WidgetKeys` resolves with `find.byKey` (locator contract).
- [ ] Reference solution for any verification run is NOT reachable in the agent's git history (L7).
- [ ] If E2E: the device preflight passes before the loop (L8).
