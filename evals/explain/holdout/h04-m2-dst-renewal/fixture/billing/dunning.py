from billing import db, mail


def send_dunning(today):
    overdue = db.query("SELECT customer_id, email FROM invoices WHERE status = 'overdue' AND due_on < %s", today)
    for row in overdue:
        mail.send(row.email, template="dunning-reminder")
    return len(overdue)
