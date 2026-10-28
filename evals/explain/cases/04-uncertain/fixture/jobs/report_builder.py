from ledgerly import flags


def build_monthly_report(db, tenant, month_start, month_end):
    hide_archived = flags.is_on("hide_archived", tenant=tenant)
    sql = (
        "SELECT id, number, total_cents, status FROM invoices "
        "WHERE tenant = %s AND issued_at >= %s AND issued_at < %s"
    )
    if hide_archived:
        sql += " AND status <> 'archived'"
    rows = db.query(sql, (tenant, month_start, month_end))
    return render(rows)


def render(rows):
    return {"count": len(rows), "lines": rows}
