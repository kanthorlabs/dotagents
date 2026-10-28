import logging
import signal
from concurrent.futures import ThreadPoolExecutor

import pika

from worker import settings
from worker.handler import handle
from worker.lifecycle import drain

log = logging.getLogger("lantern-worker")
pool = ThreadPoolExecutor(max_workers=settings.CONCURRENCY)


def on_message(channel, method, properties, body):
    pool.submit(handle, body)


def run():
    connection = pika.BlockingConnection(pika.URLParameters(settings.AMQP_URL))
    channel = connection.channel()
    channel.basic_consume(queue="thumbnails", on_message_callback=on_message, auto_ack=True)
    signal.signal(signal.SIGTERM, lambda signum, frame: channel.stop_consuming())
    channel.start_consuming()
    log.info("SIGTERM received, stop consuming, drain up to %ds", settings.DRAIN_SECONDS)
    drain(pool, settings.DRAIN_SECONDS)
    connection.close()
