from datetime import date


def build(db):
    digest_date = date.today()
    for subscriber in db.query("SELECT id, email FROM subscribers WHERE active"):
        db.execute(
            "INSERT INTO outbox (subscriber_id, email, digest_date, status) "
            "VALUES (%s, %s, %s, 'pending')",
            (subscriber.id, subscriber.email, digest_date),
        )


if __name__ == "__main__":
    from brightpost.db import connect
    build(connect())
