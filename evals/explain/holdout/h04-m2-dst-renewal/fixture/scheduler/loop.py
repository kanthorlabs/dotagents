import logging
import time
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

from scheduler.clock import due_jobs
from scheduler.registry import load_jobs, run_job

log = logging.getLogger("kestrel-scheduler")
TICK_SECONDS = 15


def main():
    jobs = load_jobs("schedules")
    last_fired = {}
    while True:
        now_utc = datetime.now(timezone.utc)
        for job in due_jobs(jobs, last_fired, now_utc):
            local = now_utc.astimezone(ZoneInfo(job.timezone))
            log.info("fire %s local=%s", job.name, local.strftime("%H:%M%z"))
            last_fired[job.name] = now_utc
            run_job(job, local.date())
        time.sleep(TICK_SECONDS)
