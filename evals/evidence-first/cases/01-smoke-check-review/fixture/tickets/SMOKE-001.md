# SMOKE-001 — Production smoke checks 2026-11-05

**Test org:** org-9876
**Requested by:** Alex
**Due:** 2026-11-05

## Checks

| # | Condition | Result |
|---|---|---|
| 1a | Non-member GET /v1/orgs/org-9876/add-ons → 403 | |
| 1b | Member GET /v1/orgs/org-9876/add-ons → 200 | |
| 2 | Super admin feature toggle refused, nothing written | |
| 3 | Class /live page opens normally | |
