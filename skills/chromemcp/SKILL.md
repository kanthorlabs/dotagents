---
name: chromemcp
description: Drive a real Chrome through the Chrome DevTools MCP to test UI behaviour, and to automate browser tasks. Activate when the user asks to test, verify, reproduce, or click through a page in a real browser, or mentions mcp__chrome-devtools__*, CDP, remote debugging port 9222, take_snapshot, or Chrome automation. Turns a plain-English test request into a preflight → plan → confirm → execute → report run.
compatibility: macOS or Linux with Google Chrome 136+ and the chrome-devtools-mcp server configured. Chrome 136+ refuses remote debugging on the default user data directory, so a dedicated debug profile is mandatory.
loading: deferred
metadata:
  author: "kanthorlabs"
  version: "1.0.0"
---

# Chrome MCP

## How to Use This Skill

**The core rules below are always available.** Read a file from `references/` only when
the task needs it. Do NOT load all references upfront.

| Need | Read |
|------|------|
| Chrome does not connect, wrong tabs appear, profile or login problems | `references/connection.md` |
| Exact behaviour of a single MCP tool, uid handling, selector strategy | `references/tools.md` |
| Classify one action, or write the confirmation block | `references/safety.md` |
| Ready-made step patterns for a test or an automation | `references/recipes.md` |

Helper script: `scripts/chrome-debug.sh` starts Chrome with a correct debug profile.

---

## Purpose

Primary use case: **UI behaviour testing**. Prove that a page does what it must do,
and report pass or fail with evidence.

Secondary use case: **browser automation**. Perform a repeatable task in a real
browser for the user.

Both use the same run loop. Testing adds explicit assertions and a verdict.

## The run loop

Run these phases in order. Never skip a phase. Never reorder them.

0. **Preflight** — prove the MCP link works. Mandatory. Never skip.
1. **Plan** — turn the user prompt into numbered steps with an expected result each.
2. **Confirm** — present every dangerous step in one block. Wait for approval.
3. **Execute** — run the steps. Observe after each one.
4. **Report** — give the verdict, the evidence, and the browser state you left behind.

Phase 2 comes before any action that changes state. Do not start Phase 3 before the
user approves. If Phase 3 finds a new dangerous step, stop and return to Phase 2.

---

## Phase 0 — Preflight (mandatory)

Run this before every task. It costs four calls. It prevents a whole class of silent
failures, above all a run against the wrong Chrome instance.

```
1. list_pages
2. new_page  https://example.com
3. take_snapshot
4. assert: heading "Example Domain" is present
```

Rules:

- `list_pages` is the only connection check. Pages returned means connected.
- Do NOT `curl http://localhost:9222/json/version`. It tests Chrome, not the MCP
  server, and its result is unreliable in both directions on current Chrome builds.
- The `example.com` load is the real proof. It shows that the MCP server can drive a
  page, not only that a socket is open.
- Assert from the **snapshot**, not from a screenshot. The heading must read
  "Example Domain".
- `example.com` is a neutral third-party host. Never substitute the user's target
  application for the preflight.
- Close the preflight tab at the end of the run, and say so in the report.

**Preflight failure paths**

| Result | Meaning | Do this |
|--------|---------|---------|
| `list_pages` returns nothing or errors | No debug Chrome attached | Run `scripts/chrome-debug.sh`, retry |
| The script exits 2 with a profile list | No profile chosen yet | Show the list, ask the user, then `-l "<name>"` |
| `list_pages` returns one lone `about:blank`, or tabs the user does not recognise | Attached to a stale debug instance | Read `references/connection.md`, find the port owner, confirm before killing it |
| `list_pages` says "Could not find DevToolsActivePort" while the port serves CDP | The MCP server runs `--autoConnect`, which only looks in the default Chrome directory | Reconfigure it to `--browserUrl http://127.0.0.1:9222`. See `references/connection.md` |
| `new_page` fails or times out | Chrome is up but the CDP session is broken | Restart the debug Chrome, retry once |
| Snapshot lacks "Example Domain" | No network, a captive portal, or a proxy | Report it. Do not start the real task |

Stop on a preflight failure. Report the failure and the fix. Never continue into
Phase 1 with an unproven connection.

**Launching Chrome.** Chrome 136+ refuses `--remote-debugging-port` on the default
user data directory. A bare `Google Chrome --remote-debugging-port=9222` opens a
window and enables nothing. Always launch with a dedicated `--user-data-dir`:

```bash
scripts/chrome-debug.sh                 # reuse the remembered profile, then launch
scripts/chrome-debug.sh -L              # list the real chrome profiles
scripts/chrome-debug.sh -l "Tuan@ELSA"  # link a REAL profile by display name
scripts/chrome-debug.sh -F              # fresh empty profile
scripts/chrome-debug.sh -s              # status, shows the remembered profile
scripts/chrome-debug.sh -k              # stop the debug instance
```

**Real profile, link mode.** A fresh profile has no logins and no extensions, so it
cannot test a real application. `-l` symlinks the real profile into the debug
directory and copies `Local State`, which holds the cookie key. Chrome follows the
symlink and uses the real logins in place.

**Choosing the profile.** Never guess the profile. The folder name, `Profile 12`,
means nothing to the user; the display name, `Tuan@ELSA`, is the one they know. Run
the script with no arguments. If no profile is chosen, it prints the list and exits 2:

```
No profile is chosen for the debug browser yet.

Chrome profiles in /Users/…/Google/Chrome:
  Default         Tuan@Upmesh              229M
  Profile 12      Tuan@ELSA                110M
  Profile 15      Demo                     6M

3 profiles found. Ask the user which one to use, then run:
  chrome-debug.sh -l "<display name or folder>"
```

Show that list to the user and ask. Then link the answer. `-l` accepts either name.

**The choice is remembered.** The symlink is the state. Later runs need no arguments
and print `using remembered profile: Profile 12 (Tuan@ELSA)`. Ask again only when the
user asks for a different profile. A new `-l` unlinks the old profile and links the
new one, and reports both.

Link mode has one hard rule: **the daily Chrome must be fully quit first.** Chrome
puts its singleton lock in the user data directory, not in the profile, so two
browsers on one linked profile both write it and corrupt cookies and history. The
script refuses to launch while another Chrome owns that directory. Tell the user to
Cmd-Q Chrome, do not kill it for them without asking.

Link mode puts real credentials under a test browser. Confirm it in Phase 2 the first
time. See `references/connection.md` for copy mode and the other alternatives.

## Phase 1 — Plan

Read the user prompt and derive intent. The user describes an outcome, not tool calls.
You choose the tool calls.

Produce a numbered step list. Each step has:

- the action, in one imperative sentence;
- the expected result, which is what you will observe to prove the step worked.

Rules:

- Never guess a URL. If the prompt has no URL and the repo has no obvious dev server,
  ask for it.
- Prefer the smallest path to the answer. Do not explore pages the test does not need.
- Every test needs at least one assertion. "Click the button" is not a test.
  "Click Save, then the row shows Saved" is a test.
- Mark each step `safe` or `danger` with `references/safety.md`.

## Phase 2 — Confirm

Present all dangerous steps in ONE block, before Phase 3 starts. Never ask mid-run
for something you already knew about in Phase 1.

Format, one bullet per item:

```
D1 - <step number> - <action> - <what changes and why it is hard to undo> - <safer alternative, or "none">
```

End the block with a single question that asks to approve all of it, or to approve a
named subset. State your recommendation first, then the alternatives.

If no step is dangerous, say "No dangerous steps." in one line and continue.

**Quick danger test.** A step is dangerous when either answer is yes:

- Does it change state outside this tab — a server record, a file, another person's inbox?
- Is it hard to undo, or does it touch real money, a real identity, or production?

Always dangerous: submit, pay, send, publish, delete, cancel, revoke, log in with real
credentials, log out, upload, download, grant a permission prompt, run a write script,
navigate off the target origin, close a tab the user opened, quit or relaunch Chrome.

Never dangerous: `take_snapshot`, `take_screenshot`, `hover`, `wait_for`,
`list_console_messages`, `list_network_requests`, `resize_page`, `emulate`,
read-only `evaluate_script`, and navigation inside the target origin on a test host.

The preflight is always safe. Never ask permission for it.

## Phase 3 — Execute

- `take_snapshot` to read state, not `take_screenshot`. The snapshot returns the
  accessibility tree with the `uid` values that `click` and `fill` need.
- Take a fresh snapshot before every interaction. Any DOM change makes old uids stale.
- `click` with `includeSnapshot: true`. It acts and returns the new state in one call.
- `take_screenshot` only for a visual check — layout, colour, rendered output.
- `wait_for` before you touch an element that loads asynchronously. Never poll with sleeps.
- `evaluate_script` for state the accessibility tree cannot express.
- `list_pages` shows all tabs. `select_page` if the target tab is not `[selected]`.
- Modal dialogs block the controls behind them. Handle the dialog first. Google Meet
  consent and leave dialogs are the common example.
- After each step, compare the observation against the expected result from Phase 1.
  On a mismatch, stop and collect evidence. Do not retry the same click blindly.

## Phase 4 — Report

For a test, report in this order:

1. **Verdict** — PASS or FAIL, one line.
2. **Steps** — each step with observed result, and a ✓ or ✗.
3. **Evidence** for a failure — the snapshot excerpt, the console error, the failed
   request, or a screenshot.
4. **Left behind** — the tabs you opened, the data you created, the session state.

For an automation, replace the verdict with the outcome, and keep sections 2 to 4.

Report the real result. If a step was skipped because the user declined it, say so.
Never report PASS for a run that did not assert anything.

---

## Anti-patterns

- Skipping the preflight because the last run connected.
- Launching Chrome without `--user-data-dir` and assuming debugging is on.
- Trusting a connection because a window opened.
- Reusing a uid after the DOM changed.
- `take_screenshot` to read text, then guessing at coordinates.
- Asking for confirmation one dangerous step at a time.
- Testing against production because the prompt did not name a host. Ask.
- Reporting PASS from a screenshot that "looks right", with no assertion.
