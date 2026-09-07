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

Start every metric at `1`. Lower a score to `0` only when explicit evidence proves the zero anchor.

| Metric | 0 | 1 | 2 |
|---|---|---|---|
| `reasoning_depth` | Mechanical change | Normal design or debugging | Multiple hypotheses, algorithms, or invariants |
| `system_span` | One local unit | Several files in one subsystem | Multiple subsystems, contracts, or repositories |
| `uncertainty` | Clear cause and solution | Some discovery required | Cause, requirements, or solution unclear |
| `impact_risk` | Local and reversible | Public behavior or compatibility risk | Security, data, migration, concurrency, or irreversible risk |
| `verification_complexity` | One deterministic check | Multiple tests or integration checks | E2E, performance, nondeterminism, or missing test infrastructure |

Send each metric in this shape:

```json
{"score": 1, "evidence": "Specific task or inspected context supporting this score."}
```

Give every score specific evidence. For each zero, give at least five words that prove the zero anchor.

Also send an `inspection` object with these fields:

- `inspected_paths`: Every project path inspected before scoring.
- `self_contained`: `true` only when the task text fully determines scope, risk, solution, and validation.
- `evidence`: Why the inspected context or self-contained task supports reliable scoring.

If the task is not self-contained, inspect at least one project path. Never use `self_contained` only to avoid inspection.

The bridge rejects bare numbers, weak zero evidence, duplicate paths, and uninspected non-self-contained tasks.

The bridge classifies the task as `hard` when any condition applies:

- The score total is at least `6`.
- `impact_risk` equals `2`.
- `reasoning_depth` and `uncertainty` both equal `2`.
- `system_span` and `verification_complexity` both equal `2`.

The bridge classifies every remaining task as `other`.

The bridge routes `hard` to `gpt-6-astra` with `high` effort. It routes `other` to `gpt-5.6-luna` with `max` effort.

File count alone does not determine hardness. Use cognitive complexity, uncertainty, impact, and verification requirements.

## Execution

1. Resolve the current project directory to an absolute path.
2. Inspect enough project context to score the metrics and create one complete task packet.
3. Build evidence-backed metrics and the inspection record.
4. Call `mcp__plugin_pi-orchestrator_pi__delegate` with the packet, directory, metrics, and inspection record.
5. Confirm that the returned `routing` preserves the evidence and matches the approved rules.
6. Read Pi's `outcome`, response, tool summary, interaction requests, and extension errors.
7. Inspect the resulting diff and run independent validation.
8. If defects remain, call `follow_up` with exact findings and verify again.
9. If Pi reports `blocked`, answer through `follow_up` when the available context resolves the blocker.
10. Close the Pi task only after verification finishes.

Claude Code owns task scope, metric evidence, scores, acceptance criteria, review, and the final report. Pi owns implementation and initial validation.

Report the inspection record, metric evidence, scores, selected route, Pi outcome, and Claude Code verification evidence separately.
