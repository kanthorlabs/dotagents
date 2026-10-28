import os

MAX_CONTENT_LENGTH = 10 * 1024 * 1024
BUCKET = os.environ.get("PINEWOOD_BUCKET", "pinewood-files")
