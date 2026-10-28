from ingest.nats import js


async def publish_dead_letter(msg):
    await js.publish("ingest.dlq", msg.data, headers={"original-subject": msg.subject})
