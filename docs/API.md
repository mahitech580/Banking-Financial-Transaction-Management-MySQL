# API Reference

Base URL for local development: `http://localhost:10000`. On Render, use the service's public URL. All responses are JSON unless the path is a static asset.

## Operational endpoints

### `GET /healthz`
Process liveness check. Returns HTTP 200 without needing MySQL:
```json
{ "ok": true, "service": "running" }
```

### `GET /api/health`
Checks MySQL connectivity and reports whether the configured schema is visible. Returns HTTP 503 if MySQL is missing or unreachable.

### `GET /api`
Returns the API route catalogue (overview, customers, accounts, transactions, analytics, branches, cards, loans, repayments, settlements, disputes, fraud events, and transfer operation).

## Read endpoints

| Method | Endpoint | Response |
|---|---|---|
| GET | `/api/overview` | Summary metrics and recent transactions |
| GET | `/api/customers?q=term` | Customer directory; optional search |
| GET | `/api/accounts?q=term` | Account directory; optional search |
| GET | `/api/transactions?q=term&status=SUCCESS` | Ledger search; supported statuses are PENDING, SUCCESS, FAILED and REVERSED |
| GET | `/api/analytics` | Daily activity, channels, transaction types and top customers |
| GET | `/api/branches` | Branch totals and aggregated balances |
| GET | `/api/cards` | Card registry; card numbers are masked in the UI |
| GET | `/api/loans` | Loan totals and linked repayment summaries |
| GET | `/api/repayments` | Individual scheduled and recorded payments |
| GET | `/api/settlements` | Settlement records and transaction references |
| GET | `/api/disputes` | Dispute records |
| GET | `/api/fraud-events` | Recorded fraud events |

Search terms are trimmed and length-limited by the server. Queries use parameter binding rather than concatenating user-provided search strings into SQL.

## Transfer operation

### `POST /api/transfers`

This demo-only write endpoint is disabled unless `ENABLE_DEMO_TRANSFERS=true` is explicitly configured.

Request:
```json
{
  "fromAccountId": 1,
  "toAccountId": 2,
  "amount": 100.00
}
```

When enabled, the endpoint validates positive integer account IDs, rejects identical accounts, requires a positive amount with no more than two decimal places, locks both account rows, verifies active status and available funds, inserts debit and credit ledger records, updates both balances, creates a transfer record and commits once. Errors roll back the operation.

Typical errors:
- `400`: invalid input
- `403`: demo transfers disabled
- `404`: account not found
- `409`: account not active or insufficient balance
- `503`: database not configured/unavailable or missing schema

This endpoint is **not authenticated** and is not designed for real financial accounts. Only enable it for a test database populated with synthetic records.

## Request size and JSON parsing

JSON request bodies are limited to 20 KB. Malformed JSON receives HTTP `400` with a stable `error` message; payloads exceeding the configured limit receive HTTP `413`. API responses, including these parser errors, use `Cache-Control: no-store`. Clients should correct the request rather than retrying the same invalid payload. The server does not echo the submitted body in the error response.

## Error handling

API errors use a JSON object with an `error` field. The application intentionally omits database credentials and raw SQL from client-facing responses. Detailed operational errors are logged by the server; avoid placing secrets or personal information in logs.

## Smoke tests

With dependencies installed:
```bash
npm test
```

The tests start the server without database credentials and cover liveness, expected database-unavailable responses, transfer fail-closed behavior, and delivery of static assets. They do not replace integration tests against a disposable MySQL instance.


## Caching and client handling

The Express service sets `Cache-Control: no-store` on `/api` responses because even synthetic financial records should not be cached by shared intermediaries. Clients should treat `503` as a database/configuration issue, `403` on transfer as the explicit demo-write flag being disabled, and `409` as an account-state or available-balance conflict. Keep the transfer action disabled in public deployments unless the service is isolated to synthetic test data.
