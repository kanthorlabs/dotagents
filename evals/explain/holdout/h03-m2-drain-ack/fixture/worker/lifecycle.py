import logging
import time

log = logging.getLogger("lantern-worker")


def drain(pool, seconds):
    deadline = time.monotonic() + seconds
    pool.shutdown(wait=False)
    while any(thread.is_alive() for thread in pool._threads):
        if time.monotonic() > deadline:
            log.warning("drain deadline reached")
            return
        time.sleep(0.5)
    log.info("drain complete")
