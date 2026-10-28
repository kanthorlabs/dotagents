# INC-57: STRIPE_API_KEY in a public support ticket

Date: 24 October 2026. Reporter: Selin Aydin (security).

A customer enabled `debug` on a `feed-fetch` request and pasted the stderr output into a public support ticket.
The output held the full environment of the plugin, including `STRIPE_API_KEY` and `SENTRY_DSN`.
`STRIPE_API_KEY` was added to the runner environment on 2 October for the new billing worker.
The key was rotated on 24 October.
