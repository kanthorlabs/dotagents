# Consumers of sparrow-ingest data

- `readings` holds the full history. Reports and exports read it by `read_at`.
- `latest_reading` holds one row per device. The live map reads it.
- The alert rule `freezer-temp-high` reads `latest_reading`. It fires when the latest value of a freezer sensor stays above -15 °C for 10 minutes.
- Each device sends one reading every 30 seconds on subject `readings.<device_id>`.
