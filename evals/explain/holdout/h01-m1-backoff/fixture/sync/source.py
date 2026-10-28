from sync import db


def changed_contacts():
    return db.query(
        "SELECT * FROM contacts WHERE synced_at IS NULL OR updated_at > synced_at ORDER BY updated_at"
    )


def mark_synced(external_id):
    db.execute("UPDATE contacts SET synced_at = now() WHERE external_id = %s", external_id)
