REVENUE_BY_REGION = """
SELECT r.name AS region, sum(i.amount_cents) AS revenue_cents
FROM invoices i
JOIN accounts a ON a.id = i.account_id
JOIN regions r ON r.id = a.region_id
WHERE i.issued_on = %(day)s
GROUP BY r.name
ORDER BY r.name
"""

CHURN_WINDOW = """
CREATE TEMP TABLE churn_window AS
SELECT s.account_id, s.plan, s.cancelled_on
FROM subscriptions s
WHERE s.cancelled_on BETWEEN %(day)s - interval '30 days' AND %(day)s
"""

CHURN_BY_PLAN = """
SELECT plan, count(*) AS cancelled
FROM churn_window
GROUP BY plan
ORDER BY plan
"""


def revenue_by_region(conn, day):
    return conn.execute(REVENUE_BY_REGION, {"day": day}).fetchall()


def churn_by_plan(conn, day):
    conn.execute(CHURN_WINDOW, {"day": day})
    return conn.execute(CHURN_BY_PLAN).fetchall()
