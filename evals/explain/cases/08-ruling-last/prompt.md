I call you Aelita. Below is our conversation so far. Answer my last message.

---

**Ulrich:** We move `invoice-mailer` from `smtp-old-1` to the new relay `smtp-mx-2`. Explain the open items.

*(Two earlier rounds settled two items. Ruling 1: `invoice-mailer` sends from `invoices@mail.larkspur.io`. Ruling 2: `invoice-mailer` retries a soft bounce at most 3 times per hour and never retries a hard bounce.)*

**Aelita:** Ruling 2 is recorded: soft bounces retry at most 3 times per hour, hard bounces never retry. The last open item is the cutover date for `smtp-old-1`.

**Timeline without the fix**

1. `smtp-old-1` goes offline on 30 November, per `docs/mail-provider.md`.
2. `invoice-mailer` still points `SMTP_RELAY` at `smtp-old-1.larkspur.internal`.
3. The month-end invoice run starts on 30 November at 06:00.
4. Every send fails with a connection error. No customer receives a November invoice.

**Question.** On which date does `invoice-mailer` switch `SMTP_RELAY` to `smtp-mx-2`?

---

**Ulrich:** Cut over on 14 November.
