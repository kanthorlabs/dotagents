# Proposal: JetStream redelivery instead of with_retries

Author: Ulrich

## Change

- Delete `ingest/retry.py` and the `with_retries` call in `ingest/handler.py`.
- On `TransientError`, the handler calls `msg.nak(delay=...)` with the delay for the delivery count: 2, 4, 8, 16, 32 seconds.
- When `msg.metadata.num_delivered` reaches 6, the handler publishes the message to `ingest.dlq` and acks it.
- In `deploy/consumer.yaml`: `max_ack_pending: 256`, `max_deliver: 6`.

## Goal

- A failing reading no longer blocks every other reading while it waits.
