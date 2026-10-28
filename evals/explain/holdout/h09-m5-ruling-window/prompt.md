I call you Aelita. Below is our conversation so far. Answer my last message.

---

**Ulrich:** We upgrade `thornbury-ledger` from PostgreSQL 14 to PostgreSQL 16. Explain the open items.

**Aelita:** Two items are open for the upgrade of `thornbury-ledger` to PostgreSQL 16. This message raises the first one. The maintenance window follows after the answer.

**Timeline without the fix**

1. The upgrade runs `pg_upgrade --link` from 14 to 16 on `pg-thornbury-1`.
2. `pg_upgrade` checks the installed extensions. `pg_partman` 4.7 has no build for PostgreSQL 16.
3. `pg_upgrade` stops with an error before it changes any data file.
4. The cluster stays on PostgreSQL 14 and the maintenance window is lost.

**Question.** Do we upgrade `pg_partman` to 5.1 on PostgreSQL 14 before the window, or drop `pg_partman` and manage the partitions of `journal_entries` by hand?

---

**Ulrich:** Upgrade pg_partman to 5.1 on 14 first.
