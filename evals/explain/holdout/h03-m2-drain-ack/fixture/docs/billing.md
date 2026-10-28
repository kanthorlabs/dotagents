# Billing

- Every thumbnail counts as one billable unit. `billing.client.record_usage` posts the unit to `meter.internal`.
- `meter.internal` belongs to the Billing team. Its code and its documentation are not part of the `lantern-jobs` repository.
