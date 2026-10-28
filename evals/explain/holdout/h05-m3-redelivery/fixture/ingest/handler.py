from ingest.dlq import publish_dead_letter
from ingest.parse import parse_reading
from ingest.retry import with_retries
from ingest.store import save_reading


async def on_reading(msg):
    reading = parse_reading(msg.data)
    try:
        await with_retries(lambda: save_reading(reading))
    except Exception:
        await publish_dead_letter(msg)
    await msg.ack()
