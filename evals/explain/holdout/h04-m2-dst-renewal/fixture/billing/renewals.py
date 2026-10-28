from billing import db, psp


def charge_renewals(today):
    due = db.query(
        "SELECT id, customer_id, amount_cents FROM subscriptions "
        "WHERE status = 'active' AND renews_on <= %s",
        today,
    )
    for sub in due:
        psp.charge(sub.customer_id, sub.amount_cents, description=f"Renewal {sub.id}")
        db.execute(
            "INSERT INTO renewal_charges (subscription_id, charged_on, settled) VALUES (%s, %s, false)",
            sub.id,
            today,
        )
    return len(due)
