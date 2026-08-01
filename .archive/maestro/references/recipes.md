# Recipes index

Common patterns digested into copy-paste forms. Templates land in `assets/templates/`.

## Real-world walkthroughs

### Native Android Contacts (random data + keyboard hide)

Demonstrates random data generators and `hideKeyboard` to dodge the soft-keyboard-covers-form problem.

```yaml
appId: com.android.contacts
---
- launchApp
- tapOn: "Create new contact"
- tapOn: "First name"
- inputRandomPersonName
- tapOn: "Last name"
- inputRandomPersonName
- tapOn: "Phone"
- inputRandomNumber: { length: 10 }
- hideKeyboard                       # keyboard covers Email field
- tapOn: "Email"
- inputRandomEmail
- tapOn: "Save"
```

### Native date picker (longPressOn + index)

Android `NumberPicker` wheels need long-press + index to focus.

```yaml
- longPressOn: { id: "android:id/numberpicker_input", index: 0 }
- inputText: "Jan"
- longPressOn: { id: "android:id/numberpicker_input", index: 1 }
- inputText: "01"
- longPressOn: { id: "android:id/numberpicker_input", index: 2 }
- inputText: "2000"
- pressKey: Enter
```

### Modular Wikipedia suite

Compose orchestrator + many subflows. See template `assets/templates/orchestrator.yaml`.

```yaml
# run-test.yml
appId: org.wikipedia
tags: [android, passing]
---
- launchApp: { clearState: true }
- runFlow: "onboarding/main.yml"
- runFlow: "dashboard/main.yml"
- runFlow: "auth/signup.yml"
- runFlow: "auth/login.yml"
```

JS-driven dynamic credentials:

```javascript
// scripts/generateCredentials.js
const ts = new Date().getTime().toString()
output.credentials = {
  username: `test_user_${ts}`,
  email:    `test-user-${ts}@test.com`,
  password: `test-user-password-${ts}`,
}
```

```yaml
- runScript: "../scripts/generateCredentials.js"
- inputText: "${output.credentials.username}"
```

## Recipe index

| Recipe | Problem solved | Key technique |
|---|---|---|
| Check OS clipboard | Validate that "Copy to Clipboard" actually wrote to the system clipboard | `pressKey: Home` + paste into Spotlight / Google Search + `assertVisible` |
| Pick image from gallery | System media picker IDs differ across SDK versions | Cascading `tapOn` calls with `optional: true` |
| Custom scroll inside fragment | `scrollUntilVisible` swipes from screen center, missing partial-screen lists | `repeat` + manual `swipe: { start: 50%,90%, end: 50%,75% }` |
| Download + open file | System dialogs differ across Android SDKs and iOS | `optional` taps + platform-conditional `runFlow` |
| Find last matching element | List length unknown at test time | `repeat`-based linear scan, store `lastElementIndex` in `output` |
| Page Object Model | Selector duplication across many flows | `output.page = {...}` defined in `*.js`, loaded once |
| Reset Android device state | Stale photos/downloads pollute test runs | Automate the system Files app to Select-all + Delete |
| Automate Android Contacts | System apps need stability across OS updates | Random data generators + `hideKeyboard` |
| Facebook sign-up (educational) | Multi-step onboarding + permission dialogs + system pickers | `clearState: true`, permission dialog handling, NumberPicker via `longPressOn` |
| Wikipedia advanced | Multi-suite orchestration + JS API calls + scrolling feeds | `runFlow` orchestrator, `http.get`, `copyTextFrom` |

Find these in upstream docs under `examples/recipes/` and `examples/real-world-examples/`.

## Patterns to memorize

### Conditionally dismiss a popup

```yaml
- tapOn:
    text: "Dismiss"
    optional: true
    label: "Dismiss popup if it exists"

# OR:
- runFlow:
    when: { visible: "Dismiss" }
    commands:
      - tapOn: "Dismiss"
```

### Platform branching for permissions

```yaml
- runFlow:
    when: { platform: Android }
    file: subflows/android-permissions.yaml
- runFlow:
    when: { platform: iOS }
    file: subflows/ios-permissions.yaml
```

### Process-death recovery

```yaml
# trigger-process-death.yaml
- pressKey: Home
- killApp
- launchApp: { stopApp: false }
```

### Reusable login as hook

```yaml
appId: com.example.app
onFlowStart:
  runFlow:
    file: subflows/login.yaml
    env: { ROLE: "admin" }
---
- launchApp
```

### Data-driven loop

```yaml
- evalScript: ${output.items = ["Headphones","Charger","Phone Case"]}
- evalScript: ${output.i = 0}
- repeat:
    while: { true: ${output.i < output.items.length} }
    commands:
      - runFlow:
          file: subflows/add_item.yaml
          env: { PRODUCT_NAME: ${output.items[output.i]} }
      - evalScript: ${output.i++}
```

### Page Object Model

```javascript
// elements/login.js
output.login = {
  email: "email_text",
  password: "password_text",
  loginBtn: "loginButton",
}
```

```yaml
- runScript: elements/login.js
- tapOn: { id: ${output.login.email} }
- inputText: "test@example.com"
- tapOn: { id: ${output.login.password} }
- inputText: ${PASSWORD}
- tapOn: { id: ${output.login.loginBtn} }
```

### API-seeded test data

```javascript
// seed.js
const r = http.post('https://api.example.com/v1/items', {
  body: JSON.stringify({ name: "Maestro test" }),
  headers: { 'Content-Type': 'application/json' }
})
output.itemName = json(r.body).name
```

```yaml
- runScript: seed.js
- launchApp
- assertVisible: ${output.itemName}
```
