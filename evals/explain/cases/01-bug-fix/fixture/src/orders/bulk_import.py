from datetime import datetime, timezone


def import_tidewater_batch(db, tenant_id, rows):
    batch_time = datetime.now(timezone.utc)
    for row in rows:
        db.execute(
            "INSERT INTO orders (tenant_id, external_ref, created_at, total_cents) "
            "VALUES (%s, %s, %s, %s)",
            (tenant_id, row["ref"], batch_time, row["total_cents"]),
        )
