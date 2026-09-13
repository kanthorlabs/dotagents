---
name: coding
description: Apply seven rules for linear control flow, bounded loops, resource ownership, small functions, assertions, explicit errors, and zero warnings. Use when the user asks to write, change, or review code.
---

# /coding

Usage: `/coding [$ARGUMENTS]`

If `$ARGUMENTS` is present, use it as the task. Otherwise, apply these rules to the current task.

## Rules

1. **Linear control flow.** Keep control flow linear. Use at most two nested control-flow levels.
   Prefer guard clauses and early returns.
2. **Bounded loops.** Give finite loops an explicit iteration bound that the code enforces.
   Do not rely on assumed input size or eventual termination.
   Give retries an attempt limit and a timeout. For intentional service loops, define an explicit shutdown path.
3. **Resource ownership.** Give every resource an explicit owner.
   Release owned resources on success, error, and cancellation. Make ownership transfers explicit.
   Prefer language constructs that guarantee cleanup, such as context managers, `defer`, `finally`, or RAII.
4. **Small functions.** Give each function one job. Keep each function within about 60 lines.
5. **Assertions.** Add at least two meaningful assertions to every function.
   Use side-effect-free assertions for internal invariants. Validate external inputs with explicit errors.
   Make assertion failures explicit.
6. **Explicit errors.** Handle or propagate every error. Never swallow an error, including through `except: pass`.
7. **Zero warnings.** Run the applicable compiler, type, lint, and static-analysis checks from the first change.
   Require zero warnings and errors. Fix warning causes. Do not suppress warnings to pass the checks.

### Fail-fast error handling (strict)

1. Before each `try/catch` addition or change, identify possible failures and
   justify error handling at that exact layer.
2. Prefer propagation over local recovery. If the current scope cannot fully
   recover and preserve correctness, let the error propagate or rethrow it.
   When useful, add context to the error.
3. Do not hide failures behind `null`, `[]`, or `false` fallbacks, swallowed parse
   errors, log-and-continue paths, or silent best-effort recovery.
4. Let JSON parse and decode errors propagate by default. Without an explicit
   compatibility requirement and clear, tested behaviour, do not implement a quiet
   fallback.
5. When HTTP routes, CLI entrypoints, or supervisors translate errors, preserve
   the failure signal. Do not report success or silently degrade.
6. Do not add or keep a catch solely to satisfy lint or style rules.
7. When correct recovery is uncertain, fail fast rather than silently degrade.

## Verification

Check the changed code against all seven rules and the strict fail-fast requirements.
Run the relevant tests and all applicable compiler, type, lint, and static-analysis checks before completion.
Require zero warnings and errors.
