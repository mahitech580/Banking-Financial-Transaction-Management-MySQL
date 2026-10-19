# Advanced SQL Case-Study Library

This directory contains two kinds of read-only analytics: sequentially numbered case studies (`NNN_topic.sql`) and supplemental examples named `supplemental_*.sql`. Supplemental filenames retain their previous number after the prefix for traceability but do not consume numbered sequence slots.

## Requirements and setup

1. Use MySQL 8.0.18 or newer.
2. Create the schema and core records by running root scripts `01_database_schema.sql` through `07_transaction_data.sql` in order.
3. Run `29_demo_operations_data.sql` only when a report needs optional card, loan-payment, fraud, dispute, or settlement records.
4. Run one report at a time in MySQL Workbench or the MySQL CLI. Use a read-only database user for analysis whenever possible.

All seed records are synthetic. Do not run setup or write-operation scripts against a production database.

## Topic map

| Numbered scripts | Topic |
|---|---|
| 001–008 | Monthly summaries, growth, success rates, flows, ranks, medians and percentiles |
| 009–024 | Running values, first/last activity, inactivity, customer frequency and channel patterns |
| 025–040 | Relative outliers, branch/account balances, branch trends, loans and repayment exposure |
| 041–065 | Fraud review candidates, risk bands, settlement/dispute analysis, card portfolios and account coverage |
| 066–096 | Customer/account activity, transaction-time patterns, rolling values, retry candidates and cross-source diagnostics |
| 097–106 | Customer account footprint, customer cohorts, age/balance bands and account status |
| 107–116 | Ledger transaction volume segmented by channel, type, status, branch, risk, account type and time |
| 117–126 | Ledger reliability diagnostics across transaction dimensions |
| 127–136 | Transaction ticket distribution by amount, channel, type, status, branch, risk and time |
| 137–146 | Merchant performance across merchant traits, channel, branch, customer segment and time |
| 147–156 | Card inventory, card status, credit limits, age, branch and customer cohorts |
| 157–166 | Card spending by channel, status, card type, merchant, branch, risk and time |
| 167–176 | Transfer flow by status, initiation time, source/destination branch, account type and customer risk |
| 177–186 | Loan portfolio by type, status, servicing branch, customer risk, start date, rate, tenure and principal |
| 187–196 | Repayment collection by payment status, loan type, risk, branch, due date, overdue age and payment timing |
| 197–206 | Fraud workload by event type, action, risk, channel, transaction status, branch and detection time |
| 207–216 | Dispute resolution by status, reason, channel, branch, customer risk, merchant category, age and amount band |
| 217–226 | Settlement reconciliation by status, channel, merchant, branch, settlement time, transaction state, latency and amount band |

Supplemental queries are intentionally separate from the numbered index to prevent filename collisions. Use `ls advanced_sql` or your editor's file search to find a supplemental report by its descriptive filename.

## Interpretation guardrails

- Count transaction attempts separately from successful movements. Failed, pending and reversed rows are not successful financial flows.
- Gross transaction value is not automatically net revenue, loss, or balance change.
- A matched amount or unusual activity pattern is a review candidate, not proof of fraud or intent.
- Settlement mismatches and balance-flow differences are diagnostic signals; they do not establish which system is correct.
- Account balances cannot be reconstructed from partial transaction flows without an opening balance and documented posting semantics.
- Card and ledger events may overlap. Do not add their amounts without a defined de-duplication policy.
- Time buckets use the MySQL session time zone. Align it before comparing extracts from separate environments.
- The seeded dataset is small and supports learning, not meaningful production performance conclusions.

## Quality checks

Run:

```bash
npm run check
npm test
```

Automated tests check that numbered SQL filenames form a gap-free sequence, all reports have a leading comment, and obvious data-changing statements do not appear in analytical scripts. These checks do not parse SQL grammar or replace execution against a disposable MySQL integration database.

## References

- [Core project README](../README.md)
- [Database and dashboard deployment](../DEPLOYMENT.md)
- [API reference](../docs/API.md)
- [QA checklist](../docs/QA_CHECKLIST.md)
- [Security policy](../SECURITY.md)
- [Advanced SQL execution guide](../docs/ADVANCED_SQL_GUIDE.md)
