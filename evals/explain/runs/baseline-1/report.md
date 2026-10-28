# /explain eval report

- Skill: `skills/explain/SKILL.md`
- Skill line count: 192
- Repeats: 3
- Total score: 213/243 = 0.877
- Score per repeat: r1 0.901, r2 0.852, r3 0.877
- M6 reading cost: mean 393 words per message
- Generation errors: 0
- Cost: generation 1.70 USD, reader 1.01 USD, grading 1.49 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Right decision | 36/36 | 1.000 |
| M2 | True facts | 35/42 | 0.833 |
| M3 | No follow-up | 34/45 | 0.756 |
| M4 | Understanding | 39/42 | 0.929 |
| M5 | Answerable close | 39/42 | 0.929 |
| M7 | Valid alternative | 27/33 | 0.818 |
| MF | Factual answer | 3/3 | 1.000 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| 01-bug-fix | 0.889 | 470 |
| 02-proposal-no-bug | 0.833 | 455 |
| 03-walkthrough | 0.917 | 265 |
| 04-uncertain | 0.389 | 468 |
| 05-branch | 1.000 | 572 |
| 06-restatement | 0.833 | 154 |
| 07-ruling-ack | 1.000 | 407 |
| 08-ruling-last | 1.000 | 150 |
| 09-review | 0.833 | 652 |
| 10-negative-factual | 1.000 | 41 |
| 11-selfdebate-source | 1.000 | 445 |
| 12-selfdebate-allowlist | 0.778 | 424 |
| 13-selfdebate-removal | 0.944 | 398 |
| 14-forbid-config | 1.000 | 384 |
| 15-swap-stream | 0.833 | 495 |
| 16-swap-async | 0.944 | 517 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| 01-bug-fix:M1 | 3/3 | non-discriminating |
| 01-bug-fix:M2 | 3/3 | non-discriminating |
| 01-bug-fix:M3 | 2/3 | non-discriminating |
| 01-bug-fix:M4 | 3/3 | non-discriminating |
| 01-bug-fix:M5 | 3/3 |  |
| 01-bug-fix:M7 | 2/3 |  |
| 02-proposal-no-bug:M1 | 3/3 | non-discriminating |
| 02-proposal-no-bug:M2 | 1/3 |  |
| 02-proposal-no-bug:M3 | 2/3 |  |
| 02-proposal-no-bug:M4 | 3/3 |  |
| 02-proposal-no-bug:M5 | 3/3 |  |
| 02-proposal-no-bug:M7 | 3/3 | non-discriminating |
| 03-walkthrough:M2 | 3/3 | non-discriminating |
| 03-walkthrough:M3 | 2/3 |  |
| 03-walkthrough:M4 | 3/3 | non-discriminating |
| 03-walkthrough:M5 | 3/3 | non-discriminating |
| 04-uncertain:M1 | 3/3 |  |
| 04-uncertain:M2 | 1/3 |  |
| 04-uncertain:M3 | 1/3 |  |
| 04-uncertain:M4 | 1/3 |  |
| 04-uncertain:M5 | 0/3 |  |
| 04-uncertain:M7 | 1/3 | non-discriminating |
| 05-branch:M1 | 3/3 | non-discriminating |
| 05-branch:M2 | 3/3 |  |
| 05-branch:M3 | 3/3 | non-discriminating |
| 05-branch:M4 | 3/3 |  |
| 05-branch:M5 | 3/3 |  |
| 05-branch:M7 | 3/3 | non-discriminating |
| 06-restatement:M2 | 2/3 |  |
| 06-restatement:M3 | 2/3 |  |
| 06-restatement:M4 | 3/3 |  |
| 06-restatement:M5 | 3/3 |  |
| 07-ruling-ack:M1 | 3/3 |  |
| 07-ruling-ack:M2 | 3/3 |  |
| 07-ruling-ack:M3 | 3/3 |  |
| 07-ruling-ack:M4 | 3/3 |  |
| 07-ruling-ack:M5 | 3/3 |  |
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
| 12-selfdebate-allowlist:M2 | 2/3 |  |
| 12-selfdebate-allowlist:M3 | 3/3 |  |
| 12-selfdebate-allowlist:M4 | 3/3 |  |
| 12-selfdebate-allowlist:M5 | 3/3 |  |
| 12-selfdebate-allowlist:M7 | 0/3 | non-discriminating |
| 13-selfdebate-removal:M1 | 3/3 | non-discriminating |
| 13-selfdebate-removal:M2 | 2/3 |  |
| 13-selfdebate-removal:M3 | 3/3 |  |
| 13-selfdebate-removal:M4 | 3/3 |  |
| 13-selfdebate-removal:M5 | 3/3 |  |
| 13-selfdebate-removal:M7 | 3/3 |  |
| 14-forbid-config:M1 | 3/3 | non-discriminating |
| 14-forbid-config:M2 | 3/3 | non-discriminating |
| 14-forbid-config:M3 | 3/3 |  |
| 14-forbid-config:M4 | 3/3 | non-discriminating |
| 14-forbid-config:M5 | 3/3 |  |
| 14-forbid-config:M7 | 3/3 |  |
| 15-swap-stream:M1 | 3/3 | non-discriminating |
| 15-swap-stream:M2 | 3/3 |  |
| 15-swap-stream:M3 | 0/3 |  |
| 15-swap-stream:M4 | 3/3 | non-discriminating |
| 15-swap-stream:M5 | 3/3 |  |
| 15-swap-stream:M7 | 3/3 |  |
| 16-swap-async:M1 | 3/3 | non-discriminating |
| 16-swap-async:M2 | 3/3 | non-discriminating |
| 16-swap-async:M3 | 2/3 | non-discriminating |
| 16-swap-async:M4 | 3/3 | non-discriminating |
| 16-swap-async:M5 | 3/3 |  |
| 16-swap-async:M7 | 3/3 |  |

## Failed measures

- 01-bug-fix r2 M3: Reader follow-up: "Must exports stay correct while orders are being created mid-export?" The ticket says no orders were created, but the message never states it. Ulrich needs that to rule.
- 01-bug-fix r2 M7: "Alternative: unique timestamps in the import." This is in invalid_options (distinct created_at without a tie-breaker), so it is an invalid listed alternative.
- 02-proposal-no-bug r1 M3: Reader: "Does the repository have a lockfile that `cache: pnpm` can key on?" The message says "I found no lockfile" and leaves it open. The ruling depends on it.
- 02-proposal-no-bug r2 M2: "**Unverified.** The 35 s figure comes from 20 manual runs with a warm store." The key says this fact is verifiable, so naming it unverified fails.
- 02-proposal-no-bug r3 M2: "It may not include the cache download of the 1.1 GB store. Treat 8 min as the upper bound until the first real runs report." The 35 s fact is verifiable true, but the message casts doubt on it and defers it.
- 03-walkthrough r1 M3: Reader follow-up: "Where is the CLI entry point that maps `mintctl deploy staging` to `deploy("staging")`" – the message hedges the core link, so Ulrich can't rule. Also the third question (how Ines knows it worked) is not stated explicitly.
- 04-uncertain r1 M5: The message ends: "Next step: read the cached flag value... After that, I can propose the exact migration fix and a restore query." That is a statement, not a question.
- 04-uncertain r2 M2: "For `northwind` the cached value is on" and "Only `northwind` had it on." The key says hide_archived for northwind is unknown, but the message states it as fact.
- 04-uncertain r2 M3: The message never says the northwind hide_archived value is unknown or what settles it. Its answer to "What is unknown and what settles it?" is missing; it says the flag value is known.
- 04-uncertain r2 M4: Reader: "report-builder then used a 3-day-old cached hide_archived flag, which was on for northwind." The key says the value is unknown and the fix waits on it.
- 04-uncertain r2 M5: "Should I draft the corrected migration and the restore statement, or only the flag change for `northwind`?" The closing_decision is to get the hide_archived evidence or decide on the restore; the flag change is not part of it.
- 04-uncertain r2 M7: "Alternative: turn off `hide_archived` for `northwind`." This is not a valid_alternatives entry, and it masks the data problem instead of correcting the data.
- 04-uncertain r3 M2: "because `hide_archived` was on for that tenant" and "The flag was on for `northwind` only."
- 04-uncertain r3 M3: Reader follow-up: "Does a pre-migration snapshot or backup of the invoices table exist, or do updated_at values show which rows 0042 changed?"
- 04-uncertain r3 M4: Reader fix: "Two options... Aelita prefers this first"; reader decision: "Change only `report-builder` now"
- 04-uncertain r3 M5: "Should I draft a corrective migration that restores the wrongly archived invoices, which needs a snapshot you can point me to, or only change `report-builder`?"
- 04-uncertain r3 M7: "Alternative: change only `report-builder`. Stop filtering archived invoices in monthly reports"
- 06-restatement r3 M2: "Every 10 minutes: unverified." The key says the schedule is verifiable in config/prod.yaml (every 10 minutes), so calling it unverified fails.
- 06-restatement r3 M3: "Every 10 minutes: unverified... I withdraw it as a fact." The expected answer to the schedule question is "Yes", so the first required question is unanswered correctly.
- 09-review r1 M3: Message marks S1-S3 'action:YES' and B2/B3 as blockers; it never separates suggestions clearly from required changes; compare_digest, logging, dead code, header parsing are listed as YES actions, and the closing question only asks approval of B1 first, not whether merge is blocked.
- 09-review r2 M4: Reader fix: "Call `verify(header, payload)` first... Only after that parse". The reader's breaks and fix omit the retry that credits twice and the dedupe on event id, which the key requires.
- 12-selfdebate-allowlist r1 M2: "PATH, which I added for subprocess lookups. No plugin I found needs it." Key: pdf-stamp needs PATH to run qpdf, so this contradicts it.
- 12-selfdebate-allowlist r1 M7: "Alternative: extend the denylist as you planned. Add STRIPE_API_KEY and SENTRY_DSN to DENYLIST." This is listed in invalid_options.
- 12-selfdebate-allowlist r2 M7: "Alternative: your denylist edit plus `BILLING_WEBHOOK_SECRET`." This is a denylist extension, in invalid_options, not the valid per-plugin declared environment.
- 12-selfdebate-allowlist r3 M7: "Alternative: extend the denylist as you planned. Add `STRIPE_API_KEY` and `SENTRY_DSN`." This is in invalid_options and does not produce the correct result.
- 13-selfdebate-removal r2 M2: "If Oakline Supply still depends on the codes, the drop breaks their ingest." The key settles that Oakline keys on the code, but the message leaves it to be confirmed.
- 15-swap-stream r1 M3: "Two things can break it" lists only Response support and the 120 s timeout. It never mentions that a stream error mid-file leaves a partial download.
- 15-swap-stream r2 M3: The "what can break" answer covers the 120 s timeout but never mentions that a stream error mid-file leaves a partial download.
- 15-swap-stream r3 M3: The "what can break" answer covers the 120 s gunicorn limit but never says a stream error mid-file leaves a partial download.
- 16-swap-async r1 M3: "What can break?" expects mail delays, link expiry and documents queue load. The message names only request email and `storage.put`; reader lists them as follow-ups.

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.924

| Check | Rule | Passed |
| --- | --- | --- |
| 01-bug-fix:bold-leadins | R46 | 2/3 |
| 01-bug-fix:change-bullets | R46 | 3/3 |
| 01-bug-fix:close-last | R17 | 3/3 |
| 01-bug-fix:conclusion-first | R11 | 2/3 |
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
| 01-bug-fix:step-sentences | R23 | 1/3 |
| 01-bug-fix:timeline-bounds | R24 | 2/3 |
| 02-proposal-no-bug:bold-leadins | R46 | 3/3 |
| 02-proposal-no-bug:change-bullets | R46 | 3/3 |
| 02-proposal-no-bug:close-last | R17 | 3/3 |
| 02-proposal-no-bug:conclusion-first | R11 | 2/3 |
| 02-proposal-no-bug:fixed-starts-at-divergence | R25 | 3/3 |
| 02-proposal-no-bug:has-failing-timeline | R13 | 3/3 |
| 02-proposal-no-bug:has-fixed-timeline | R14 | 2/3 |
| 02-proposal-no-bug:has-recommendation | R16 | 3/3 |
| 02-proposal-no-bug:has-what-changes | R15 | 3/3 |
| 02-proposal-no-bug:headers | R48 | 3/3 |
| 02-proposal-no-bug:names-self | R22 | 3/3 |
| 02-proposal-no-bug:no-alt-timeline | R30 | 3/3 |
| 02-proposal-no-bug:no-em-dash | R45 | 3/3 |
| 02-proposal-no-bug:no-flattery | R49 | 3/3 |
| 02-proposal-no-bug:no-paren-aside | R45 | 3/3 |
| 02-proposal-no-bug:section-order | R10 | 3/3 |
| 02-proposal-no-bug:sections-labeled | R47 | 3/3 |
| 02-proposal-no-bug:sentence-length | R44 | 3/3 |
| 02-proposal-no-bug:step-sentences | R23 | 1/3 |
| 02-proposal-no-bug:timeline-bounds | R24 | 3/3 |
| 03-walkthrough:bold-leadins | R46 | 2/3 |
| 03-walkthrough:close-last | R17 | 2/3 |
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
| 04-uncertain:bold-leadins | R46 | 3/3 |
| 04-uncertain:close-last | R17 | 3/3 |
| 04-uncertain:conclusion-first | R11 | 3/3 |
| 04-uncertain:has-failing-timeline | R13 | 3/3 |
| 04-uncertain:headers | R48 | 3/3 |
| 04-uncertain:no-em-dash | R45 | 3/3 |
| 04-uncertain:no-fixed-timeline | R20 | 2/3 |
| 04-uncertain:no-flattery | R49 | 3/3 |
| 04-uncertain:no-paren-aside | R45 | 1/3 |
| 04-uncertain:section-order | R10 | 3/3 |
| 04-uncertain:sections-labeled | R47 | 3/3 |
| 04-uncertain:sentence-length | R44 | 3/3 |
| 04-uncertain:step-sentences | R23 | 1/3 |
| 04-uncertain:timeline-bounds | R24 | 2/3 |
| 05-branch:bold-leadins | R46 | 2/3 |
| 05-branch:close-last | R17 | 3/3 |
| 05-branch:conclusion-first | R11 | 3/3 |
| 05-branch:fixed-starts-at-divergence | R25 | 3/3 |
| 05-branch:headers | R48 | 3/3 |
| 05-branch:names-self | R22 | 3/3 |
| 05-branch:no-em-dash | R45 | 3/3 |
| 05-branch:no-flattery | R49 | 3/3 |
| 05-branch:no-paren-aside | R45 | 3/3 |
| 05-branch:section-order | R10 | 3/3 |
| 05-branch:sections-labeled | R47 | 3/3 |
| 05-branch:sentence-length | R44 | 3/3 |
| 05-branch:step-sentences | R23 | 2/3 |
| 05-branch:timeline-bounds | R24 | 3/3 |
| 05-branch:two-failing-timelines | R29 | 0/3 |
| 05-branch:two-fixed-timelines | R29 | 1/3 |
| 06-restatement:bold-leadins | R46 | 1/3 |
| 06-restatement:close-last | R17 | 3/3 |
| 06-restatement:headers | R48 | 3/3 |
| 06-restatement:list-covers-parts | R04 | 3/3 |
| 06-restatement:no-em-dash | R45 | 3/3 |
| 06-restatement:no-flattery | R49 | 3/3 |
| 06-restatement:no-paren-aside | R45 | 3/3 |
| 06-restatement:opens-with-list | R04 | 3/3 |
| 06-restatement:sentence-length | R44 | 3/3 |
| 07-ruling-ack:bold-leadins | R46 | 1/3 |
| 07-ruling-ack:close-last | R17 | 3/3 |
| 07-ruling-ack:close-one-question | R40 | 3/3 |
| 07-ruling-ack:headers | R48 | 3/3 |
| 07-ruling-ack:no-em-dash | R45 | 3/3 |
| 07-ruling-ack:no-flattery | R49 | 3/3 |
| 07-ruling-ack:no-paren-aside | R45 | 3/3 |
| 07-ruling-ack:ruling-first | R07 | 3/3 |
| 07-ruling-ack:sentence-length | R44 | 3/3 |
| 07-ruling-ack:timeline-bounds | R24 | 3/3 |
| 08-ruling-last:bold-leadins | R46 | 2/3 |
| 08-ruling-last:headers | R48 | 3/3 |
| 08-ruling-last:no-em-dash | R45 | 3/3 |
| 08-ruling-last:no-flattery | R49 | 3/3 |
| 08-ruling-last:no-paren-aside | R45 | 3/3 |
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
| 11-selfdebate-source:bold-leadins | R46 | 3/3 |
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
| 11-selfdebate-source:no-paren-aside | R45 | 2/3 |
| 11-selfdebate-source:no-pr-deferral | R34 | 3/3 |
| 11-selfdebate-source:section-order | R10 | 3/3 |
| 11-selfdebate-source:sections-labeled | R47 | 3/3 |
| 11-selfdebate-source:sentence-length | R44 | 3/3 |
| 11-selfdebate-source:step-sentences | R23 | 3/3 |
| 11-selfdebate-source:timeline-bounds | R24 | 2/3 |
| 12-selfdebate-allowlist:bold-leadins | R46 | 0/3 |
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
| 12-selfdebate-allowlist:step-sentences | R23 | 2/3 |
| 12-selfdebate-allowlist:timeline-bounds | R24 | 1/3 |
| 13-selfdebate-removal:bold-leadins | R46 | 2/3 |
| 13-selfdebate-removal:close-last | R17 | 3/3 |
| 13-selfdebate-removal:conclusion-first | R11 | 3/3 |
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
| 14-forbid-config:bold-leadins | R46 | 2/3 |
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
| 14-forbid-config:no-paren-aside | R45 | 3/3 |
| 14-forbid-config:section-order | R10 | 3/3 |
| 14-forbid-config:sections-labeled | R47 | 3/3 |
| 14-forbid-config:sentence-length | R44 | 3/3 |
| 14-forbid-config:step-sentences | R23 | 2/3 |
| 14-forbid-config:timeline-bounds | R24 | 3/3 |
| 15-swap-stream:bold-leadins | R46 | 1/3 |
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
| 15-swap-stream:step-sentences | R23 | 3/3 |
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
| 16-swap-async:no-paren-aside | R45 | 3/3 |
| 16-swap-async:section-order | R10 | 3/3 |
| 16-swap-async:sections-labeled | R47 | 3/3 |
| 16-swap-async:sentence-length | R44 | 3/3 |
| 16-swap-async:step-sentences | R23 | 1/3 |
| 16-swap-async:timeline-bounds | R24 | 3/3 |
