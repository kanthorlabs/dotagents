# osprey databases

- Primary: `pg-osprey-1`. Secret `osprey-primary`, key `url`.
- Replica: `pg-osprey-2`, a hot standby with streaming replication. Secret `osprey-replica`, key `url`. The dashboards service reads from it today.
- The hot standby rejects every write. This includes `CREATE TEMP TABLE` and any `INSERT`.
- Replication lag: p99 2 seconds over the last 30 days.
