# Advanced SQL Case-Study Library

This folder contains **65 standalone analytical SQL examples** (`001`–`065`) built on the `banking_financial_management` schema. Each file starts with a business question and is intended to be opened and executed individually.

## Requirements and setup

1. Use MySQL 8.0.18 or newer.
2. Create the schema and base tables by running root scripts `01_database_schema.sql` through `07_transaction_data.sql` in order.
3. Run `29_demo_operations_data.sql` if you want the optional card, loan repayment, fraud, dispute and settlement reports to return seeded examples.
4. Open one script at a time in MySQL Workbench or the MySQL CLI. The files in this folder are intended as read-only analytical queries.

Do not run database reset/setup scripts against production data. All seed records in this repository are synthetic.

## Case-study map

| Scripts | Topic |
|---|---|
| 001–008 | Monthly summaries, growth, success rates, credit/debit flow, account rankings, median and percentile analysis |
| 009–015 | Running values, first/last activity, inactivity, customer transaction frequency, debit and net-flow analysis |
| 016–024 | Daily/hourly/weekday patterns, after-hours activity, channel/type mix, merchant value, transaction frequency |
| 025–030 | Customer-relative outliers, branch/account balances, branch summaries, branch rankings and monthly trends |
| 031–040 | Loan portfolio, repayments, overdue candidates, missed payments, coverage, customer/branch exposure and repayment delays |
| 041–050 | Recorded fraud cases, risk bands, channel comparisons, repeated alerts, high-value candidates, transaction sequence/amount changes |
| 051–057 | Pending settlements, reconciliation differences, missing settlements, disputes and disputed-value breakdowns |
| 058–060 | Card portfolio status, blocked cards and accounts without linked cards |
| 061–065 | Customer/account coverage, customers without accounts, account-type/status totals, balance share and quartile segmentation |

## Interpretation notes

- Transaction amount totals should be interpreted alongside the transaction status. A failed, pending or reversed row is not the same as a successful financial movement.
- An outlier query or rule-based alert is a review candidate, not proof of fraud or malicious intent.
- A settlement mismatch highlights data for reconciliation; it does not by itself identify which system is correct.
- Median, percentile and window-function examples require MySQL 8-compatible window functions.
- The seeded dataset is intentionally small. Performance conclusions require a larger representative test dataset and query-plan inspection.

## Root project references

- [Core project README](../README.md)
- [Database and dashboard deployment](../DEPLOYMENT.md)
- [API reference](../docs/API.md)
- [QA checklist](../docs/QA_CHECKLIST.md)
- [Security policy](../SECURITY.md)
