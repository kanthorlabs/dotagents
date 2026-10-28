from datetime import datetime, timedelta, timezone

IDLE_LIMIT = timedelta(minutes=30)


def collect(db):
    cutoff = datetime.now(timezone.utc) - IDLE_LIMIT
    db.execute("DELETE FROM sessions WHERE last_seen_at < %s", (cutoff,))
