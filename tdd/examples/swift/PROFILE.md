# Project Profile — KanthorVault (Swift / SwiftUI, macOS + iOS)

Worked instantiation of `../../PROFILE.template.md`. Rendering the skeleton
(`../../commands/work.md`, `../../agents/*.md`) with the tokens and slots below
reproduces the behavior of the project's live `.claude/commands/work.md` and
`.claude/agents/*.md`. This is the "Project Swift specific" half of
*skeleton + project specifics*.

---

## 1. Path & constant tokens

| Token | Value |
|---|---|
| `{{REPO_NAME}}` | `kanthorvault` |
| `{{PLAN_EPICS_DIR}}` | `.agents/plan/v2/epics/` |
| `{{PLAN_STORIES_DIR}}` | `.agents/plan/v2/stories/` |
| `{{PLAN_FEEDBACK_DIR}}` | `.agents/plan/v2/feedback/` |
| `{{DISCUSSION_DIR}}` | `.agents/debate/history/` |
| `{{DRAFT_DIR}}` | `.agents/debate/` |
| `{{MEMORY_DIR}}` | `.agents/memory/` |
| `{{AGENT_DIR}}` | `.claude/agents/` |
| `{{DEFAULT_TURN_CAP}}` | `128` |
| `{{ATTEMPT_LIMIT}}` | `3` |

## 2. Optional capability flags

| Capability | Value |
|---|---|
| Multi-variant parallelism | **yes** — `shared`, `ios`, `macos` |
| Sketch phase | **yes** — Phase A macOS UI sketch, human visual review |
| UI/E2E tests | **yes** — XCUITest (`iosUITests`/`macosUITests`) |
| Locked copy | **yes** — verbatim copy in `docs/UIUX/mockup/*.html` |

---

## 3. Slots

### `{{> PROJECT_CONTEXT}}`

KanthorVault is a local-only personal vault app for macOS and iOS, built with
**built-in SwiftUI components only** — no UIKit/AppKit bridges, no third-party
packages, no hand-drawn chrome. MVP is local-only: encryption / sync / CloudKit
are **not in MVP**; a Task requiring real crypto is a plan error → `OPEN:`. If a
design seems to require a non-built-in component, stop and flag `OPEN:` with a
proposed built-in alternative.

### `{{> VARIANTS_AND_SCOPES}}`

Three variants, built in dependency order:

| Variant | Owns dirs | Build target / scheme | Depends on |
|---|---|---|---|
| `shared` | `KanthorVault/shared/` (Domain/ Services/ ViewModels/ Infrastructure/) | `ios` scheme (shared tests run via `iosTests`) | — |
| `ios` | `KanthorVault/ios/` + `iosApp.swift` | `ios` scheme, iOS Simulator | `shared` |
| `macos` | `KanthorVault/macos/` + `macosApp.swift` | `macos` scheme, `platform=macOS` | `shared` |

`shared` first, always: iOS and macOS Stories both depend on `shared/`
Domain/Services/ViewModels. Get `shared` to `HUMAN_REVIEW: PASS`, commit it,
then run `--variant ios` and `--variant macos` in parallel with `--base <that
shared commit>`.

**Build isolation:** never pass `-derivedDataPath`. `xcodebuild` keys
DerivedData by the `.xcodeproj`'s absolute path, so each worktree already gets
its own isolated cache outside the repo. Worktrees are siblings of the repo
(`../kanthorvault-worktrees/…`) so Xcode's file-system-synchronized folders
never ingest them.

**Merge strategy (join):** iOS and macOS edit disjoint dirs, so join conflicts
should be rare. A conflict in `shared/` means both variants diverged the shared
layer → human reconciles. There is no separate lockfile/manifest (no SwiftPM
deps), so the only cross-variant shared surface is `KanthorVault/shared/` and
the `.xcodeproj` (which neither role may edit — file-system-synchronized
folders mean new files need no project edit).

### `{{> SOURCE_AND_TEST_LAYOUT}}`

Six targets in `KanthorVault/KanthorVault.xcodeproj`: `ios`, `iosTests`,
`iosUITests`, `macos`, `macosTests`, `macosUITests`. Module names are lowercase
(`ios`, `macos`) — never `@testable import KanthorVault`.

| Code under test | Test target | Framework | Scheme | Import |
|---|---|---|---|---|
| `shared/` logic | `iosTests/` (default) | Swift Testing | `ios` | `@testable import ios` |
| `ios/` views | `iosTests/` + `iosUITests/` | Swift Testing / XCTest | `ios` | `@testable import ios` (unit only) |
| `macos/` views | `macosTests/` + `macosUITests/` | Swift Testing / XCTest | `macos` | `@testable import macos` (unit only) |

- Shared code is verified from `iosTests` by default; mirror into `macosTests`
  only when a Story's gate asks.
- **No `#if os()`** — platform code splits by directory; if you think you need
  one, the file is in the wrong directory. No `EXCLUDED_SOURCE_FILE_NAMES`.
- `shared/` must compile for both targets, no platform UI dependencies. SwiftUI
  views belong in `ios/`/`macos/`.
- File naming: `<Target>/<Area>/<TypeUnderTest>Tests.swift`; one suite per file.

### `{{> LANE_OWNERSHIP}}`

Source and tests live in disjoint top-level dirs, so a **prefix table** is
valid:

| scope | test-engineer may change | software-engineer may change |
|---|---|---|
| `all` (serial) | `KanthorVault/{iosTests,iosUITests,macosTests,macosUITests}/` | `KanthorVault/{shared,ios,macos}/` |
| `shared` | `KanthorVault/iosTests/` (and `macosTests/` only if a gate mirrors there) | `KanthorVault/shared/` |
| `ios` | `KanthorVault/{iosTests,iosUITests}/` | `KanthorVault/ios/` |
| `macos` | `KanthorVault/{macosTests,macosUITests}/` | `KanthorVault/macos/` |

`ios/`/`macos/` prefixes do **not** match `iosTests/`/`macosTests/` — the
trailing slash differs. **Always forbidden to both roles:** EPIC/Story files
under `.agents/plan/`, and `*.pbxproj` / `*.xcodeproj/` (a `.pbxproj` change is
a red flag — file-system-synchronized folders mean new Swift files need no
project edit). In sketch mode the software-engineer may additionally write
`data/screenshots/`.

### `{{> BUILD_AND_TEST_COMMANDS}}`

Scripts are MANDATORY — never run raw `xcodebuild test`.

| Purpose | Command |
|---|---|
| Produce handoff artifact (build) | `xcodebuild build -project KanthorVault/KanthorVault.xcodeproj -scheme <ios\|macos> -destination "<dest>" 2>&1 \| tee .agents/debate/.build-check-<scheme>.log` |
| Run unit tests | `bash scripts/run-unit-test.sh <ios\|macos> [--udid "$UDID"] [--only-testing Target/Class[/method]] [--skip-open] [--quiet]` |
| Run UI tests | `bash scripts/run-ui-test.sh <ios\|macos> [--udid "$UDID"] [--only-testing …]` |
| Verify handoff artifact | `bash scripts/verify-build.sh <log>` → prints `PASS`/`FAIL` |

- iOS dest: `platform=iOS Simulator,id=$UDID` (or `generic/platform=iOS
  Simulator` for build-only). macOS dest: `platform=macOS`.
- `--only-testing` is `Target/ClassName[/method]` — never a folder path
  (a folder silently matches 0 tests and exits 0).
- **macOS XCUITest launch args (mandatory):**
  `app.launchArguments = ["-ApplePersistenceIgnoreState", "YES"] + args`
  — `-ApplePersistenceIgnoreState YES` first, always.
- Build cache: do NOT pass `-derivedDataPath` (see VARIANTS_AND_SCOPES).

### `{{> ENV_PREFLIGHT}}`

Boot the iOS Simulator **once** and reuse the warm sim for every dispatch:

```bash
SIM_UDID=$(make -s ios-simulator)
```

If `SIM_UDID` is empty, stop — ask the human to resolve it, then re-run.
**Skip this entirely when the scope is `macos`** (macOS tests run natively, no
simulator). For `shared` and `ios`, capture the UDID and pass it as
`Pre-booted simulator UDID` in every dispatch; never shut the sim down. In a
parallel iOS+macOS run only the iOS cycle touches the sim — no contention.

### `{{> GOTCHA_FILES}}`

| File | When to read |
|---|---|
| `.agents/memory/swift-6.md` | Writing SwiftUI views, `@Observable`, Swift concurrency, or Observation framework (existential trap, read-based tracking, `State(wrappedValue:)` init, macOS-26 WindowGroup-root constraint, Xcode 26 quirks) |
| `.agents/memory/swift-testing.md` | Writing/debugging XCUITest/XCTest, accessibility identifiers, navigation testing — the macOS NSTableView entries are mandatory before any macOS UI test |
| `.agents/snippets/README.md` | Before reusing any code from the snippets archive (read its known-bugs column first) |

### `{{> IDIOM_CHECKLIST}}`  *(software-engineer)*

Apple frameworks only, **no third-party packages**. MVP is local-only; real
crypto/sync/CloudKit is a plan error → `OPEN:`.

1. UI: **built-in SwiftUI components only** (NavigationSplitView, List, Form,
   Table, …) — no custom chrome, no bridges. Non-built-in needed → `OPEN:` +
   propose a built-in alternative.
2. Persistence: SwiftData `@Model final class`, `@Relationship(.cascade)` for
   owned children; register every model in the one `ModelContainer(for: …)` in
   `shared/Infrastructure/`. Fetch via `@Query` or `FetchDescriptor`. SwiftData
   service calls: **never `try?`** — log and surface failures (vault data loss
   is the primary failure mode).
3. State: `@Observable final class` (never `ObservableObject`/Combine);
   flow/step state = `@Observable` controller with an `enum` step; persisted
   flags = `UserDefaults` behind an injectable protocol; placeholder auth =
   `AuthService` protocol + auto-succeeding conformer; QR = CoreImage `CIFilter`
   `"CIQRCodeGenerator"` → `CGImage?`.
4. Explicit `@MainActor` on any `@Observable` type a view body reads — the
   project has no global actor default. Read `swift-6.md` first.
5. CPU-bound work (CoreImage etc.): `Task.detached` inside `.task {}`, result
   back via `.value` — never synchronous CPU work in `body` or a stored-property
   initializer.
6. Access control: `private` by default; `internal` only when a test or sibling
   needs it. A service protocol exists so tests can substitute a fake — match
   the protocol name the Task's GREEN block gives; injected dependencies thread
   through `init` with a sensible default.
7. Read `swift-testing.md` before adding accessibility identifiers or wiring any
   view a UI test queries.

### `{{> TEST_CONVENTIONS}}`  *(test-engineer)*

- **Unit tests are Swift Testing** (`import Testing`, `struct` suite, `@Test`,
  `#expect`/`#require`). **UI tests are XCTest** (`XCUIApplication`); UI targets
  do not import the app module. Never mix.
- File naming `<Target>/<Area>/<TypeUnderTest>Tests.swift`; one suite per file.
- `@MainActor` on a `@Test` that touches `@MainActor` types; mocks consumed only
  from `@MainActor` tests should be `@MainActor final class` — no
  `nonisolated(unsafe)`.
- **Fake vs Mock:** Fake = generic safe defaults; Mock = deterministic
  Story-specified values. Story names a value → wire the Mock.
- UI tests cold-launch `XCUIApplication` with `--uitesting` + the Story's
  `--seed-*` flags; the SE wires the seam, the TE specifies the flag name.
- The reusable Swift Testing unit-seam pattern and all XCUITest query patterns
  live in `.agents/memory/swift-testing.md` — read it before writing any test.
- UI-test failure triage (binding): classify the failure layer first (element
  not found = your query; interaction synthesized but state unchanged =
  production/env — verify out-of-band with `bash scripts/inspect-app.sh
  --app-args "--uitesting …" [--tree]` and check its `built:` timestamp);
  identifier-based queries are the standard; re-validate historical gotcha
  patterns on the current macOS/Xcode before citing one.

### `{{> UI_LOCATOR_CONTRACT}}`  *(Phase B, platform scope only — never shared)*

Each platform owns its own identifier registry: `iosUITests/TestID.swift` and
`macosUITests/TestID.swift` (independent — the UIs differ). Before any UI test
queries an identifier, the test-engineer defines it as a `static let` (or
`static func` for indexed elements):

- Format: `<screen>_<area>_<element>[_<state>]` (e.g. `main_sidebar_vault_link`,
  `vault_detail_title`).
- Tests reference `TestID.xxx`, **never** inline string literals. The
  software-engineer mirrors the exact string in production
  `.accessibilityIdentifier("…")` — character-for-character; never invents one
  (`OPEN:` if undefined), never imports `TestID` from production code.
- RED turns list new identifiers under `**TestID identifiers defined.**`; SE
  reports assignments under `**Identifiers assigned.**`.
- No TestID work in shared scope or Phase A.

### `{{> COPY_SOURCING}}`  *(locked user-facing copy)*

Before hard-coding any user-facing string in an assertion or a view, confirm it
against a source: `rg -n "<phrase>" docs/UIUX/mockup/ docs/UIUX/plan.md`. Not
found → `OPEN: copy not in mockup — needs human sourcing`. Never invent or
paraphrase copy.

- macOS mockups are split per screen: `macos_vault.html`, `macos_contacts.html`
  (State 5 — mockup says "Family", the flow is **Contacts**),
  `macos_settings.html`, `macos.html` (shell/window). Read ONLY the file for the
  flow you're working.
- iOS ports: `ios_tab_vault.html`, `ios_tab_family.html` (Contacts — file keeps
  its old name), `ios_tab_settings.html`.
- The five credential field labels and the F3 reveal strings are locked strings
  carried verbatim — not authored.

### `{{> REVIEW_DIMENSIONS}}`  *(reviewer-engineer)*

Six dimensions. Phase A review is narrowed to dimensions **1, 2, 5** only
(crashes and over-complexity don't wait for Phase B; tests/data don't exist
yet). Each finding cites a source per the skeleton's methodology table.

1. **Correctness — AC match.** Each in-scope Task: every AC line satisfied? Named
   REFACTOR applied? Test verifies the AC itself, not something adjacent? (Phase
   A: visual-spec numbers + verbatim copy ACs only.)
2. **Swift 6 / Concurrency safety.** Read `swift-6.md` FIRST. `@Observable`
   classes: protocol existentials stored as observed properties; `let` vs `var`
   child properties (blocker only with `@Bindable`/projected bindings);
   read-based tracking. `nonisolated`/`nonisolated(unsafe)`: is the opt-out
   justified by real background work (else SUGGESTION; compiler warning =
   BLOCKER), and only then is the accessed type thread-safe? No global
   `@MainActor` default — a UI-state `@Observable` class missing `@MainActor` is
   a BLOCKER. Actor hopping in `nonisolated async` mutating state. **Full check
   in Phase A too.**
3. **Test quality (Phase B only).** Read `swift-testing.md` FIRST. Each test maps
   to a specific AC? Silent fallbacks (`#expect(true)`, empty catches)? Mocks
   repeating unsafe production patterns? Missing edge/initial-state checks?
4. **API design (Phase B only).** Can both platform layers consume the shared
   seam cleanly? Protocol requirements explicit about isolation? Composes with
   SwiftUI (`@Observable`, `@Bindable`)?
5. **Simplicity.** Over-abstraction, speculative patterns, dead code? Fewer
   types/protocols/annotations possible? Annotations that don't do what the
   author thinks? **Non-built-in UI components = BLOCKER** (built-in SwiftUI
   only). **Full check in Phase A.**
6. **Security & privacy (Phase B only, vault-specific).** Secrets/sensitive data
   in `UserDefaults`/unprotected storage or leaked to logs? Keychain for
   secrets, encrypted containers for vault data, file protection
   `.completeUntilFirstUserAuthentication` minimum. **SwiftData `try?` = BLOCKER**
   (silent persistence error = data loss with UI showing success). Deletion/reset
   completeness; entitlements scoped to need.

### `{{> SKETCH_MODE}}`  *(Phase A — macOS UI sketch)*

1. **Stories covered:** `SA*` stories (macOS only). `--sketch` requires
   `--platform macos`.
2. **Proof artifact:** one screenshot per screen state the story's Verification
   Gate names, captured to `data/screenshots/<epic-slug>/<story>-<state>.png`
   via `scripts/inspect-app.sh` (`--screenshot <path>` for the launch state;
   `--exec '<nav script>'` for states needing navigation/appearance toggles —
   it exports `WIN_ID`, capture with `screencapture -x -o -l "$WIN_ID" <path>`).
   The script owns launch, build-freshness (`built:`), window-wait, cleanup — do
   NOT hand-roll inline osascript/screencapture.
3. **Comparator / acceptance:** human visual review against the Story ACs —
   layout regions/ratios, verbatim copy, light + dark, stock-SwiftUI look. The
   human records `HUMAN_REVIEW: PASS` or `FAIL` + `BLOCKER:` lines and logs UX
   feedback to `.agents/plan/v2/feedback/<epic>-feedback.md` (the next epic's
   authoring session consumes it).
4. **Constraints during Phase A:** inline `@State`/stub data only; no service
   seams, no launch-arg seeding except capture-args routed through
   `UITestLaunchArgs.isActive(_:in:)` (no raw `ProcessInfo…contains`), no
   TestID/accessibility-identifier work, **built-in SwiftUI only**. Apply capture
   args **at depth, not on the WindowGroup root** (swift-6.md macOS-26
   constraint). CLAUDE.md Rule 8 ("no DONE without a passing test") is suspended
   for Phase A — the screenshot review is the gate.

**Sketch-mode dispatch paragraph** (appended to the SE dispatch prompt when
`SKETCH=true`):

> Mode: sketch (Phase A). You are the software-engineer working SA* stories in
> document order, one story per turn. Build macOS UI with inline stub data only.
> After implementing a story, run the macOS build check (`xcodebuild build
> -scheme macos` → `verify-build.sh PASS`), capture one screenshot per screen
> state the story's Verification Gate names into
> `data/screenshots/<epic-slug>/`, and append a Phase A turn listing the
> screenshot paths under `**Phase A proof.**`. The discussion file may be empty
> — you are the opener in sketch mode. When EVERY SA* story has Phase A proof,
> append a final turn whose body starts with `IMPLEMENTATION_READY_FOR_REVIEW:`
> listing all screenshot paths (ending `END: SOFTWARE-ENGINEER`).

**Sketch-mode human pause message** (used at Step 6c instead of the default):

> SKETCH REVIEW — <EPIC_SLUG> — visual approval needed. The reviewer's Phase A
> verdict (dimensions 1, 2, 5) is above; action:YES findings were auto-routed
> and fixed. No test suite ran — the gate is YOUR visual review. Open the
> screenshots under `data/screenshots/<epic-slug>/` and check against the Story
> ACs (layout regions, verbatim copy, light+dark, stock-SwiftUI look). To
> accept: append `HUMAN_REVIEW: PASS`. To send back: append `HUMAN_REVIEW: FAIL`
> + one `BLOCKER:` per problem, then re-run. Record UX feedback in
> `.agents/plan/v2/feedback/<epic>-feedback.md`.
