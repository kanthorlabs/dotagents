# CLI reference

Install, run, and integrate the `maestro` CLI.

## Install

Prerequisite: **Java 17+** with `JAVA_HOME` set. Verify with `java -version`.

```bash
# macOS / Linux / WSL2
curl -fsSL "https://get.maestro.mobile.dev" | bash

# macOS via Homebrew
brew tap mobile-dev-inc/tap
brew install mobile-dev-inc/tap/maestro

# Windows native — use curl|bash above, OR download maestro.zip from GitHub releases
#   then extract to C:\maestro and add C:\maestro\bin to PATH:
#   setx PATH "%PATH%;C:\maestro\bin"

maestro --help
maestro --version
```

iOS testing also needs Xcode + Command Line Tools (macOS).

### Update / pin version

```bash
# Standard update
curl -fsSL "https://get.maestro.mobile.dev" | bash

# Homebrew
brew update && brew upgrade mobile-dev-inc/tap/maestro

# Pin a specific version
export MAESTRO_VERSION=1.39.0; curl -Ls "https://get.maestro.mobile.dev" | bash
```

## Invocation pattern

```bash
maestro [global-options] [subcommand] [subcommand-options]
```

`--device`, `--platform`, `--verbose` are **global** and must precede the subcommand:

```bash
maestro --device emulator-5554 test flow.yaml
maestro --verbose test flow.yaml --include-tags=smoke
```

## Subcommands

| Subcommand | Purpose |
|---|---|
| `test` | Run flows on a local device/emulator. |
| `cloud` | Upload and run flows on Maestro Cloud. |
| `record` | Record a flow run as MP4. Use `--local`. |
| `start-device` | Create + launch an Android emulator or iOS simulator. |
| `list-devices` | List local device models + OS versions. |
| `list-cloud-devices` | List Cloud-supported `{device_model, device_os}` pairs. |
| `mcp` | Start the Maestro MCP server (stdio). |
| `studio` | Launch Maestro Studio. |
| `login` / `logout` | Maestro Cloud auth. |
| `download-samples` | Pull a curated set of sample flows. |
| `chat` | Maestro GPT (apps + tests assistance). |
| `bugreport` | Send a bug report. |
| `driver-setup` | Install Maestro drivers for the device. |

## `maestro test`

Most-used subcommand.

```bash
maestro test flow.yaml
maestro test ./tests
maestro test --include-tags=smoke ./tests
maestro test -e USERNAME=alice -e PASSWORD=secret flow.yaml
maestro test --config .maestro/ci-config.yaml ./tests
maestro test --format junit --output build/report.xml ./tests
maestro test --format html-detailed --output build/report.html ./tests
maestro test --test-output-dir=build/maestro-results ./tests
maestro test --debug-output=build/debug ./tests
maestro test --analyze flow.yaml                 # AI insights report
maestro test -c flow.yaml                        # continuous mode (re-runs on file change)
maestro test --headless --screen-size=1920x1080 flow.yaml   # web only
```

Sharding (need ≥N booted devices):

```bash
maestro test --shard-all 3 ./tests          # same suite on 3 devices
maestro test --shard-split 3 ./tests        # split suite across 3
maestro test --device "emulator-5554,emulator-5556" --shard-split 2 ./tests
```

`test` flag inventory:

| Flag | Purpose |
|---|---|
| `--config=<file>` | Workspace YAML config. |
| `-e KEY=VAL` | Inject env var (parameter). |
| `--include-tags`, `--exclude-tags` | Tag filtering (OR within flag). |
| `--format JUNIT\|HTML\|HTML-DETAILED\|NOOP` | Report format. |
| `--output=<path>` | Report file destination. |
| `--test-output-dir=<dir>` | Screenshots/video/AI/JSON. |
| `--debug-output=<dir>` | `maestro.log`. |
| `--flatten-debug-output` | Drop per-run subfolders/timestamps. |
| `--analyze` | AI insights report (needs login). |
| `--api-key`, `--api-url` | (Beta) override AI API. |
| `-c`, `--continuous` | Watch mode. |
| `--headless` | Web only. |
| `--screen-size=WxH` | Headless browser size. |
| `--shard-all=N` | Same suite on N devices. |
| `--shard-split=N` | Split suite across N devices. |
| `-s, --shards=N` | Generic shard count. |
| `--test-suite-name=<name>` | Override suite name in reports. |

## `maestro cloud`

Upload to Maestro Cloud. Pass a **folder** to `--flows`, not a single file (subflows + scripts must be present).

```bash
maestro cloud --app-file app.apk --flows ./tests
maestro cloud \
  --app-file app.apk \
  --flows ./tests \
  --device-model pixel_6 \
  --device-os android-34 \
  --device-locale fr_FR \
  --branch main --commit-sha "$GITHUB_SHA" \
  --pull-request-id 123 --repo-owner my-org --repo-name my-app \
  --format junit --output build/cloud-report.xml \
  --include-tags=smoke
```

Auth: `maestro login` (interactive) or `MAESTRO_CLOUD_API_KEY=<key>`.

Use named flags (`--app-file`, `--flows`) — positional `maestro cloud app.apk ./tests` works only if order is correct, and is unsafe in CI.

Use `--app-binary-id` to skip re-uploading an already-uploaded binary.

## Devices

```bash
maestro start-device --platform android                  # default Pixel 6 / android-30
maestro start-device --platform ios --device-locale fr_FR
maestro start-device --platform android --device-model pixel_7 --device-os android-34
maestro start-device --platform android --force-create   # rebuild even if exists

maestro list-devices                                     # local supported pairs
maestro list-devices --platform ios
maestro list-cloud-devices                               # cloud-supported pairs
```

Find an existing device's identifier:

```bash
adb devices                                # Android
xcrun simctl list devices booted           # iOS
```

Web has no device list — Maestro launches its own Chromium.

## Locales

```bash
# Locale must be set when starting the device — NOT on `maestro test`
maestro start-device --platform android --device-locale fr_FR
maestro test ./tests
```

`--device-locale` is supported on `start-device` and `cloud`. Format: `<lang>_<COUNTRY>` (e.g., `fr_FR`, `it_IT`, `de_DE`). Web is fixed to `en-US`.

## Recording

```bash
maestro record --local YourFlow.yaml
maestro record --local YourFlow.yaml output.mp4
```

`--local` is recommended (privacy, no remote upload). Recordings cap at 2 minutes.

## MCP

```bash
maestro mcp                # stdio MCP server
```

Most agents register this via their own MCP config. See [mcp.md](mcp.md).

## Environment variables

| Variable | Type | Default | Effect |
|---|---|---|---|
| `MAESTRO_CLOUD_API_KEY` | string | — | Cloud auth (CI). |
| `MAESTRO_DRIVER_STARTUP_TIMEOUT` | int (ms) | `15000` Android, `120000` iOS | Wait for driver to boot. CI runners may need 180000. |
| `MAESTRO_DISABLE_UPDATE_CHECK` | bool | `false` | Skip CLI version check on startup. |
| `MAESTRO_CLI_NO_ANALYTICS` | bool | `false` | Disable analytics. |
| `MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED` | bool | `false` | Suppress "Analyzing flow…" banner. |
| `MAESTRO_CLI_LOG_PATTERN_CONSOLE` | string | `%highlight([%5level]) %msg%n` | Logback console layout. |
| `MAESTRO_CLI_LOG_PATTERN_FILE` | string | `%d{HH:mm:ss.SSS} [%5level] %logger.%method: %msg%n` | Logback file layout. |
| `MAESTRO_*` (any) | — | — | Auto-injected as flow `env` (CLI only, not Studio). |

## Proxy

Set `MAESTRO_OPTS` (Maestro-only) or `JAVA_OPTS` (all JVM apps).

```bash
# System proxy
export MAESTRO_OPTS="-Djava.net.useSystemProxies=true"

# Custom proxy
export MAESTRO_OPTS="-Dhttps.proxyHost=myproxy.com -Dhttps.proxyPort=8080"

maestro login
```

Persist by appending to `~/.zshrc` / `~/.bashrc`. Windows: `setx MAESTRO_OPTS "-Djava.net.useSystemProxies=true"`.

## CI integration sketch (GitHub Actions, Android)

```yaml
- uses: actions/checkout@v4
- uses: actions/setup-java@v4
  with: { distribution: temurin, java-version: '17' }
- uses: reactivecircus/android-emulator-runner@v2
  with:
    api-level: 34
    arch: x86_64
    profile: pixel_6
    script: |
      curl -fsSL "https://get.maestro.mobile.dev" | bash
      export PATH=$PATH:$HOME/.maestro/bin
      export MAESTRO_DRIVER_STARTUP_TIMEOUT=180000
      maestro test --format junit --output build/report.xml ./.maestro
- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: maestro-report
    path: build/report.xml
```

For Cloud-based CI: store `MAESTRO_CLOUD_API_KEY` as a secret and call `maestro cloud --app-file app.apk --flows ./tests`.

## Troubleshooting

- **Driver startup timeout** → bump `MAESTRO_DRIVER_STARTUP_TIMEOUT` (e.g., `180000`).
- **"Failed to parse file" on Cloud** → you passed a single file to `--flows`; pass the folder instead.
- **`adb` smartsocket bind error in WSL** → another ADB is running on Windows; `taskkill /F /IM adb.exe` then restart.
- **WSL emulator not visible** → connect via `export ADB_SERVER_SOCKET=tcp:<WINDOWS_IP>:5037` and pass `maestro --host <WINDOWS_IP>`.
