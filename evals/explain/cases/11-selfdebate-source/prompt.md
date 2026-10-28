I call you Aelita.

Aelita, `digest-mailer` sends the Monday digest of `brightpost` twice to every subscriber since late September. I see two fixes: dedupe in `digest-mailer` by email address, or add a unique index on `outbox(subscriber_id, digest_date)`. Explain the problem and recommend one. The repository is in the current directory.
