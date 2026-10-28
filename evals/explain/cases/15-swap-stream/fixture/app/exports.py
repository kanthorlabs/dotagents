import csv
import io

from ferngrove import db
from ferngrove.web import Response, route


@route("GET", "/exports/contacts.csv")
def export_contacts(request):
    rows = db.query("SELECT id, name, email, company, created_at FROM contacts WHERE tenant_id = %s", (request.tenant_id,))
    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["id", "name", "email", "company", "created_at"])
    writer.writerows(rows)
    return Response(buffer.getvalue(), content_type="text/csv")
