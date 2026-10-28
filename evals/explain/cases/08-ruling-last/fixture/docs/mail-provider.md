# Mail provider rules for invoice-mailer

The new relay `smtp-mx-2` blocks a sender for 24 hours when one recipient bounces more than 5 times in one hour.
`smtp-old-1` has no such limit. `smtp-old-1` goes offline on 30 November.
A hard bounce means the mailbox does not exist. A soft bounce means the mailbox is full or the server is busy.
`invoice-mailer` does not tell hard bounces from soft bounces today.
