---
name: seniorgo
description: Senior Go developer skill. Code review, refactoring, testing, performance optimization following Effective Go 2026 guidelines. Use for Go projects requiring idiomatic, production-quality code.
compatibility: Requires Go 1.22+, staticcheck, gofmt
loading: deferred
metadata:
  author: kanthorlabs
  version: "25.4.28"
  go-version: "1.26"
---

## How to Use This Skill

**Core rules below are always available.** For deeper guidance, read the relevant
reference file from `references/` on-demand — check the Deferred References table
to find the right file for your task. Do NOT load all references upfront.

## Core Rules (Always Loaded)

### Error Handling

- Never discard errors with `_`. Check, return, or handle every error.
- Wrap with context: `fmt.Errorf("processing %d: %w", id, err)`
- Use `errors.Is` for sentinel checks, `errors.As` for type checks.
- Error strings: lowercase, no punctuation — they compose into larger messages.
- Return `(value, error)` pairs, not sentinel values (-1, "", nil).

### Naming

- Package names: lowercase, single-word, no `util`/`common`/`misc`/`helpers`.
- No stuttering: `http.Server` not `http.HTTPServer`.
- Consistent initialisms: `URL`/`url` never `Url`, `ID` never `Id`.
- Short locals (`c` not `lineCount`), descriptive far from declaration.
- Getters: `Owner()` not `GetOwner()`. Setters: `SetOwner()`.
- One-method interfaces: method name + `-er` (`Reader`, `Writer`).
- Receiver: 1-2 letter, consistent across methods. Never `self`/`this`/`me`.

### Code Review Essentials

- Context as first param: `func F(ctx context.Context, ...)`. Never store in structs.
- Handle errors first, return early — keep happy path at minimal indentation.
- Interfaces: define in consumer package, not producer. Return concrete types.
- Receiver type: pointer when in doubt. Value only for small immutable types.
- Don't mix receiver types on a type.
- Goroutine lifetimes must be obvious. Blocked goroutines never GC'd.
- Prefer sync over async. Let callers add concurrency.
- Imports: stdlib first, blank line, then external. Use `goimports`.
- `import _` only in main or tests. `import .` only for circular test deps.
- Named returns: only when same-type returns need disambiguation.
- Nil slice (`var t []string`) preferred. Non-nil `[]string{}` only when JSON needs `[]`.
- Pass values not pointers for small types — don't optimize what doesn't matter.

### Functions

- Multiple returns: `(value, error)` pattern is idiomatic.
- `defer` for cleanup — evaluated at defer, executed at return, LIFO order.

### Concurrency Quick Reference

- Share by communicating, don't communicate by sharing.
- `sync.WaitGroup.Go` (1.25+) for managed goroutine spawning.
- `sync.OnceFunc`/`OnceValue`/`OnceValues` (1.21+) for lazy init.
- `select` with `ctx.Done()` for cancellation-aware operations.

## Deferred References

**Read these files on-demand when the task matches.** Each row tells you when to load.

| Reference | Load when... |
|-----------|-------------|
| [concurrency.md](references/concurrency.md) | Writing/reviewing goroutines, channels, sync primitives, `select`, weak pointers |
| [generics.md](references/generics.md) | Type parameters, constraints, generic data structures |
| [testing.md](references/testing.md) | Writing/reviewing tests, benchmarks, `synctest`, fuzzing |
| [performance.md](references/performance.md) | Profiling, benchmarks, `sync.Pool`, inlining, PGO |
| [data.md](references/data.md) | Allocation, `new`/`make`, slices, maps, `append`, 2D slices, `strings.Builder` |
| [control-structures.md](references/control-structures.md) | `if`/`for`/`switch`/`select` patterns, type switches, range |
| [security-and-cryptography.md](references/security-and-cryptography.md) | Crypto, TLS, FIPS mode, key management |
| [modules-and-dependencies.md](references/modules-and-dependencies.md) | `go.mod`, versioning, vendoring, dependency management |
| [interfaces-and-types.md](references/interfaces-and-types.md) | Type assertions, type switches, interface composition |
| [code-review.md](references/code-review.md) | Full review checklist (core rules above cover 80% — load for edge cases) |
| [errors.md](references/errors.md) | Detailed error wrapping, sentinel errors, custom error types |
| [names.md](references/names.md) | Full naming guide with examples (core rules above cover essentials) |
| [iterators.md](references/iterators.md) | Range-over-func (1.23+), `iter.Seq`, push/pull iterators |
| [embedding.md](references/embedding.md) | Struct/interface embedding patterns |
| [methods.md](references/methods.md) | Method declarations, pointer vs value receivers in depth |
| [functions.md](references/functions.md) | Detailed defer, named returns, multiple return patterns |
| [panic-and-recover.md](references/panic-and-recover.md) | When to panic, recover patterns, implicit panics |
| [formatting.md](references/formatting.md) | `gofmt` details, `gofumpt`, indentation rules |
| [commentary.md](references/commentary.md) | Doc comment conventions, `//go:` directives |
| [semicolons.md](references/semicolons.md) | Lexer rules, brace placement |
| [blank-identifier.md](references/blank-identifier.md) | `_` usage: unused imports, type checks, interface enforcement |
| [introduction.md](references/introduction.md) | Language philosophy overview |
| [version-history.md](references/version-history.md) | Go version changelog, feature availability by version |

## Available Scripts

- `scripts/lint.sh` — Run gofmt, go vet, staticcheck
- `scripts/test.sh` — Run tests with coverage report
