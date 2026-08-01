# Workspace reference

How to organize many flows: `config.yaml`, tags, execution order, reports, AI analysis, recording.

## `config.yaml` — workspace brain

Optional but essential as your suite grows. Place at workspace root (commonly under `.maestro/`). Filename must be exactly `config.yaml`.

When Maestro runs against a directory it auto-discovers a sibling `config.yaml` unless `--config <path>` is passed.

Maestro Studio does NOT use `config.yaml` (it includes the file in Cloud uploads though).

### Full schema

```yaml
# config.yaml
flows:                        # glob patterns; default "*" (root only). "**" = recursive
  - "subFolder/*"
  - "tests/**"

testOutputDir: build/maestro-results   # default: ~/.maestro/tests/

includeTags: [smoke, production_ready] # OR-logic; runs only flows tagged at least one
excludeTags: [wip, flaky]              # skips any flow tagged at least one

executionOrder:
  continueOnFailure: false             # default: true
  flowsOrder:                          # filenames (no .yaml) or `name:` from header
    - signup_flow
    - verify_email_flow
    - complete_profile

# Cloud-only:
baselineBranch: main
notifications:
  email:
    enabled: true
    recipients: [john@example.com]
  slack:
    endpoint: https://hooks.slack.com/services/...

# Platform-specific:
platform:
  ios:
    snapshotKeyHonorModalViews: false  # include background hierarchy when modal visible
    disableAnimations: true            # CLOUD ONLY — Reduce Motion
  android:
    disableAnimations: true            # CLOUD ONLY
```

CLI flags always override `config.yaml`. Use multiple configs for different scenarios (`smoke-config.yaml`, `ci-config.yaml`) and pass `--config <path>`.

## Test discovery (`flows`)

Default behavior is **non-recursive**: only `*.yaml` at the root of the directory you point at.

```yaml
flows:
  - "*"          # root only
  - "auth/*"     # one subfolder
  - "tests/**"   # recursive
```

## Tags

Define on a flow:

```yaml
appId: com.example.app
tags:
  - smoke
  - registration
---
- launchApp
```

Filter at run time:

```bash
maestro test . --include-tags=smoke
maestro test . --exclude-tags=wip
maestro test . --include-tags="auth,checkout" --exclude-tags="experimental,stagingOnly"
```

Logic:
- Multiple tags inside one flag → **OR**.
- Both flags together → AND between groups (include first, then remove excludes).
- **No AND-within-flag.** You cannot match `smoke AND auth` in a single flag.

Workspace policy via `config.yaml`:

```yaml
includeTags: [production_ready]
excludeTags: [experimental, flaky]
```

CLI flags > `config.yaml`.

## Sequential execution

Default: non-deterministic order. Forced order via `executionOrder`:

```yaml
executionOrder:
  continueOnFailure: false
  flowsOrder:
    - signup_flow         # Step 1
    - verify_email_flow   # Step 2
    - complete_profile    # Step 3
```

Behavior:
1. Listed flows run in given order.
2. After list completes (or fails), undiscovered/non-listed flows run in random order.

`continueOnFailure: false` — abort sequence on first failure (use for genuinely dependent steps).

Best practice: each flow should still run cleanly on a fresh device. Use hooks or nested flows for required state, NOT execution order.

| Need | Tool |
|---|---|
| Logic dependency (must be logged in) | Hook (`onFlowStart`) or `runFlow` |
| Convenience ordering | `executionOrder.flowsOrder` |
| Stop on first failure | `continueOnFailure: false` |

## Reports & artifacts

Default output:
- macOS/Linux: `~/.maestro/tests`
- Windows: `%userprofile%\.maestro\tests`

Override via CLI (highest precedence) or `config.yaml`:

```bash
maestro test --test-output-dir=build/maestro-results ./e2e
```
```yaml
testOutputDir: build/maestro-results
```

### Formats (CLI-only via `--format`)

```bash
maestro test --format junit         --output build/report.xml      ./e2e
maestro test --format html          --output build/report.html     ./e2e
maestro test --format html-detailed --output build/detailed.html   ./e2e
```

Report files are NOT placed inside `--test-output-dir`/`--debug-output`.

### Custom JUnit properties

Per flow:

```yaml
appId: com.example.app
name: Login Flow
properties:
  testCaseId: "TC-101"
  priority: "High"
---
- launchApp
```

### `--test-output-dir` vs `--debug-output`

| Artifact | `--test-output-dir` | `--debug-output` |
|---|---|---|
| Screenshots / video | ✅ | ❌ |
| `maestro.log` | ❌ | ✅ |
| `commands-*.json` | ✅ | ✅ |
| AI reports | ✅ | ✅ |

If both flags point to the **same** directory, everything is consolidated. If they point to **different** directories, `--debug-output` only gets `maestro.log`; everything else lands in `--test-output-dir`.

## Recording

```bash
maestro record --local YourFlow.yaml          # local render, recommended
maestro record YourFlow.yaml                  # legacy remote render (deprecated)
```

Limits: 2-minute cap; remote recordings → signed URL valid 60min, auto-deleted after 24h.

For per-step inline capture, use the `startRecording` / `stopRecording` commands instead.

## AI test analysis

`--analyze` flag generates an HTML insights report (UI regressions, spelling, layout breaks, internationalization). Requires Maestro Cloud login (free account is enough).

```bash
maestro login                                    # interactive
export MAESTRO_CLOUD_API_KEY=<your_key>          # CI/non-interactive
maestro test login_flow.yaml --analyze
```

Old `MAESTRO_CLI_AI_KEY` / `MAESTRO_CLI_AI_MODEL` env vars are deprecated. AI is routed through Maestro Cloud's managed model.

Suppress the "Analyzing Flow…" banner in CI:

```bash
export MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true
```

Inline AI commands (don't need `--analyze`): `assertWithAI`, `assertNoDefectsWithAI`, `extractTextWithAI`. See [commands.md](commands.md).

## Suggested workspace layout

```
.
├── .maestro/
│   ├── config.yaml
│   ├── e2e/
│   │   ├── checkout_flow.yaml
│   │   └── profile_flow.yaml
│   └── subflows/
│       ├── login.yaml
│       └── payment_setup.yaml
├── scripts/
│   ├── seed_user.js
│   └── teardown.js
└── assets/
    ├── headshot.png
    └── upload.csv
```
