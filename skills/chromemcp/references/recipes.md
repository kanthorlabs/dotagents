# Recipes

Each recipe is a step pattern. Adapt it. Do not run it blind.

The preflight is the exception. Run it verbatim, every time, before anything else.

---

## Recipe: preflight (mandatory, run first)

```
1. list_pages
   -> pages returned = the MCP server is attached
   -> nothing, or a lone about:blank, or unknown tabs = see references/connection.md
2. new_page  https://example.com
3. take_snapshot
4. assert  heading "Example Domain"
```

Do not replace `example.com` with the target application. The point is to test the
link, not the application. A failure here is a setup problem, and a run against the
target would misreport it as a product bug.

Close this tab in the cleanup, and list it under "Left behind".

---

## From prompt to plan

The user gives an outcome. You produce steps. Examples of the mapping:

| Prompt | Derived plan |
|--------|--------------|
| "Check the login form shows an error for a bad password" | Navigate, snapshot, fill with a fake password, submit, wait for the error, assert its text |
| "Does the cart total update when I change quantity?" | Navigate to the cart, snapshot, read the total, change the quantity, wait, read the total, compare |
| "The dropdown is broken on mobile" | Resize to a phone width, snapshot, click the dropdown, snapshot, assert the options are visible and inside the viewport |
| "Fill this form for me with X" | Automation. Fill, then stop and confirm before the submit |

Rules for the mapping:

- Every "does it ...?" prompt needs a before value and an after value.
- Every "is it broken?" prompt needs the console and the network log as evidence.
- Every automation prompt stops at the last safe step and confirms the rest.

---

## Recipe: assert a visible change

```
1. navigate_page <url>
2. wait_for <text that proves the page is ready>
3. take_snapshot                          -> record the before value
4. click <uid>  includeSnapshot: true
5. wait_for <text that proves the update landed>
6. take_snapshot                          -> record the after value
7. compare before and after
```

Assert on the value, not on the click succeeding.

## Recipe: form validation

```
1. navigate_page <url>
2. take_snapshot
3. fill_form  <invalid values>
4. press_key Enter    (this is a submit — confirm it first)
5. wait_for <error text>
6. take_snapshot      -> assert the error text and the field it attaches to
7. list_console_messages   -> assert no unexpected error
```

Test the invalid path before the valid path. The invalid path is usually safe, because
it does not create a record.

## Recipe: responsive check

```
1. resize_page 390 x 844
2. take_snapshot        -> assert the mobile controls exist
3. take_screenshot      -> visual check only
4. resize_page 1440 x 900
5. take_snapshot        -> assert the desktop controls exist
```

Assert from the snapshot. Use the screenshot to show the user, not to decide.

## Recipe: loading and empty states

```
1. emulate  slow network
2. navigate_page <url>
3. take_snapshot        -> assert the skeleton or the spinner
4. wait_for <loaded content>
5. take_snapshot        -> assert the loaded state
6. emulate  reset
```

## Recipe: is it the UI or the API?

```
1. navigate_page <url>
2. click <uid>  includeSnapshot: true
3. list_network_requests
4. get_network_request <the relevant one>
```

- No request fired — the bug is in the UI handler.
- Request fired and returned an error — the bug is in the backend or the payload.
- Request returned 200 and the UI did not change — the bug is in the render path.

Put this conclusion in the report.

## Recipe: authenticated flow

```
1. list_pages                    -> is a session already open?
2. If signed out: confirm the login as a dangerous step, then log in once
3. Run the test steps
4. Do NOT log out at the end
```

The debug profile keeps the session. Logging out costs the next run a fresh login,
and it is itself a dangerous step.

## Recipe: multi-tab flow

```
1. new_page <url>  background: false
2. Run the steps
3. list_pages                    -> confirm which tab is [selected]
4. select_page <other tab>       -> switch when needed
5. close_page <only tabs you opened>
```

## Recipe: modal-heavy app (Google Meet pattern)

```
1. navigate_page <meeting url>
2. take_snapshot                 -> the consent dialog is modal
3. Handle the dialog             -> confirm first if it grants camera or microphone
4. take_snapshot                 -> now the call controls are reachable
5. Run the steps
6. Leaving the call is a dangerous step. Confirm it.
```

## Recipe: reproduce a reported bug

```
1. Restate the reported steps as a numbered plan
2. Run them exactly, with a snapshot after each
3. On the first divergence, stop
4. Collect: the snapshot, list_console_messages, list_network_requests
5. Report the exact step that diverged, expected against observed
```

Do not fix the bug in the same run unless the user asks. Report first.

---

## Report template

```
VERDICT: FAIL

1. Navigate to /checkout            ✓ page loaded
2. Set quantity to 3                ✓ input shows 3
3. Wait for the total to update     ✗ total stayed at $19.00, expected $57.00

Evidence
- console: TypeError: cannot read properties of undefined (reading 'price')
- network: POST /api/cart 200, response body has the correct total

Conclusion: the API is correct. The render path drops the update.

Left behind
- one tab open at /checkout
- cart quantity changed to 3 for the qa@example.com session
```
