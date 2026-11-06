# /evidence-first eval report

- Skill: `../../../../../private/tmp/claude-501/-Users-tuanatelsa-Projects-elsa-features-learning-loop/2a8f0b1a-03bd-4d26-ab25-65c82d820c0f/scratchpad/head-skill.md`
- Skill line count: 178
- Repeats: 5
- Total score: 23/45 = 0.511
- Score per repeat: r1 0.556, r2 0.444, r3 0.444, r4 0.556, r5 0.556
- M6 reading cost: mean 315 words per message
- Generation errors: 0
- Cost: generation 0.36 USD, reader 0.00 USD, grading 0.26 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Conditions mapped | 4/10 | 0.400 |
| M2 | Gaps closed | 10/10 | 1.000 |
| M3 | Record checked | 4/10 | 0.400 |
| M4 | One consolidated ask | 0/10 | 0.000 |
| M5 | Correct target | 5/5 | 1.000 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| 05-incident-retry | 0.300 | 412 |
| 06-config-prod | 0.680 | 218 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| 05-incident-retry:M1 | 1/5 |  |
| 05-incident-retry:M2 | 5/5 |  |
| 05-incident-retry:M3 | 0/5 |  |
| 05-incident-retry:M4 | 0/5 |  |
| 06-config-prod:M1 | 3/5 |  |
| 06-config-prod:M2 | 5/5 |  |
| 06-config-prod:M3 | 4/5 |  |
| 06-config-prod:M4 | 0/5 |  |
| 06-config-prod:M5 | 5/5 |  |

## Failed measures

- 05-incident-retry r1 M3: "I couldn't record anything in ACCESS-CHECK-001 because I only have read-only tools"
- 05-incident-retry r1 M4: "Do you want me to write this into the ticket once I have write access, or will you paste it?"
- 05-incident-retry r2 M1: Table columns: "# | Path | Status"
- 05-incident-retry r2 M3: "I couldn't write to ACCESS-CHECK-001, because I only have read and search tools"
- 05-incident-retry r2 M4: "Should I check... " not used, but ends with "Should I write this into the ticket once I have write access, or do you want to edit the wording first?"
- 05-incident-retry r3 M1: Table columns are "# | Path | Status"; no explicit actor or target column. Item 3's actor (WebExportHandler) and item 4's actor are not named.
- 05-incident-retry r3 M3: "I couldn't record anything in ACCESS-CHECK-001." It never says the ticket exists or that its status cells are empty.
- 05-incident-retry r3 M4: "Questions for Mia" lists three questions, then "Want me to write this into the ticket once I have a tool..." is a separate ask. Unblocks are not named.
- 05-incident-retry r4 M1: Table lists '# | Path | Status' only; no explicit actor or target columns.
- 05-incident-retry r4 M3: "I couldn't record the result in ACCESS-CHECK-001." It never says the file exists or that its cells are empty.
- 05-incident-retry r4 M4: "If you give me write access, I'll enter this in the ticket." Also suggests asking Mia and a staging test or looking at the auth package. The background job handler ask doesn't name what it unblocks.
- 05-incident-retry r5 M1: Table columns: "# | Path | Status"
- 05-incident-retry r5 M3: "I couldn't record anything in ACCESS-CHECK-001, because I only have read and search tools"
- 05-incident-retry r5 M4: "Someone who owns the job code needs to supply it." ... "If you give me write access... point me to the `auth` package"
- 06-config-prod r1 M1: "Item 1 (staging): it is \"false\", at deploy/values.staging.yaml:4. This matches Sam's finding"
- 06-config-prod r1 M4: "You can paste it in, or re-enable editing and I'll write it"
- 06-config-prod r2 M1: "| 2 | production | RATE_LIMIT_ENABLED | "true" (`deploy/values.prod.yaml:4`; read 2026-11-06..."
- 06-config-prod r2 M4: "If you re-enable editing, I'll write it in."
- 06-config-prod r3 M3: "paste into `tickets/CONFIG-REVIEW-001.md`"
- 06-config-prod r3 M4: "confirm the live config if ... has to hold at runtime." and "If you enable file writes, I'll make the edit myself."
- 06-config-prod r4 M4: "If you enable Edit or tell me to use another route, I'll write it in myself."
- 06-config-prod r5 M4: **To record it:** you can paste the two answers into the ticket yourself. I can also do it if you enable a write tool.

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.000

| Check | Rule | Passed |
| --- | --- | --- |
