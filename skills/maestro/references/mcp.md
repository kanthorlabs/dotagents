# Maestro MCP reference

Maestro ships with a Model Context Protocol server inside the CLI binary. Once registered with an MCP-capable agent (Claude Code/Desktop, Cursor, Codex, Copilot CLI, Gemini, Windsurf, JetBrains AI, etc.), the agent gets direct access to authoring/run/cloud tools over stdio.

## Why prefer MCP over crafting YAML blind

- Element IDs and texts come from the **live device** — no guessing or stale cache.
- `run` validates YAML server-side and surfaces errors fast.
- Skips the `maestro test` boot cycle for iteration.
- Cloud tools return dashboard URLs without extra plumbing.

When MCP is available: **always call `inspect_screen` before authoring selectors**, and re-call after any UI change.

## Install (per agent)

CLI must be on `PATH` first (`brew install maestro` or curl installer).

| Agent | Command |
|---|---|
| Claude Code CLI | `claude mcp add maestro -- maestro mcp` |
| Codex | `codex mcp add maestro -- maestro mcp` |
| Cursor | one-click button or edit `.cursor/mcp.json` |
| Copilot CLI | `/mcp add` (Name: `maestro`, Type: `local`, Command: `maestro mcp`) |
| Gemini CLI | `gemini mcp add maestro maestro mcp` |
| Generic | see JSON below |

Generic stdio config:

```json
{
  "mcpServers": {
    "maestro": {
      "command": "maestro",
      "args": ["mcp"]
    }
  }
}
```

If `maestro` is not on the agent's PATH (Claude Desktop launches from a minimal shell), use the absolute path and pass `JAVA_HOME`:

```json
{
  "mcpServers": {
    "maestro": {
      "command": "/opt/homebrew/bin/maestro",
      "args": ["mcp"],
      "env": { "JAVA_HOME": "/opt/homebrew/opt/openjdk@17" }
    }
  }
}
```

After `maestro` CLI updates, **reload the MCP** in your agent (e.g., Claude Code: `/mcp` → `maestro` → Reconnect; Codex/Copilot/Gemini: restart the CLI; Cursor: toggle off/on).

## Tools

| Tool | Use when | Notes |
|---|---|---|
| `list_devices` | Before any authoring/run. | Returns Android emulators, iOS simulators, Chromium for web. |
| `inspect_screen` | Before targeting any element. | Returns view hierarchy as compact JSON. **Call again after every UI change.** |
| `take_screenshot` | When a visual disambiguates similar elements. | Useful for AI-assisted picking. |
| `run` | Iterating on a flow. | Accepts exactly one of `{ yaml }` (inline, preferred for exploration), `{ files: [...] }`, or `{ dir, include_tags, exclude_tags }`. YAML is validated. |
| `cheat_sheet` | Unsure of a command's syntax. | Returns canonical commands + best practices. Call before authoring unfamiliar commands. |
| `list_cloud_devices` | Before `run_on_cloud`. | Returns valid `{ device_model, device_os }` pairs. **OS values must be passed verbatim**, e.g. `iOS-17-5`, `android-34`. |
| `run_on_cloud` | Submitting to Maestro Cloud. | Returns `upload_id`, `project_id`, dashboard URL immediately. |
| `get_cloud_run_status` | Polling Cloud results. | Poll every ~60s until terminal: `SUCCESS` / `ERROR` / `CANCELED` / `WARNING`. |

Cloud-prefixed tools require auth: `maestro login` (recommended) or `MAESTRO_CLOUD_API_KEY` env var.

## Authoring loop

```
1. list_devices                     → confirm a device is connected
2. inspect_screen                   → snapshot current UI
3. (think) → propose YAML
4. run { yaml: "<small flow>" }     → execute on the device, get result
5. inspect_screen                   → see new state
6. iterate steps 3–5
7. write final YAML to a file       → use Edit/Write
8. (optional) run { files: ["..."] }→ rerun from disk
9. (optional) run_on_cloud          → submit a stable run
```

## `run` parameter shapes

```
# Inline (preferred during exploration)
{ "yaml": "appId: com.example\n---\n- launchApp\n- tapOn: \"Sign in\"" }

# Specific files
{ "files": ["./tests/login.yaml", "./tests/checkout.yaml"] }

# Folder + tag filtering
{ "dir": "./tests", "include_tags": ["smoke"], "exclude_tags": ["wip"] }
```

Pass exactly one shape. Mixing them is rejected.

## When MCP is NOT installed

Fall back to:
- `maestro studio` — visual element inspector + REPL.
- `maestro test --debug-output build/debug` — read `build/debug/maestro.log` for failure traces.
- `maestro list-devices` for device IDs.

See [cli.md](cli.md).
