from ingest.db import pool

INSERT_HISTORY = """
INSERT INTO readings (device_id, value, read_at)
VALUES (%(device_id)s, %(value)s, %(read_at)s)
"""

UPSERT_LATEST = """
INSERT INTO latest_reading (device_id, value, read_at)
VALUES (%(device_id)s, %(value)s, %(read_at)s)
ON CONFLICT (device_id) DO UPDATE
SET value = EXCLUDED.value, read_at = EXCLUDED.read_at
"""


async def save_reading(reading):
    async with pool.connection() as conn:
        async with conn.transaction():
            await conn.execute(INSERT_HISTORY, reading)
            await conn.execute(UPSERT_LATEST, reading)
