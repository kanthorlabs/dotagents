import os

AMQP_URL = os.environ["LANTERN_AMQP_URL"]
CONCURRENCY = int(os.environ.get("LANTERN_CONCURRENCY", "4"))
DRAIN_SECONDS = int(os.environ.get("LANTERN_DRAIN_SECONDS", "60"))
