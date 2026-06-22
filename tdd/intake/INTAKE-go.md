# TDD-Pipeline Intake — Go pack

Load **`INTAKE.md` (generic) first**, then this file. These are
**questions-with-defaults** that *refine* the Section-A answers for a Go stack —
confirm or override each default; a default is not a baked answer.

> **No `BAKING-go.md` exists yet.** This pack establishes the Go profile; treat
> its defaults as a first proposal, **unverified by a real bake**. The first Go
> bake's fidelity gate is an adversarial review (no committed `.claude/` to diff,
> L9).

Each item points back at the generic category it sharpens `(A#)` and the lesson
it de-risks `⚠`.

- **G1 (A6 / ⚠L2)** — Q: confirm Go **co-locates `foo_test.go` with `foo.go`** →
  a prefix table cannot separate lanes → a **predicate script is mandatory**
  (classify `*_test.go` → test-engineer, other `*.go` → software-engineer).
  *This is the single most important Go answer.*
- **G2 (A7 / ⚠L1)** — Q: handoff gate? · *Default:* `go build ./...` **and**
  `go vet ./...` (PASS iff both exit 0) · also: `golangci-lint` in the gate?
  `gofmt`/`goimports` clean enforced?
- **G3 (A10)** — Q: stdlib `testing` + table-driven tests ± `testify`? `-race` on
  the unit-test command (*default: yes*)? `t.Run` subtests as the suite unit?
  golden files via an `-update` flag?
- **G4 (A9)** — Q: error-wrapping `fmt.Errorf("...: %w", err)` with a dropped
  error = BLOCKER? `context.Context` propagation? interface-at-consumer DI seam
  (the fake is a small interface the *caller* defines)? no naked `panic` in
  library code? exported-identifier doc comments?
- **G5 (A11)** — Q: concurrency as a first-class review dimension — `-race`
  green, goroutine-leak (every spawn has a stop path), `context` cancellation
  honored, no unguarded shared map? · security: no `os/exec` with interpolated
  shell, parameterized SQL, secrets not logged?
- **G6 (A4)** — Q: single module (`app`) or `go.work` multi-module (a variant per
  module + dependency order, shared merge surface `go.mod`/`go.sum`)?
- **G7 (A12)** — Q: seed `go-gotchas.md` — loop-variable capture (pre-1.22),
  `nil` interface vs `nil` pointer, slice aliasing/`append` reuse, deferred-close
  error handling, map-iteration nondeterminism (an L3 ordering trap)?
- **G8 (A8)** — Q: `None.` (default — tests run in-process) or an integration DB
  booted once via testcontainers/docker?
- **G9 (A13)** — Q: sketch `Not applicable`; UI locator contract only for a web
  frontend?

## Capability-flag defaults (confirm)
| Capability | Default |
|---|---|
| Multi-variant parallelism | **no** (single module `app`); **yes** only for a `go.work` multi-module |
| Sketch phase | **no** — all test-gated; `--sketch` errors |
| UI/E2E tests | **no** (library/service/CLI); **yes** only for a web frontend |
| Locked copy | **no** |
