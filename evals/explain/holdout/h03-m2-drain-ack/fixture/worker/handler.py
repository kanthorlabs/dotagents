import json
import logging
import time

from billing.client import record_usage
from worker.render import render_thumbnail
from worker.storage import put_thumbnail

log = logging.getLogger("lantern-worker")


def handle(body):
    job = json.loads(body)
    started = time.monotonic()
    log.info("job start upload=%s kind=%s", job["upload_id"], job["kind"])
    image = render_thumbnail(job["source_url"], job["kind"])
    put_thumbnail(f"thumbs/{job['upload_id']}.webp", image)
    record_usage(job["account_id"], "thumbnail", job["upload_id"])
    log.info("job done upload=%s kind=%s %.1fs", job["upload_id"], job["kind"], time.monotonic() - started)
