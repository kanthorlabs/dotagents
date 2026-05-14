# Platforms reference

Maestro is black-box and platform-agnostic, but each runtime exposes different metadata to the OS accessibility tree. Use this reference to pick the right selector strategy.

## Header rule (recap)

| Platform | Root header key |
|---|---|
| Android, iOS | `appId: <package_or_bundle>` |
| Web (Chromium) | `url: https://...` |

Never both.

## Android (Views and Compose)

Maestro talks to the Android Accessibility Service. Zero instrumentation needed — tests the production binary.

| Selector | Source |
|---|---|
| `text` | `android:text`, plus `android:contentDescription` for icons, plus `android:hint` for empty inputs. |
| `id` | `android:id` (Resource ID). Regex supported. |
| `description` | Some flows accept `description` synonym for `contentDescription`. |

### Compose

Compose exposes accessibility via Semantics. Required for Maestro to "see" custom widgets:

```kotlin
Modifier.semantics { contentDescription = "Login Button" }
```

To surface `testTag`s as `id`:

```kotlin
Modifier.semantics { testTagsAsResourceId = true }
```

Without `testTagsAsResourceId = true`, `testTag` is invisible to the accessibility layer.

### Lists (`RecyclerView`, `LazyColumn`)

Don't compute offsets — use `scrollUntilVisible`:

```yaml
- scrollUntilVisible:
    element: { text: "Item #50" }
    direction: DOWN
```

### Limitation

`inputText` cannot type Unicode on Android (selectors and assertions handle Unicode fine).

## iOS — UIKit

Maestro reads the iOS Accessibility Tree. Local Simulator only — physical iOS devices not yet supported.

| Selector | Source |
|---|---|
| `text` | `accessibilityLabel` and visible text (e.g., `UIButton.title`). |
| `id` | `accessibilityIdentifier` — gold standard. |

```swift
button.setTitle("Submit Order", for: .normal)
button.accessibilityIdentifier = "login_button_id"
```

```yaml
- tapOn: "Submit Order"
- tapOn: { id: "login_button_id" }
```

## iOS — SwiftUI

Same accessibility tree, declarative annotation:

```swift
.accessibilityIdentifier("donut_editor")
```

```yaml
- tapOn: { id: "donut_editor" }
```

Quirks:
- `WheelPickerStyle` may not return a full hierarchy — fall back to text or `point` selection.
- A `Toggle` initialized with text often merges the label and switch into one accessibility element. Use `point: "X%,Y%"` within the merged element if the toggle won't accept taps directly.
- Always inspect with **Maestro Studio** or MCP `inspect_screen` before guessing IDs — composition resolution is non-obvious.

Example mixing strategies:

```yaml
- tapOn: { id: "controls_item" }
- tapOn: { point: "84%,23%" }                       # complex toggle
- tapOn: { text: "Chocolate", index: 0 }
- tapOn: { id: "flavor_picker_segmented_Strawberry" }
```

System navigation (returning from Safari, e.g.) — Maestro can tap the iOS breadcrumb:

```yaml
- tapOn: "link_item"
- tapOn: { id: "breadcrumb" }
```

## React Native (Android + iOS)

Single suite covers both platforms. No npm packages required.

```javascript
<Button title="Go" onPress={...} />
<TextInput placeholder="Username" testID="username_input" />
```

```yaml
- tapOn: "Go"
- tapOn: { id: "username_input" }
- inputText: "maestro_user"
```

`testID` maps to `id` on both platforms.

### Expo Go

Cannot use `launchApp` with a custom `appId` (the actual app ID is the Expo container). Use `openLink` with the dev URL:

```yaml
- openLink: exp://127.0.0.1:19000
```

EAS / standalone builds: standard `launchApp` with the bundle ID / package name works as usual.

### iOS nested-touch quirk

If a deeply nested inner element won't accept taps, set `accessible={false}` on the outer container and `accessible={true}` on the inner one:

```jsx
<TouchableOpacity accessible={false}>
  <Text>Wrapper</Text>
  <TouchableOpacity accessible={true}>
    <Text>I'm a small button</Text>
  </TouchableOpacity>
</TouchableOpacity>
```

## Flutter

Maestro reads the Flutter Semantics Tree. Test the compiled APK / IPA — no `pubspec.yaml` integration.

### "Keys" don't work

Flutter `Key`s are not exposed to the OS accessibility layer. **Always use Semantics**, never Keys.

### Annotation patterns

```dart
// 1. Implicit text — Text and TextField widgets work out of the box.
Text("Welcome")

// 2. Add semantic label to icon
FloatingActionButton(
  onPressed: ...,
  child: Icon(Icons.add, semanticLabel: 'fabAddIcon'),
)

// 3. Wrap a non-text container
Semantics(
  label: 'yellow_box',
  child: Container(color: Colors.yellow, width: 100, height: 100),
)

// 4. Stable identifier (Flutter 3.19+) — best practice for i18n / A/B
Semantics(
  identifier: 'login_button',
  child: ElevatedButton(onPressed: _login, child: Text('Sign In')),
)
```

```yaml
- tapOn: "fabAddIcon"
- tapOn: "yellow_box"
- tapOn: { id: "login_button" }
```

### Limitations

- **Flutter Desktop**: not supported.
- **Flutter Web**: supported — works like standard web testing; use Semantics to make elements addressable.

## Web (Chromium) — Beta

Same YAML, replace `appId` with `url`. First run downloads a managed Chromium build; subsequent runs are fast.

```yaml
url: https://maestro.mobile.dev
---
- launchApp                                  # navigates to root url
- tapOn: "Installing Maestro"
- assertVisible: "Installing the CLI"
```

### Differences vs mobile

| Aspect | Behavior |
|---|---|
| Header | `url:` (not `appId:`) |
| `back` | Supported (browser back). |
| `setOrientation` | Not supported. |
| `setAirplaneMode`, `toggleAirplaneMode` | Not supported. |
| `hideKeyboard` | No-op. |
| `clearKeychain` | No-op. |
| `clearState` | Clears origin storage (cookies, localStorage). |
| Locale | Fixed `en-US` in beta — `--device-locale` ignored. |
| Viewport / screen size | Preset; configurable only in `--headless` mode via `--screen-size=WxH`. |
| Browser engine | Chromium only. |
| Permissions | Maestro CANNOT manage Chrome's system permissions. |

### Selectors

Standard `text` and `id` work. `css` is web-only:

```yaml
- tapOn: { css: ".secondaryButton" }
- assertVisible: { css: "#main-header" }
```

For React/Vue/Angular sites, prioritize visible text or stable accessibility attributes — DOM class names refactor often.

### Flutter Web

Same as Flutter mobile — annotate via Semantics. Flutter Web renders to canvas-style output; without Semantics elements are invisible to Maestro.

### Studio support

Maestro Studio supports web fully — visual element inspection + YAML generation work out of the box.

### State persistence

Browser state (cookies, localStorage) is **retained between flows** in the same run by default. Reset per origin via `clearState: https://example.com` or `launchApp.clearState: true`.

## Cross-platform summary table

| Capability | Android | iOS Sim | iOS Device | Web (Chromium) |
|---|---|---|---|---|
| `back` | ✅ | ❌ | ❌ | ✅ |
| `clearKeychain` | ❌ | ✅ | n/a | ❌ |
| `setAirplaneMode` / `toggleAirplaneMode` | ✅ | ❌ | n/a | ❌ |
| `setOrientation` | ✅ | ✅ | ❌ | ❌ |
| `setLocation` | API ≥ 31 | ✅ | n/a | ❌ |
| `addMedia` | ✅ | ✅ | ❌ | ❌ |
| `killApp` | ✅ | ✅ | ❌ | ❌ |
| `inputText` Unicode | ❌ | ✅ | n/a | ✅ |
| `hideKeyboard` | ✅ | ✅ | n/a | no-op |
| Maestro-managed permissions | ✅ | ✅ | n/a | ❌ |
| `--device-locale` | ✅ | ✅ | n/a | fixed `en-US` |
| `disableAnimations` | Cloud-only | Cloud-only | n/a | n/a |
| Local execution | ✅ | ✅ Simulator | ❌ Not yet | ✅ |
