# TDD-Pipeline Intake — Flutter / Dart pack

Load **`INTAKE.md` (generic) first**, then this file. These are
**questions-with-defaults** that *refine* the Section-A answers for a
Flutter/Dart stack — confirm or override each default; a default is not a baked
answer.

Each item points back at the generic category it sharpens `(A#)` and the lesson
it de-risks `⚠`.

- **F1 (A7 / ⚠L1)** — Q: handoff gate? · *Default:* `dart analyze` (fast) ±
  `flutter build <target> --debug` · if codegen (freezed/json_serializable): the
  software-engineer runs `build_runner` before analyze, and
  `*.g.dart`/`*.freezed.dart` are forbidden to hand-edit.
- **F2 (A6 / ⚠L2)** — Q: confirm `test/` mirrors `lib/` + `integration_test/` →
  dirs disjoint from `lib/` → a prefix table is valid?
- **F3 (A4)** — Q: single variant `app` (one `lib/` builds all targets), per-flavor
  (`dev`/`prod`), or a melos monorepo (`core`→`app`, merge surface
  `pubspec.lock`/`packages/core/`)?
- **F4 (A9)** — Q: which **ONE** state-mgmt lib (Riverpod/Bloc/Provider) — others
  forbidden (a second approach is a review BLOCKER)? null-safety bang policy?
  post-`await` `if (!mounted) return;`? `const` correctness? `compute()`/isolate
  for heavy work?
- **F5 (A10)** — Q: `flutter_test` (`testWidgets`, `WidgetTester`) +
  `integration_test`; `mocktail` (no codegen); is a `pumpAndSettle` that masks a
  hang flagged (L3)?
- **F6 (A13 / UI)** — Q: locators = `Key`s declared in `WidgetKeys`/`keys.dart`
  (test-engineer names, software-engineer assigns the **exact** key, tests
  `find.byKey`); Maestro analog = `testID`/semantics, one registry?
- **F7 (A13 / copy)** — Q: locked copy → l10n ARB (`lib/l10n/app_en.arb`), assert
  the generated key (not a literal)? else `Not applicable`.
- **F8 (A13 / sketch)** — Q: visual review → proof = **golden images**
  (`--update-goldens` → review PNGs) or widget-harness screenshots; comparator =
  human golden review; constraints = stub data, chosen widgets only — else
  `Not applicable`?
- **F9 (A8 / ⚠L8)** — Q: unit/widget = `None.` (headless Dart VM);
  `integration_test`/E2E boots/selects a device once (`-d <id>`) + preflights
  device responsiveness (window/automation flakiness)?

## Capability-flag defaults (confirm)
| Capability | Default |
|---|---|
| Multi-variant parallelism | **no** (one `lib/` builds all platforms); **yes** only for flavors or a melos monorepo |
| Sketch phase | **optional** — on only if you do golden/visual review before behavioral tests; default off |
| UI/E2E tests | **yes** — `integration_test` + widget tests (± Maestro) |
| Locked copy | project-dependent (l10n ARB) |
