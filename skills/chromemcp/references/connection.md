# Connection and Profiles

## The one rule

Chrome 136 and later **refuse remote debugging when the browser uses the default user
data directory**. On macOS that directory is
`~/Library/Application Support/Google/Chrome`.

The refusal is silent. Chrome starts, a window opens, and no port listens.

Verified on Chrome 150.0.7871.187, macOS:

- `Google Chrome --remote-debugging-port=9222` with the default directory — process
  runs, nothing listens on 9222.
- Same flags plus `--user-data-dir=<dedicated path>` — port listens, CDP responds.

So the plain command in older notes no longer enables anything by itself:

```bash
# DOES NOT WORK on Chrome 136+
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

## The working launch

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.cache/chrome-debug" \
  --no-first-run --no-default-browser-check
```

Or use `scripts/chrome-debug.sh`, which adds the port check and the wait.

## Second rule — flags reach only a new process

Chrome runs one browser process per user data directory. A second launch on the same
directory sends a message to the running process and exits. The new flags are dropped.

Result: if a Chrome already runs on `~/.cache/chrome-debug`, adding a different port
does nothing. Quit that instance first, or use a different directory.

## Configure the MCP server with --browserUrl, not --autoConnect

`chrome-devtools-mcp --autoConnect` discovers Chrome by reading `DevToolsActivePort`
inside the **default** user data directory. Chrome 136+ can never enable debugging on
that directory. The two features contradict each other.

Verified on Chrome 150: the debug browser served CDP on port 9222, and the MCP server
still failed with

```
Could not connect to Chrome. Check if Chrome is running.
Cause: Could not find DevToolsActivePort for chrome at
  /Users/…/Library/Application Support/Google/Chrome/DevToolsActivePort
```

Worse, a stale `DevToolsActivePort` from an earlier session stays in that directory
and points the MCP server at a dead browser.

Fix the server configuration in `~/.claude.json` under `mcpServers.chrome-devtools`:

```json
{
  "type": "stdio",
  "command": "npx",
  "args": ["chrome-devtools-mcp@1.1.1",
           "--browserUrl", "http://127.0.0.1:9222",
           "--no-usage-statistics"]
}
```

Restart Claude Code after the change. `--browserUrl` names the endpoint directly, so
the debug directory no longer has to be the default one.

Keep the port stable. `chrome-debug.sh` uses 9222 by default, which matches.

### Temporary bridge, without a restart

If a restart is not possible, write a correct `DevToolsActivePort` into the default
directory so that `--autoConnect` finds the live browser:

```bash
WS=$(curl -s http://127.0.0.1:9222/json/version |
     python3 -c "import sys,json;print(json.load(sys.stdin)['webSocketDebuggerUrl'])")
DEF="$HOME/Library/Application Support/Google/Chrome/DevToolsActivePort"
printf '9222\n%s\n' "${WS#ws://127.0.0.1:9222}" > "$DEF"
```

This writes into the real Chrome directory, so it is a dangerous action. Confirm it.
Chrome rewrites the file on its next start, so the change heals by itself.

## Verify the connection

Call `mcp__chrome-devtools__list_pages`. Pages returned means connected.

Do not use `curl http://localhost:9222/json/version` as the check. Two reasons:

- It tests Chrome, not the MCP server. The MCP server can be attached elsewhere.
- Discovery endpoints have returned 404 on some Chrome builds even while CDP works.
  Chrome 150 does answer `/json/version`, so a 404 is not proof of failure either.
  The endpoint is unreliable in both directions. `list_pages` is not.

## Multiple profiles

A profile is a folder inside the user data directory: `Default`, `Profile 1`,
`Profile 12`. Names live in `Local State` under `profile.info_cache`.

Read the names:

```bash
python3 -c "
import json,os
p=os.path.expanduser('~/Library/Application Support/Google/Chrome/Local State')
for k,v in json.load(open(p))['profile']['info_cache'].items(): print(k,'=>',v.get('name'))
"
```

Facts that matter:

- Remote debugging is a property of the **instance**, not of the profile. One debug
  instance exposes every window it owns, across all of its profiles.
- `--profile-directory="QA"` selects the profile inside the user data directory.
  Chrome creates the folder if it does not exist. Verified working with CDP.
- A dedicated `--user-data-dir` does **not** contain the user's daily profiles. It
  starts with one empty `Default`. The user's logins are not there.

So the answer to "does this still work with several profiles?" is yes, with one cost:
the debug instance carries its own profile set. Plan for the login.

## Using a real profile — link mode

A fresh profile has no logins, no extensions, and no settings, so it cannot test a
real application. Link the real profile into the debug directory instead.

### Pick the profile with the user

Never guess. Users know the display name, not the folder name.

```bash
scripts/chrome-debug.sh -L
```

```
Chrome profiles in /Users/tuannguyen/Library/Application Support/Google/Chrome:
  Default         Tuan@Upmesh              229M
  Profile 12      Tuan@ELSA                110M
  Profile 15      Demo                     6M
```

`Guest Profile` and `System Profile` are internal directories. They are filtered out,
because they never appear in the `profile.info_cache` list.

Running the script with no chosen profile prints the same list and exits 2. Show it
to the user. Ask which one. Then link the answer:

```bash
scripts/chrome-debug.sh -l "Tuan@ELSA"      # display name
scripts/chrome-debug.sh -l "Profile 12"     # or folder name; both resolve
```

### The choice is remembered

The symlink is the state. There is no extra state file to go stale.

- Later runs need no arguments: `using remembered profile: Profile 12 (Tuan@ELSA)`.
- `-s` shows the remembered profile and its source path.
- A new `-l` unlinks the old profile and links the new one, and reports both:

```
unlinked Profile 12 (Tuan@ELSA)
linked Profile 15 (Demo)
```

Ask the user again only when they ask for a different profile.

`-F` keeps a fresh empty profile instead, for a test that must start signed out.

### What the link does

What the script does:

1. Creates a symlink `<debug dir>/Default` that points at the real profile folder.
2. Copies `Local State` into the debug directory. That file holds the `os_crypt` key
   that decrypts the cookies. It is copied, not linked, so the debug browser never
   rewrites the real one.
3. Runs the shared-profile guard, then launches.

Verified on Chrome 150: Chrome enables remote debugging, because `--user-data-dir`
holds a non-default value. Chrome follows the symlink and reads and writes the real
profile in place. The logins, extensions, and settings are all present.

### The one hard rule

**Never run two browsers on a linked profile at the same time.**

Chrome puts its singleton lock in the user data directory, not in the profile folder.
Two data directories mean two locks, so Chrome does not notice the clash. Verified:
the daily browser and the debug browser both held the same profile open, with 36 and
108 file handles into it. That corrupts cookies, history, and Local Storage.

`scripts/chrome-debug.sh` refuses to launch while another Chrome owns the real data
directory. It tests **ownership**, not open file handles. A daily Chrome with every
window closed holds no profile files, and it still opens the profile the moment a
window appears.

Quit the daily Chrome fully — Cmd-Q, not just closing the windows — before a linked
run. The debug browser then owns the profile until you stop it.

### Alternatives to link mode

- **Copy the profile** into the debug directory. The daily Chrome can keep running,
  and a bad test cannot damage the real profile. The copy drifts from the real one,
  so re-copy when the state matters. Profiles are small: 234M, 116M, and 7.3M here.
- **A fresh dedicated profile**, signed in once by hand. Safest, but it rebuilds the
  setup that link mode exists to avoid.

Both link mode and copy mode place real credentials under a test browser. Confirm
with the user before either. See `references/safety.md`.

## Attached to the wrong Chrome

`chrome-devtools-mcp --autoConnect` attaches to whatever debug Chrome it finds. Old
debug instances from earlier sessions survive and win.

Symptom: `list_pages` returns one `about:blank`, or tabs the user does not recognise.

Diagnose:

```bash
# which processes, and their flags
ps auxww | grep "[G]oogle Chrome.app/Contents/MacOS/Google Chrome "
# which process actually owns the port
lsof -nP -iTCP:9222 -sTCP:LISTEN
```

Fix: quit the stale instance, then relaunch the one you want.

```bash
pkill -f "user-data-dir=<stale path>"
```

Confirm the `pkill` with the user when the path is not a scratchpad path. Killing a
Chrome that holds real tabs loses the user's work.

## Troubleshooting table

| Symptom | Cause | Fix |
|---------|-------|-----|
| `list_pages` returns nothing | No debug Chrome, or MCP attached to a dead one | Launch with `scripts/chrome-debug.sh`, retry |
| Port not listening after launch | Default user data directory used | Add `--user-data-dir` |
| Flags ignored, no new process | Chrome already runs on that directory | Quit it, or use another directory |
| Wrong tabs listed | Stale debug instance won `--autoConnect` | `lsof` the port, kill the stale one |
| Signed out on every run | Temporary user data directory | Use one stable debug path |
| Tab exists but actions do nothing | Target tab is not selected | `list_pages`, then `select_page` |
