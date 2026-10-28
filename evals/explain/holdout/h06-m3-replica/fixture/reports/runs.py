RECORD_RUN = """
INSERT INTO report_runs (report_date, pdf_path, finished_at)
VALUES (%(day)s, %(path)s, now())
"""


def record_run(conn, day, path):
    conn.execute(RECORD_RUN, {"day": day, "path": path})
    conn.commit()
