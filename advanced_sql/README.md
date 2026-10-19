# Advanced SQL Case-Study Library

This folder contains **120 standalone analytical SQL examples** (`001`–`120`) built on the `banking_financial_management` schema. Each file is intended to be opened and executed individually. Newer examples include a short business question or explanatory comment.

## Requirements and setup

1. Use MySQL 8.0.18 or newer.
2. Create the schema and base tables by running root scripts `01_database_schema.sql` through `07_transaction_data.sql` in order.
3. Run `29_demo_operations_data.sql` if you want the optional card, loan repayment, fraud, dispute and settlement reports to return seeded examples.
4. Open one script at a time in MySQL Workbench or the MySQL CLI. These examples are intended as read-only analytical queries.

Do not run database reset/setup scripts against production data. All seed records in this repository are synthetic.

## Case-study map

| Scripts | Topic |
|---|---|
| 001–008 | Monthly summaries, growth, success rates, credit/debit flow, rankings, median and percentiles |
| 009–015 | Running values, first/last activity, inactivity and customer frequency |
| 016–024 | Daily/hourly/weekday patterns, channels, types and merchants |
| 025–030 | Relative outliers, branch/account balances and branch trends |
| 031–040 | Loan portfolio, repayments, overdue candidates and exposure |
| 041–050 | Fraud review candidates, risk bands, repeated alerts and transaction sequences |
| 051–057 | Settlements, reconciliation differences and disputes |
| 058–065 | Card portfolio and account/customer coverage |
| 066–076 | Additional customer, account, transaction and operations analysis |
| 077–086 | Monthly success rate, customer net flow, amount deciles, merchant failures, activity gaps, recency, transfer consistency and daily/channel summaries |
| 087–096 | Risk/activity matrix, account concentration, branch mix, customer cohort activity, outlier candidates, balance-flow diagnostics, card-vs-ledger comparisons and weekly channel performance |
| 097–106 | Channel amount deciles, onboarding cohorts, inactive high-balance accounts, repeated-amount review, first-transaction latency, account trends, branch coverage and merchant comparisons |
| 107–116 | Account value ranking, ATM/fee summaries, amount integrity checks, retry candidates, historical baselines, weekend/weekday analysis and amount-band conversion |
| 117–120 | Channel-days without successes, branch balance share, customers without transaction history and account channel adoption |

## Interpretation notes

- Transaction amount totals must be interpreted alongside transaction status. A failed, pending or reversed row is not the same as a successful financial movement.
- An outlier query or rule-based alert is a review candidate, not proof of fraud or malicious intent.
- Settlement mismatches and balance-flow differences are diagnostic candidates, not automatic evidence that a particular source is correct.
- Card activity and ledger activity may overlap; do not add them together without a de-duplication model.
- Window-function examples require MySQL 8-compatible window functions.
- The seeded dataset is intentionally small. Performance conclusions require a larger representative test dataset and query-plan inspection.

## Quality checks

Run `npm run check` and `npm test`. The static advanced-SQL checks validate naming sequence, introductory comments and obvious destructive statements; they do not parse SQL grammar or prove that every query executes against a live MySQL instance.

## Root project references

- [Core project README](../README.md)
- [Database and dashboard deployment](../DEPLOYMENT.md)
- [API reference](../docs/API.md)
- [QA checklist](../docs/QA_CHECKLIST.md)
- [Security policy](../SECURITY.md)
- [Expanded SQL guide](../docs/ADVANCED_SQL_GUIDE.md)
