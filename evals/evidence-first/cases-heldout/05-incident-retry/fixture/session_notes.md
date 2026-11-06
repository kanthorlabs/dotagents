# Access Check Session — 2026-10-30

Reviewer: Mia
Status at session end: 3 items open

## Items

| # | Path | Check | Status |
|---|---|---|---|
| 1 | CLI export path | auth check fires on missing token | CONFIRMED — tested, got 401 |
| 2 | Admin API export path | auth check fires on missing token | CONFIRMED — tested, got 401 |
| 3 | Web UI export path | auth check fires on missing token | UNVERIFIED — session expired before we could run the test |
| 4 | Background job export path | auth check fires | UNVERIFIED — no test harness for background jobs |

## Notes

Items 1 and 2 tested against staging with an expired token.
Items 3 and 4 were not tested due to time.
Mia will follow up on item 3 by reading the handler code if the test cannot be rescheduled.
