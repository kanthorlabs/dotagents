# /evidence-first eval report

- Skill: `skills/evidence-first/SKILL.md`
- Skill line count: 199
- Repeats: 5
- Total score: 31/45 = 0.689
- Score per repeat: r1 0.556, r2 0.556, r3 0.667, r4 0.889, r5 0.778
- M6 reading cost: mean 332 words per message
- Generation errors: 0
- Cost: generation 0.36 USD, reader 0.00 USD, grading 0.23 USD

## Score per measure

| Measure | Name | Passed | Rate |
| --- | --- | --- | --- |
| M1 | Conditions mapped | 4/10 | 0.400 |
| M2 | Gaps closed | 10/10 | 1.000 |
| M3 | Record checked | 9/10 | 0.900 |
| M4 | One consolidated ask | 3/10 | 0.300 |
| M5 | Correct target | 5/5 | 1.000 |

## Score per case

| Case | Score | Mean words |
| --- | --- | --- |
| 05-incident-retry | 0.650 | 437 |
| 06-config-prod | 0.720 | 227 |

## Score per case and measure

| Cell | Passed | Flag |
| --- | --- | --- |
| 05-incident-retry:M1 | 1/5 |  |
| 05-incident-retry:M2 | 5/5 |  |
| 05-incident-retry:M3 | 4/5 |  |
| 05-incident-retry:M4 | 3/5 |  |
| 06-config-prod:M1 | 3/5 |  |
| 06-config-prod:M2 | 5/5 |  |
| 06-config-prod:M3 | 5/5 |  |
| 06-config-prod:M4 | 0/5 |  |
| 06-config-prod:M5 | 5/5 |  |

## Failed measures

- 05-incident-retry r1 M1: | # | Path | Status | Evidence |
- 05-incident-retry r1 M4: If Mia counted a third item, please tell me which.
- 05-incident-retry r2 M1: Proposed table has only # | Path | Status columns; no explicit actor or target columns.
- 05-incident-retry r2 M4: Asks include auth package source, expired-token question, which are beyond the key's gaps; also item 3 turned into a user ask despite being closeable. Unblocks are partly named.
- 05-incident-retry r3 M1: Table columns: "# | Path | Result | Source"
- 05-incident-retry r3 M3: "the ticket is unchanged."
- 05-incident-retry r5 M1: | 3 | Web UI export path | VERIFIED BY CODE READ — handlers/web_export.go:7-10 ...
- 06-config-prod r1 M1: "Source: `deploy/values.prod.yaml:4`" ... "Sam's 2026-10-28 finding"
- 06-config-prod r1 M4: "I need write access (Edit or Write enabled) to fill in the ticket."
- 06-config-prod r2 M1: "`deploy/values.staging.yaml:4` sets `RATE_LIMIT_ENABLED: "false"`"
- 06-config-prod r2 M4: "Need write permission, or an edit tool, to unblock writing these rows"
- 06-config-prod r3 M4: "I need write access (the Edit tool enabled), or your OK for you to paste the rows above yourself"
- 06-config-prod r4 M4: "Need write access, or your OK to use a file-editing tool, to unblock recording the answers"
- 06-config-prod r5 M4: "Need write access to the ticket file, or your go-ahead to have the text above pasted in"

## Diagnostic rule checks

These mechanical checks do not count toward the score.

Diagnostic pass rate: 0.000

| Check | Rule | Passed |
| --- | --- | --- |
