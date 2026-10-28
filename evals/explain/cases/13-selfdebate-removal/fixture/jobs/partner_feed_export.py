import csv

from cartwheel import sftp


def export(db):
    rows = db.query("SELECT partner_ref, name, price_cents FROM v_partner_feed ORDER BY partner_ref")
    with open("/tmp/oakline-feed.csv", "w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["partner_ref", "name", "price_cents"])
        writer.writerows(rows)
    sftp.upload("/tmp/oakline-feed.csv", host="sftp.oaklinesupply.com", path="/inbound/cartwheel.csv")
