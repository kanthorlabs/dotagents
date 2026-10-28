import json

import redis

_client = redis.Redis.from_url("redis://events.saltmarsh.internal:6379/0")


def publish(channel, payload):
    _client.publish(channel, json.dumps(payload))


def subscribe(channel, handler):
    pubsub = _client.pubsub()
    pubsub.subscribe(**{channel: lambda message: handler(json.loads(message["data"]))})
    return pubsub.run_in_thread(sleep_time=0.5, daemon=True)
