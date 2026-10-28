from zoneinfo import ZoneInfo

from scheduler.cron import matches

MIN_GAP_SECONDS = 60


def due_jobs(jobs, last_fired, now_utc):
    due = []
    for job in jobs:
        local = now_utc.astimezone(ZoneInfo(job.timezone))
        if not matches(job.cron, local):
            continue
        previous = last_fired.get(job.name)
        if previous is not None and (now_utc - previous).total_seconds() < MIN_GAP_SECONDS:
            continue
        due.append(job)
    return due
