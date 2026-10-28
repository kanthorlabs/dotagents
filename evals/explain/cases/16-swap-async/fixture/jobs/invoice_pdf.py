from tallyhall import mailer, storage, taskq


@taskq.task(queue="documents")
def render_invoice_pdf(invoice_id, recipient):
    pdf = render(invoice_id)
    key = storage.put(f"invoices/{invoice_id}.pdf", pdf)
    url = storage.signed_url(key, expires_hours=72)
    mailer.send(recipient, "Your invoice", f"Download: {url}")


def render(invoice_id):
    raise NotImplementedError
