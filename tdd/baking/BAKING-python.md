# Baking the TDD pipeline for Python

Stack-specific bake. Read `BAKING.md` (common procedure + lessons L1–L8) first.
Python is the cleanest stress-test of the skeleton's generalizations: **no
compile step** (handoff = lint/typecheck), **tests often co-located** (lane =
predicate, not prefix), and usually **no sketch phase** (all test-gated).

---

## Profile (`PROFILE.md` values)

### Tokens
| Token | Value |
|---|---|
| `{{REPO_NAME}}` | your Python repo name |
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
| Multi-variant parallelism | **no** for a single package (variant `app`). **Yes** for a monorepo of packages — define each package as a variant with its dependency order. |
| Sketch phase | **no** — no GUI/visual artifact; all work is test-gated. `{{> SKETCH_MODE}}` = `Not applicable`. |
| UI/E2E tests | usually **no** (library/service/CLI). **Yes** only for a web UI (Playwright/Selenium) — then enable `{{> UI_LOCATOR_CONTRACT}}`. |
| Locked copy | usually **no** (`Not applicable`). |

### Slots

**`{{> PROJECT_CONTEXT}}`** — A Python [library / service / CLI], Python 3.x,
fully type-hinted. Stdlib-first; new third-party dep needs justification.
[State any hard constraints: async vs sync, framework (FastAPI/Django/none),
no `eval`/`pickle` of untrusted data.]

**`{{> VARIANTS_AND_SCOPES}}`** — Single variant `app` owning `src/<pkg>/`;
parallel/worktree/join machinery collapses to a no-op. (Monorepo: define a
variant per package with dependency order, e.g. `core` → `api`; the shared merge
surface is `pyproject.toml` / the lockfile and any shared `core` package.)

**`{{> SOURCE_AND_TEST_LAYOUT}}`** — Production: `src/<pkg>/` (src-layout) — or
`<pkg>/` (flat). Tests: **decide one and tell the lane slot** —
(a) **separate** `tests/` mirroring `src/` (`tests/<mod>/test_<thing>.py`), or
(b) **co-located** `src/<pkg>/<mod>/test_<thing>.py` next to the module. Import =
`from <pkg>.<mod> import ...`. File naming `test_*.py`; one test module per
source module; `pytest` test functions/classes.

**`{{> LANE_OWNERSHIP}}`** — **Depends on the test layout (lesson L2):**
- *Separate `tests/`* → prefix table works:

  | scope | test-engineer | software-engineer |
  |---|---|---|
  | `app` | `tests/` | `src/` |

- *Co-located tests* → a prefix CANNOT separate lanes (both roles touch
  `src/<pkg>/`). Supply a **predicate script** `scripts/lane-check.sh`:
  ```sh
  # exit 0 = in-lane
  role="$1" scope="$2" path="$3"
  case "$role" in
    test-engineer)     case "$path" in */test_*.py|*_test.py|tests/*) exit 0;; *) exit 1;; esac;;
    software-engineer) case "$path" in */test_*.py|*_test.py|tests/*) exit 1;; src/*|*/*.py) exit 0;; *) exit 1;; esac;;
  esac
  ```
  Always forbidden to both: `.agents/plan/`, `pyproject.toml`/`setup.cfg`/lockfiles, CI config.

**`{{> BUILD_AND_TEST_COMMANDS}}`** — *No build step* — the handoff artifact is
the **lint+typecheck** result (lesson L1):
| Purpose | Command |
|---|---|
| produce handoff artifact | `ruff check src tests && mypy src` ; tee to `.agents/debate/.check.log` |
| run unit tests | `pytest [tests/<path> or -k <expr>] -q` |
| run E2E (only if web UI) | `pytest tests/e2e -q` (Playwright) |
| verify handoff | `scripts/verify-check.sh <log>` → PASS iff ruff exit 0 AND mypy "Success: no issues" |
Cache: pytest/mypy caches live in `.pytest_cache`/`.mypy_cache` (gitignored) —
a worktree gets its own; fine. Use a project venv (`uv`/`venv`); the dispatch
env must activate it.

**`{{> ENV_PREFLIGHT}}`** — `None.` for a library/service (tests run in-process).
If web E2E: install browsers once (`playwright install`) and note it.

**`{{> GOTCHA_FILES}}`** — `.agents/memory/python-gotchas.md`: mutable default
args, late-binding closures in loops, `==` vs `is`, `__eq__`/`__hash__` pairing,
`asyncio` (don't block the loop; `await` everything), context-manager/resource
cleanup, `dataclass`/`frozen` pitfalls, import-time side effects. If async:
`.agents/memory/asyncio-gotchas.md`.

**`{{> IDIOM_CHECKLIST}}`** *(software-engineer)*
1. **Full type hints**; code passes `mypy` (strict if the project sets it). No bare `Any` to dodge a type.
2. No mutable default arguments; no late-binding loop closures.
3. Prefer stdlib + `dataclasses`/`enum`/`pathlib`/`typing`; new dep needs justification.
4. Resources via context managers (`with`); no leaked file handles/connections.
5. Errors: specific exceptions, no bare `except:`; never silently swallow (a dropped persistence error = data loss). Log, don't `print`.
6. Async (if used): no blocking calls in `async def`; offload CPU work to a thread/process pool.
7. Access: leading `_` for internal; a Protocol/ABC seam where tests substitute a fake — match the name the Task's GREEN block gives; inject deps via `__init__` with sensible defaults.

**`{{> TEST_CONVENTIONS}}`** *(test-engineer)* — `pytest` (functions or classes,
`assert`, fixtures, `pytest.raises`, `parametrize`). Fakes = plain stub objects /
`unittest.mock` with safe defaults; Mocks = `MagicMock`/spec'd with
Story-specified return values. `hypothesis` for property/edge coverage when a
Task's behavior has an input space (great for L3 edge-pinning). `conftest.py` for
shared fixtures. One test module per source module. Read `python-gotchas.md`
before writing tests touching async/resources.

**`{{> UI_LOCATOR_CONTRACT}}`** — `Not applicable.` (library/service/CLI.) *If a
web UI:* declare Playwright locators (`data-testid`) in a shared registry; the
test-engineer names them, the software-engineer puts the exact `data-testid` on
the element; tests never inline a raw selector.

**`{{> COPY_SOURCING}}`** — `Not applicable.` (Unless the project locks
user-facing strings — then source from the message catalog, assert the key.)

**`{{> REVIEW_DIMENSIONS}}`** *(reviewer-engineer)* — cite-a-source structure;
dimensions:
1. Correctness — AC match; named REFACTOR applied; test verifies the AC not an adjacent symbol.
2. **Type & contract safety** (replaces "concurrency" for sync code) — does it pass `mypy`? Are public signatures precisely typed? For async: no blocking in the event loop, no unawaited coroutines (BLOCKER), shared-state races.
3. Test quality — each test maps to an AC; no `assert True`/empty `except`; mocks not repeating prod bugs; edge cases (esp. via `parametrize`/`hypothesis`) present.
4. API design — the seam is importable/substitutable by a fake; Protocol explicit; composes for callers.
5. Simplicity — no over-abstraction/speculative class hierarchy; stdlib over a dep; dead code.
6. Security — no `eval`/`exec`/`pickle.loads` on untrusted input; no `shell=True` with interpolation; secrets not in code/logs; SQL parameterized; persistence errors surfaced (no silent swallow). BLOCKER on any.
(No Phase A — all dimensions every review.)

**`{{> SKETCH_MODE}}`** — `Not applicable — all work is test-gated.` (The
`/work --sketch` flag therefore errors, by design.)

---

## Python-specific bake steps (in addition to BAKING.md §1)

1. Scripts: `scripts/verify-check.sh` (PASS iff `ruff` exit 0 AND `mypy` "Success"); ensure the dispatch env activates the project venv.
2. Decide test layout (separate vs co-located) and wire the matching lane mechanism — **this is the L2 decision; don't default to a prefix table if tests are co-located.**
3. Seed `python-gotchas.md` (+ `asyncio-gotchas.md` if async).
4. Confirm `{{> SKETCH_MODE}}` = Not applicable so `--sketch` is correctly disabled.
5. Smoke epic: one pure function + one `pytest` Task — fastest end-to-end (no device, no build).

## Verification checklist (Python)
- [ ] BAKING.md §3 checklist passes.
- [ ] Handoff gate = `ruff` + `mypy` (NOT "build"); `verify-check.sh` returns PASS/FAIL (L1).
- [ ] If tests are co-located: the **lane predicate script** correctly classifies `src/pkg/mod.py` (SE) vs `src/pkg/test_mod.py` (TE) (L2). Test both paths.
- [ ] A deliberately loose RED test (passes on first run) is flagged by the persona (L3) — use `hypothesis`/`parametrize` to pin edges.
- [ ] `--sketch` errors (sketch correctly disabled).
- [ ] Reference solution for a verification run is NOT reachable in the agent's git history (L7).
