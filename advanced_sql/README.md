# Advanced SQL Case-Study Library

This directory contains **400 sequentially numbered analytical case studies** (`001`–`400`) plus **24 supplemental queries** prefixed with `supplemental_`. Supplemental files preserve added analytics that previously collided with the numbered sequence.

## Requirements and setup

1. Use MySQL 8.0.18 or newer.
2. Initialize the schema and base records with root scripts `01_database_schema.sql` through `07_transaction_data.sql` in the order documented in the root README.
3. Run `29_demo_operations_data.sql` only for queries requiring optional card, loan-payment, fraud, dispute, settlement, or operations data.
4. Execute one analytical report at a time in MySQL Workbench or the MySQL CLI. Prefer a read-only MySQL account for reporting.

All repository seed rows are synthetic. Do not run setup or write-operation scripts against production data.

## Numbered topic map

| Scripts | Topic |
|---|---|
| 001–024 | Transaction fundamentals, date-based summaries, channel mix and customer activity |
| 025–065 | Distribution/outlier analysis, account and branch reports, lending, fraud, settlement/dispute and card topics |
| 066–096 | Customer/account activity, windows and rolling metrics, retry candidates and reconciliation diagnostics |
| 097–106 | Customer account footprint by risk, branch, city, cohort, age, account type/status, opening year and balance band |
| 107–126 | Ledger volume and reliability by channel, transaction type/status, branch, customer risk, account type and time |
| 127–136 | Transaction-ticket distribution by amount and transaction dimensions |
| 137–146 | Merchant performance by merchant traits, channel, branch, customer segment and time |
| 147–156 | Card inventory, status, limits, age, branch and customer cohort |
| 157–166 | Card spending by channel, status, card type, merchant, branch, risk and time |
| 167–176 | Transfer flows by status, initiation time, source/destination branch, account type and customer risk |
| 177–186 | Loan portfolio by type, status, branch, borrower risk, rate, tenure and principal |
| 187–196 | Repayment collection by payment status, loan type, risk, branch, due date, overdue age and timing |
| 197–206 | Fraud workload by event type, action, risk, channel, status, branch and detection time |
| 207–216 | Dispute resolution by status, reason, channel, branch, customer risk, age and amount band |
| 217–226 | Settlement reconciliation by status, channel, merchant, branch, transaction status, latency and amount |
| 227–236 | Audit activity by entity, action, event date/time, JSON detail type and entity/action pair |
| 237–246 | Account-balance profiles by branch, city, account type/status, risk, opening period and balance band |
| 247–256 | Customer cohort activity by signup cohort, transaction period, risk, branch, channel, type, status and amount |
| 257–266 | Branch operations by geography, channel, account type, risk, month, merchant category and time |
| 267–276 | Merchant/card activity and review signals by merchant traits, card type, channel, risk and period |
| 277–286 | Loan collection efficiency by loan type/status, branch, customer risk, due month, tenure, payment status, rate, principal and overdue band |
| 287–296 | Customer total exposure by risk, branch, city, cohort, age, account/loan portfolio size and active-account relationship |
| 297–306 | Customer quarterly net flow, product breadth/exposure, account channel preference, loan payment timeliness, settlement latency, card purchase repeats, long activity gaps, ledger-flow diagnostics, branch failure trends and fraud-detection latency |
| 307–316 | Card merchant breadth, multi-branch footprints, dispute exposure, age-band success rates, overdue repayments, account-type flows, statistical outliers, cumulative branch flows, settlement amount variance and risk-band deciles |
| 317–326 | Account activation cohorts, customer balance concentration, transfer routes, credit-card spend-to-limit proxy, weekly branch activity, settlement queue age, retry sequences, channel interarrival gaps, repayment collection and status transitions |
| 327–336 | Cross-source card/ledger comparisons, merchant-value volatility, channel concentration, customer channel breadth, dispute aging, quarterly repayment timeliness, fraud-signal overlap, branch risk mix and cross-account repeats |
| 337–342 | Card issue cohorts, timestamp-based settlement speed, customer attempt-volume outliers, monthly account coverage and net flow, loan schedule/principal ratios and audit event gaps |
| 343–357 | Account outcome mix, hourly and weekend channel quality, combined review signals, dormant accounts, cross-source matching, settlement duplicates, loan collection, dispute frequency, concentration, ranked daily transactions and latency gaps |
| 358–372 | Customer retention cohorts, transfer consistency/routes, card spend-to-limit proxies, account activation, missing repayment schedules, repayment aging, dispute/fraud outcomes, merchant/source comparisons, channel shifts and rolling branch/customer concentration metrics |
| 373–386 | Annual customer value ranks, balance deciles, fraud-event gaps, weekly branch outcomes, settlement coverage/matching, dispute exposure, transfer profiles, repeated-card candidates, daily failure spikes, active-card usage and overdue lending exposure |
| 387–400 | Repayment/settlement field consistency, reversed-transaction disputes, branch alignment, product breadth, transfer linkage/status, near-duplicate transfer candidates, merchant-reference coverage and card/account lifecycle reviews |

## Supplemental reconciliation and data-quality checks

The `supplemental_*.sql` reports cover cross-table ownership alignment for cards and loans; settlement timestamps, amounts and duplicate records; dispute amount and repeated-case checks; fraud action/score review; audit-log volume and entity churn; overdue repayment exposure; payment-status consistency; transfer debit/credit matching; account status/balance checks; card credit-limit configuration; and cross-branch customer account footprints.

These reports only surface candidates for review. For example, a customer may validly hold an account at a different branch, and multiple settlement or dispute records can be valid lifecycle events.

## Interpretation guardrails

- Count transaction attempts separately from successful movements. Failed, pending and reversed rows are not successful financial flows.
- Gross transaction value is not automatically net revenue, loss, or balance change.
- An unusual-activity pattern is a review candidate, not proof of fraud or intent.
- Settlement mismatches and balance-flow differences do not establish which system is correct.
- Stored balances cannot be reconstructed from partial transaction flows without opening-balance history and defined posting semantics.
- Card and account-ledger events can overlap; do not add amounts without a de-duplication policy.
- Time buckets use the MySQL session time zone. Align it before comparing extracts across environments.
- Seed data is small and suitable for learning, not production benchmarking.

## Quality checks

Run:

```bash
npm run check
npm test
```

Static checks validate the numbered filename sequence, supplemental naming, non-empty case-study files, introductory comments, distinct file contents and basic read-only query shape. They do not parse all MySQL syntax or replace execution against a disposable MySQL integration database.

## References

- [Core project README](../README.md)
- [Deployment guide](../DEPLOYMENT.md)
- [API reference](../docs/API.md)
- [QA checklist](../docs/QA_CHECKLIST.md)
- [Security policy](../SECURITY.md)
- [Expanded SQL guide](../docs/ADVANCED_SQL_GUIDE.md)
