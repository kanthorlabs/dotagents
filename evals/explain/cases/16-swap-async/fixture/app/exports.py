import csv
import io

from tallyhall import db
from tallyhall.web import Response, route


@route("GET", "/exports/invoices.csv")
def export_invoices(request):
    rows = db.query("SELECT id, number, customer, total_cents, issued_at FROM invoices WHERE tenant_id = %s", (request.tenant_id,))
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["id", "number", "customer", "total_cents", "issued_at"])
    writer.writerows(rows)
    return Response(buffer.getvalue(), content_type="text/csv")
