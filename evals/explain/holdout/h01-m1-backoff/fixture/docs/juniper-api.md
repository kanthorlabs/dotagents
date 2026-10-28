# Juniper CRM API v2: notes for tidepool-sync

## Rate limit

- The standard tier allows 100 requests per minute per API key.
- tidepool-sync uses one API key, `JUNIPER_API_KEY`, for all workers.
- A request above the limit returns HTTP 429 with `Retry-After: 60`.

## Endpoints

- `PUT /v2/contacts/{external_id}` upserts one contact.
- `POST /v2/contacts:batchUpsert` upserts up to 100 contacts in one call. One batch call counts as one request against the rate limit. The response lists the result per contact.
- A batch call with 100 contacts takes 5 to 7 seconds.

## Tiers

- The enterprise tier allows 1,000 requests per minute per API key.
- It costs 1,450 USD per month on top of the current contract.
- Juniper sales quotes a lead time of 3 weeks for a tier change.
