# Coverage of the outcome measures

Each case lists its measures in `key.json`. A measure that is not listed does not apply to that case and does not count.

| Measure | Name | How it is graded | Cases |
| --- | --- | --- | --- |
| M1 | Right decision | Grader, against `correct_recommendations` and `invalid_options` | 01-bug-fix, 02-proposal-no-bug, 04-uncertain, 05-branch, 07-ruling-ack, 09-review, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| M2 | True facts | Grader, against `dependent_facts` | 01-bug-fix, 02-proposal-no-bug, 03-walkthrough, 04-uncertain, 05-branch, 06-restatement, 07-ruling-ack, 09-review, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| M3 | No follow-up | Grader, against `required_questions` and the reader follow-up questions | 01-bug-fix, 02-proposal-no-bug, 03-walkthrough, 04-uncertain, 05-branch, 06-restatement, 07-ruling-ack, 08-ruling-last, 09-review, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| M4 | Understanding | Grader, reader reconstruction against `understanding` | 01-bug-fix, 02-proposal-no-bug, 03-walkthrough, 04-uncertain, 05-branch, 06-restatement, 07-ruling-ack, 09-review, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| M5 | Answerable close | Grader, against `closing_decision` and the reader closing answer. When `closing_decision` is `none`, a mechanical check for no question mark | 01-bug-fix, 02-proposal-no-bug, 03-walkthrough, 04-uncertain, 05-branch, 06-restatement, 07-ruling-ack, 08-ruling-last, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| M6 | Reading cost | Word count. Reported, not scored | all cases |
| M7 | Valid alternative | Grader, against `valid_alternatives` and `invalid_options` | 01-bug-fix, 02-proposal-no-bug, 04-uncertain, 05-branch, 07-ruling-ack, 11-selfdebate-source, 12-selfdebate-allowlist, 13-selfdebate-removal, 14-forbid-config, 15-swap-stream, 16-swap-async |
| MF | Factual answer | Mechanical: correct value, at most 80 words, no template | 10-negative-factual |

## Measures per case

| Case | Measures |
| --- | --- |
| 01-bug-fix | M1, M2, M3, M4, M5, M7 |
| 02-proposal-no-bug | M1, M2, M3, M4, M5, M7 |
| 03-walkthrough | M2, M3, M4, M5 |
| 04-uncertain | M1, M2, M3, M4, M5, M7 |
| 05-branch | M1, M2, M3, M4, M5, M7 |
| 06-restatement | M2, M3, M4, M5 |
| 07-ruling-ack | M1, M2, M3, M4, M5, M7 |
| 08-ruling-last | M3, M5 |
| 09-review | M1, M2, M3, M4 |
| 10-negative-factual | MF |
| 11-selfdebate-source | M1, M2, M3, M4, M5, M7 |
| 12-selfdebate-allowlist | M1, M2, M3, M4, M5, M7 |
| 13-selfdebate-removal | M1, M2, M3, M4, M5, M7 |
| 14-forbid-config | M1, M2, M3, M4, M5, M7 |
| 15-swap-stream | M1, M2, M3, M4, M5, M7 |
| 16-swap-async | M1, M2, M3, M4, M5, M7 |

## Self-debate failures

- Failure 1, the fix sits at the source: `11-selfdebate-source`. M1 fails when the primary fix is a dedupe or an index instead of the crontab removal.
- Failure 2, a denylist instead of an allowlist: `12-selfdebate-allowlist`. M1 needs the allowlist. M2 needs the plugin variables from the plugin code. M7 fails when the longer denylist appears as an alternative.
- Failure 3, a removal without the mechanism: `13-selfdebate-removal`. M2 and M3 need the view `v_partner_feed` and the reason for the column, both read from the fixture.
- Swap pair: `15-swap-stream` and `16-swap-async`. Both have the same two correct fixes. The key reverses the primary, and M7 requires the other fix as an alternative.

## Diagnostic rule checks

Mechanical rule checks from `common_checks.json` and each `checks.json` run as a diagnostic layer. They map to the rule ids in `rules.json`. They do not count toward the score.

## Holdout cases

Each holdout case stresses the measure in its id. It still scores every measure in its `key.json`.

| Case | Measures |
| --- | --- |
| h01-m1-backoff | M1, M2, M3, M4, M5, M7 |
| h02-m1-stale-price | M1, M2, M3, M4, M5, M7 |
| h03-m2-drain-ack | M1, M2, M3, M4, M5, M7 |
| h04-m2-dst-renewal | M1, M2, M3, M4, M5, M7 |
| h05-m3-redelivery | M1, M2, M3, M4, M5, M7 |
| h06-m3-replica | M1, M2, M3, M4, M5, M7 |
| h07-m4-pool-deadlock | M1, M2, M3, M4, M5, M7 |
| h08-m4-retry-storm | M1, M2, M3, M4, M5, M7 |
| h09-m5-ruling-window | M1, M2, M3, M4, M5, M7 |
| h10-m5-restatement-none | M2, M3, M4, M5 |
| h11-m7-upload-limit | M1, M2, M3, M4, M5, M7 |
| h12-m7-revoke-sessions | M1, M2, M3, M4, M5, M7 |
| h13-mf-replicas | MF |
| h14-mf-node-version | MF |
