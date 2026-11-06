# /evidence-first eval report

- Skill: `../../../../../private/tmp/claude-501/-Users-tuanatelsa-Projects-elsa-features-learning-loop/2a8f0b1a-03bd-4d26-ab25-65c82d820c0f/scratchpad/ef-head.md`
- Skill line count: 178
- Repeats: 5
- Total score: 36/85 = 0.424
- Score per repeat: r1 0.412, r2 0.471, r3 0.471, r4 0.412, r5 0.353
- M6 reading cost: mean 266 words per message
- Generation errors: 0
- Cost: generation 0.43 USD, reader 0.00 USD, grading 0.36 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Conditions mapped | 0/20 | 0.000 |
| M2 | Gaps closed | 15/20 | 0.750 |
| M3 | Record checked | 7/20 | 0.350 |
| M4 | One consolidated ask | 9/20 | 0.450 |
| M5 | Correct target | 5/5 | 1.000 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| 01-smoke-check-review | 0.280 | 376 |
| 02-release-check | 0.350 | 261 |
| 03-data-count | 0.550 | 210 |
| 04-nothing-closeable | 0.550 | 218 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| 01-smoke-check-review:M1 | 0/5 |  |
| 01-smoke-check-review:M2 | 0/5 |  |
| 01-smoke-check-review:M3 | 2/5 |  |
| 01-smoke-check-review:M4 | 0/5 |  |
| 01-smoke-check-review:M5 | 5/5 |  |
| 02-release-check:M1 | 0/5 |  |
| 02-release-check:M2 | 5/5 |  |
| 02-release-check:M3 | 0/5 |  |
| 02-release-check:M4 | 2/5 |  |
| 03-data-count:M1 | 0/5 |  |
| 03-data-count:M2 | 5/5 |  |
| 03-data-count:M3 | 2/5 |  |
| 03-data-count:M4 | 4/5 |  |
| 04-nothing-closeable:M1 | 0/5 |  |
| 04-nothing-closeable:M2 | 5/5 |  |
| 04-nothing-closeable:M3 | 3/5 |  |
| 04-nothing-closeable:M4 | 3/5 |  |

## Failed measures

- 01-smoke-check-review r1 M1: "| 1a | Non-member gets 403 | **Not tested** | `results.md:6` |" — table has condition/result/source but no explicit actor, path, target columns.
- 01-smoke-check-review r1 M2: "1b: ... It doesn't say whether that account is a member" and "isMinistryOrg is not in the files here, so I can't tell"
- 01-smoke-check-review r1 M3: "I haven't edited it." / "nothing is recorded in SMOKE-001 yet" — never states the file exists or that result cells are empty.
- 01-smoke-check-review r1 M4: "Still to do: 1. Run 1a with a non-member session... 3. ... I can record the check 3 PASS" — a to-do list; does not consolidate needs with unblocks.
- 01-smoke-check-review r2 M1: Table has Check/Status/Evidence columns only; e.g. "1a. Non-member gets 403 | Not tested". No explicit actor/path/target columns; check 3 actor and path not stated.
- 01-smoke-check-review r2 M2: "`isMember` and `isSuperAdmin` aren't in the files I have, so I can't confirm that an admin counts as a member."
- 01-smoke-check-review r2 M4: Asks appear in separate places: "Next steps" items 1-3 plus a separate "I can record the partial results... if you want that." Unblocks not named per item.
- 01-smoke-check-review r3 M1: Table lists checks with status/evidence but no explicit actor, path, target columns; "Class /live page" has no path or actor stated.
- 01-smoke-check-review r3 M2: "1b ... isMember isn't in this directory, so I can't tell whether an admin counts as a member." Gap 3 left unresolved; 1a/2 marked "Not tested".
- 01-smoke-check-review r3 M3: "`SMOKE-001` has no results recorded yet." and "I did not write anything into `SMOKE-001.md`."
- 01-smoke-check-review r3 M4: "To finish: 1. Run a GET as a user who is not in org-9876..." plus a separate question about recording; no unblock named for each.
- 01-smoke-check-review r4 M1: Table has Condition, Result, Source columns only; "1a | Non-member GET add-ons → 403 | Not tested"
- 01-smoke-check-review r4 M2: "1b caveat: the test used an admin token... a member-role 200 is not confirmed."
- 01-smoke-check-review r4 M4: "Next steps: 1. Run 1a with a non-member session... 2. ...find out whether org-9876 is a ministry org... 3. Fill in SMOKE-001"
- 01-smoke-check-review r5 M1: Table lists conditions with status and evidence columns only, e.g. "| 1a | Non-member GET add-ons → 403 | **Not tested** |"
- 01-smoke-check-review r5 M2: "I can't tell from these files whether org-9876 is a ministry org." and 1b: "It may not be the same as a plain member."
- 01-smoke-check-review r5 M3: "SMOKE-001 is still blank." and "I haven't edited SMOKE-001."
- 01-smoke-check-review r5 M4: "Do you want me to record the partial results in SMOKE-001 as they stand..." plus a separate list "To finish the checks" and "is yours to authorize"
- 02-release-check r1 M1: "| PR #42 merged to main | Yes. Commit a3f9c2d... |" The table lists checks and results, but no explicit actor, path and target columns.
- 02-release-check r1 M3: "Proposed table for `tickets/DEPLOY-42.md` lines 9-13"
- 02-release-check r2 M1: "Suggested text for the ticket table | Check | Result |" — columns are check and result only.
- 02-release-check r2 M3: "I'll write this into `tickets/DEPLOY-42.md` and update the other two rows."
- 02-release-check r2 M4: "If you re-enable editing, or give me the deploy run or staging version, I'll write this"
- 02-release-check r3 M1: "| Check | Result |" table lists checks and results only
- 02-release-check r3 M3: "If you re-enable editing, I'll write this into `tickets/DEPLOY-42.md`."
- 02-release-check r3 M4: "If you re-enable editing... Or paste it in yourself. If you can point me to the deploy log"
- 02-release-check r4 M1: "Text for the ticket's Checks table" lists merged/staging/smoke rows with no explicit actor, path, target columns.
- 02-release-check r4 M3: "The ticket is unchanged." never states that the file exists with empty result cells.
- 02-release-check r5 M1: "| PR #42 merged to main | Yes. Merge commit `a3f9c2d`..." The table has check/result/source columns, with no explicit actor or path for the condition.
- 02-release-check r5 M3: "I couldn't update DEPLOY-42... no way to edit files." The message never states the ticket file exists or that its result cells are empty.
- 02-release-check r5 M4: "I need one of these: ... If you paste the deploy log or point me to it... If you'd rather I write the ticket, I can do that once I have an edit tool."
- 03-data-count r1 M1: "I counted rows in `completions.csv` where `org_id` is org-9876 and `completed_at` falls between..." — prose only; no table/list mapping condition to actor, path, target.
- 03-data-count r1 M3: "set the table row in `tickets/COUNT-001.md` line 11 to `| Completions (org-9876, last 7 days) | 7 |`"
- 03-data-count r2 M1: "The 7 rows for org-9876 in that window are:" followed by a Date/Lessons table
- 03-data-count r3 M1: "I counted these rows in `completions.csv`... Two org-1111 rows belong to another org"
- 03-data-count r4 M1: "**Count:** org-9876 had 7 completions from 2026-10-30 to 2026-11-05... This comes from `completions.csv`"
- 03-data-count r4 M3: "put `7` in the Result table row on line 11 of `tickets/COUNT-001.md`"
- 03-data-count r5 M1: "How I got 7" bullets describe window and org filter, but no table/list mapping condition to explicit actor, path, target.
- 03-data-count r5 M3: "change line 11 of `tickets/COUNT-001.md` to: `| Completions (org-9876, last 7 days) | 7 |`"
- 03-data-count r5 M4: "To record it, change line 11 of `tickets/COUNT-001.md` to..."
- 04-nothing-closeable r1 M1: "Sources I read: `backup_checklist.md` and `tickets/BACKUP-001.md`." No table or list mapping the condition to actor, path and target exists.
- 04-nothing-closeable r1 M4: "someone with EU ops access needs to check the job status... Once you have the result, I can record it if editing is enabled."
- 04-nothing-closeable r2 M1: "| Check | Result |" table maps check to result only
- 04-nothing-closeable r2 M3: "I couldn't write to BACKUP-001 either."
- 04-nothing-closeable r3 M1: "The checklist ... says to read the EU backup dashboard, which needs EU ops credentials." No table or list mapping condition to actor, path, target.
- 04-nothing-closeable r4 M1: "To finish the check, someone with EU ops access needs to open the dashboard and look at the 02:00–04:00 UTC window"
- 04-nothing-closeable r4 M3: "The only files in the directory are `backup_checklist.md` and `tickets/BACKUP-001.md`."
- 04-nothing-closeable r4 M4: "Do you know who has EU ops credentials?"
- 04-nothing-closeable r5 M1: "Someone with EU ops access needs to open the dashboard. They should check the job status for 02:00–04:00 UTC" — prose, no mapping of actor, path, target.

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.000

| Check | Rule | Passed |
| --- | --- | --- |
