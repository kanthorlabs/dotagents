---
name: pi-orchestration
description: Use when Claude Code must delegate coding implementation to Pi, ask Pi to modify a project, or orchestrate Pi worker tasks.
version: 0.3.0
---

# Pi orchestration

Keep Claude Code as the orchestrator. Delegate implementation, tests, and corrections to Pi.

## Handoff contract

Send one self-contained task packet through `mcp__plugin_pi-orchestrator_pi__delegate`.

Include these fields in the packet:

- Objective
- Relevant context and paths
- Acceptance criteria
- Constraints and preserved behavior
- Required validation

Pass the absolute project directory as `cwd`.

## Internal classification

After context inspection, score every metric from `0` through `2`.

Start every metric at `1`. Lower a score to `0` only when explicit evidence proves the zero anchor.

| Metric | 0 | 1 | 2 |
|---|---|---|---|
| `reasoning_depth` | Mechanical | Normal design or debugging | Multiple hypotheses, algorithms, or invariants |
| `system_span` | One local unit | One subsystem | Multiple subsystems, contracts, or repositories |
| `uncertainty` | Clear | Some discovery | Cause, requirements, or solution unclear |
| `impact_risk` | Local and reversible | Public behavior or compatibility | Security, data, migration, concurrency, or irreversible impact |
| `verification_complexity` | One deterministic check | Multiple or integration checks | E2E, performance, nondeterminism, or missing infrastructure |

Send every metric as `{ "score": N, "evidence": "specific evidence" }`.

Give every score specific evidence. For each zero, give at least five words that prove the zero anchor.

Send `inspection` with all inspected paths, a `self_contained` flag, and evidence for the context basis.

If the task is not self-contained, inspect at least one path. Never claim self-containment only to avoid inspection.

The bridge rejects bare numbers, weak zero evidence, duplicate paths, and uninspected non-self-contained tasks.

The bridge selects `hard` when the total reaches `6`. The bridge also selects `hard` for any approved override:

- `impact_risk` equals `2`.
- `reasoning_depth` and `uncertainty` both equal `2`.
- `system_span` and `verification_complexity` both equal `2`.

The bridge routes `hard` to `gpt-6-astra` with `high` effort. It routes every other task to `gpt-5.6-luna` with `max` effort.

## Result contract

Wait for `agent_settled`, which the bridge enforces. Do not treat prompt acceptance as task completion.

Inspect these result fields:

- `outcome`
- `routing.metrics`
- `routing.inspection`
- `response`
- `tools`
- `interaction_requests`
- `extension_errors`
- `task_id`

Use `follow_up` with the same `task_id` for answers, defects, or missing validation. The Pi session retains its full context.

Use `abort` for obsolete work. Use `close` only after independent verification finishes.

## Orchestrator checks

Inspect the workspace after each Pi run. Compare the diff against the acceptance criteria.

Run independent validation when practical. Never claim that Pi succeeded from its report alone.

If Pi reports `blocked`, resolve the listed questions or escalate them. If Pi reports `failed`, preserve the error and decide the next action.

Do not implement the delegated task in parallel with Pi. Parallel edits can collide in one working tree.
