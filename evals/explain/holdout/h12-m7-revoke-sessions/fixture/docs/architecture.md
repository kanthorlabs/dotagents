# quayside-api architecture

- Peak load: about 2,500 API requests per second.
- `api/auth/middleware.py` validates the access token on every request. It reads neither the database nor Redis.
- Redis `quayside-cache` is available to the API. Today it holds rate-limit counters only.
- The mobile app refreshes its access token with `POST /auth/refresh` when the access token expires.
