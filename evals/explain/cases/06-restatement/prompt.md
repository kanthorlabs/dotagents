I call you Aelita. Below is our conversation so far. Answer my last message.

---

**Ulrich:** Explain why users of `pinecrest-app` get logged out after about 30 minutes even while they click around.

**Aelita:** `edge-proxy` never refreshes `last_seen_at`, so `session-gc` deletes active sessions 30 minutes after login. Aelita recommends turning on `touch_on_request` in production.

**Timeline without the fix**

1. Lena Vogt logs in at 09:00. `auth-service` writes her session with `last_seen_at` 09:00.
2. Lena clicks through `pinecrest-app` from 09:00 to 09:40. Each request passes `edge-proxy`.
3. `edge-proxy` skips the touch call, because `touch_on_request` is false in `config/prod.yaml`.
4. `session-gc` runs at 09:40. Its 10-minute schedule finds `last_seen_at` older than 30 minutes.
5. `session-gc` deletes the session. Lena lands on the login page in the middle of her work.

**Question.** Do we turn on `touch_on_request` in production, or move the touch into `auth-service`?

---

**Ulrich:** Let me check that I get it. `session-gc` runs every 10 minutes. It deletes sessions that look idle for 30 minutes. And the real problem is that `session-gc` compares `last_seen_at` in local time against UTC, so active sessions look older than they are. Right?
