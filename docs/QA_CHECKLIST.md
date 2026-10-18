# QA Checklist

Use this checklist before demonstrating the portfolio project or changing its database configuration.

## 1. Static checks

- [ ] Install dependencies with `npm install`.
- [ ] Run `npm run check` to parse the server and browser JavaScript.
- [ ] Run `npm test` to execute the no-database smoke tests.
- [ ] Confirm the latest commit is on `main` and the deployment uses that branch.

## 2. Service health

- [ ] `GET /healthz` returns HTTP 200 when the app process is running.
- [ ] `GET /api/health` returns `database: connected` only after MySQL is configured and reachable.
- [ ] A missing or unreachable database results in clear HTTP 503 responses from data endpoints, not fabricated dashboard metrics.
- [ ] Review service logs for startup errors without exposing credentials.

## 3. MySQL setup

- [ ] Use MySQL 8.0+ and a disposable database.
- [ ] Run scripts 01–07 in order.
- [ ] Run `29_demo_operations_data.sql` to populate example cards, loans, repayments, fraud events, disputes and settlements.
- [ ] Run read-only analytics and views, and confirm each referenced table exists.
- [ ] Script 01 is non-destructive (`CREATE DATABASE IF NOT EXISTS`); perform any manual reset only on a disposable demo database.

## 4. Dashboard behavior

- [ ] Overview metrics match direct SQL counts and sums.
- [ ] Customer and account search returns matching rows.
- [ ] Transaction search and each status filter operate as expected.
- [ ] Analytics show sensible values or a clear empty state.
- [ ] Cards, branches, loans, repayments, settlements, disputes and fraud screens handle empty datasets.
- [ ] CSV exports contain the visible rows and correctly quote commas and double quotes.
- [ ] Desktop and mobile navigation can reach every page.

## 5. Demo transfer tests — isolated synthetic data only

- [ ] Keep `ENABLE_DEMO_TRANSFERS=false` on any public or shared instance by default.
- [ ] On a private disposable test database only, enable the flag explicitly.
- [ ] Confirm a valid transfer creates outgoing and incoming transaction entries and changes both account balances by equal amounts.
- [ ] Confirm insufficient balance is rejected with no balance or ledger change.
- [ ] Confirm a closed/frozen account and same-account transfer are rejected.
- [ ] Confirm invalid amounts and unknown account IDs are rejected.
- [ ] Confirm failures roll back all related writes.
- [ ] Turn the flag off after the demo.

The automated smoke tests do not exercise successful MySQL transfers. Perform those checks only with an isolated database and reconcile the related rows before and after each test. This project is not production banking software.

- [ ] Run the balance, repayment and fraud-score validation queries added to `03_constraints.sql` and confirm they return no invalid rows.
- [ ] Review `29_demo_operations_data.sql` counts and referential-integrity checks after optional seed loading.
- [ ] Verify API responses carry `Cache-Control: no-store` and the transfer route stays disabled by default.
