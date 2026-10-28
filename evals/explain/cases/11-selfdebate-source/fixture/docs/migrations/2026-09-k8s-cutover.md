# Cutover of scheduled jobs from ops-box-2 to Kubernetes

Owner: Henrik Saar. Cutover date: 21 September 2026.

- [x] Create CronJob `digest-builder` in namespace `brightpost`
- [x] Create CronJob `rotate-logs`
- [x] Verify the first Kubernetes run of `digest-builder` on 22 September
- [ ] Remove the `digest_builder` line from the crontab of `ops-box-2`
- [ ] Remove the `rotate-logs` line from the crontab of `ops-box-2`
- [ ] Decommission `ops-box-2`, planned for Q1 2027
