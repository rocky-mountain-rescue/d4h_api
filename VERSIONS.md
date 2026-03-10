# Versions

## 2.1.0 (2026-03-10)

- Switched Faraday request encoding from `url_encoded` to `json` in API client connection

## 2.0.1 (2026-03-10)

- Made `context_id` optional on `Client` — only required for context-scoped resources
- `whoami` now hits `v3/whoami` directly (no context prefix), matching the D4H API spec
- A client created without `context_id` can call `whoami.show` for identity discovery; other resources raise `ArgumentError`
- Error messages now include `title` and `detail` fields from D4H v3 API error responses

## 2.0.0 (2026-03-09)

- Migrated from D4H API v2 to v3 (new URL patterns, page-based pagination, Bearer auth)
- Required Ruby >= 4.0
- Replaced RSpec with Minitest
- Added 56 resource endpoints covering the full D4H API surface
- Added `Collection` class with `Enumerable` for paginated results
- Added `list_all` auto-pagination on all list-capable resources
- Updates use PATCH (except documents which use PUT)
- Client now requires `context_id:` and supports `context:` ("team" or "organisation")
- Added exponential backoff retry for transient errors (429, 500, 502, 503, 504) via `faraday-retry`
- Added `RetriableError` subclass to distinguish transient from permanent failures
- Configurable `max_retries:` (default 3) and `retry_interval:` (default 1s) on Client
- Retry logs to stderr: `[D4H] Retry 1/3 for GET .../members ...`

## 0.0.5 (2023-01-26)

- Updated gem version.

## 0.0.0 (2023-01-26)

- Added initial implementation.
