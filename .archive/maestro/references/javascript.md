# JavaScript reference

Maestro embeds a sandboxed JS engine (GraalJS, ES6+ default; Rhino opt-in but discouraged). No file system, no Node modules. Same behavior locally and on Cloud.

## Three execution modes

```yaml
# 1. Inline ${} expression — for one-liners inside any command
- inputText: ${'User_' + faker.name().firstName()}
- tapOn: ${maestro.platform === 'ios' ? 'Allow' : 'While using the app'}

# 2. evalScript — logic without a UI command attached
- evalScript: ${output.timestamp = new Date().getTime()}
- evalScript: ${console.log('Test started')}

# 3. runScript — external .js file
- runScript:
    file: setupUser.js
    env:
      userRole: "admin"
```

`runScript` paths are **relative to the flow file**. Required for Cloud uploads (full workspace folder).

## The `output` object — global, persistent

Survives the whole flow execution. Standard JS notation.

```javascript
// myScript.js
output.result = 'Hello World'
output.user = { name: 'Alice', role: 'admin' }
```

```yaml
- runScript: myScript.js
- inputText: ${output.result}
- assertVisible: ${output.user.name}
```

### Namespace to avoid collisions

```javascript
// authScript.js
output.auth = { token: "abc-123", expiry: 3600 }

// profileScript.js
output.profile = { username: "MaestroUser", role: "Admin" }
```

```yaml
- inputText: ${output.auth.token}
- assertVisible: ${output.profile.username}
```

### Shared functions

Define utility helpers via `onFlowStart` hook so the rest of the suite can use them.

```javascript
// apiUtils.js
function generateToken(prefix) { return prefix + "_" + Math.random().toString(36) }
output.utils = { generateToken: generateToken }
```

```yaml
appId: com.example.app
onFlowStart:
  - runScript: apiUtils.js
---
- evalScript: ${output.sessionToken = output.utils.generateToken('session')}
```

## The `maestro` object

| Property | Description |
|---|---|
| `maestro.copiedText` | Last `copyTextFrom` result (Maestro internal clipboard, NOT system clipboard). |
| `maestro.platform` | `ios` / `android` / `web` — useful in conditional logic. |

```yaml
- copyTextFrom: { id: userName }
- inputText: ${'Hello ' + maestro.copiedText}
```

## env vars in scripts

Vars passed via `env:` arrive as **bare globals** in the script (no `process.env.X`):

```yaml
- runScript:
    file: setupUser.js
    env: { userRole: "admin" }
```

```javascript
// setupUser.js
const role = userRole              // direct global access
console.log(`Setting up: ${role}`)
```

`MAESTRO_*` shell env vars are auto-imported by the CLI (see flow-control.md → Parameters).

## HTTP client (`http`)

Built-in synchronous wrapper around okhttp3. Methods: `http.get`, `http.post`, `http.put`, `http.delete`, plus `http.request(url, { method, ... })` for `PATCH`/`OPTIONS`.

```javascript
const r = http.get('https://api.example.com/user/1', {
  headers: { 'Authorization': 'Bearer ' + output.token }
})

const r2 = http.post('https://api.example.com/login', {
  body: JSON.stringify({ username: "u", password: "p" }),
  headers: { 'Content-Type': 'application/json' }
})

const r3 = http.request('https://api.example.com', {
  method: "PATCH",
  body: JSON.stringify({ status: "active" })
})
```

Multipart (`body` is ignored when `multipartForm` is present):

```javascript
http.post('https://example.com/upload', {
  multipartForm: {
    uploadType: "import",
    data: { filePath: "/path/to/file.csv", mediaType: "text/csv" }
  }
})
```

### Response

| Field | Type | Notes |
|---|---|---|
| `ok` | bool | true if 200–299 |
| `status` | number | HTTP code |
| `body` | string | raw body |
| `headers` | object | multi-values comma-joined |

Parse JSON via global `json()`:

```javascript
const r = http.get('https://api.example.com/user/1')
const data = json(r.body)
output.username = data.profile.name
```

### Test-data seeding pattern

Skip slow UI setup — seed via API, assert via UI:

```javascript
// create_appointment.js
const r = http.post('https://my-api.com/v1/appointments', {
  body: JSON.stringify({ title: "Maestro Health Check", date: "2026-02-10" }),
  headers: { 'Content-Type': 'application/json' }
})
output.appointmentTitle = json(r.body).title
```

```yaml
- launchApp
- runScript: create_appointment.js
- tapOn: "My Appointments"
- assertVisible: ${output.appointmentTitle}
```

## DataFaker — `faker` global

Wraps the [DataFaker](https://www.datafaker.net/) Java library. Same API as DataFaker.

```yaml
- inputText: ${faker.name().firstName()}
- inputText: ${faker.internet().emailAddress()}
- evalScript: '${output.bio = faker.expression("#{name.fullName} lives in #{address.city}")}'
```

Common providers:
- `faker.name().firstName()`, `.fullName()`
- `faker.internet().emailAddress()`
- `faker.finance().creditCard()`
- `faker.number().digits(5)`
- `faker.expression("#{number.numberBetween '1' '10'}")`
- `faker.lordOfTheRings().character()`

YAML-only random shorthands also exist: `inputRandomEmail`, `inputRandomPersonName`, `inputRandomNumber`, `inputRandomText`, `inputRandomCityName`, `inputRandomCountryName`, `inputRandomColorName` (see commands.md → inputText).

## Logging / debug

`console.log` outputs prefixed with `JsConsole` to `maestro.log` (run with `--debug-output` to capture).

Gotchas:
- **Multiple args not supported** — `console.log('x', y)` only logs `x`. Use concatenation or template literals.
- **Template literals don't work in `evalScript`** — the outer `${...}` swallows them. Use concatenation:

```yaml
# wrong
- evalScript: console.log(`Value ${myVar}`)
# right
- evalScript: '${console.log("Value: " + myVar)}'
```

In external `runScript` files, template literals work fine:

```javascript
console.log(`Operation status: ${status}`)
```
