# Contact export

Users click "Export contacts" and the CSV downloads in the browser.
About 6 exports run per day across all tenants.

`edge-lb` closes a connection after 30 seconds without a byte in either direction.
The idle timer restarts on every byte that the upstream sends.

The stack has no job queue and no outbound email service today. Each new component needs an owner and on-call coverage.
