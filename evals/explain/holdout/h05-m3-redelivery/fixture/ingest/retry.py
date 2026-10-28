import asyncio

from ingest.errors import TransientError

DELAYS_SECONDS = [2, 4, 8, 16, 32]


async def with_retries(operation):
    for delay in DELAYS_SECONDS:
        try:
            return await operation()
        except TransientError:
            await asyncio.sleep(delay)
    return await operation()
