# Troubleshooting

Common Maestro failure modes and their fixes. Roughly ordered by frequency.

## Authoring failures

### "Element not found" / `assertVisible` keeps timing out

1. Confirm the element actually rendered — `inspect_screen` (MCP) or `maestro studio` to see the live tree.
2. Selector may be too strict. `text:` is regex — try a partial match: `text: ".*Submit.*"`.
3. Multiple matches with `index:` out of range. Drop `index:` to see the count, then re-add.
4. Element exists but is below the fold → `scrollUntilVisible` first, or wrap the assert in `extendedWaitUntil` (>7s).
5. Element exists but disabled → add `enabled: false` to confirm; tap requires `enabled: true`.
6. Element is Compose without `testTagsAsResourceId = true` → `id:` won't match. Use `text:` / `description:` or add the modifier.
7. Element is Flutter and you're using a `Key` → Keys are invisible to a11y. Add a `Semantics(identifier: ...)` (Flutter 3.19+).
8. Element is iOS SwiftUI Toggle merged with text → tap the merged element with a `point: "X%,Y%"`.
9. Web (Chromium) and the page hasn't finished loading → `extendedWaitUntil` and consider `--headless` viewport mismatch.

### "Ghost taps" — tap registered, UI didn't move

```yaml
- tapOn:
    id: "btn"
    retryTapIfNoChange: true
```
Or pre-stabilize with `waitForAnimationToEnd`.

### Multiple elements match same `text` / `id`

Add `index:`, or anchor with a relational selector (`below`, `childOf`, `containsDescendants`). Last resort: shorten regex to be unique.

```yaml
- tapOn:
    text: "Edit"
    childOf: { id: "profile_card" }
```

### `inputText` doesn't type Unicode (Android)

Known limitation — selectors can match Unicode but typing can't produce it on Android. Workaround: pre-set the field via `setClipboard` + `pasteText`, or seed via API.

### Soft keyboard hides next input

Use `hideKeyboard` (Android: triggers `back`; iOS: micro-swipe). If that fails, tap a known non-tappable header to dismiss:

```yaml
- tapOn: { id: "header_title" }
```

### `pasteText` does nothing

`pasteText` reads Maestro's **internal** clipboard, NOT the OS clipboard. You must precede it with `copyTextFrom` or `setClipboard`.

To validate the *OS* clipboard, paste into a system search field (Spotlight / Google Search) and assert visible — see `references/recipes.md`.

### `scrollUntilVisible` finds nothing in a partial-screen scrollable

It swipes from screen center, so bottom-sheet / fragment lists get missed. Roll a custom loop:

```yaml
- evalScript: ${output.found = 0}
- repeat:
    while: { true: ${output.found == 0} }
    commands:
      - swipe: { start: "50%,90%", end: "50%,75%" }
      - runFlow:
          when: { visible: { id: "${TARGET_ID}" } }
          commands:
            - evalScript: ${output.found = 1}
```

### Loop never terminates

`repeat: { while: ... }` has no built-in cap. Always add `times: N` as a safety belt:

```yaml
- repeat:
    times: 20
    while: { visible: "More items" }
    commands: [...]
```

## Run-time failures

### "Failed to parse file" on Maestro Cloud

You passed a single file to `--flows`. Pass the workspace **folder** so subflows + scripts get uploaded:

```bash
# wrong
maestro cloud --app-file app.apk --flows ./tests/login.yaml
# right
maestro cloud --app-file app.apk --flows ./tests
```

### Driver startup timeout

Default 15s Android, 120s iOS. CI runners can be slow on first boot.

```bash
export MAESTRO_DRIVER_STARTUP_TIMEOUT=180000
maestro test ./tests
```

### `runScript` "Failed to parse file"

Same as Cloud — script paths are relative to the **flow file**, and Cloud requires the folder to be uploaded.

### `--shard-all` / `--shard-split` errors

Need ≥N booted devices. Boot them first:

```bash
maestro start-device --platform android
maestro start-device --platform android
maestro test --shard-split 2 ./tests
```

### Screenshot file collisions during sharding

Multiple shards write to the same workspace. Namespace the path:

```yaml
- takeScreenshot: "Login-shard_${MAESTRO_SHARD_INDEX}-${MAESTRO_DEVICE_UDID}"
```

### iOS test won't run on physical device

Not supported yet — iOS Simulator only.

### Web test launches Chromium but fails on first-run download

First run downloads a managed Chromium build. Network proxy issues block this — set `MAESTRO_OPTS` (see `references/cli.md` → Proxy).

### `--device-locale` ignored on `maestro test`

Locale is a device-level setting. Set it on `start-device` (or `cloud`):

```bash
maestro start-device --platform android --device-locale fr_FR
maestro test ./tests
```

Web is fixed to `en-US` regardless.

## Hook / sequencing failures

### Hook ran twice / loops infinitely

A hook called a flow that has the same hook → recursion. Hooks fire for *every* flow execution. If you `runFlow` from inside a hook, the called flow's hooks also fire.

### `onFlowComplete` runs even on hook failure

By design — Maestro guarantees teardown even when setup failed. Plan teardown to be idempotent.

### Tests rely on previous flow leaving state

Brittle. Each flow should run on a fresh device. Use `onFlowStart: runFlow: subflows/login.yaml` for required state, not `executionOrder`.

## Permission / system dialog failures

### Permission prompt blocks the flow

Maestro auto-grants on `launchApp` by default. If you set `permissions: { all: deny }`, expect the prompt mid-flow:

```yaml
- runFlow:
    when: { visible: "Allow Notifications" }
    commands: [{ tapOn: "Allow" }]
```

### iOS notifications: no system prompt to handle

Unlike other iOS permissions, notification prompt requires *the app to ask* — Maestro auto-taps Allow when it appears. Set the perm before the asking screen.

### Chrome / Web permissions can't be set

Maestro cannot manage Chromium's system permissions. Test with permissions pre-granted via `clearState`-friendly Chrome flags only.

## Environment & install failures

### Java version mismatch

`maestro --version` errors → check `java -version`. Maestro needs **Java 17+**. Set `JAVA_HOME` to a JDK 17 install.

### Smartsocket bind error in WSL

Another ADB is running on Windows. Kill it:

```powershell
taskkill /F /IM adb.exe
```
Then restart the WSL → Windows ADB bridge.

### `adb` not recognized in PowerShell (Windows)

Add `%LOCALAPPDATA%\Android\Sdk\platform-tools` to PATH:

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:LOCALAPPDATA\Android\Sdk\platform-tools", "User")
```

### MCP tool calls error after CLI upgrade

The agent is using the old binary. Reload:
- Claude Code: `/mcp` → `maestro` → Reconnect.
- Cursor IDE: toggle the MCP off/on.
- Codex/Copilot/Gemini/Cursor CLI: restart the CLI.
- Claude Desktop: restart the app.

## AI command failures

### `assertWithAI` / `assertNoDefectsWithAI` flaky

Default `optional: true` keeps tests stable. Don't flip to `optional: false` unless you accept LLM nondeterminism aborting the run.

### "AI features require login"

```bash
maestro login
# or for CI:
export MAESTRO_CLOUD_API_KEY=<key>
```

Free Cloud account is enough — paid plan is needed only for actually running flows on Cloud.

## Debugging tooling

```bash
# Verbose console output
maestro --verbose test flow.yaml

# Capture full log
maestro test --debug-output ./build/debug flow.yaml
# → ./build/debug/maestro.log

# Continuous mode — re-runs on file change
maestro test -c flow.yaml

# Inspect the live UI tree
maestro studio
# or via MCP:
inspect_screen
```
