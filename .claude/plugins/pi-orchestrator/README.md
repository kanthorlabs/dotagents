# Pi Orchestrator

Pi Orchestrator lets Claude Code assign coding work to persistent Pi workers. Claude remains responsible for scope, review, and final verification.

## Requirements

- Claude Code 2.1 or newer
- Pi 0.82 or newer
- Node.js 22.19 or newer
- OpenAI Codex authentication for `gpt-5.6-sol` and `gpt-5.6-luna`

## Usage

The dotagents installer adds the exact command alias:

```text
/pi add request validation and cover it with tests
```

A marketplace-only installation uses the namespaced command:

```text
/pi-orchestrator:pi add request validation and cover it with tests
```

Claude can also load the bundled skill for natural delegation requests.

## Model routing

Claude scores five metrics after project inspection:

- Reasoning depth
- System span
- Uncertainty
- Impact risk
- Verification complexity

Each metric ranges from `0` through `2`. Claude starts each score at `1` and attaches specific evidence.

A zero requires at least five evidence words that prove its zero anchor. Bare numeric metrics fail before Pi starts.

Claude also reports inspected paths. An empty path list requires evidence that the task is fully self-contained.

The bridge validates evidence structure and preserves every statement for review. It does not independently judge semantic truth.

The bridge computes the route only after validation.

A task is `hard` when the total reaches `6`. These conditions also force `hard`:

- Impact risk equals `2`.
- Reasoning depth and uncertainty both equal `2`.
- System span and verification complexity both equal `2`.

The `hard` route uses `openai-codex/gpt-5.6-sol` with `high` effort. The `other` route uses `openai-codex/gpt-5.6-luna` with `max` effort.

The bridge checks Pi's selected model and effort before sending the task. Any mismatch returns a structured failure.

## Tools

| Tool | Purpose |
|---|---|
| `delegate` | Validate metric scores, select a route, and start a Pi task. |
| `follow_up` | Continue the same Pi session with corrections or answers. |
| `status` | Inspect one task or list all bridge tasks. |
| `abort` | Stop an active run and retain its session. |
| `close` | Stop and remove a retained Pi worker. |

Each run returns its evidence, scores, inspection record, classification, route, task identifier, outcome, and Pi session metadata.

## Communication guarantees

The bridge provides these deterministic guarantees:

- MCP request identifiers correlate every Claude call.
- Pi RPC request identifiers correlate every worker command.
- Server-owned rules reject incomplete or unsupported classification evidence.
- Server-owned rules map validated metrics to fixed model routes.
- Pi startup verifies the selected model and effort.
- Strict LF-delimited parsing preserves Unicode line separators.
- `agent_settled` ends work only after retries and queued continuations finish.
- Follow-ups reuse the original Pi process and conversation.
- Claude cancellation propagates to Pi through RPC `abort`.
- Interactive Pi dialogs auto-cancel and return their details to Claude.
- Pi stderr never enters the MCP protocol stream.
- Timeouts and process exits return structured failures.
- Server shutdown closes every retained Pi process.

The bridge cannot guarantee model availability or implementation correctness. Claude must inspect changes and run independent validation.

## Configuration

The bridge uses `pi` from `PATH` by default.

| Variable | Default | Purpose |
|---|---:|---|
| `PI_ORCHESTRATOR_PI_COMMAND` | `pi` | Pi executable path. |
| `PI_ORCHESTRATOR_PI_ARGS` | `[]` | JSON array placed before Pi RPC arguments. |
| `PI_ORCHESTRATOR_START_TIMEOUT_MS` | `30000` | Pi startup deadline. |
| `PI_ORCHESTRATOR_COMMAND_TIMEOUT_MS` | `30000` | Pi RPC command deadline. |
| `PI_ORCHESTRATOR_TASK_TIMEOUT_MS` | `1800000` | One Pi run deadline. |

Use `PI_ORCHESTRATOR_PI_ARGS` only for unrelated global Pi flags. Routed model and effort flags always take precedence.

## Security

A delegated Pi worker inherits the current operating-system permissions. Pi can modify files and run commands inside the selected directory.

Review the tool call before approval. Use a sandbox when the target project is untrusted.

The bridge does not add `--approve`. Pi applies the configured non-interactive project-trust policy.

## Tests

Run deterministic protocol tests:

```bash
npm test
```

Run the optional real-Pi proof:

```bash
npm run test:live
```

The live proof creates an isolated temporary directory. Pi writes and validates one proof file there.
