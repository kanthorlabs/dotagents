# /explain eval report

- Skill: `skills/explain/SKILL.md`
- Skill line count: 192
- Repeats: 3
- Total score: 178/216 = 0.824
- Score per repeat: r1 0.819, r2 0.819, r3 0.833
- M6 reading cost: mean 423 words per message
- Generation errors: 0
- Cost: generation 1.88 USD, reader 0.94 USD, grading 1.35 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Right decision | 31/33 | 0.939 |
| M2 | True facts | 33/36 | 0.917 |
| M3 | No follow-up | 26/36 | 0.722 |
| M4 | Understanding | 31/36 | 0.861 |
| M5 | Answerable close | 32/36 | 0.889 |
| M7 | Valid alternative | 21/33 | 0.636 |
| MF | Factual answer | 4/6 | 0.667 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| h01-m1-backoff | 0.722 | 545 |
| h02-m1-stale-price | 0.833 | 540 |
| h03-m2-drain-ack | 0.944 | 544 |
| h04-m2-dst-renewal | 0.444 | 484 |
| h05-m3-redelivery | 0.667 | 530 |
| h06-m3-replica | 0.889 | 484 |
| h07-m4-pool-deadlock | 0.833 | 480 |
| h08-m4-retry-storm | 1.000 | 531 |
| h09-m5-ruling-window | 0.889 | 412 |
| h10-m5-restatement-none | 0.833 | 232 |
| h11-m7-upload-limit | 0.944 | 538 |
| h12-m7-revoke-sessions | 0.944 | 474 |
| h13-mf-replicas | 1.000 | 62 |
| h14-mf-node-version | 0.333 | 70 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| h01-m1-backoff:M1 | 3/3 |  |
| h01-m1-backoff:M2 | 2/3 |  |
| h01-m1-backoff:M3 | 3/3 |  |
| h01-m1-backoff:M4 | 3/3 |  |
| h01-m1-backoff:M5 | 2/3 |  |
| h01-m1-backoff:M7 | 0/3 | non-discriminating |
| h02-m1-stale-price:M1 | 2/3 | non-discriminating |
| h02-m1-stale-price:M2 | 3/3 |  |
| h02-m1-stale-price:M3 | 2/3 | non-discriminating |
| h02-m1-stale-price:M4 | 2/3 |  |
| h02-m1-stale-price:M5 | 3/3 |  |
| h02-m1-stale-price:M7 | 3/3 |  |
| h03-m2-drain-ack:M1 | 3/3 | non-discriminating |
| h03-m2-drain-ack:M2 | 3/3 |  |
| h03-m2-drain-ack:M3 | 3/3 |  |
| h03-m2-drain-ack:M4 | 3/3 | non-discriminating |
| h03-m2-drain-ack:M5 | 2/3 |  |
| h03-m2-drain-ack:M7 | 3/3 | non-discriminating |
| h04-m2-dst-renewal:M1 | 2/3 | non-discriminating |
| h04-m2-dst-renewal:M2 | 1/3 |  |
| h04-m2-dst-renewal:M3 | 0/3 |  |
| h04-m2-dst-renewal:M4 | 1/3 |  |
| h04-m2-dst-renewal:M5 | 2/3 |  |
| h04-m2-dst-renewal:M7 | 2/3 |  |
| h05-m3-redelivery:M1 | 3/3 | non-discriminating |
| h05-m3-redelivery:M2 | 3/3 | non-discriminating |
| h05-m3-redelivery:M3 | 0/3 | non-discriminating |
| h05-m3-redelivery:M4 | 2/3 | non-discriminating |
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
| h08-m4-retry-storm:M2 | 3/3 |  |
| h08-m4-retry-storm:M3 | 3/3 | non-discriminating |
| h08-m4-retry-storm:M4 | 3/3 |  |
| h08-m4-retry-storm:M5 | 3/3 |  |
| h08-m4-retry-storm:M7 | 3/3 |  |
| h09-m5-ruling-window:M1 | 3/3 | non-discriminating |
| h09-m5-ruling-window:M2 | 3/3 |  |
| h09-m5-ruling-window:M3 | 2/3 | non-discriminating |
| h09-m5-ruling-window:M4 | 2/3 | non-discriminating |
| h09-m5-ruling-window:M5 | 3/3 | non-discriminating |
| h09-m5-ruling-window:M7 | 3/3 | non-discriminating |
| h10-m5-restatement-none:M2 | 3/3 |  |
| h10-m5-restatement-none:M3 | 2/3 |  |
| h10-m5-restatement-none:M4 | 3/3 | non-discriminating |
| h10-m5-restatement-none:M5 | 2/3 | non-discriminating |
| h11-m7-upload-limit:M1 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M2 | 3/3 |  |
| h11-m7-upload-limit:M3 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M4 | 3/3 | non-discriminating |
| h11-m7-upload-limit:M5 | 3/3 |  |
| h11-m7-upload-limit:M7 | 2/3 | non-discriminating |
| h12-m7-revoke-sessions:M1 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M2 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M3 | 3/3 | non-discriminating |
| h12-m7-revoke-sessions:M4 | 3/3 |  |
| h12-m7-revoke-sessions:M5 | 3/3 |  |
| h12-m7-revoke-sessions:M7 | 2/3 |  |
| h13-mf-replicas:MF | 3/3 | non-discriminating |
| h14-mf-node-version:MF | 1/3 | non-discriminating |

## Failed measures

- h01-m1-backoff r1 M7: "Alternative: the enterprise tier... It becomes the primary only if the volume grows past about 6,000 batch calls per run." The enterprise tier is in invalid_options, and valid_alternatives is empty.
- h01-m1-backoff r2 M5: "Do you approve the batch endpoint with a `Retry-After` guard? If so, can you share a sample `batchUpsert` response...?" The message ends with two questions.
- h01-m1-backoff r2 M7: "Alternative: enterprise tier... the 3-week lead time misses Friday." The key lists enterprise tier as an invalid option, and it does not produce the correct result.
- h01-m1-backoff r3 M2: "`docs/juniper-api.md` says the batch response lists a result per contact. It does not give the field names." Batch endpoint is a verifiable fact, but the message leaves the response schema unresolved.
- h01-m1-backoff r3 M7: "Alternative: enterprise tier... costs 1,450 USD per month. The lead time is 3 weeks, so it misses the Friday deadline." It is in invalid_options and was offered as an alternative.
- h02-m1-stale-price r1 M1: "Aelita recommends removing the per-pod cache." The key's recommendation is per-pod eviction via price.changed; removing the cache is only a listed alternative, not the primary.
- h02-m1-stale-price r1 M3: Required question "What exactly changes?" expects pods subscribing to price.changed and popping the SKU. The message instead says "delete `price_cache`".
- h02-m1-stale-price r1 M4: Reader fix: "Delete price_cache and the TTLCache import". The key fix is eviction on every pod via price.changed, and the cost is a small subscriber.
- h03-m2-drain-ack r3 M5: "Do you approve the manual ack, prefetch, drain and grace changes? If so, should I also ask Billing...?" The message ends with two questions.
- h04-m2-dst-renewal r1 M2: "I found no file that shows whether Payrail accepts an idempotency key."
- h04-m2-dst-renewal r1 M3: Reader follow-up: "Does Payrail accept an idempotency key on charge requests?" The message never says the Payrail charge has no key.
- h04-m2-dst-renewal r2 M1: "Aelita recommends moving the three schedules to UTC." UTC is only a valid alternative in the key. It is not a correct_recommendations entry (fire once per local slot, or idempotent charge).
- h04-m2-dst-renewal r2 M3: "The next item is the refund list". The message never says how to refund safely, such as finding manual refunds from Payrail records.
- h04-m2-dst-renewal r2 M4: Reader fix: "Switch the three schedules to UTC". The key fix is to fire each local slot once in the scheduler and refund the duplicates. The reader also omits the refund.
- h04-m2-dst-renewal r2 M5: "Do you approve moving the three schedules to UTC?" This is a single question, but the decision is UTC, which does not match the closing_decision (scheduler fix).
- h04-m2-dst-renewal r3 M2: "Whether Payrail accepts an idempotency key on `POST /v1/charges` is unverified... The Payrail docs would settle it." The key says billing/psp.py settles that psp.charge sends none, and the message never states this.
- h04-m2-dst-renewal r3 M3: The safe-refund question is unanswered. The message only says "The unrecorded manual refunds from Monday 26 October are the next open item." It gives no way to find them or refund the rest.
- h04-m2-dst-renewal r3 M4: Reader fix: "INSERT ... ON CONFLICT DO NOTHING into renewal_charges first" with no duplicate refund. Reader cost: "One migration". The key fix and cost include a refund run that needs the manual-refund list.
- h04-m2-dst-renewal r3 M7: "or the scheduler runs jobs in UTC. This also fixes the dunning emails and needs no migration." The UTC option is folded in without its trade-off, the local run time shifting by one hour twice a year.
- h05-m3-redelivery r1 M3: The message never says the handler sends to ingest.dlq and acks. It also omits max_ack_pending 256 and the same-transaction insert, so "How does it work now?" and "What stays?" are unanswered.
- h05-m3-redelivery r1 M4: Reader fix: "Approve the proposal as in `docs/proposals/redelivery.md`". The reader never learns the nak delays or max_ack_pending 256, and the cost field drifts to the INSERT_HISTORY risk.
- h05-m3-redelivery r1 M7: "Alternative: reject and keep serial processing. Keep `max_ack_pending: 1` and shorten the delays." It still stalls and is not the valid per-device partition alternative; it is close to an invalid option.
- h05-m3-redelivery r2 M3: Never states how current with_retries works (2,4,8,16,32 sleeps, then ingest.dlq and ack) nor what stays (same delays, DLQ, explicit ack, one transaction).
- h05-m3-redelivery r2 M7: Offers "keep with_retries and run several consumers"; ordering "would still depend on how messages are spread", and condition is "if the guard cannot ship today", not the key's strict-order need.
- h05-m3-redelivery r3 M3: The message never says how retry works now: with_retries sleeping 2–32 s inside the handler, then the handler sends to ingest.dlq and acks. Reader also asks about a unique key.
- h06-m3-replica r2 M7: "Alternative: keep the temp table and run everything on the primary. Nothing changes" is the invalid 'Change nothing' option and does not take load off the primary.
- h06-m3-replica r3 M7: Offers "keep the temp table and run churn_by_plan on the primary" — not a valid_alternatives entry; it keeps part of the load on the primary.
- h07-m4-pool-deadlock r1 M3: The required question "Why not a bigger pool?" is never answered. The message never mentions raising max_size or says the deadlock returns at the new size.
- h07-m4-pool-deadlock r2 M7: "Alternative: raise `max_size` above the concurrent request count." The key lists this as an invalid option, and the message offers it as the fallback primary.
- h07-m4-pool-deadlock r3 M7: "Alternative: raise `max_size` or lower `timeout`." Raising max_size and raising the pool timeout are in invalid_options, and the message calls this a stopgap primary.
- h09-m5-ruling-window r1 M4: Reader fix: "Book step 3 for Saturday 7 November 2026, 02:00 UTC". The key fix is Sunday 8 November, so the reader's fix and cost (Saturday's 95 writes per second) differ.
- h09-m5-ruling-window r3 M3: Required question "Is any item left after this one?" is never answered. The message says "The second open item" but not that it is the last. Reader also asks about Signe.
- h10-m5-restatement-none r2 M3: "Do you want me to record the corrected wording for Petra...?" Key expects 'Is anything still open?' = No.
- h10-m5-restatement-none r2 M5: 1 question marks
- h11-m7-upload-limit r1 M7: "I dropped the presigned upload. `storage.presign_post` exists but nothing calls it" gives no trade-off and does not say it becomes primary after 9 November or at larger scale.
- h12-m7-revoke-sessions r2 M7: "Alternative: rotate `SIGNING_KEY`... It fails SR-12 and is dropped." The message lists an invalid option as an alternative.
- h14-mf-node-version r1 MF: 22.11.0; 53 words; **Other constraint.** `package.json:6` declares `"engines": {"node": ">=20"}`. That only states the 
- h14-mf-node-version r3 MF: 22.11.0; 88 words; **Timeline**

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.895

| Check | Rule | Passed |
| --- | --- | --- |
| h01-m1-backoff:bold-leadins | R46 | 3/3 |
| h01-m1-backoff:change-bullets | R46 | 3/3 |
| h01-m1-backoff:close-last | R17 | 3/3 |
| h01-m1-backoff:conclusion-first | R11 | 3/3 |
| h01-m1-backoff:fixed-starts-at-divergence | R25 | 3/3 |
| h01-m1-backoff:has-failing-timeline | R13 | 3/3 |
| h01-m1-backoff:has-fixed-timeline | R14 | 3/3 |
| h01-m1-backoff:has-recommendation | R16 | 3/3 |
| h01-m1-backoff:has-what-changes | R15 | 3/3 |
| h01-m1-backoff:headers | R48 | 3/3 |
| h01-m1-backoff:names-self | R22 | 3/3 |
| h01-m1-backoff:no-alt-timeline | R30 | 3/3 |
| h01-m1-backoff:no-deferral | R34 | 3/3 |
| h01-m1-backoff:no-em-dash | R45 | 3/3 |
| h01-m1-backoff:no-flattery | R49 | 3/3 |
| h01-m1-backoff:no-paren-aside | R45 | 3/3 |
| h01-m1-backoff:section-order | R10 | 3/3 |
| h01-m1-backoff:sections-labeled | R47 | 3/3 |
| h01-m1-backoff:sentence-length | R44 | 3/3 |
| h01-m1-backoff:step-sentences | R23 | 0/3 |
| h01-m1-backoff:timeline-bounds | R24 | 3/3 |
| h02-m1-stale-price:bold-leadins | R46 | 3/3 |
| h02-m1-stale-price:change-bullets | R46 | 3/3 |
| h02-m1-stale-price:close-last | R17 | 3/3 |
| h02-m1-stale-price:conclusion-first | R11 | 1/3 |
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
| h02-m1-stale-price:no-paren-aside | R45 | 0/3 |
| h02-m1-stale-price:section-order | R10 | 3/3 |
| h02-m1-stale-price:sections-labeled | R47 | 3/3 |
| h02-m1-stale-price:sentence-length | R44 | 3/3 |
| h02-m1-stale-price:step-sentences | R23 | 0/3 |
| h02-m1-stale-price:timeline-bounds | R24 | 3/3 |
| h03-m2-drain-ack:bold-leadins | R46 | 3/3 |
| h03-m2-drain-ack:change-bullets | R46 | 3/3 |
| h03-m2-drain-ack:close-last | R17 | 3/3 |
| h03-m2-drain-ack:conclusion-first | R11 | 3/3 |
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
| h03-m2-drain-ack:no-paren-aside | R45 | 2/3 |
| h03-m2-drain-ack:section-order | R10 | 3/3 |
| h03-m2-drain-ack:sections-labeled | R47 | 3/3 |
| h03-m2-drain-ack:sentence-length | R44 | 2/3 |
| h03-m2-drain-ack:step-sentences | R23 | 0/3 |
| h03-m2-drain-ack:timeline-bounds | R24 | 3/3 |
| h04-m2-dst-renewal:bold-leadins | R46 | 3/3 |
| h04-m2-dst-renewal:change-bullets | R46 | 3/3 |
| h04-m2-dst-renewal:close-last | R17 | 3/3 |
| h04-m2-dst-renewal:conclusion-first | R11 | 3/3 |
| h04-m2-dst-renewal:fixed-starts-at-divergence | R25 | 2/3 |
| h04-m2-dst-renewal:has-failing-timeline | R13 | 3/3 |
| h04-m2-dst-renewal:has-fixed-timeline | R14 | 2/3 |
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
| h05-m3-redelivery:bold-leadins | R46 | 0/3 |
| h05-m3-redelivery:change-bullets | R46 | 3/3 |
| h05-m3-redelivery:close-last | R17 | 3/3 |
| h05-m3-redelivery:conclusion-first | R11 | 3/3 |
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
| h05-m3-redelivery:no-paren-aside | R45 | 0/3 |
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
| h06-m3-replica:step-sentences | R23 | 3/3 |
| h06-m3-replica:timeline-bounds | R24 | 3/3 |
| h07-m4-pool-deadlock:bold-leadins | R46 | 0/3 |
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
| h07-m4-pool-deadlock:no-paren-aside | R45 | 1/3 |
| h07-m4-pool-deadlock:section-order | R10 | 3/3 |
| h07-m4-pool-deadlock:sections-labeled | R47 | 3/3 |
| h07-m4-pool-deadlock:sentence-length | R44 | 3/3 |
| h07-m4-pool-deadlock:step-sentences | R23 | 0/3 |
| h07-m4-pool-deadlock:timeline-bounds | R24 | 2/3 |
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
| h08-m4-retry-storm:no-paren-aside | R45 | 0/3 |
| h08-m4-retry-storm:section-order | R10 | 3/3 |
| h08-m4-retry-storm:sections-labeled | R47 | 3/3 |
| h08-m4-retry-storm:sentence-length | R44 | 3/3 |
| h08-m4-retry-storm:step-sentences | R23 | 0/3 |
| h08-m4-retry-storm:timeline-bounds | R24 | 3/3 |
| h09-m5-ruling-window:bold-leadins | R46 | 0/3 |
| h09-m5-ruling-window:close-last | R17 | 3/3 |
| h09-m5-ruling-window:close-one-question | R40 | 3/3 |
| h09-m5-ruling-window:headers | R48 | 3/3 |
| h09-m5-ruling-window:no-em-dash | R45 | 3/3 |
| h09-m5-ruling-window:no-flattery | R49 | 3/3 |
| h09-m5-ruling-window:no-paren-aside | R45 | 3/3 |
| h09-m5-ruling-window:ruling-first | R07 | 3/3 |
| h09-m5-ruling-window:sentence-length | R44 | 3/3 |
| h10-m5-restatement-none:bold-leadins | R46 | 1/3 |
| h10-m5-restatement-none:headers | R48 | 3/3 |
| h10-m5-restatement-none:list-covers-parts | R04 | 3/3 |
| h10-m5-restatement-none:no-em-dash | R45 | 3/3 |
| h10-m5-restatement-none:no-flattery | R49 | 3/3 |
| h10-m5-restatement-none:no-paren-aside | R45 | 1/3 |
| h10-m5-restatement-none:no-question | R41 | 2/3 |
| h10-m5-restatement-none:opens-with-list | R04 | 3/3 |
| h10-m5-restatement-none:sentence-length | R44 | 3/3 |
| h11-m7-upload-limit:bold-leadins | R46 | 1/3 |
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
| h11-m7-upload-limit:no-paren-aside | R45 | 1/3 |
| h11-m7-upload-limit:section-order | R10 | 3/3 |
| h11-m7-upload-limit:sections-labeled | R47 | 3/3 |
| h11-m7-upload-limit:sentence-length | R44 | 3/3 |
| h11-m7-upload-limit:step-sentences | R23 | 0/3 |
| h11-m7-upload-limit:timeline-bounds | R24 | 2/3 |
| h12-m7-revoke-sessions:bold-leadins | R46 | 2/3 |
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
| h12-m7-revoke-sessions:no-paren-aside | R45 | 2/3 |
| h12-m7-revoke-sessions:section-order | R10 | 3/3 |
| h12-m7-revoke-sessions:sections-labeled | R47 | 3/3 |
| h12-m7-revoke-sessions:sentence-length | R44 | 3/3 |
| h12-m7-revoke-sessions:step-sentences | R23 | 0/3 |
| h12-m7-revoke-sessions:timeline-bounds | R24 | 2/3 |
| h13-mf-replicas:correct | R02 | 3/3 |
| h13-mf-replicas:no-template | R02 | 3/3 |
| h13-mf-replicas:short | R02 | 3/3 |
| h14-mf-node-version:correct | R02 | 3/3 |
| h14-mf-node-version:no-template | R02 | 1/3 |
| h14-mf-node-version:short | R02 | 2/3 |
