from pathlib import Path

OUTPUT_DIR = Path("/srv/osprey/reports")


def write_pdf(day, revenue, churn):
    path = OUTPUT_DIR / f"nightly-{day.isoformat()}.pdf"
    path.write_bytes(_render(day, revenue, churn))
    return str(path)


def _render(day, revenue, churn):
    from reports.pdf import build

    return build(title=f"Nightly report {day.isoformat()}", revenue=revenue, churn=churn)
