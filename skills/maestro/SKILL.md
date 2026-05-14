---
name: maestro
description: Author, run, and debug Maestro UI test flows for mobile and web. Activate when user mentions Maestro CLI/Cloud/Studio, `.yaml` flow files under `.maestro/` or `flows/` directories, Maestro-specific commands (launchApp, runFlow, assertWithAI), or asks to write/fix E2E tests targeting Android/iOS/web apps via the Maestro framework.
compatibility: Assumes `maestro` CLI on PATH and a target device/simulator already running. Maestro MCP server (bundled with CLI) recommended.
loading: deferred
metadata:
  author: "kanthorlabs"
  version: "1.2.0"
---

# Maestro Flow Authoring

## How to Use This Skill

**Core rules, cheat sheet, and selector quickref below are always available.** For deeper guidance, read the relevant reference file from `references/` on-demand — check the Deferred References table to find the right file for your task. **Do NOT load all references upfront.**

---

Maestro is a declarative YAML framework for end-to-end UI testing of Android, iOS, and web (Chromium beta) applications. It is **black-box**: it drives the device through the OS accessibility tree and input layer, not the app's source. Tests are called **flows**.

## When to activate

Activate when **two or more** of these signals are present, or when any single **strong** signal appears:

**Strong signals (any one is enough):**
- Explicit mention of Maestro, `maestro test`, `maestro cloud`, `maestro mcp`, Maestro Studio
- A `.yaml` file under a `.maestro/` or `flows/` directory
- Maestro-specific header keys: `appId:`, `url:` (in flow context), `onFlowStart:`, `onFlowComplete:`
- Maestro-only commands: `launchApp`, `runFlow`, `scrollUntilVisible`, `assertWithAI`, `extractTextWithAI`, `evalScript`

**Weak signals (need ≥2 together):**
- Generic commands that overlap with other frameworks: `tapOn`, `assertVisible`, `inputText`, `swipe`, `back`
- Mobile/web E2E testing without naming a framework
- YAML editing involving UI step sequences

## When NOT to activate

- Generic YAML editing unrelated to UI testing
- Other test frameworks: Appium, Espresso, Detox, XCUITest, Playwright, Selenium, Cypress
- Maestro CLI install, update, JDK setup, emulator provisioning — out of scope; user owns setup
- `tapOn` / `assertVisible` in isolation without Maestro context (could be any framework)

## Mental model

A flow is a YAML file with two sections separated by `---`:

```yaml
# 1. Config header — exactly ONE of `appId` (mobile) or `url` (web).
appId: ${APP_ID}
env:
  APP_ID: com.example.app   # default; override via CLI: -e APP_ID=com.real.app
# Optional: tags, onFlowStart, onFlowComplete, name
---
# 2. Ordered list of step commands.
- launchApp
- tapOn: { id: "sign_in_btn" }
- tapOn: { id: "username_input" }
- inputText: ${USERNAME}
- assertVisible: { id: "welcome_screen" }
```

Key invariants:
- Maestro **auto-waits up to ~7s** on every assert/tap. Do not insert manual sleeps.
- `assertVisible` / `assertNotVisible` retry; `extendedWaitUntil` extends the timeout.
- Selectors target the accessibility tree; prefer `text` / `id` over coordinates.
- Mobile flows use `appId` (package / bundle ID). Web flows use `url`. Never both.
- **Use env vars for all configurable values** — `appId`, `url`, credentials, API endpoints. See Hard rules #11.

## Prefer Maestro MCP when available

If the agent has the Maestro MCP server connected (tools prefixed with the registered MCP name, exposing `inspect_screen`, `run`, `list_devices`, `take_screenshot`, `cheat_sheet`, `list_cloud_devices`, `run_on_cloud`, `get_cloud_run_status`):

1. Call `list_devices` first to confirm a target is connected.
2. Call `inspect_screen` BEFORE crafting selectors. Re-call after any UI change. Do not guess at element IDs.
3. Use `run` with inline `{ yaml }` to iterate. Maestro validates the YAML server-side.
4. Call `cheat_sheet` if uncertain about a command name or syntax.

See [references/mcp.md](references/mcp.md) for the full tool list.

Without MCP, fall back to the `maestro` CLI — see [references/cli.md](references/cli.md).

## Deferred References

**Read these files on-demand when the task matches.** Each row tells you when to load. Only load what you need.

| Reference | Load when... |
|---|---|
| [references/commands.md](references/commands.md) | Writing a new flow, looking up command syntax, need the full 44-command list |
| [references/selectors.md](references/selectors.md) | Element not found, flaky tap, choosing between `id`/`text`/relational selectors |
| [references/flow-control.md](references/flow-control.md) | Conditions (`when`), loops (`repeat`), `retry`, nested `runFlow`, hooks, parameters, permissions |
| [references/javascript.md](references/javascript.md) | Dynamic input, `evalScript`/`runScript`, HTTP calls, `output` object, `faker`, data seeding |
| [references/cli.md](references/cli.md) | Running flows, CLI flags, CI integration, `maestro cloud`, sharding, recording, env vars |
| [references/workspace.md](references/workspace.md) | Organizing many flows, `config.yaml`, tags, `includeTags`/`excludeTags`, execution order, reports |
| [references/platforms.md](references/platforms.md) | Platform-specific behavior — Flutter Semantics, React Native `testID`, Compose `testTag`, iOS/SwiftUI quirks, web Chromium limitations |
| [references/mcp.md](references/mcp.md) | Maestro MCP server is connected, need `inspect_screen`/`run`/`list_devices` tool guidance |
| [references/troubleshooting.md](references/troubleshooting.md) | Flow fails, element not found, driver timeout, cloud upload errors, flaky tests |
| [references/recipes.md](references/recipes.md) | Need a reusable pattern — login, onboarding, scroll-to-element, wait strategies |
| [`assets/templates/`](assets/templates/) | Starting a new flow from scratch — copy the matching template (`flow-mobile.yaml`, `flow-web.yaml`, `login.yaml`, etc.) |
| [`scripts/`](scripts/) | Scaffolding (`new-flow.sh`) or validating (`validate.sh`) flow files |

## Top commands cheat sheet

```yaml
- launchApp                                  # launch root appId; restart by default
- launchApp:                                 # clean state + permissions
    clearState: true
    permissions: { all: allow }
- tapOn: "Sign in"                           # by visible text (shorthand)
- tapOn:                                     # by id, with retry on no-change
    id: "login_btn"
    retryTapIfNoChange: true
- longPressOn: "Item"                        # 3s long press, same selectors as tapOn
- doubleTapOn: "Map"                         # equiv: tapOn repeat:2 delay:100
- inputText: "user@example.com"              # types into focused field; supports ${vars}
- inputRandomEmail                           # random email; also Number/Text/PersonName/CityName
- eraseText                                  # backspace x50; or `eraseText: 10`
- copyTextFrom: { id: "code" }               # → maestro.copiedText
- pasteText                                  # paste from internal clipboard
- setClipboard: "literal or ${expr}"
- assertVisible: "Welcome"                   # waits up to 7s
- assertNotVisible: "Loading…"
- assertTrue: ${output.viewA == output.viewB}
- extendedWaitUntil: { visible: "Slow", timeout: 30000 }
- scroll                                     # vertical swipe up
- scrollUntilVisible:                        # auto-scroll, default DOWN, 20s
    element: { id: "row_42" }
    direction: DOWN
- swipe: { direction: LEFT }                 # or start/end coords, or `from: <selector>`
- waitForAnimationToEnd                      # blocks on continuous animation
- back                                       # Android + Web only
- hideKeyboard
- pressKey: enter                            # home|enter|backspace|volume up|down|back|tab|...
- openLink: https://example.com              # or { link, autoVerify, browser } (Android)
- takeScreenshot: LoginScreen
- assertScreenshot: { path: splash.png, thresholdPercentage: 98 }
- addMedia: ["./assets/foo.png", "./assets/foo.mp4"]
- clearState                                 # current app; `clearState: app.id` for another
- clearKeychain                              # iOS only
- killApp                                    # system-initiated death (Android)
- stopApp                                    # graceful stop
- setLocation: { latitude: 52.36, longitude: 4.88 }
- setOrientation: LANDSCAPE_LEFT             # or LANDSCAPE_RIGHT|PORTRAIT|UPSIDE_DOWN
- setAirplaneMode: enabled                   # Android only
- toggleAirplaneMode                         # Android only
- setPermissions: { permissions: { camera: allow, notifications: deny } }
- startRecording: my_run                     # → my_run.mp4
- stopRecording
- runFlow: subflows/login.yaml               # or { file, env, label } / { commands, env, label }
- repeat: { times: 3, commands: [ ... ] }
- repeat: { while: { notVisible: "Done" }, commands: [ ... ] }
- retry: { maxRetries: 3, commands: [ ... ] }   # 0–3
- evalScript: ${output.x = MY_ENV.toUpperCase()}
- runScript: ./scripts/uppercase.js
- assertWithAI: { assertion: "OTP screen with 6 boxes", optional: false }
- assertNoDefectsWithAI                       # screenshot smoke; experimental
- extractTextWithAI: "CAPTCHA value"          # → ${aiOutput}
- travel: { points: ["48.85,2.29","41.89,12.49"], speed: 150000 }
```

Full per-command reference: [references/commands.md](references/commands.md).

## Selector quickref

Prefer `id` first, then `text`, then relational, then `point` as last resort.

```yaml
# Best: by accessibility id (locale-proof, copy-change-proof):
- tapOn: { id: "submit_btn" }
- assertVisible: { id: "welcome_screen" }

# OK: by visible text (only for stable, non-localized strings):
- tapOn: "Submit"

# Map form — combine matchers:
- tapOn:
    id: ".*login_btn"        # accessibility id; regex supported
    enabled: true
    index: 0                 # if multiple match

# Relational (when element lacks unique id):
- tapOn:
    text: "Edit"
    below: { text: "Profile" }   # also: above, leftOf, rightOf, containsChild, childOf

# Last resort: coordinate tap
- tapOn: { point: "50%,50%" }
```

Full reference: [references/selectors.md](references/selectors.md).

## Hard rules

1. **One root identifier.** Header MUST contain exactly one of `appId:` (mobile) or `url:` (web). Never both.
2. **`---` separates header from steps.** No exceptions.
3. **No bare `sleep`.** Use `extendedWaitUntil` or rely on built-in retry on assertions. Do not insert `evalScript` sleeps.
4. **Prefer `id` over `text`, and `text` over coordinates.** Always target elements by accessibility ID first (`id:` selector). IDs are locale-proof, copy-change-proof, and A/B-test-proof. Require the app to expose stable IDs: `accessibilityIdentifier` (iOS/SwiftUI), `testID` (React Native), `Semantics(identifier:)` (Flutter 3.19+), `Modifier.semantics { testTagsAsResourceId = true }` (Compose). Fall back to `text:` only for truly stable strings. Coordinate `point:` taps are a last resort.
5. **Do not wrap entire flows in `retry:`.** It hides real bugs. Use `retry:` for one specific flaky step.
6. **`maxRetries` is capped at 3** by Maestro. Anything higher errors.
7. **Cloud uploads need a folder, not a file.** Use `--flows ./tests/`, not `--flows ./tests/login.yaml`, otherwise dependent subflows/scripts are missing.
8. **`runScript` paths are relative to the flow file**, not CWD.
9. **AI commands are experimental** and `optional: true` by default. Set `optional: false` only when you want failure to abort.
10. **Web (Chromium) is beta.** Locale fixed `en-US`, viewport fixed, `back` works, `setOrientation` does not.
11. **Env vars for all configurable values.** Never hardcode `appId`, `url`, credentials, API endpoints, or environment-specific strings directly in flow YAML. Use `${VAR_NAME}` with sensible defaults in the `env:` block. Inject overrides via CLI (`-e`), shell `MAESTRO_*` prefix, or `runFlow.env`. This keeps flows portable across environments (dev/staging/prod) and CI.
