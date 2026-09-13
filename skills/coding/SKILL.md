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

## Verification

Check the changed code against all seven rules.
Run the relevant tests and all applicable compiler, type, lint, and static-analysis checks before completion.
Require zero warnings and errors.
