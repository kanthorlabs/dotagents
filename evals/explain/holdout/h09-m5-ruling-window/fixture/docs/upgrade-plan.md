# thornbury-ledger: PostgreSQL 14 to 16

Owner: Signe Aaberg, DBA

## Deadline

- PostgreSQL 14 reaches end of life on 12 November 2026.
- Audit requirement AR-7: every production database runs a supported major version. The major upgrade must finish before 12 November 2026.

## Steps

1. Upgrade `pg_partman` from 4.7 to 5.1 on PostgreSQL 14 in production.
2. Watch the partition maintenance job of `pg_partman` 5.1 complete two nightly runs in production before the major upgrade. The job runs every night at 03:30 UTC.
3. Run `pg_upgrade --link` from 14 to 16 on `pg-thornbury-1` in a maintenance window.
4. Run `vacuumdb --analyze-in-stages` after the start of PostgreSQL 16.

## Schedule

- Step 1 is booked for Wednesday 4 November 2026, 10:00 UTC, the first slot after the change freeze. Signe Aaberg is on leave until 3 November.
- The date of step 3 is open.

## Measured on the staging copy, 20 October 2026

- `pg_upgrade --link` downtime: 14 min 10 s.
- `vacuumdb --analyze-in-stages`: 38 minutes. The database is online during it, but reports are slow.
