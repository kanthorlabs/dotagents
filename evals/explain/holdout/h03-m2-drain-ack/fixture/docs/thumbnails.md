# Thumbnails

- An upload publishes one job to the RabbitMQ queue `thumbnails`.
- `lantern-worker` renders the thumbnail, writes `thumbs/<upload_id>.webp` to the bucket `lantern-thumbs`, and records one usage event for billing.
- Image thumbnails take 1 to 3 seconds. Video thumbnails take 25 to 70 seconds.
- The upload page shows a placeholder until `thumbs/<upload_id>.webp` exists. It shows no error.
