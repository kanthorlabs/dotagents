# Invoice export

Accountants export invoices at month end to reconcile their books.
At month end, about 900 exports run in two days. On other days, about 20 exports run per day.

`gw-billing` closes a connection after 30 seconds without a byte, and after 300 seconds in total.

The stack runs `taskq` with the queue `documents` and the `mailer` service. Invoice PDFs already use them.
