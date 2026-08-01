# Flow control reference

Conditions, loops, retries, nested flows, hooks, parameters, waits, permissions, sharding, locales, labels, and `optional`.

## Conditions: `when`

Attach a `when` block to a command (most commonly `runFlow`, `tapOn` via `optional`, etc.). Multiple keys → AND.

| Key | Fires when |
|---|---|
| `visible` | Selector matches a visible element. |
| `notVisible` | Selector does not match. |
| `platform` | Current platform matches `Android` / `iOS` / `Web`. |
| `true` | JS expression evaluates truthy. |

```yaml
# Platform branching
- runFlow:
    when: { platform: Android }
    file: subflows/android-permissions.yaml
- runFlow:
    when: { platform: iOS }
    file: subflows/ios-permissions.yaml

# Optional dismissal popup (runFlow + when)
- runFlow:
    when: { visible: "Dismiss" }
    commands:
      - tapOn: "Dismiss"

# Or shorter, single-step pattern with `optional`:
- tapOn:
    text: "Dismiss"
    optional: true
    label: "Dismiss popup if it exists"

# Negative branch
- runFlow:
    when: { notVisible: "Biometric Login" }
    commands:
      - tapOn: "Standard Login"

# Multiple AND conditions
- runFlow:
    when:
      platform: Android
      visible: "Allow Notifications"
    commands:
      - tapOn: "Allow"

# Feature flag via JS
- runFlow:
    when: { true: ${IS_FEATURE_ENABLED == true} }
    file: subflows/new-feature-test.yaml

# For multi-line JS, externalize:
- runScript: checkFeature.js
- runFlow:
    when: { true: ${output.shouldRunTest} }
    file: subflows/advanced-test.yaml
```

Anti-pattern: do not stuff every test full of `when` branches. Prefer separate flows for materially different scenarios.

## Loops: `repeat`

Three modes:

```yaml
# Fixed
- repeat:
    times: 5
    commands:
      - tapOn: "Add Item"

# Conditional (continues while truthy)
- repeat:
    while: { notVisible: "Your inbox is empty" }
    commands:
      - tapOn: "Delete"
      - tapOn: "Confirm"

# Smart loop — safety cap
- repeat:
    times: 10
    while: { visible: "Update available" }
    commands:
      - tapOn: "Dismiss"
      - assertNotVisible: "Dismiss"
```

JS counter pattern:

```yaml
- evalScript: ${output.attempt = 0}
- repeat:
    while: { true: ${output.attempt < 3} }
    commands:
      - tapOn: "Refresh"
      - evalScript: ${output.attempt++}
```

Data-driven loop with subflow:

```yaml
- evalScript: ${output.items = ["Headphones", "Charger", "Phone Case"]}
- evalScript: ${output.i = 0}
- repeat:
    while: { true: ${output.i < output.items.length} }
    commands:
      - runFlow:
          file: subflows/add_item.yaml
          env: { PRODUCT_NAME: ${output.items[output.i]} }
      - evalScript: ${output.i++}
```

If iterations include rapid screen changes, drop `waitForAnimationToEnd` inside `commands:` to stabilize.

## Retry on failure: `retry`

`maxRetries` 0–3 (default 1). Wrap a single fragile step, NOT the whole flow.

```yaml
- retry:
    maxRetries: 3
    commands:
      - tapOn: { id: "fragile_button" }

- retry:
    file: subflows/login.yaml
    maxRetries: 2
```

## Nested flows: `runFlow`

Externalize repeated sequences. Pass `env`. Use `label` for reports.

```yaml
- runFlow: ../common/login.yaml
- runFlow:
    file: ../common/login.yaml
    env: { USERNAME: alice, PASSWORD: secret }
    label: "Login as alice"
- runFlow:
    label: "Sort A-Z"
    commands:
      - tapOn: { id: sort_icon }
      - tapOn: "A-Z"
```

Recommended layout:

```
.
├── flows/
│   ├── e2e/
│   │   ├── checkout_flow.yaml
│   │   └── profile_flow.yaml
│   └── subflows/
│       ├── login.yaml
│       └── payment_setup.yaml
```

Best practices: keep subflows atomic (one job each), one file per task, prefer hooks for setup/teardown.

## Hooks: `onFlowStart` / `onFlowComplete`

Defined in the **header** (above `---`). Run for every Flow execution.

```yaml
appId: my.app
onFlowStart:
  - runFlow: setup.yaml
  - runScript: setup.js
onFlowComplete:
  - runFlow: teardown.yaml
---
- launchApp
```

Behavior on failure (matches JUnit `@Before`/`@After` semantics):
- `onFlowStart` fails → flow marked failed, body skipped, `onFlowComplete` still runs.
- `onFlowComplete` fails → flow marked failed even if body passed.

Watch out for infinite loops — never have a hook call a flow that re-triggers the same hook.

Dynamic hooks:

```yaml
onFlowStart:
  runFlow:
    file: subflows/login.yaml
    env: { ROLE: "admin" }
```

## Parameters and constants

Same `${VAR}` syntax. Case-sensitive.

```bash
# CLI
maestro test -e USERNAME=user@example.com -e PASSWORD=secret flow.yaml
```

```yaml
# Inline constants in header
appId: com.example.app
env:
  DEFAULT_TIMEOUT: 5000
  IS_DEBUG: true
---
- inputText: ${USERNAME || "guest"}     # default fallback (JS or operator)
```

Shell env vars prefixed `MAESTRO_` are auto-imported (CLI only, not Studio):

```bash
export MAESTRO_API_KEY=12345
```
```yaml
- evalScript: ${output.apiKey = MAESTRO_API_KEY}
```

CLI params arrive as **strings** — parse if you need numbers/bools (`parseInt(${COUNT})`).

Override priority: subflow `env` > parent `env` > CLI `-e`.

### Built-in parameters

| Parameter | Value |
|---|---|
| `MAESTRO_FILENAME` | Current flow filename. |
| `MAESTRO_DEVICE_UDID` | Device identifier under test. |
| `MAESTRO_SHARD_ID` | Shard ID, 1-based. Defaults `1`. |
| `MAESTRO_SHARD_INDEX` | Shard index, 0-based. Defaults `0`. |
| `MAESTRO_PLATFORM` | `Android` / `iOS` / `Web` (used in JS conditions). |

## Wait strategies

Decision order:
1. **Default**: assertions auto-poll up to ~7s. Use `assertVisible` / `assertNotVisible` whenever possible.
2. **Long ops** (>7s, e.g. payment): `extendedWaitUntil` with realistic timeout.
3. **Animations** (visible but moving): `waitForAnimationToEnd` (succeeds on timeout, does not abort).
4. **Ghost taps** (button there but not yet clickable): combine with `tapOn.retryTapIfNoChange: true`.

```yaml
- tapOn: "Submit"
- assertVisible: "Success!"               # 7s built-in poll

- extendedWaitUntil:
    visible: "Payment Confirmed"
    timeout: 30000

- waitForAnimationToEnd: { timeout: 5000 }
```

Do not blanket-set 60s timeouts — masks regressions.

## Permissions

Two entry points:
- `launchApp.permissions:` — set on launch.
- `setPermissions:` — set mid-flow (before deeplinks, etc).

Default state (no config): all granted. To force prompts: `unset`.

| Value | Behavior |
|---|---|
| `allow` | Grant. iOS dismisses prompt automatically. |
| `deny` | Deny. Android may still prompt later when feature requests it. |
| `unset` | Reset state — system prompts when app asks. |

Cross-platform names: `bluetooth`, `calendar`, `camera`, `contacts`, `homekit`, `location`, `medialibrary`, `microphone`, `motion`, `notifications`, `phone`, `photos`, `reminders`, `siri`, `sms`, `speech`, `storage`, `usertracking`. Each row in the docs table notes iOS/Android availability.

iOS `location` granular values: `always`, `inuse`, `never`. iOS `photos` supports `limited`.

Android custom permissions — pass full ID:

```yaml
- launchApp:
    clearState: true
    permissions:
      android.permission.MANAGE_EXTERNAL_STORAGE: deny
```

`all: allow` covers custom permissions too.

iOS notification prompts: Maestro auto-taps "Allow" on the system dialog. Android grants silently.

Web/Chrome: Maestro cannot manage Chrome's system permissions.

## Specify and start devices

```bash
maestro start-device                    # show options
maestro start-device --platform android # default Pixel 6 / API 30
maestro start-device --platform ios     # default iPhone 11 / iOS 15.5

maestro list-devices                    # local device models + OS versions
maestro list-cloud-devices              # Maestro Cloud-supported pairs
```

Find an existing device's identifier:

```bash
adb devices                              # Android
xcrun simctl list devices booted         # iOS
```

Web has no device list — Maestro launches its own Chromium.

Target a specific device (the `--device` flag goes **before** `test`):

```bash
maestro --device 5B6D77EF-2AE9-47D0-9A62-70A1ABBC5FA2 test flow.yaml
```

### Sharding (parallel local runs)

```bash
# Strategy A — same suite on N devices (cross-validation, flake hunting)
maestro test --shard-all 3 .maestro

# Strategy B — split suite across N devices (fastest total wall time)
maestro test --shard-split 3 .maestro

# Limit which devices participate
maestro test --device "emulator-5554,emulator-5556" --shard-split 2 ./tests
```

Pre-condition: requested shard count ≤ booted devices, else error.

When sharding, screenshots collide unless namespaced:

```yaml
- takeScreenshot: "LoginScreen-shard_${MAESTRO_SHARD_INDEX}-device_${MAESTRO_DEVICE_UDID}.png"
```

Maestro Cloud handles parallelism automatically — sharding flags are for local/CI hardware only.

## Detect Maestro from app code

Mobile (iOS/Android/RN/Flutter) — pass a `launchApp.arguments` flag and read it in your app:

```yaml
- launchApp:
    appId: com.example.app
    arguments:
      isMaestro: "true"
```

```kotlin
val isMaestro = intent.getStringExtra("isMaestro") == "true"
```
```swift
if ProcessInfo.processInfo.arguments.contains("isMaestro") { ... }
```
```javascript
// React Native
import { LaunchArguments } from 'react-native-launch-arguments'
LaunchArguments.value().isMaestro === "true"
```

Web — Maestro injects `window.maestro`:

```javascript
if (window.maestro) { /* test mode */ }
```

Deprecated and unsupported on Cloud: probing ports `7001` (Android) / `22087` (iOS).

## Locales

Set device locale before running flows. See the upstream docs page `flows/flow-control-and-logic/test-in-different-locales/locales-supported-by-maestro.md` for the full supported list. Web is fixed to `en-US` in beta.

## Labels and `optional`

`label`: human-readable description in console + reports. Hides sensitive text from console summaries (NOT from internal debug logs). Use to mask passwords/PII and to document intent.

```yaml
- inputText:
    text: "super-secret-pass"
    label: "Enter test user password"
```

`optional: true`: command failure becomes a warning, flow continues. Use for non-critical UI, transient banners, A/B variants. Defaults: standard commands `false`; AI commands (`assertWithAI`, `assertNoDefectsWithAI`, `extractTextWithAI`) `true`.

```yaml
- assertVisible:
    text: "Summer sale is here!"
    optional: true
```

No effect on commands that cannot fail (`back`, `stopRecording`, `clearState`).
