import os

from psycopg_pool import ConnectionPool

pool = ConnectionPool(
    conninfo=os.environ["DATABASE_URL"],
    min_size=4,
    max_size=10,
    timeout=30,
)
