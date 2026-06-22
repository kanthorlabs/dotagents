# TDD-Pipeline Intake — Python pack

Load **`INTAKE.md` (generic) first**, then this file. These are
**questions-with-defaults** that *refine* the Section-A answers for a Python
stack — confirm or override each default; a default is not a baked answer.

Each item points back at the generic category it sharpens `(A#)` and the lesson
it de-risks `⚠`.

- **P1 (A7 / ⚠L1)** — Q: handoff gate? · *Default:* `ruff check` + `mypy` (PASS
  iff ruff exit 0 AND mypy "Success: no issues"), venv activated in the dispatch
  env · *Tradeoff:* add `pytest --collect-only` import-smoke if mypy is partial.
- **P2 (A6 / ⚠L2)** — Q: tests in a separate `tests/` (prefix table works) or
  **co-located** `test_*.py` beside modules (**predicate script required** — a
  prefix can't separate lanes when both roles touch `src/`)?
- **P3 (A4)** — Q: src-layout (`src/<pkg>/`) or flat? single package (`app`) or
  monorepo (a variant per package + dependency order, shared merge surface
  `pyproject.toml`/lockfile)?
- **P4 (A9)** — Q: strict `mypy`? async or sync? framework (FastAPI/Django/none)?
  · forbid: `eval`/`exec`/`pickle` of untrusted data, mutable default args, bare
  `except`.
- **P5 (A10)** — Q: `pytest` (functions/classes) + `hypothesis` for L3
  edge-pinning? `unittest.mock`/spec'd for Mocks, plain stubs for Fakes;
  `conftest.py` for shared fixtures; one test module per source module.
- **P6 (A11)** — Q: "type & contract safety" replaces "concurrency" for sync
  code; async BLOCKERs = blocking the event loop / unawaited coroutine — agreed?
- **P7 (A12)** — Q: seed `python-gotchas.md` (mutable defaults, late-binding loop
  closures, `==` vs `is`, `__eq__`/`__hash__` pairing, import-time side effects,
  context-manager/resource cleanup) + `asyncio-gotchas.md` if async?
- **P8 (A13)** — Q: sketch `Not applicable` (default — no visual artifact)? UI
  locator contract only if there is a web UI (Playwright `data-testid`)?

## Capability-flag defaults (confirm)
| Capability | Default |
|---|---|
| Multi-variant parallelism | **no** (single package `app`); **yes** only for a monorepo of packages |
| Sketch phase | **no** — all test-gated; `--sketch` errors |
| UI/E2E tests | **no** (library/service/CLI); **yes** only for a web UI |
| Locked copy | **no** |
