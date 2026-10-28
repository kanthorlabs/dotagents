# kestrel-scheduler

- Each file in `schedules/` defines one job with a five-field cron expression and a timezone.
- The scheduler matches the cron expression against the local wall-clock time in that timezone.
- `kestrel-scheduler` runs as one process. It ticks every 15 seconds.
