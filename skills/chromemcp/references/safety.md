# Danger Classification and Confirmation

## The two questions

Ask both about every planned step. One "yes" makes the step dangerous.

1. Does the step change state outside this browser tab? A server record, a file on
   disk, a message in another person's inbox, a payment, a permission grant.
2. Is the step hard to undo, or does it touch real money, a real identity, or a
   production system?

A step is safe only when both answers are no.

## Safe — never ask

| Tool | Note |
|------|------|
| `take_snapshot`, `take_screenshot` | Read only |
| `list_pages`, `select_page` | Read only |
| `hover`, `press_key` for navigation keys | No submit |
| `wait_for` | Read only |
| `list_console_messages`, `get_console_message` | Read only |
| `list_network_requests`, `get_network_request` | Reads the log, sends nothing |
| `resize_page`, `emulate` | Local to the browser |
| `performance_start_trace`, `performance_stop_trace`, `lighthouse_audit` | Loads the page; safe on a test host |
| `take_heapsnapshot` | Local, but large output |
| `evaluate_script` that only reads the DOM | See the script rule below |
| `navigate_page`, `new_page` inside the target origin, on a non-production host | See the host rule below |

## Dangerous — always ask

**State change**
- Submit a form. `fill_form` followed by a submit click.
- Create, update, or delete a record.
- Publish, post, comment, or share.
- Send a message, an email, or an invitation.
- Pay, subscribe, or cancel a subscription.

**Identity**
- Log in with real credentials.
- Log out. It ends a session the user may not be able to recover.
- Change a password, an email, or a multi-factor setting.
- Accept an OAuth consent screen.

**Irreversible**
- Delete, revoke, deactivate, archive, or transfer.
- Any action with a "this cannot be undone" warning in the UI.

**Leaving the sandbox**
- Any action on a production host.
- Navigation to an origin the user did not name.
- `upload_file`. It reads a real file from disk.
- A download triggered by a click.
- A browser permission prompt: camera, microphone, geolocation, notifications,
  clipboard, screen share.

**Script**
- `evaluate_script` that writes. Any `fetch` or `XMLHttpRequest` that is not GET, any
  write to `localStorage`, `sessionStorage`, `document.cookie`, or `indexedDB`, any
  DOM mutation, any call to `submit()`, `click()`, or `location =`.

**Environment**
- Quit or relaunch Chrome.
- Kill a Chrome process outside a scratchpad directory.
- `close_page` on a tab the user opened.
- Copy or symlink a real Chrome profile into a debug directory. Both put real
  credentials under a test browser, and link mode writes to the real profile.
- Quit the user's daily Chrome so that a linked profile is free. Ask. Never `pkill`
  a Chrome that holds real tabs.
- Clear cookies, storage, or cache.

## Host rule

Classify the host before you plan.

- `localhost`, `127.0.0.1`, `*.local`, an explicit dev or staging domain — test host.
  Navigation and reads are safe there.
- Anything else — treat as production. Every write is dangerous, and say so.
- No host in the prompt — ask. Never default to production.

## Script rule

Before you run `evaluate_script`, read your own function body. If it contains any
write listed above, it is dangerous. Show the exact function text in the confirmation
block. Do not describe it in prose.

## Confirmation block

Present it once, after the plan, before any action. One bullet per item.

```
D<n> - step <k> - <action> - <what changes and why it is hard to undo> - <safer alternative, or "none">
```

Example:

```
No dangerous steps except these:

D1 - step 4 - Log in as qa@example.com on staging - Creates a real session and may
     trigger a login alert email - Reuse the saved debug-profile session instead
D2 - step 7 - Click "Delete workspace" - Removes the workspace and its data; the UI
     says it cannot be undone - Test on a throwaway workspace created in step 6

I want to run D2 against a throwaway workspace, and skip D1 by reusing the saved
session. Alternatives: approve both as planned, which uses the real account and
deletes the named workspace; or approve D1 only, which stops the run before step 7.
```

End with one question. Do not proceed on silence.

## Mid-run rule

A new dangerous step found during execution stops the run. Do not ask and continue in
the same breath. Report what is done, present the new item in the same format, and
wait.

An unexpected modal is not automatic approval. A dialog that asks "Delete?" is a
dangerous step even when clicking it was not in the plan.

## What never needs a question

Do not ask permission to read, to snapshot, to wait, or to take a screenshot. Asking
about safe steps trains the user to approve without reading. Keep the block short so
each line matters.
