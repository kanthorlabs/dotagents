I call you Aelita. Below is our conversation so far. Answer my last message.

---

**Ulrich:** We move `invoice-mailer` from `smtp-old-1` to the new relay `smtp-mx-2`. Explain the open items.

**Aelita:** Three items are open for the move of `invoice-mailer` to `smtp-mx-2`. This message raises the first one. The retry limit for bounced mails and the cutover date for `smtp-old-1` follow after the answer.

**Timeline without the fix**

1. Larkspur sends invoice INV-2207 to Oskar Brandt from `billing@larkspur.io`.
2. `smtp-mx-2` checks the SPF record of `larkspur.io`. The record lists `smtp-old-1` only.
3. `smtp-mx-2` signs the mail, but the receiver sees a sender domain that does not authorize the relay.
4. The receiver files INV-2207 as spam. Oskar Brandt never sees the invoice.

**Question.** Does `invoice-mailer` keep sending from `billing@larkspur.io` with an updated SPF record, or move to the new address `invoices@mail.larkspur.io`, whose SPF record already lists `smtp-mx-2`?

---

**Ulrich:** Move to invoices@mail.larkspur.io.
