# Swift example — composing the skeleton with this profile

This directory shows how the **KanthorVault** project's live TDD pipeline
decomposes into **skeleton + profile**:

```
.claude/commands/work.md          ==  ../../commands/work.md          rendered with PROFILE.md
.claude/agents/test-engineer.md   ==  ../../agents/test-engineer.md   rendered with PROFILE.md
.claude/agents/software-engineer.md == ../../agents/software-engineer.md rendered with PROFILE.md
.claude/agents/reviewer-engineer.md == ../../agents/reviewer-engineer.md rendered with PROFILE.md
```

"Rendered" = substitute every `{{TOKEN}}` with its value from `PROFILE.md` §1
and expand every `{{> SLOT}}` with its body from `PROFILE.md` §3.

## What lives where

- **Workflow mechanics** (the loop, escalation, review routing, discussion
  protocol, worktree isolation) → the skeleton. These are byte-for-byte the
  same across any project that adopts this methodology.
- **Swift/Xcode/macOS-iOS specifics** (xcodebuild, schemes, simulator, Swift
  Testing vs XCTest, TestID, SwiftData/`@Observable` idioms, the six review
  dimensions' concurrency/security detail, the macOS screenshot sketch flow) →
  `PROFILE.md`.

## Faithfulness to the original

`PROFILE.md` is filled from the original `.claude/` files, so a rendering
reconstructs their behavior. A few deliberate generalizations the skeleton made
(and the profile re-specializes):

- **"platform" → "variant"**: the skeleton speaks of `--variant`; this profile
  binds the three variants `shared`/`ios`/`macos`, so `--variant macos` in a
  rendering means the original's `--platform macos`. The original `/work` used
  `--platform`; a faithful rendering can alias `--variant` back to `--platform`
  if you want the exact original flag name.
- **"build-proof gate" → "handoff verification gate"**: same mechanic
  (test-engineer re-runs `verify-build.sh` on the SE's cited log); only the name
  generalized.
- **Lane prefix table**: this project's source/test dirs are disjoint, so the
  profile supplies a prefix table (not a predicate script). The skeleton allows
  either.

## Drift to watch

If the live `.claude/` files change, update `PROFILE.md` (for a
Swift/tooling/idiom change) or the skeleton (for a workflow-mechanics change) —
deciding which is itself the useful discipline: a change that would apply to a
Python port of this methodology belongs in the skeleton; a change that is about
Xcode or SwiftUI belongs here.
