import os
from datetime import date, timedelta

import psycopg

from reports.queries import churn_by_plan, revenue_by_region
from reports.render import write_pdf
from reports.runs import record_run


def report_date():
    return date.today() - timedelta(days=1)


def main():
    day = report_date()
    with psycopg.connect(os.environ["DATABASE_URL"]) as conn:
        revenue = revenue_by_region(conn, day)
        churn = churn_by_plan(conn, day)
        path = write_pdf(day, revenue, churn)
        record_run(conn, day, path)


if __name__ == "__main__":
    main()
