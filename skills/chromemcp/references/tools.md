# Tool Reference

All tools carry the `mcp__chrome-devtools__` prefix. It is dropped below.

## Reading state

### take_snapshot
Returns the accessibility tree with a `uid` on each element. This is the primary read.

- Use it to find elements, to read text, and to assert.
- Every uid belongs to one snapshot. A DOM change invalidates it.
- Take a fresh snapshot before every interaction.
- A stale uid produces "element not found" or, worse, a click on the wrong element.

### take_screenshot
Use only for a visual check: layout, spacing, colour, an image, a canvas, a chart.

Never read text from a screenshot when a snapshot can give it. Never derive
coordinates from a screenshot to click.

### list_console_messages / get_console_message
Collect errors after a failing step. A console error is good failure evidence.

### list_network_requests / get_network_request
Check that a request fired, its status, and its payload. Use it to prove that a click
reached the server, and to separate a UI bug from an API bug.

## Interacting

### click
Pass `includeSnapshot: true`. It acts and returns the resulting tree in one call. This
removes the snapshot-then-click race.

### fill / fill_form
`fill` sets one field. `fill_form` sets several in one call, which is faster and less
prone to stale uids on a long form.

Filling is safe. The submit that follows is usually not. Classify them separately.

### type_text
Use when the page reacts per keystroke: an autocomplete, a search-as-you-type, a
masked input. `fill` sets the value at once and can skip those handlers.

### press_key
Use for `Enter`, `Tab`, `Escape`, and arrow keys. `Enter` inside a form is a submit.
Treat it as a submit.

### hover
Use for tooltips, hover menus, and hover-only controls. Safe.

### drag
Use for reorder, slider, and drag-and-drop tests. Take a snapshot before it and after
it, because the tree changes a lot.

### upload_file
Reads a real file from disk. Always confirm. Prefer a small fixture file inside the
repo or the scratchpad.

### handle_dialog
Handles `alert`, `confirm`, `prompt`, and `beforeunload`.

Accepting a `confirm` can perform a destructive action. Read the dialog message before
you accept it. If the message was not in the plan, stop.

## Navigation

### navigate_page
Moves the selected tab. Check the target origin against the host rule in
`references/safety.md`.

### new_page
Opens a tab. Use `background: true` when the user watches another tab. Remember every
tab you open, and list them in the report.

### close_page
Only close tabs you opened. The last tab cannot be closed.

### list_pages / select_page
`list_pages` marks the active tab `[selected]`. Actions apply to it. Call
`select_page` when the target is another tab. A silent no-op is almost always a
wrong-tab problem.

## Waiting

### wait_for
Wait for text or a condition before you interact with async content. Use it after a
navigation, after a submit, and after any spinner.

Never use a fixed sleep. It is slower and it still races.

## Scripting

### evaluate_script
Use for what the accessibility tree cannot express:

- computed styles, element geometry, scroll position;
- `localStorage` and `sessionStorage` reads;
- framework internals and custom element state;
- a precise assertion over many nodes.

The function must return JSON-serialisable data. Read the script rule in
`references/safety.md` before you run anything that writes.

## Emulation

### resize_page
Test responsive breakpoints. Resize, then snapshot, then assert.

### emulate
CPU throttling and network throttling. Use it to test loading states, skeletons, and
timeouts.

## Performance

### performance_start_trace / performance_stop_trace / performance_analyze_insight
Use for a load-performance question, not for behaviour. `lighthouse_audit` gives the
scored report. `take_heapsnapshot` supports a memory-leak investigation and produces
a large output.

## Selector strategy

Prefer, in this order:

1. The accessible name and role from the snapshot. It matches what a user sees.
2. A stable test attribute, read through `evaluate_script`.
3. Text content.

Avoid a CSS path or an index-based selector. Both break on the next markup change.

## Modal dialogs

A modal blocks the controls behind it. Snapshot first, close the modal, then continue.

Google Meet is the standard example. Its consent dialog and its leave dialog are both
modal. Handle them before you touch the call controls.
