from brightpost import smtp


def send_pending(db):
    for row in db.query("SELECT id, email, digest_date FROM outbox WHERE status = 'pending'"):
        smtp.send_digest(row.email, row.digest_date)
        db.execute("UPDATE outbox SET status = 'sent' WHERE id = %s", (row.id,))
