# Retention in vaultline

`retention_days` sets how long vaultline keeps an upload after it starts.
`purge-worker` runs every 15 minutes and deletes uploads older than the retention.
A multipart upload can stay in progress for up to 6 hours.
Supported values: 1 to 3650 days. A tenant that wants no retention deletes uploads through the API.
