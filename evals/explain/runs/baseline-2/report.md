# /explain eval report

- Skill: `skills/explain/SKILL.md`
- Skill line count: 192
- Repeats: 3
- Total score: 211/243 = 0.868
- Score per repeat: r1 0.815, r2 0.877, r3 0.914
- M6 reading cost: mean 385 words per message
- Generation errors: 0
- Cost: generation 1.63 USD, reader 1.09 USD, grading 1.47 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Right decision | 36/36 | 1.000 |
| M2 | True facts | 39/42 | 0.929 |
| M3 | No follow-up | 37/45 | 0.822 |
| M4 | Understanding | 38/42 | 0.905 |
| M5 | Answerable close | 37/42 | 0.881 |
| M7 | Valid alternative | 21/33 | 0.636 |
| MF | Factual answer | 3/3 | 1.000 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| 01-bug-fix | 0.778 | 444 |
| 02-proposal-no-bug | 1.000 | 484 |
| 03-walkthrough | 0.917 | 272 |
| 04-uncertain | 0.611 | 415 |
| 05-branch | 0.778 | 534 |
| 06-restatement | 0.917 | 143 |
| 07-ruling-ack | 0.833 | 396 |
| 08-ruling-last | 1.000 | 180 |
| 09-review | 0.833 | 631 |
| 10-negative-factual | 1.000 | 35 |
| 11-selfdebate-source | 1.000 | 427 |
| 12-selfdebate-allowlist | 0.833 | 416 |
| 13-selfdebate-removal | 0.833 | 387 |
| 14-forbid-config | 1.000 | 399 |
| 15-swap-stream | 1.000 | 510 |
| 16-swap-async | 0.778 | 479 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| 01-bug-fix:M1 | 3/3 | non-discriminating |
| 01-bug-fix:M2 | 2/3 | non-discriminating |
| 01-bug-fix:M3 | 2/3 | non-discriminating |
| 01-bug-fix:M4 | 3/3 | non-discriminating |
| 01-bug-fix:M5 | 3/3 |  |
| 01-bug-fix:M7 | 1/3 |  |
| 02-proposal-no-bug:M1 | 3/3 | non-discriminating |
| 02-proposal-no-bug:M2 | 3/3 |  |
| 02-proposal-no-bug:M3 | 3/3 |  |
| 02-proposal-no-bug:M4 | 3/3 |  |
| 02-proposal-no-bug:M5 | 3/3 |  |
| 02-proposal-no-bug:M7 | 3/3 | non-discriminating |
| 03-walkthrough:M2 | 3/3 | non-discriminating |
| 03-walkthrough:M3 | 2/3 |  |
| 03-walkthrough:M4 | 3/3 | non-discriminating |
| 03-walkthrough:M5 | 3/3 | non-discriminating |
| 04-uncertain:M1 | 3/3 |  |
| 04-uncertain:M2 | 2/3 |  |
| 04-uncertain:M3 | 3/3 |  |
| 04-uncertain:M4 | 1/3 |  |
| 04-uncertain:M5 | 2/3 |  |
| 04-uncertain:M7 | 0/3 | non-discriminating |
| 05-branch:M1 | 3/3 | non-discriminating |
| 05-branch:M2 | 2/3 |  |
| 05-branch:M3 | 2/3 | non-discriminating |
| 05-branch:M4 | 3/3 |  |
| 05-branch:M5 | 2/3 |  |
| 05-branch:M7 | 2/3 | non-discriminating |
| 06-restatement:M2 | 3/3 |  |
| 06-restatement:M3 | 3/3 |  |
| 06-restatement:M4 | 2/3 |  |
| 06-restatement:M5 | 3/3 |  |
| 07-ruling-ack:M1 | 3/3 |  |
| 07-ruling-ack:M2 | 3/3 |  |
| 07-ruling-ack:M3 | 1/3 |  |
| 07-ruling-ack:M4 | 3/3 |  |
| 07-ruling-ack:M5 | 2/3 |  |
| 07-ruling-ack:M7 | 3/3 | non-discriminating |
| 08-ruling-last:M3 | 3/3 | non-discriminating |
| 08-ruling-last:M5 | 3/3 | non-discriminating |
| 09-review:M1 | 3/3 | non-discriminating |
| 09-review:M2 | 3/3 | non-discriminating |
| 09-review:M3 | 2/3 |  |
| 09-review:M4 | 2/3 | non-discriminating |
| 10-negative-factual:MF | 3/3 | non-discriminating |
| 11-selfdebate-source:M1 | 3/3 |  |
| 11-selfdebate-source:M2 | 3/3 |  |
| 11-selfdebate-source:M3 | 3/3 | non-discriminating |
| 11-selfdebate-source:M4 | 3/3 | non-discriminating |
| 11-selfdebate-source:M5 | 3/3 |  |
| 11-selfdebate-source:M7 | 3/3 |  |
| 12-selfdebate-allowlist:M1 | 3/3 |  |
| 12-selfdebate-allowlist:M2 | 3/3 |  |
| 12-selfdebate-allowlist:M3 | 3/3 |  |
| 12-selfdebate-allowlist:M4 | 3/3 |  |
| 12-selfdebate-allowlist:M5 | 3/3 |  |
| 12-selfdebate-allowlist:M7 | 0/3 | non-discriminating |
| 13-selfdebate-removal:M1 | 3/3 | non-discriminating |
| 13-selfdebate-removal:M2 | 3/3 |  |
| 13-selfdebate-removal:M3 | 3/3 |  |
| 13-selfdebate-removal:M4 | 3/3 |  |
| 13-selfdebate-removal:M5 | 1/3 |  |
| 13-selfdebate-removal:M7 | 2/3 |  |
| 14-forbid-config:M1 | 3/3 | non-discriminating |
| 14-forbid-config:M2 | 3/3 | non-discriminating |
| 14-forbid-config:M3 | 3/3 |  |
| 14-forbid-config:M4 | 3/3 | non-discriminating |
| 14-forbid-config:M5 | 3/3 |  |
| 14-forbid-config:M7 | 3/3 |  |
| 15-swap-stream:M1 | 3/3 | non-discriminating |
| 15-swap-stream:M2 | 3/3 |  |
| 15-swap-stream:M3 | 3/3 |  |
| 15-swap-stream:M4 | 3/3 | non-discriminating |
| 15-swap-stream:M5 | 3/3 |  |
| 15-swap-stream:M7 | 3/3 |  |
| 16-swap-async:M1 | 3/3 | non-discriminating |
| 16-swap-async:M2 | 3/3 | non-discriminating |
| 16-swap-async:M3 | 1/3 | non-discriminating |
| 16-swap-async:M4 | 3/3 | non-discriminating |
| 16-swap-async:M5 | 3/3 |  |
| 16-swap-async:M7 | 1/3 |  |

## Failed measures

- 01-bug-fix r1 M7: "Alternative: unique `created_at` in `bulk_import.py`... It is not a standalone fix." This is in invalid_options. It is offered as an alternative.
- 01-bug-fix r3 M2: "It beats the recommendation when orders can be created mid-export" – the ticket settles that no orders were created during the export. The message leaves it open.
- 01-bug-fix r3 M3: Reader follow-up: "Can orders be created while a client is running an export?" The message never says none were created, and Ulrich needs that to choose between the fixes.
- 01-bug-fix r3 M7: "Alternative: unique `created_at` per row in `bulk_import.py`." This is in invalid_options and is offered as an alternative, though the message does not recommend it.
- 03-walkthrough r2 M3: Reader: "How does `deploy staging` reach `deploy(\"staging\")`: where is the entry point or dispatcher" and message: "I found no CLI entry point"
- 04-uncertain r1 M2: "`northwind` had `hide_archived` on in the cached flags" is stated as fact in the opening, but the key says the value is unknown. It also says "so `hide_archived` was off for them" for acme and globex.
- 04-uncertain r1 M4: The reader fix is "Add AND issued_at < now() - interval '90 days' to migration 0042. Add a repair migration". The key says no fix is chosen yet and waits on the hide_archived value.
- 04-uncertain r1 M5: "Should Aelita draft the 0042 fix and the repair migration, or remove the `hide_archived` filter from the report?" The key's closing decision is to get the hide_archived evidence or restore the invoices.
- 04-uncertain r1 M7: "Alternative: stop `hide_archived` from hiding invoices in reports. Remove the flag from `build_monthly_report`." This is the invalid option 'Change report-builder to ignore hide_archived'.
- 04-uncertain r2 M7: "Alternative: turn hide_archived off for northwind." This is not in valid_alternatives (restore now / get flag evidence first) and leaves the wrong data in place.
- 04-uncertain r3 M4: Reader fix: "Recommended: a corrective migration 0043 ... Alternative: turn `hide_archived` off". Key says no fix is chosen yet; it waits for the flag value.
- 04-uncertain r3 M7: "Alternative: turn `hide_archived` off for `northwind`." This is not in valid_alternatives and does not fix the wrongly archived data.
- 05-branch r1 M2: "I found no file that settles this." (us-east reaching redis-locks) is not a dependent fact, but the message states 'You don't need to know the region' without naming the region as unknown; also it never states us-east replicas correctly? It does. Main fail: region fact is not named unverified.
- 05-branch r1 M3: Reader follow-up: "Can us-east pods reach the `redis-locks` Redis?" The message admits it found no file settling this, and the reader holds approval on it: a real gap.
- 05-branch r1 M5: Reader closing_answer: "Neither yet." The question offers lock fix vs idempotent POs, which fits closing_decision, but the reader could not give a real answer and held approval.
- 05-branch r1 M7: "It becomes the primary if you want protection that does not depend on Redis." The trade-off is stated, but the alternative is said to need a change in an unread package, not the schema change the key names; the condition differs from the key's 'one guard covering every cause'.
- 06-restatement r1 M4: Reader cost: "not stated". Key cost is n/a, so skipped. But reader fix: "Set `touch_on_request` to true ... The alternative is to move the touch into `auth-service`." This matches the key. Problem and breaks match too.
- 07-ruling-ack r1 M3: The reader asks where handle_bounce is called and whether it can get the bounce type. The message says "I cannot see where that type would come from", so the ruling depends on an unanswered gap.
- 07-ruling-ack r2 M3: Reader: "I will not rule until I know how often one recipient gets several invoices per hour." The message does not answer this, and the reader needs it to choose between the two options.
- 07-ruling-ack r2 M5: Reader closing_answer: "I will not rule until I know how often one recipient gets several invoices per hour." It is a conditional hold, not a real answer, even though the question holds one decision.
- 09-review r2 M3: "S1 - ... No replay protection ... fix: store the event `id` and skip any id already seen"; recommendation: "S1 to S4 left as follow-ups."
- 09-review r2 M4: Reader fix: "B1... B2... B3... B4" with no dedupe; breaks omits retried event credits twice.
- 12-selfdebate-allowlist r1 M7: "Alternative: pattern denylist. Block names ending in `_KEY`, `_SECRET`..." A pattern-based denylist is listed in invalid_options.
- 12-selfdebate-allowlist r2 M7: "Alternative: extend the denylist. Add `STRIPE_API_KEY`, `SENTRY_DSN` and `BILLING_WEBHOOK_SECRET`." A name-based denylist is in invalid_options and is not a valid alternative.
- 12-selfdebate-allowlist r3 M7: "Alternative: extend the denylist... It leaves this class of leak open." and "Alternative: remove the debug dump." Both fall under invalid_options, and the valid per-plugin alternative is not offered.
- 13-selfdebate-removal r1 M5: "Should Aelita draft the `partner_refs` migrations and view change, or keep `legacy_sku` as it is?" It is one question with one decision, matching the closing decision, but the reader answered "do not keep it as it is", so it works. However it adds drafting scope; still, it is the one decision.
- 13-selfdebate-removal r2 M5: "Has Oakline Supply moved from Brightstock codes to the new `sku`? If not, do you approve keeping `legacy_sku` for now?" The message ends with two questions, which the rule fails.
- 13-selfdebate-removal r2 M7: "Alternative: drop now and send `sku` anyway." This matches the invalid option of dropping the column and changing the view to p.sku without Oakline Supply.
- 16-swap-async r1 M3: "What can break" is only partly answered: the message covers documents queue sharing but never mentions mail delivery delays or link expiry.
- 16-swap-async r1 M7: For the idle-timeout alternative, the message says "I would not pick it." It gives no condition under which it becomes the primary.
- 16-swap-async r2 M3: The required question "What can break?" is unanswered. The message never mentions mail delivery delays, link expiry or documents queue month-end load.
- 16-swap-async r3 M7: "Alternative: raise `idle_timeout_seconds`." The trade-off is given, but the message states no condition that would make it primary.

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.914

| Check | Rule | Passed |
| --- | --- | --- |
| 01-bug-fix:bold-leadins | R46 | 3/3 |
| 01-bug-fix:change-bullets | R46 | 3/3 |
| 01-bug-fix:close-last | R17 | 3/3 |
| 01-bug-fix:conclusion-first | R11 | 3/3 |
| 01-bug-fix:fixed-starts-at-divergence | R25 | 3/3 |
| 01-bug-fix:has-failing-timeline | R13 | 3/3 |
| 01-bug-fix:has-fixed-timeline | R14 | 3/3 |
| 01-bug-fix:has-recommendation | R16 | 3/3 |
| 01-bug-fix:has-what-changes | R15 | 3/3 |
| 01-bug-fix:headers | R48 | 3/3 |
| 01-bug-fix:names-self | R22 | 3/3 |
| 01-bug-fix:no-alt-timeline | R30 | 3/3 |
| 01-bug-fix:no-em-dash | R45 | 3/3 |
| 01-bug-fix:no-flattery | R49 | 3/3 |
| 01-bug-fix:no-paren-aside | R45 | 2/3 |
| 01-bug-fix:section-order | R10 | 3/3 |
| 01-bug-fix:sections-labeled | R47 | 3/3 |
| 01-bug-fix:sentence-length | R44 | 3/3 |
| 01-bug-fix:step-sentences | R23 | 3/3 |
| 01-bug-fix:timeline-bounds | R24 | 2/3 |
| 02-proposal-no-bug:bold-leadins | R46 | 3/3 |
| 02-proposal-no-bug:change-bullets | R46 | 3/3 |
| 02-proposal-no-bug:close-last | R17 | 3/3 |
| 02-proposal-no-bug:conclusion-first | R11 | 3/3 |
| 02-proposal-no-bug:fixed-starts-at-divergence | R25 | 3/3 |
| 02-proposal-no-bug:has-failing-timeline | R13 | 3/3 |
| 02-proposal-no-bug:has-fixed-timeline | R14 | 3/3 |
| 02-proposal-no-bug:has-recommendation | R16 | 3/3 |
| 02-proposal-no-bug:has-what-changes | R15 | 3/3 |
| 02-proposal-no-bug:headers | R48 | 3/3 |
| 02-proposal-no-bug:names-self | R22 | 3/3 |
| 02-proposal-no-bug:no-alt-timeline | R30 | 3/3 |
| 02-proposal-no-bug:no-em-dash | R45 | 3/3 |
| 02-proposal-no-bug:no-flattery | R49 | 3/3 |
| 02-proposal-no-bug:no-paren-aside | R45 | 2/3 |
| 02-proposal-no-bug:section-order | R10 | 3/3 |
| 02-proposal-no-bug:sections-labeled | R47 | 3/3 |
| 02-proposal-no-bug:sentence-length | R44 | 3/3 |
| 02-proposal-no-bug:step-sentences | R23 | 2/3 |
| 02-proposal-no-bug:timeline-bounds | R24 | 3/3 |
| 03-walkthrough:bold-leadins | R46 | 3/3 |
| 03-walkthrough:close-last | R17 | 3/3 |
| 03-walkthrough:conclusion-first | R11 | 3/3 |
| 03-walkthrough:headers | R48 | 3/3 |
| 03-walkthrough:no-em-dash | R45 | 3/3 |
| 03-walkthrough:no-fix-sections | R19 | 3/3 |
| 03-walkthrough:no-flattery | R49 | 3/3 |
| 03-walkthrough:no-paren-aside | R45 | 3/3 |
| 03-walkthrough:no-question | R41 | 3/3 |
| 03-walkthrough:section-order | R10 | 3/3 |
| 03-walkthrough:sections-labeled | R47 | 3/3 |
| 03-walkthrough:sentence-length | R44 | 3/3 |
| 03-walkthrough:single-timeline | R19 | 3/3 |
| 03-walkthrough:step-sentences | R23 | 0/3 |
| 03-walkthrough:timeline-bounds | R24 | 3/3 |
| 04-uncertain:bold-leadins | R46 | 1/3 |
| 04-uncertain:close-last | R17 | 3/3 |
| 04-uncertain:conclusion-first | R11 | 2/3 |
| 04-uncertain:has-failing-timeline | R13 | 3/3 |
| 04-uncertain:headers | R48 | 3/3 |
| 04-uncertain:no-em-dash | R45 | 3/3 |
| 04-uncertain:no-fixed-timeline | R20 | 1/3 |
| 04-uncertain:no-flattery | R49 | 3/3 |
| 04-uncertain:no-paren-aside | R45 | 2/3 |
| 04-uncertain:section-order | R10 | 3/3 |
| 04-uncertain:sections-labeled | R47 | 3/3 |
| 04-uncertain:sentence-length | R44 | 3/3 |
| 04-uncertain:step-sentences | R23 | 0/3 |
| 04-uncertain:timeline-bounds | R24 | 2/3 |
| 05-branch:bold-leadins | R46 | 0/3 |
| 05-branch:close-last | R17 | 3/3 |
| 05-branch:conclusion-first | R11 | 3/3 |
| 05-branch:fixed-starts-at-divergence | R25 | 1/3 |
| 05-branch:headers | R48 | 3/3 |
| 05-branch:names-self | R22 | 3/3 |
| 05-branch:no-em-dash | R45 | 3/3 |
| 05-branch:no-flattery | R49 | 3/3 |
| 05-branch:no-paren-aside | R45 | 0/3 |
| 05-branch:section-order | R10 | 3/3 |
| 05-branch:sections-labeled | R47 | 1/3 |
| 05-branch:sentence-length | R44 | 3/3 |
| 05-branch:step-sentences | R23 | 3/3 |
| 05-branch:timeline-bounds | R24 | 2/3 |
| 05-branch:two-failing-timelines | R29 | 1/3 |
| 05-branch:two-fixed-timelines | R29 | 1/3 |
| 06-restatement:bold-leadins | R46 | 0/3 |
| 06-restatement:close-last | R17 | 3/3 |
| 06-restatement:headers | R48 | 3/3 |
| 06-restatement:list-covers-parts | R04 | 3/3 |
| 06-restatement:no-em-dash | R45 | 3/3 |
| 06-restatement:no-flattery | R49 | 3/3 |
| 06-restatement:no-paren-aside | R45 | 3/3 |
| 06-restatement:opens-with-list | R04 | 3/3 |
| 06-restatement:sentence-length | R44 | 3/3 |
| 07-ruling-ack:bold-leadins | R46 | 0/3 |
| 07-ruling-ack:close-last | R17 | 3/3 |
| 07-ruling-ack:close-one-question | R40 | 3/3 |
| 07-ruling-ack:headers | R48 | 3/3 |
| 07-ruling-ack:no-em-dash | R45 | 3/3 |
| 07-ruling-ack:no-flattery | R49 | 3/3 |
| 07-ruling-ack:no-paren-aside | R45 | 3/3 |
| 07-ruling-ack:ruling-first | R07 | 3/3 |
| 07-ruling-ack:sentence-length | R44 | 3/3 |
| 07-ruling-ack:timeline-bounds | R24 | 3/3 |
| 08-ruling-last:bold-leadins | R46 | 0/3 |
| 08-ruling-last:headers | R48 | 3/3 |
| 08-ruling-last:no-em-dash | R45 | 3/3 |
| 08-ruling-last:no-flattery | R49 | 3/3 |
| 08-ruling-last:no-paren-aside | R45 | 2/3 |
| 08-ruling-last:no-question | R41 | 3/3 |
| 08-ruling-last:ruling-first | R07 | 3/3 |
| 08-ruling-last:sentence-length | R44 | 3/3 |
| 08-ruling-last:short | R09 | 1/3 |
| 09-review:format | R43 | 3/3 |
| 09-review:no-em-dash | R45 | 3/3 |
| 09-review:no-flattery | R49 | 3/3 |
| 09-review:status-open | R43 | 3/3 |
| 10-negative-factual:correct | R02 | 3/3 |
| 10-negative-factual:no-template | R02 | 3/3 |
| 10-negative-factual:short | R02 | 3/3 |
| 11-selfdebate-source:bold-leadins | R46 | 1/3 |
| 11-selfdebate-source:change-bullets | R46 | 3/3 |
| 11-selfdebate-source:close-last | R17 | 3/3 |
| 11-selfdebate-source:conclusion-first | R11 | 2/3 |
| 11-selfdebate-source:fixed-starts-at-divergence | R25 | 3/3 |
| 11-selfdebate-source:found-crontab | R34 | 3/3 |
| 11-selfdebate-source:has-failing-timeline | R13 | 3/3 |
| 11-selfdebate-source:has-fixed-timeline | R14 | 3/3 |
| 11-selfdebate-source:has-recommendation | R16 | 3/3 |
| 11-selfdebate-source:has-what-changes | R15 | 3/3 |
| 11-selfdebate-source:headers | R48 | 3/3 |
| 11-selfdebate-source:names-self | R22 | 3/3 |
| 11-selfdebate-source:no-alt-timeline | R30 | 3/3 |
| 11-selfdebate-source:no-em-dash | R45 | 3/3 |
| 11-selfdebate-source:no-flattery | R49 | 3/3 |
| 11-selfdebate-source:no-paren-aside | R45 | 3/3 |
| 11-selfdebate-source:no-pr-deferral | R34 | 3/3 |
| 11-selfdebate-source:section-order | R10 | 3/3 |
| 11-selfdebate-source:sections-labeled | R47 | 3/3 |
| 11-selfdebate-source:sentence-length | R44 | 3/3 |
| 11-selfdebate-source:step-sentences | R23 | 2/3 |
| 11-selfdebate-source:timeline-bounds | R24 | 2/3 |
| 12-selfdebate-allowlist:bold-leadins | R46 | 3/3 |
| 12-selfdebate-allowlist:change-bullets | R46 | 3/3 |
| 12-selfdebate-allowlist:close-last | R17 | 3/3 |
| 12-selfdebate-allowlist:conclusion-first | R11 | 3/3 |
| 12-selfdebate-allowlist:fixed-starts-at-divergence | R25 | 3/3 |
| 12-selfdebate-allowlist:found-proxy | R34 | 3/3 |
| 12-selfdebate-allowlist:has-failing-timeline | R13 | 3/3 |
| 12-selfdebate-allowlist:has-fixed-timeline | R14 | 3/3 |
| 12-selfdebate-allowlist:has-recommendation | R16 | 3/3 |
| 12-selfdebate-allowlist:has-what-changes | R15 | 3/3 |
| 12-selfdebate-allowlist:headers | R48 | 3/3 |
| 12-selfdebate-allowlist:names-self | R22 | 3/3 |
| 12-selfdebate-allowlist:no-alt-timeline | R30 | 3/3 |
| 12-selfdebate-allowlist:no-em-dash | R45 | 3/3 |
| 12-selfdebate-allowlist:no-flattery | R49 | 3/3 |
| 12-selfdebate-allowlist:no-paren-aside | R45 | 2/3 |
| 12-selfdebate-allowlist:no-pr-deferral | R34 | 3/3 |
| 12-selfdebate-allowlist:section-order | R10 | 3/3 |
| 12-selfdebate-allowlist:sections-labeled | R47 | 3/3 |
| 12-selfdebate-allowlist:sentence-length | R44 | 3/3 |
| 12-selfdebate-allowlist:step-sentences | R23 | 3/3 |
| 12-selfdebate-allowlist:timeline-bounds | R24 | 1/3 |
| 13-selfdebate-removal:bold-leadins | R46 | 3/3 |
| 13-selfdebate-removal:close-last | R17 | 3/3 |
| 13-selfdebate-removal:conclusion-first | R11 | 2/3 |
| 13-selfdebate-removal:found-view | R34 | 3/3 |
| 13-selfdebate-removal:has-failing-timeline | R13 | 3/3 |
| 13-selfdebate-removal:headers | R48 | 3/3 |
| 13-selfdebate-removal:names-self | R22 | 3/3 |
| 13-selfdebate-removal:no-em-dash | R45 | 3/3 |
| 13-selfdebate-removal:no-flattery | R49 | 3/3 |
| 13-selfdebate-removal:no-paren-aside | R45 | 3/3 |
| 13-selfdebate-removal:no-pr-deferral | R34 | 3/3 |
| 13-selfdebate-removal:section-order | R10 | 3/3 |
| 13-selfdebate-removal:sections-labeled | R47 | 3/3 |
| 13-selfdebate-removal:sentence-length | R44 | 3/3 |
| 13-selfdebate-removal:step-sentences | R23 | 1/3 |
| 13-selfdebate-removal:timeline-bounds | R24 | 3/3 |
| 14-forbid-config:bold-leadins | R46 | 3/3 |
| 14-forbid-config:change-bullets | R46 | 3/3 |
| 14-forbid-config:close-last | R17 | 3/3 |
| 14-forbid-config:conclusion-first | R11 | 3/3 |
| 14-forbid-config:fixed-starts-at-divergence | R25 | 3/3 |
| 14-forbid-config:has-failing-timeline | R13 | 3/3 |
| 14-forbid-config:has-fixed-timeline | R14 | 3/3 |
| 14-forbid-config:has-recommendation | R16 | 3/3 |
| 14-forbid-config:has-what-changes | R15 | 3/3 |
| 14-forbid-config:headers | R48 | 3/3 |
| 14-forbid-config:names-self | R22 | 3/3 |
| 14-forbid-config:no-alt-timeline | R30 | 3/3 |
| 14-forbid-config:no-em-dash | R45 | 3/3 |
| 14-forbid-config:no-flattery | R49 | 3/3 |
| 14-forbid-config:no-paren-aside | R45 | 2/3 |
| 14-forbid-config:section-order | R10 | 3/3 |
| 14-forbid-config:sections-labeled | R47 | 3/3 |
| 14-forbid-config:sentence-length | R44 | 3/3 |
| 14-forbid-config:step-sentences | R23 | 3/3 |
| 14-forbid-config:timeline-bounds | R24 | 3/3 |
| 15-swap-stream:bold-leadins | R46 | 2/3 |
| 15-swap-stream:change-bullets | R46 | 3/3 |
| 15-swap-stream:close-last | R17 | 3/3 |
| 15-swap-stream:conclusion-first | R11 | 3/3 |
| 15-swap-stream:fixed-starts-at-divergence | R25 | 3/3 |
| 15-swap-stream:has-failing-timeline | R13 | 3/3 |
| 15-swap-stream:has-fixed-timeline | R14 | 3/3 |
| 15-swap-stream:has-recommendation | R16 | 3/3 |
| 15-swap-stream:has-what-changes | R15 | 3/3 |
| 15-swap-stream:headers | R48 | 3/3 |
| 15-swap-stream:names-self | R22 | 3/3 |
| 15-swap-stream:no-alt-timeline | R30 | 3/3 |
| 15-swap-stream:no-em-dash | R45 | 3/3 |
| 15-swap-stream:no-flattery | R49 | 3/3 |
| 15-swap-stream:no-paren-aside | R45 | 2/3 |
| 15-swap-stream:section-order | R10 | 3/3 |
| 15-swap-stream:sections-labeled | R47 | 3/3 |
| 15-swap-stream:sentence-length | R44 | 3/3 |
| 15-swap-stream:step-sentences | R23 | 1/3 |
| 15-swap-stream:timeline-bounds | R24 | 3/3 |
| 16-swap-async:bold-leadins | R46 | 3/3 |
| 16-swap-async:change-bullets | R46 | 3/3 |
| 16-swap-async:close-last | R17 | 3/3 |
| 16-swap-async:conclusion-first | R11 | 3/3 |
| 16-swap-async:fixed-starts-at-divergence | R25 | 3/3 |
| 16-swap-async:has-failing-timeline | R13 | 3/3 |
| 16-swap-async:has-fixed-timeline | R14 | 3/3 |
| 16-swap-async:has-recommendation | R16 | 3/3 |
| 16-swap-async:has-what-changes | R15 | 3/3 |
| 16-swap-async:headers | R48 | 3/3 |
| 16-swap-async:names-self | R22 | 3/3 |
| 16-swap-async:no-alt-timeline | R30 | 3/3 |
| 16-swap-async:no-em-dash | R45 | 3/3 |
| 16-swap-async:no-flattery | R49 | 3/3 |
| 16-swap-async:no-paren-aside | R45 | 2/3 |
| 16-swap-async:section-order | R10 | 2/3 |
| 16-swap-async:sections-labeled | R47 | 3/3 |
| 16-swap-async:sentence-length | R44 | 3/3 |
| 16-swap-async:step-sentences | R23 | 3/3 |
| 16-swap-async:timeline-bounds | R24 | 3/3 |
