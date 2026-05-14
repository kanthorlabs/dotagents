# Selectors reference

Maestro identifies UI elements through the OS accessibility tree. Most commands (`tapOn`, `assertVisible`, `copyTextFrom`, `scrollUntilVisible`, …) accept a selector either as a **text shorthand** or a **selector map**. Map keys combine with **AND** logic.

```yaml
- tapOn: "Login"            # shorthand → { text: "Login" }
- tapOn:                    # map: must match all conditions
    id: submit_button
    enabled: true
    below: "Password"
```

`text` and `id` are **regex** by default. Escape `$`, `[`, etc. with `\`.

Platform notes:
- **Flutter**: use visible text or Semantics Labels (for `text`), Semantics Identifiers (for `id`). Internal Flutter "Keys" are **not** supported.
- **Android Compose**: enable `Modifier.semantics { testTagsAsResourceId = true }` so test tags surface as `id`.

## Decision guide

| Need | Use |
|---|---|
| Match by visible text | `text` (or shorthand) |
| Match by accessibility id / resource id | `id` |
| Pick Nth match when multiple match | `index` |
| Match by web DOM | `css` (web only) |
| Tap an exact coordinate | `point` |
| Filter by interactive state | `enabled`, `checked`, `focused`, `selected` |
| Anchor to a nearby element by screen position | `above`, `below`, `leftOf`, `rightOf` |
| Anchor by tree relationship | `containsChild`, `childOf`, `containsDescendants` |
| Filter by physical size | `width`, `height`, `tolerance` |
| Filter by inherent characteristic | `traits` (`text`, `long-text`, `square`) |

## Core selectors

### `text`

Visible text or accessibility label. Regex.
- Android: matches `text` and `contentDescription`.
- iOS: matches `accessibilityLabel`.

```yaml
- tapOn: Login
- tapOn: { text: ".*Continue.*" }
```

### `id`

Technical identifier — Android Resource ID or iOS `accessibilityIdentifier`. Regex.

```yaml
- tapOn: { id: login_button }
- assertVisible: { id: ".*header_icon" }
```

### `index`

0-based. Picks among multiple matches.

```yaml
- tapOn:
    id: buy_button
    index: 2          # third matching button
```

### `point`

Coordinate. Relative `"50%,50%"` or absolute `"100,200"`. Use as last resort.

```yaml
- tapOn: { point: "50%,50%" }
- tapOn:
    text: "Hyperlink"
    point: "90%,50%"     # tap point INSIDE the matched element
```

### `css`

**Web only.** Standard CSS selector. No regex.

```yaml
- tapOn: { css: ".secondaryButton" }
- assertVisible: { css: "#main-header" }
```

## State selectors

All boolean.

| Selector | Use for |
|---|---|
| `enabled` | Verify a button is clickable / not grayed out. |
| `checked` | Checkbox / radio / switch state. |
| `focused` | Currently focused text input. |
| `selected` | Tabs / segmented controls / highlighted list items. |

```yaml
- assertVisible: { id: login_button, enabled: false }
- tapOn:        { id: login_button, enabled: true }
- assertVisible: { id: remember_me_checkbox, checked: true }
- assertVisible: { id: search_input, focused: true }
- tapOn:        { text: Profile, selected: true }
```

## Relational selectors

### Position (screen-bounds based)

`above`, `below`, `leftOf`, `rightOf` use coordinates only — they may match an element that is far away horizontally/vertically. Always combine with another matcher for precision.

```yaml
- tapOn: { below: Email }
- tapOn:
    rightOf: { id: input_text }
- tapOn:
    text: "Edit"
    rightOf: "Profile"
    enabled: true
```

Stack to assert vertical hierarchy:

```yaml
- assertVisible:
    text: Top
    above:
      text: Middle
      above:
        text: Bottom
```

### Tree (accessibility-tree based)

| Selector | Meaning |
|---|---|
| `containsChild` | Direct child matches inner selector. |
| `childOf` | Element is direct child of inner selector. |
| `containsDescendants` | List of descendants — any depth, all must match. |

```yaml
- tapOn:
    containsChild: { text: "Order 12345" }

- tapOn:
    text: Delete
    childOf: { id: basket_container }

- assertVisible:
    id: list_item
    containsDescendants:
      - text: Wireless Headphones
      - text: $99.99
```

## Element traits

```yaml
- tapOn:        { traits: text }            # any element with text
- assertVisible: { traits: long-text }       # ≥200 chars block
- tapOn:
    traits: square                          # width/height differ <3%
    rightOf: Home
```

Use `long-text` to verify dynamic content (feed, article body) actually loaded.

## Dimension matchers

Pixel values. Combine with other selectors and a `tolerance` to survive device variance.

```yaml
- assertVisible:
    id: profile_header
    height: 350
- assertVisible:
    id: settings_icon
    width: 48
    height: 48
    tolerance: 2          # ± px
```

## Best practices

1. **Prefer `id` as the primary selector.** Accessibility IDs are locale-proof, copy-change-proof, and survive A/B tests. Require the app to expose stable IDs:
   - **iOS UIKit**: `accessibilityIdentifier`
   - **iOS SwiftUI**: `.accessibilityIdentifier("...")`
   - **Android Views**: `android:id` (Resource ID)
   - **Android Compose**: `Modifier.semantics { testTagsAsResourceId = true }` + `testTag`
   - **React Native**: `testID` (maps to `id` on both platforms)
   - **Flutter**: `Semantics(identifier: '...')` (3.19+) or `Semantics(label: '...')`
   - **Web**: `data-testid`, `id`, or `aria-label` via `css` selector
2. Fall back to **visible `text`** only for truly stable, non-localized strings (e.g., brand names, proper nouns).
3. **Anchor with relational logic** when an element lacks a unique handle (`below: "Personal Information"`).
4. **Regex** handles dynamic strings — `text: ".*₹\\d+"` for prices.
5. **Verify state before action**: `enabled: true` on a tap waits for the button to become interactive.
6. **Avoid `point:`** unless absolutely necessary; coordinate taps are the most brittle.
7. **If an element has no `id` and no stable `text`, request the dev team add one** rather than writing a fragile selector chain.
