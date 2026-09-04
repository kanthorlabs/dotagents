---
description: Delegate a coding task to Pi while Claude Code orchestrates and verifies the result
argument-hint: <task>
allowed-tools:
  - mcp__plugin_pi-orchestrator_pi__delegate
  - mcp__plugin_pi-orchestrator_pi__follow_up
  - mcp__plugin_pi-orchestrator_pi__status
  - mcp__plugin_pi-orchestrator_pi__abort
  - mcp__plugin_pi-orchestrator_pi__close
---

# Delegate to Pi

Treat `$ARGUMENTS` as the requested coding outcome.

## Internal classification

After context inspection, score every metric from `0` through `2`.

| Metric | 0 | 1 | 2 |
|---|---|---|---|
| `reasoning_depth` | Mechanical change | Normal design or debugging | Multiple hypotheses, algorithms, or invariants |
| `system_span` | One local unit | Several files in one subsystem | Multiple subsystems, contracts, or repositories |
| `uncertainty` | Clear cause and solution | Some discovery required | Cause, requirements, or solution unclear |
| `impact_risk` | Local and reversible | Public behavior or compatibility risk | Security, data, migration, concurrency, or irreversible risk |
| `verification_complexity` | One deterministic check | Multiple tests or integration checks | E2E, performance, nondeterminism, or missing test infrastructure |

The bridge classifies the task as `hard` when any condition applies:

- The score total is at least `6`.
- `impact_risk` equals `2`.
- `reasoning_depth` and `uncertainty` both equal `2`.
- `system_span` and `verification_complexity` both equal `2`.

The bridge classifies every remaining task as `other`.

The bridge routes `hard` to `gpt-5.6-sol` with `high` effort. It routes `other` to `gpt-5.6-luna` with `max` effort.

File count alone does not determine hardness. Use cognitive complexity, uncertainty, impact, and verification requirements.

## Execution

1. Resolve the current project directory to an absolute path.
2. Inspect enough project context to score the metrics and create one complete task packet.
3. Call `mcp__plugin_pi-orchestrator_pi__delegate` with the packet, directory, and five metric scores.
4. Confirm that the returned `routing` matches the scores and approved rules.
5. Read Pi's `outcome`, response, tool summary, interaction requests, and extension errors.
6. Inspect the resulting diff and run independent validation.
7. If defects remain, call `follow_up` with exact findings and verify again.
8. If Pi reports `blocked`, answer through `follow_up` when the available context resolves the blocker.
9. Close the Pi task only after verification finishes.

Claude Code owns task scope, metric scores, acceptance criteria, review, and the final report. Pi owns implementation and its first validation pass.

Report the scores, selected route, Pi outcome, and Claude Code verification evidence separately.
