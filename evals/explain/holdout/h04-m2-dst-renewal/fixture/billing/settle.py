from billing import db


def settle_renewals(today):
    db.execute(
        "UPDATE subscriptions SET renews_on = renews_on + interval '1 month' "
        "WHERE id IN (SELECT subscription_id FROM renewal_charges WHERE charged_on = %s AND settled = false)",
        today,
    )
    return db.execute(
        "UPDATE renewal_charges SET settled = true WHERE charged_on = %s AND settled = false",
        today,
    )
