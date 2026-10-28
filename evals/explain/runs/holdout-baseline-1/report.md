# /explain eval report

- Skill: `skills/explain/SKILL.md`
- Skill line count: 192
- Repeats: 3
- Total score: 192/216 = 0.889
- Score per repeat: r1 0.875, r2 0.889, r3 0.903
- M6 reading cost: mean 419 words per message
- Generation errors: 0
- Cost: generation 1.84 USD, reader 0.91 USD, grading 1.37 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Right decision | 33/33 | 1.000 |
| M2 | True facts | 35/36 | 0.972 |
| M3 | No follow-up | 30/36 | 0.833 |
| M4 | Understanding | 33/36 | 0.917 |
| M5 | Answerable close | 35/36 | 0.972 |
| M7 | Valid alternative | 21/33 | 0.636 |
| MF | Factual answer | 5/6 | 0.833 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| h01-m1-backoff | 0.833 | 483 |
| h02-m1-stale-price | 1.000 | 516 |
| h03-m2-drain-ack | 1.000 | 521 |
| h04-m2-dst-renewal | 0.833 | 549 |
| h05-m3-redelivery | 0.778 | 493 |
| h06-m3-replica | 0.889 | 407 |
| h07-m4-pool-deadlock | 0.833 | 516 |
| h08-m4-retry-storm | 0.889 | 631 |
| h09-m5-ruling-window | 0.778 | 407 |
| h10-m5-restatement-none | 0.917 | 242 |
| h11-m7-upload-limit | 1.000 | 486 |
| h12-m7-revoke-sessions | 0.944 | 475 |
| h13-mf-replicas | 1.000 | 70 |
| h14-mf-node-version | 0.667 | 63 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| h01-m1-backoff:M1 | 3/3 |  |
| h01-m1-backoff:M2 | 3/3 |  |
| h01-m1-backoff:M3 | 3/3 |  |
| h01-m1-backoff:M4 | 3/3 |  |
| h01-m1-backoff:M5 | 3/3 |  |
| h01-m1-backoff:M7 | 0/3 | non-discriminating |
| h02-m1-stale-price:M1 | 3/3 | non-discriminating |
| h02-m1-stale-price:M2 | 3/3 |  |
| h02-m1-stale-price:M3 | 3/3 | non-discriminating |
| h02-m1-stale-price:M4 | 3/3 |  |
| h02-m1-stale-price:M5 | 3/3 |  |
| h02-m1-stale-price:M7 | 3/3 |  |
| h03-m2-drain-ack:M1 | 3/3 | non-discriminating |
| h03-m2-drain-ack:M2 | 3/3 |  |
| h03-m2-drain-ack:M3 | 3/3 |  |
| h03-m2-drain-ack:M4 | 3/3 | non-discriminating |
| h03-m2-drain-ack:M5 | 3/3 |  |
| h03-m2-drain-ack:M7 | 3/3 | non-discriminating |
| h04-m2-dst-renewal:M1 | 3/3 | non-discriminating |
| h04-m2-dst-renewal:M2 | 3/3 |  |
| h04-m2-dst-renewal:M3 | 2/3 |  |
| h04-m2-dst-renewal:M4 | 2/3 |  |
| h04-m2-dst-renewal:M5 | 3/3 |  |
| h04-m2-dst-renewal:M7 | 2/3 |  |
| h05-m3-redelivery:M1 | 3/3 | non-discriminating |
| h05-m3-redelivery:M2 | 3/3 | non-discriminating |
| h05-m3-redelivery:M3 | 1/3 | non-discriminating |
| h05-m3-redelivery:M4 | 3/3 | non-discriminating |
| h05-m3-redelivery:M5 | 3/3 |  |
| h05-m3-redelivery:M7 | 1/3 | non-discriminating |
| h06-m3-replica:M1 | 3/3 | non-discriminating |
| h06-m3-replica:M2 | 3/3 | non-discriminating |
| h06-m3-replica:M3 | 3/3 | non-discriminating |
| h06-m3-replica:M4 | 3/3 | non-discriminating |
| h06-m3-replica:M5 | 3/3 |  |
| h06-m3-replica:M7 | 1/3 | non-discriminating |
| h07-m4-pool-deadlock:M1 | 3/3 | non-discriminating |
| h07-m4-pool-deadlock:M2 | 3/3 | non-discriminating |
| h07-m4-pool-deadlock:M3 | 2/3 |  |
| h07-m4-pool-deadlock:M4 | 3/3 | non-discriminating |
| h07-m4-pool-deadlock:M5 | 3/3 |  |
| h07-m4-pool-deadlock:M7 | 1/3 |  |
| h08-m4-retry-storm:M1 | 3/3 | non-discriminating |
| h08-m4-retry-storm:M2 | 2/3 |  |
| h08-m4-retry-storm:M3 | 3/3 | non-discriminating |
| h08-m4-retry-storm:M4 | 3/3 |  |
| h08-m4-retry-storm:M5 | 3/3 |  |
| h08-m4-retry-storm:M7 | 2/3 |  |
| h09-m5-ruling-window:M1 | 3/3 | non-discriminating |
| h09-m5-ruling-window:M2 | 3/3 |  |
| h09-m5-ruling-window:M3 | 1/3 | non-discriminating |
| h09-m5-ruling-window:M4 | 1/3 | non-discriminating |
| h09-m5-ruling-window:M5 | 3/3 | non-discriminating |
| h09-m5-ruling-window:M7 | 3/3 | non-discriminating |
| h10-m5-restatement-none:M2 | 3/3 |  |
| h10-m5-restatement-none:M3 | 3/3 |  |
| h10-m5-restatement-none:M4 | 3/3 | non-discriminating |
| h10-m5-restatement-none:M5 | 2/3 | non-discriminating |
| h11-m7-upload-limit:M1 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M2 | 3/3 |  |
| h11-m7-upload-limit:M3 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M4 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M5 | 3/3 |  |
| h11-m7-upload-limit:M7 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M1 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M2 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M3 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M4 | 3/3 |  |
| h12-m7-revoke-sessions:M5 | 3/3 |  |
| h12-m7-revoke-sessions:M7 | 2/3 |  |
| h13-mf-replicas:MF | 3/3 | non-discriminating |
| h14-mf-node-version:MF | 2/3 | non-discriminating |

## Failed measures

- h01-m1-backoff r1 M7: "Alternative: enterprise tier." Buying the enterprise tier is in invalid_options, and the message itself says it "cannot meet the 30 October deadline". valid_alternatives is empty.
- h01-m1-backoff r2 M7: "Alternative: enterprise tier... Juniper quotes 3 weeks of lead time, so it misses Friday." valid_alternatives is empty and this option does not meet the deadline.
- h01-m1-backoff r3 M7: "Alternative: enterprise tier... It becomes the primary if `batchUpsert` proves unreliable." valid_alternatives is empty and the enterprise tier is in invalid_options, so this listed alternative fails.
- h04-m2-dst-renewal r1 M3: Refund question unanswered: "I will raise how to find the remaining customers next." No safe-refund approach is given.
- h04-m2-dst-renewal r1 M4: Reader fix: "Two guards" only, with no refund step. Reader cost omits the refund run needing the manual-refund list.
- h04-m2-dst-renewal r1 M7: Idempotency-key alternative states a trade-off but no condition that makes it the primary. It also says "I did not verify that Payrail supports one".
- h05-m3-redelivery r1 M7: "Alternative: keep `max_ack_pending: 1` and shorten the delays." This is not the valid per-device partition alternative, and it still blocks, so it does not produce the correct result.
- h05-m3-redelivery r2 M3: The message never says what stays: same delays, DLQ after the 6th delivery, explicit ack, and the history insert in one transaction with the upsert. It also omits that exhausted retries go to ingest.dlq and ack.
- h05-m3-redelivery r2 M7: "Alternative: keep `max_ack_pending: 1`." This is not the valid partitioned-consumer alternative, and the message admits it fails the stall goal, so it does not produce the correct result.
- h05-m3-redelivery r3 M3: The message never says the history insert shares a transaction with the upsert, or that explicit ack stays. The reader also lists an open follow-up: "Does any consumer of `readings` need rows written in strict arrival order?"
- h06-m3-replica r1 M7: "Alternative: skip record_run." This is not in valid_alternatives. It drops the report_runs audit row, so it does not produce the correct result.
- h06-m3-replica r3 M7: "Alternative: keep the job on the primary and tune the queries." This does not match either valid alternative (lower-traffic hour, or a separate wrapper step) and does not remove the load.
- h07-m4-pool-deadlock r1 M7: "Alternative: raise `max_size`." It is in invalid_options, and the message says it becomes primary if a hotfix is needed.
- h07-m4-pool-deadlock r2 M3: The message never addresses "Why not a bigger pool?" It does not say the deadlock returns once concurrent checkouts reach the new size.
- h07-m4-pool-deadlock r3 M7: "**Alternative: raise `max_size`.**" The message offers it as a fallback primary, but raising max_size is in invalid_options and does not fix the deadlock.
- h08-m4-retry-storm r2 M7: "Alternative: drop expired requests... needs a new header and changes in all three layers." It states a cost but no condition under which it would become the primary.
- h08-m4-retry-storm r3 M2: "At about 2,300/s of excess load, the queue should have grown far beyond 180,000. I cannot explain this from the files." The queue figure is verifiable, yet the message calls it unexplained.
- h09-m5-ruling-window r1 M3: The message never says the window is the last open item. It frames the cost as "a thin buffer" and never says reports are slow. First gap: "Is any item left after this one?"
- h09-m5-ruling-window r1 M4: Reader cost: "The buffer before the 12 November end of life is thin." The key cost is about 14 minutes of downtime and 38 minutes of slow reports in a weekend slot. Downtime is not in the reader's cost.
- h09-m5-ruling-window r2 M4: Reader cost: "A retry on Monday to Wednesday runs at about 130 writes per second." The key cost is about 14 min downtime and 38 min slow reports, or the weekend shift. The reader names neither.
- h09-m5-ruling-window r3 M3: The cost question is only half answered. The message gives downtime of about 14 min 10 s and analyze ending 02:55. It never says reports are slow during that time.
- h10-m5-restatement-none r2 M5: 1 question marks
- h12-m7-revoke-sessions r3 M7: "Alternative: rotate `SIGNING_KEY`." This option is in invalid_options. The message offers it as an alternative and gives no condition that makes it primary.
- h14-mf-node-version r2 MF: 22.11.0; 86 words; **Timeline**

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.911

| Check | Rule | Passed |
| --- | --- | --- |
| h01-m1-backoff:bold-leadins | R46 | 3/3 |
| h01-m1-backoff:change-bullets | R46 | 3/3 |
| h01-m1-backoff:close-last | R17 | 3/3 |
| h01-m1-backoff:conclusion-first | R11 | 3/3 |
| h01-m1-backoff:fixed-starts-at-divergence | R25 | 3/3 |
| h01-m1-backoff:has-failing-timeline | R13 | 3/3 |
| h01-m1-backoff:has-fixed-timeline | R14 | 2/3 |
| h01-m1-backoff:has-recommendation | R16 | 3/3 |
| h01-m1-backoff:has-what-changes | R15 | 3/3 |
| h01-m1-backoff:headers | R48 | 3/3 |
| h01-m1-backoff:names-self | R22 | 3/3 |
| h01-m1-backoff:no-alt-timeline | R30 | 3/3 |
| h01-m1-backoff:no-deferral | R34 | 3/3 |
| h01-m1-backoff:no-em-dash | R45 | 3/3 |
| h01-m1-backoff:no-flattery | R49 | 3/3 |
| h01-m1-backoff:no-paren-aside | R45 | 2/3 |
| h01-m1-backoff:section-order | R10 | 3/3 |
| h01-m1-backoff:sections-labeled | R47 | 3/3 |
| h01-m1-backoff:sentence-length | R44 | 3/3 |
| h01-m1-backoff:step-sentences | R23 | 1/3 |
| h01-m1-backoff:timeline-bounds | R24 | 3/3 |
| h02-m1-stale-price:bold-leadins | R46 | 3/3 |
| h02-m1-stale-price:change-bullets | R46 | 3/3 |
| h02-m1-stale-price:close-last | R17 | 3/3 |
| h02-m1-stale-price:conclusion-first | R11 | 3/3 |
| h02-m1-stale-price:fixed-starts-at-divergence | R25 | 3/3 |
| h02-m1-stale-price:has-failing-timeline | R13 | 3/3 |
| h02-m1-stale-price:has-fixed-timeline | R14 | 3/3 |
| h02-m1-stale-price:has-recommendation | R16 | 3/3 |
| h02-m1-stale-price:has-what-changes | R15 | 3/3 |
| h02-m1-stale-price:headers | R48 | 3/3 |
| h02-m1-stale-price:names-self | R22 | 3/3 |
| h02-m1-stale-price:no-alt-timeline | R30 | 3/3 |
| h02-m1-stale-price:no-deferral | R34 | 3/3 |
| h02-m1-stale-price:no-em-dash | R45 | 3/3 |
| h02-m1-stale-price:no-flattery | R49 | 3/3 |
| h02-m1-stale-price:no-paren-aside | R45 | 2/3 |
| h02-m1-stale-price:section-order | R10 | 3/3 |
| h02-m1-stale-price:sections-labeled | R47 | 3/3 |
| h02-m1-stale-price:sentence-length | R44 | 3/3 |
| h02-m1-stale-price:step-sentences | R23 | 0/3 |
| h02-m1-stale-price:timeline-bounds | R24 | 3/3 |
| h03-m2-drain-ack:bold-leadins | R46 | 3/3 |
| h03-m2-drain-ack:change-bullets | R46 | 3/3 |
| h03-m2-drain-ack:close-last | R17 | 3/3 |
| h03-m2-drain-ack:conclusion-first | R11 | 2/3 |
| h03-m2-drain-ack:fixed-starts-at-divergence | R25 | 3/3 |
| h03-m2-drain-ack:has-failing-timeline | R13 | 3/3 |
| h03-m2-drain-ack:has-fixed-timeline | R14 | 3/3 |
| h03-m2-drain-ack:has-recommendation | R16 | 3/3 |
| h03-m2-drain-ack:has-what-changes | R15 | 3/3 |
| h03-m2-drain-ack:headers | R48 | 3/3 |
| h03-m2-drain-ack:names-self | R22 | 3/3 |
| h03-m2-drain-ack:no-alt-timeline | R30 | 3/3 |
| h03-m2-drain-ack:no-deferral | R34 | 3/3 |
| h03-m2-drain-ack:no-em-dash | R45 | 3/3 |
| h03-m2-drain-ack:no-flattery | R49 | 3/3 |
| h03-m2-drain-ack:no-paren-aside | R45 | 1/3 |
| h03-m2-drain-ack:section-order | R10 | 3/3 |
| h03-m2-drain-ack:sections-labeled | R47 | 3/3 |
| h03-m2-drain-ack:sentence-length | R44 | 3/3 |
| h03-m2-drain-ack:step-sentences | R23 | 0/3 |
| h03-m2-drain-ack:timeline-bounds | R24 | 2/3 |
| h04-m2-dst-renewal:bold-leadins | R46 | 2/3 |
| h04-m2-dst-renewal:change-bullets | R46 | 3/3 |
| h04-m2-dst-renewal:close-last | R17 | 3/3 |
| h04-m2-dst-renewal:conclusion-first | R11 | 2/3 |
| h04-m2-dst-renewal:fixed-starts-at-divergence | R25 | 3/3 |
| h04-m2-dst-renewal:has-failing-timeline | R13 | 3/3 |
| h04-m2-dst-renewal:has-fixed-timeline | R14 | 3/3 |
| h04-m2-dst-renewal:has-recommendation | R16 | 3/3 |
| h04-m2-dst-renewal:has-what-changes | R15 | 3/3 |
| h04-m2-dst-renewal:headers | R48 | 3/3 |
| h04-m2-dst-renewal:names-self | R22 | 3/3 |
| h04-m2-dst-renewal:no-alt-timeline | R30 | 3/3 |
| h04-m2-dst-renewal:no-deferral | R34 | 3/3 |
| h04-m2-dst-renewal:no-em-dash | R45 | 3/3 |
| h04-m2-dst-renewal:no-flattery | R49 | 3/3 |
| h04-m2-dst-renewal:no-paren-aside | R45 | 2/3 |
| h04-m2-dst-renewal:section-order | R10 | 3/3 |
| h04-m2-dst-renewal:sections-labeled | R47 | 3/3 |
| h04-m2-dst-renewal:sentence-length | R44 | 3/3 |
| h04-m2-dst-renewal:step-sentences | R23 | 0/3 |
| h04-m2-dst-renewal:timeline-bounds | R24 | 3/3 |
| h05-m3-redelivery:bold-leadins | R46 | 1/3 |
| h05-m3-redelivery:change-bullets | R46 | 3/3 |
| h05-m3-redelivery:close-last | R17 | 3/3 |
| h05-m3-redelivery:conclusion-first | R11 | 2/3 |
| h05-m3-redelivery:fixed-starts-at-divergence | R25 | 3/3 |
| h05-m3-redelivery:has-failing-timeline | R13 | 3/3 |
| h05-m3-redelivery:has-fixed-timeline | R14 | 2/3 |
| h05-m3-redelivery:has-recommendation | R16 | 3/3 |
| h05-m3-redelivery:has-what-changes | R15 | 3/3 |
| h05-m3-redelivery:headers | R48 | 3/3 |
| h05-m3-redelivery:names-guard | R35 | 3/3 |
| h05-m3-redelivery:names-self | R22 | 3/3 |
| h05-m3-redelivery:no-alt-timeline | R30 | 3/3 |
| h05-m3-redelivery:no-em-dash | R45 | 3/3 |
| h05-m3-redelivery:no-flattery | R49 | 3/3 |
| h05-m3-redelivery:no-paren-aside | R45 | 2/3 |
| h05-m3-redelivery:section-order | R10 | 3/3 |
| h05-m3-redelivery:sections-labeled | R47 | 3/3 |
| h05-m3-redelivery:sentence-length | R44 | 3/3 |
| h05-m3-redelivery:step-sentences | R23 | 0/3 |
| h05-m3-redelivery:timeline-bounds | R24 | 3/3 |
| h06-m3-replica:bold-leadins | R46 | 2/3 |
| h06-m3-replica:change-bullets | R46 | 3/3 |
| h06-m3-replica:close-last | R17 | 3/3 |
| h06-m3-replica:conclusion-first | R11 | 3/3 |
| h06-m3-replica:fixed-starts-at-divergence | R25 | 3/3 |
| h06-m3-replica:has-failing-timeline | R13 | 3/3 |
| h06-m3-replica:has-fixed-timeline | R14 | 3/3 |
| h06-m3-replica:has-recommendation | R16 | 3/3 |
| h06-m3-replica:has-what-changes | R15 | 3/3 |
| h06-m3-replica:headers | R48 | 3/3 |
| h06-m3-replica:names-self | R22 | 3/3 |
| h06-m3-replica:names-writes | R35 | 3/3 |
| h06-m3-replica:no-alt-timeline | R30 | 3/3 |
| h06-m3-replica:no-em-dash | R45 | 3/3 |
| h06-m3-replica:no-flattery | R49 | 3/3 |
| h06-m3-replica:no-paren-aside | R45 | 3/3 |
| h06-m3-replica:section-order | R10 | 3/3 |
| h06-m3-replica:sections-labeled | R47 | 3/3 |
| h06-m3-replica:sentence-length | R44 | 3/3 |
| h06-m3-replica:step-sentences | R23 | 2/3 |
| h06-m3-replica:timeline-bounds | R24 | 3/3 |
| h07-m4-pool-deadlock:bold-leadins | R46 | 1/3 |
| h07-m4-pool-deadlock:change-bullets | R46 | 3/3 |
| h07-m4-pool-deadlock:close-last | R17 | 3/3 |
| h07-m4-pool-deadlock:conclusion-first | R11 | 3/3 |
| h07-m4-pool-deadlock:fixed-starts-at-divergence | R25 | 3/3 |
| h07-m4-pool-deadlock:has-failing-timeline | R13 | 3/3 |
| h07-m4-pool-deadlock:has-fixed-timeline | R14 | 3/3 |
| h07-m4-pool-deadlock:has-recommendation | R16 | 3/3 |
| h07-m4-pool-deadlock:has-what-changes | R15 | 3/3 |
| h07-m4-pool-deadlock:headers | R48 | 3/3 |
| h07-m4-pool-deadlock:names-self | R22 | 3/3 |
| h07-m4-pool-deadlock:no-alt-timeline | R30 | 3/3 |
| h07-m4-pool-deadlock:no-em-dash | R45 | 3/3 |
| h07-m4-pool-deadlock:no-flattery | R49 | 3/3 |
| h07-m4-pool-deadlock:no-paren-aside | R45 | 2/3 |
| h07-m4-pool-deadlock:section-order | R10 | 3/3 |
| h07-m4-pool-deadlock:sections-labeled | R47 | 3/3 |
| h07-m4-pool-deadlock:sentence-length | R44 | 3/3 |
| h07-m4-pool-deadlock:step-sentences | R23 | 0/3 |
| h07-m4-pool-deadlock:timeline-bounds | R24 | 3/3 |
| h08-m4-retry-storm:bold-leadins | R46 | 3/3 |
| h08-m4-retry-storm:change-bullets | R46 | 3/3 |
| h08-m4-retry-storm:close-last | R17 | 3/3 |
| h08-m4-retry-storm:conclusion-first | R11 | 3/3 |
| h08-m4-retry-storm:fixed-starts-at-divergence | R25 | 3/3 |
| h08-m4-retry-storm:has-failing-timeline | R13 | 3/3 |
| h08-m4-retry-storm:has-fixed-timeline | R14 | 3/3 |
| h08-m4-retry-storm:has-recommendation | R16 | 3/3 |
| h08-m4-retry-storm:has-what-changes | R15 | 3/3 |
| h08-m4-retry-storm:headers | R48 | 3/3 |
| h08-m4-retry-storm:names-self | R22 | 3/3 |
| h08-m4-retry-storm:no-alt-timeline | R30 | 3/3 |
| h08-m4-retry-storm:no-em-dash | R45 | 3/3 |
| h08-m4-retry-storm:no-flattery | R49 | 3/3 |
| h08-m4-retry-storm:no-paren-aside | R45 | 1/3 |
| h08-m4-retry-storm:section-order | R10 | 3/3 |
| h08-m4-retry-storm:sections-labeled | R47 | 3/3 |
| h08-m4-retry-storm:sentence-length | R44 | 3/3 |
| h08-m4-retry-storm:step-sentences | R23 | 0/3 |
| h08-m4-retry-storm:timeline-bounds | R24 | 1/3 |
| h09-m5-ruling-window:bold-leadins | R46 | 0/3 |
| h09-m5-ruling-window:close-last | R17 | 3/3 |
| h09-m5-ruling-window:close-one-question | R40 | 3/3 |
| h09-m5-ruling-window:headers | R48 | 3/3 |
| h09-m5-ruling-window:no-em-dash | R45 | 3/3 |
| h09-m5-ruling-window:no-flattery | R49 | 3/3 |
| h09-m5-ruling-window:no-paren-aside | R45 | 3/3 |
| h09-m5-ruling-window:ruling-first | R07 | 3/3 |
| h09-m5-ruling-window:sentence-length | R44 | 3/3 |
| h10-m5-restatement-none:bold-leadins | R46 | 0/3 |
| h10-m5-restatement-none:headers | R48 | 3/3 |
| h10-m5-restatement-none:list-covers-parts | R04 | 3/3 |
| h10-m5-restatement-none:no-em-dash | R45 | 3/3 |
| h10-m5-restatement-none:no-flattery | R49 | 3/3 |
| h10-m5-restatement-none:no-paren-aside | R45 | 1/3 |
| h10-m5-restatement-none:no-question | R41 | 2/3 |
| h10-m5-restatement-none:opens-with-list | R04 | 3/3 |
| h10-m5-restatement-none:sentence-length | R44 | 3/3 |
| h11-m7-upload-limit:bold-leadins | R46 | 3/3 |
| h11-m7-upload-limit:change-bullets | R46 | 3/3 |
| h11-m7-upload-limit:close-last | R17 | 3/3 |
| h11-m7-upload-limit:conclusion-first | R11 | 3/3 |
| h11-m7-upload-limit:fixed-starts-at-divergence | R25 | 3/3 |
| h11-m7-upload-limit:has-alternative | R39 | 3/3 |
| h11-m7-upload-limit:has-failing-timeline | R13 | 3/3 |
| h11-m7-upload-limit:has-fixed-timeline | R14 | 3/3 |
| h11-m7-upload-limit:has-recommendation | R16 | 3/3 |
| h11-m7-upload-limit:has-what-changes | R15 | 3/3 |
| h11-m7-upload-limit:headers | R48 | 3/3 |
| h11-m7-upload-limit:names-self | R22 | 3/3 |
| h11-m7-upload-limit:no-alt-timeline | R30 | 3/3 |
| h11-m7-upload-limit:no-em-dash | R45 | 3/3 |
| h11-m7-upload-limit:no-flattery | R49 | 3/3 |
| h11-m7-upload-limit:no-paren-aside | R45 | 2/3 |
| h11-m7-upload-limit:section-order | R10 | 3/3 |
| h11-m7-upload-limit:sections-labeled | R47 | 3/3 |
| h11-m7-upload-limit:sentence-length | R44 | 3/3 |
| h11-m7-upload-limit:step-sentences | R23 | 1/3 |
| h11-m7-upload-limit:timeline-bounds | R24 | 2/3 |
| h12-m7-revoke-sessions:bold-leadins | R46 | 3/3 |
| h12-m7-revoke-sessions:change-bullets | R46 | 3/3 |
| h12-m7-revoke-sessions:close-last | R17 | 3/3 |
| h12-m7-revoke-sessions:conclusion-first | R11 | 3/3 |
| h12-m7-revoke-sessions:fixed-starts-at-divergence | R25 | 3/3 |
| h12-m7-revoke-sessions:has-failing-timeline | R13 | 3/3 |
| h12-m7-revoke-sessions:has-fixed-timeline | R14 | 3/3 |
| h12-m7-revoke-sessions:has-recommendation | R16 | 3/3 |
| h12-m7-revoke-sessions:has-what-changes | R15 | 3/3 |
| h12-m7-revoke-sessions:headers | R48 | 3/3 |
| h12-m7-revoke-sessions:names-self | R22 | 3/3 |
| h12-m7-revoke-sessions:no-alt-timeline | R30 | 3/3 |
| h12-m7-revoke-sessions:no-em-dash | R45 | 3/3 |
| h12-m7-revoke-sessions:no-flattery | R49 | 3/3 |
| h12-m7-revoke-sessions:no-paren-aside | R45 | 3/3 |
| h12-m7-revoke-sessions:section-order | R10 | 3/3 |
| h12-m7-revoke-sessions:sections-labeled | R47 | 3/3 |
| h12-m7-revoke-sessions:sentence-length | R44 | 3/3 |
| h12-m7-revoke-sessions:step-sentences | R23 | 0/3 |
| h12-m7-revoke-sessions:timeline-bounds | R24 | 3/3 |
| h13-mf-replicas:correct | R02 | 3/3 |
| h13-mf-replicas:no-template | R02 | 3/3 |
| h13-mf-replicas:short | R02 | 3/3 |
| h14-mf-node-version:correct | R02 | 3/3 |
| h14-mf-node-version:no-template | R02 | 2/3 |
| h14-mf-node-version:short | R02 | 2/3 |
