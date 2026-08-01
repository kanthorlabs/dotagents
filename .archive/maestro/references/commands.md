# Commands reference

All 44 Maestro flow commands. Each entry: purpose, key params, minimal YAML. Alphabetical.

---

## addMedia

Adds media files (PNG, JPEG, JPG, GIF, MP4) from your workspace to the device gallery so an app can read them via the system media picker. Mobile only.

```yaml
- addMedia:
    - "./assets/foo.png"
    - "./assets/foo.mp4"
```

## assertNoDefectsWithAI

Experimental. Screenshots current view, asks an LLM to flag visual defects (cut-off text, overlapping elements, miscentered widgets). Saves HTML+JSON report under `~/.maestro/tests/<run>/`.

| Param | Description |
|---|---|
| `optional` | Default `true` — failure does not abort. Set `false` to make a failure stop the run. |

```yaml
- assertNoDefectsWithAI
- assertNoDefectsWithAI:
    optional: false
```

## assertNotVisible

Asserts an element is not on screen. Auto-retries up to ~7s waiting for it to disappear. Accepts the same selectors as `tapOn`.

```yaml
- assertNotVisible: "Loading…"
- assertNotVisible:
    text: "Error"
    enabled: true
```

## assertScreenshot

Visual regression. Compares current screen to a stored PNG. Fails if similarity < threshold or reference missing.

| Param | Default | Description |
|---|---|---|
| `path` | — | Reference PNG, relative to flow file. |
| `cropOn` | — | Selector to crop both screenshots before compare. |
| `thresholdPercentage` | `95.0` | Match percentage required. |
| `label` | — | Report label. |

```yaml
- assertScreenshot: splash.png
- assertScreenshot:
    path: screen.png
    cropOn: { id: banner }
    thresholdPercentage: 98
```

## assertTrue

Asserts a JS expression is truthy.

```yaml
- assertTrue: ${output.viewA == output.viewB}
- assertTrue:
    condition: ${count > 0}
    label: "Cart has items"
```

## assertVisible

Asserts an element is on screen. Auto-retries up to ~7s. Use `extendedWaitUntil` for longer waits. Accepts text shorthand or selector map.

```yaml
- assertVisible: "Welcome"
- assertVisible:
    text: "Submit"
    enabled: true
```

## assertWithAI

Experimental. Captures a screenshot and asks an LLM to evaluate a natural-language assertion.

| Field | Description |
|---|---|
| `assertion` | Natural-language description of the expected state. |
| `optional` | Default `true`. Set `false` to abort on failure. |

```yaml
- assertWithAI:
    assertion: "OTP screen with 6 digit boxes is visible"
    optional: false
```

## back

Press the system back button. **Android and Web only** — no-op on iOS.

```yaml
- back
```

## clearKeychain

Clears the iOS Keychain. **iOS only** — no-op on Android/Web. For per-launch clearing prefer `launchApp.clearKeychain: true`.

```yaml
- clearKeychain
```

## clearState

Clears app data. Android: `adb shell pm clear`. iOS: reinstalls the app. Web: clears origin storage.

```yaml
- clearState                     # current app
- clearState: com.example.app    # specific app
- clearState: https://example.com  # web origin
- clearState:
    appId: com.example.app
    label: "Reset before login"
```

## copyTextFrom

Copy text from a UI element into Maestro's internal clipboard, accessible via `${maestro.copiedText}`. Selector required.

```yaml
- copyTextFrom: { id: "code" }
- inputText: ${maestro.copiedText}
```

Distinct from the system clipboard — `pasteText` reads only the internal one.

## doubleTapOn

Double-tap an element. Same selectors as `tapOn`.

| Param | Default | Description |
|---|---|---|
| selector | — | text shorthand or selector map. |
| `delay` | `100` | ms between taps. |

```yaml
- doubleTapOn: "Map"
- doubleTapOn: { id: "marker", delay: 200 }
```

## eraseText

Backspaces from the focused field. Default 50 characters, max 100.

```yaml
- eraseText        # up to 50 chars
- eraseText: 10    # exactly 10
```

For long text: `longPressOn` → tap "Select All" → `eraseText: 1`.

## evalScript

Inline single-expression JavaScript. Result can be assigned to `output.*` for later use.

```yaml
- evalScript: ${output.upper = MY_NAME.toUpperCase()}
- inputText: ${output.upper}
```

## extendedWaitUntil

Wait beyond the default 7s for a selector to appear or disappear.

| Arg | Description |
|---|---|
| `visible` | Selector to wait to become visible. |
| `notVisible` | Selector to wait to disappear. |
| `timeout` | Max wait in ms. |

```yaml
- extendedWaitUntil:
    visible: "Order confirmed"
    timeout: 30000
- extendedWaitUntil:
    notVisible: { id: "spinner" }
    timeout: 10000
```

## extractTextWithAI

Experimental. Screenshots the view and uses an LLM to extract text matching a query. Stores result in `${aiOutput}` (or `${outputVariable}`).

| Param | Description |
|---|---|
| `query` | Required. Natural language description of what to extract. |
| `outputVariable` | Default `aiOutput`. |
| `optional` | Default `true`. |

```yaml
- extractTextWithAI: "CAPTCHA value"
- inputText: ${aiOutput}
```

## hideKeyboard

Dismiss the soft keyboard. Android: simulates back. iOS: micro-swipes. No-op on Web. Workaround if it fails: `tapOn` a non-tappable header area.

```yaml
- hideKeyboard
```

## inputText

Types text into the focused field. Supports `${vars}` and JS expressions. **Unicode unsupported on Android.**

```yaml
- inputText: "Hello"
- inputText: ${USER_EMAIL}
- inputText:
    text: "user@example.com"
    label: "Type test email"
```

Random data variants (use [DataFaker](https://www.datafaker.net/)):

```yaml
- inputRandomEmail
- inputRandomPersonName
- inputRandomNumber: { length: 9 }
- inputRandomText: { length: 11 }
- inputRandomCityName
- inputRandomCountryName
- inputRandomColorName
```

## killApp

System-initiated process death. Useful for testing app recovery. **Mobile only**, primarily Android.

```yaml
- killApp                              # default app
- killApp:
    appId: "com.example.otherapp"
```

## launchApp

Launch the app under test (or another). Default behavior: stop existing instance and restart.

| Param | Description |
|---|---|
| `appId` | Optional. Defaults to root `appId`. |
| `clearState` | Reset app data before launch. |
| `clearKeychain` | iOS only. |
| `stopApp` | Default `true`. Set `false` to bring backgrounded app forward without restart. |
| `permissions` | Map: `all: allow|deny|unset` or per-permission name. |
| `arguments` | Map of launch args (string/bool/double/int). |

```yaml
- launchApp                                     # restart root app
- launchApp:
    clearState: true
    clearKeychain: true
    permissions: { all: allow }
    arguments:
      isFooEnabled: true
      foo: "bar"
- launchApp: { stopApp: false }                 # foreground without restart
```

For web flows, `launchApp` redirects to the root `url`.

## longPressOn

3-second long press. Same selectors and `point`-within-element behavior as `tapOn`.

```yaml
- longPressOn: "Item"
- longPressOn: { id: "row_42" }
- longPressOn:
    text: "Link"
    point: "90%,50%"
```

## openLink

Open a URL or deeplink.

| Key | Description |
|---|---|
| `link` | Required. Web URL or `scheme://...`. |
| `autoVerify` | Android. Bypass app-disambiguation; auto-accept Chrome agreements (Android 12+). |
| `browser` | Android. Force-open in Chrome. |

```yaml
- openLink: https://example.com
- openLink:
    link: awesomeapp://settings
- openLink:
    link: https://example.com
    autoVerify: true
    browser: true
```

## pasteText

Paste from Maestro's internal clipboard into the focused field. Requires prior `copyTextFrom` or `setClipboard`. Does **not** read the OS clipboard.

```yaml
- copyTextFrom: { id: "code" }
- tapOn: { id: "input" }
- pasteText
```

## pressKey

Simulate a hardware/system key. Supported: `home`, `lock`, `enter`, `backspace`, `volume up`, `volume down`, `back` (Android), `power` (Android), `tab` (Android), and many Android TV remote keys.

```yaml
- pressKey: enter
- pressKey: home
- pressKey: "volume up"
```

## repeat

Loop a command block by count, while a condition holds, or both (whichever exits first).

| Param | Description |
|---|---|
| `times` | Iteration cap. |
| `while` | Condition map (`visible`, `notVisible`, `true: ${expr}`). |
| `commands` | List of inner commands. |

```yaml
- repeat:
    times: 3
    commands:
      - tapOn: "Like"
- repeat:
    while:
      notVisible: "Done"
    commands:
      - tapOn: "Next"
- repeat:
    times: 10
    while:
      true: ${output.counter < 5}
    commands:
      - evalScript: ${output.counter++}
```

## retry

Re-run a command block on failure, up to **0–3** retries.

| Param | Description |
|---|---|
| `maxRetries` | 0–3, default `1`. |
| `commands` | Inline commands. |
| `file` | Or path to a flow file. (Provide one of `commands`/`file`.) |

```yaml
- retry:
    maxRetries: 3
    commands:
      - tapOn: { id: "fragile_button" }
```

Anti-pattern: do not wrap an entire flow in `retry:`.

## runFlow

Compose flows. Run a separate flow file or an inline subflow.

| Param | Description |
|---|---|
| `file` | Path to subflow file (relative). |
| `commands` | Inline list (alternative to `file`). |
| `env` | Map of vars passed to the subflow. |
| `label` | Description for reports. |
| `when` | Conditional gate (see flow-control). |

```yaml
- runFlow: subflows/login.yaml
- runFlow:
    file: subflows/login.yaml
    env:
      USERNAME: alice
    label: "Login as alice"
- runFlow:
    label: "Sort A-Z"
    commands:
      - tapOn: { id: "sort_icon" }
      - tapOn: "A-Z"
```

For Cloud, pass a workspace folder via `--flows`, not a single file.

## runScript

Execute an external JS file. Script reads `env` vars and writes to `output.*`. `console.log` is forwarded to the Maestro console. Paths are relative to the flow file.

```yaml
- runScript: ./scripts/uppercase.js
- runScript:
    file: ./scripts/uppercase.js
    env:
      myParameter: "Parameter"
```

For Cloud, the entire workspace folder must be uploaded, not just the flow file.

## scroll

One vertical (UP) swipe from screen center to 10% top. No arguments.

```yaml
- scroll
```

## scrollUntilVisible

Auto-scrolls in a direction until a target element is visible, or fails on timeout.

| Param | Default | Description |
|---|---|---|
| `element` | — | **Required.** Selector. |
| `direction` | `DOWN` | `DOWN` / `UP` / `LEFT` / `RIGHT`. |
| `timeout` | `20000` | Max ms to keep scrolling. |
| `speed` | `40` | 0–100. |
| `visibilityPercentage` | `100` | % of element that must be visible. |
| `centerElement` | `false` | Keep scrolling until element ≥30% from edge. |

```yaml
- scrollUntilVisible:
    element: "Item 42"
    direction: DOWN
- scrollUntilVisible:
    element: { id: ".*footer" }
    centerElement: true
```

For partial-screen scrolls (sheets, fragments) write a custom `repeat`+`swipe` loop instead.

## setAirplaneMode

**Android only.** No-op on iOS/Web.

```yaml
- setAirplaneMode: enabled
- setAirplaneMode: disabled
```

## setClipboard

Set Maestro's internal clipboard to a string or JS expression. Useful before `pasteText` to avoid typing flakiness.

```yaml
- setClipboard: "user@example.com"
- setClipboard: ${'user' + Math.floor(Math.random()*1000) + '@example.com'}
```

Access later via `${maestro.copiedText}`.

## setLocation

Mock GPS coordinates. Android requires API ≥ 31. On Maestro Cloud, IP-based geolocation services still resolve to a US IP.

```yaml
- setLocation:
    latitude: 52.3599976
    longitude: 4.8830301
```

## setOrientation

Rotate the device. **Not supported on Web.**

| Value | |
|---|---|
| `PORTRAIT` | default |
| `LANDSCAPE_LEFT` | rotated 90° CCW |
| `LANDSCAPE_RIGHT` | rotated 90° CW |
| `UPSIDE_DOWN` | inverted |

```yaml
- setOrientation: LANDSCAPE_LEFT
```

## setPermissions

Set permissions outside `launchApp` (e.g., before a deeplink). Android + iOS. No control over Chrome.

```yaml
- setPermissions:
    permissions: { all: allow }
- setPermissions:
    appId: com.example.app
    permissions:
      camera: allow
      notifications: deny
```

## startRecording

Begin screen capture. Save as MP4. Requires a matching `stopRecording`.

| Param | Default | Description |
|---|---|---|
| `path` | — | File path relative to flow. Shorthand: bare string. |
| `label` | — | Report label. |
| `optional` | `false` | Don't fail flow if recording engine errors. |

```yaml
- startRecording: my_run                # → my_run.mp4
- startRecording:
    path: "recordings/onboarding"
    optional: true
```

## stopApp

Graceful stop. Use `killApp` for system-death simulation.

```yaml
- stopApp
- stopApp: com.example.otherapp
```

## stopRecording

Finalize an in-progress recording. No-op (does not fail) if none in progress.

```yaml
- stopRecording
```

## swipe

Gestural swipe. Mutually exclusive parameter sets:
- `direction:` (UP/DOWN/LEFT/RIGHT) — uses standard endpoints.
- `start:` + `end:` — pixel or `%,%` coordinates.
- `from: <selector>` + `direction:` — start from element center.

| Param | Default | Description |
|---|---|---|
| `duration` | `400` | ms; longer = slower. |
| `waitToSettleTimeoutMs` | — | Best-effort settle ceiling. |

```yaml
- swipe: { direction: LEFT }
- swipe:
    start: "90%,50%"
    end: "10%,50%"
- swipe:
    from: { id: "card" }
    direction: UP
```

## takeScreenshot

Save a PNG to the workspace's `.maestro/` (or `.maestro/screenshots` from Studio). Override location with `--test-output-dir` or `testOutputDir` in workspace config.

| Param | Description |
|---|---|
| `path` | File name without `.png`. Path is **workspace-relative**. |
| `cropOn` | Selector to narrow the image (often paired with `assertScreenshot`). |
| `label` | Report label. |

```yaml
- takeScreenshot: LoginScreen
- takeScreenshot:
    path: LoginScreen
    cropOn: { id: LoginFormContainer }
```

## tapOn

Tap a UI element by selector or coordinate. Most-used command.

| Param | Description |
|---|---|
| selector | Required. Text shorthand or selector map. |
| `point` | `"x%,y%"` or `"x,y"` — taps inside the matched element, or absolute if no selector. |
| `repeat` | Tap N times. |
| `delay` | ms between taps when `repeat` set. Default `100`. |
| `retryTapIfNoChange` | Retry the tap if the UI hierarchy didn't change. |
| `waitToSettleTimeoutMs` | Best-effort settle ceiling. |

```yaml
- tapOn: "Sign in"
- tapOn:
    id: "plus_btn"
    repeat: 5
    delay: 200
    retryTapIfNoChange: true
- tapOn:
    text: "Hyperlink"
    point: "90%,50%"
- tapOn: { point: "50%,50%" }      # bare coord (last resort)
```

## toggleAirplaneMode

**Android only.**

```yaml
- toggleAirplaneMode
```

## travel

Mock a GPS path traversal. Provide ordered points and a speed (units per second; example uses ~150000 = 150 km/s).

```yaml
- travel:
    points:
      - "48.8578065, 2.295188"     # Paris
      - "46.2276, 5.9900"
      - "43.7230, 10.3966"
      - "41.8902, 12.4922"          # Rome
    speed: 150000
```

## waitForAnimationToEnd

Block until UI stops animating, or until `timeout`. If the timeout hits while an animation still runs, the command **succeeds** and execution continues.

```yaml
- waitForAnimationToEnd
- waitForAnimationToEnd: { timeout: 5000 }
```
