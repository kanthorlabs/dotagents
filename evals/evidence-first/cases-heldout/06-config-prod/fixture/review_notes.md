# Rate-Limit Config Review — 2026-10-28

Reviewer: Sam

## Items

| # | Environment | Variable | Status |
|---|---|---|---|
| 1 | staging | RATE_LIMIT_ENABLED | CONFIRMED — values.staging.yaml: "false" |
| 2 | production | RATE_LIMIT_ENABLED | OPEN — session timed out before deploy dir was mounted; prod values not read |

## Notes

Item 1 confirmed from deploy/values.staging.yaml in the same repo.
Item 2 was not completed. Sam notes the prod values file should be at deploy/values.prod.yaml in the same repo when available.
Follow-up: re-run once deploy dir is accessible.
