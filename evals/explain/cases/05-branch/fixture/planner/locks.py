import redis

_client = redis.Redis(host="redis-locks", port=6379)


def acquire(name, backend, ttl_seconds):
    if backend == "none":
        return True
    return bool(_client.set(f"lock:{name}", "1", nx=True, ex=ttl_seconds))
