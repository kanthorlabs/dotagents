PAGE_SIZE = 50


def list_orders(db, tenant_id, page):
    offset = (page - 1) * PAGE_SIZE
    return db.query(
        "SELECT id, created_at, total_cents FROM orders "
        "WHERE tenant_id = %s ORDER BY created_at DESC "
        "LIMIT %s OFFSET %s",
        (tenant_id, PAGE_SIZE, offset),
    )
