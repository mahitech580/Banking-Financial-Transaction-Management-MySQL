# Advanced SQL: execution and interpretation guide

## Safe execution

- Use MySQL 8.0.18+ and a disposable development schema.
- Run the core setup scripts in the order documented in the root README before running analytics.
- Load optional operations seed data only when a case study uses cards, loans, repayments, fraud, disputes, or settlements.
- Execute one analytical script at a time. These examples are intended to be read-only; do not paste them into a production session without review.
- Use a read-only MySQL account for reporting whenever possible.

## Reading results responsibly

- Counts of attempts are not the same as successful financial movements.
- Gross transaction value is not net revenue, loss, or balance change.
- Card activity and account-ledger activity can represent overlapping events. Never sum them without a defined reconciliation model.
- Balance comparisons are diagnostic only unless opening balances, transfer posting rules, reversals, fees, and ledger completeness are known.
- Statistical outlier queries are review candidates. They do not establish fraud, intent, or customer risk by themselves.
- Date-based reports use the database session's time zone. Align session time zones before comparing extracts from different environments.

## Quality checks

Run the static project checks and test suite:

```bash
npm run check
npm test
```

The Node test suite checks filename sequencing, business-question annotations, and obvious destructive SQL statements. It does not parse SQL grammar or prove that queries execute against a live MySQL instance. Run integration checks against a disposable database before treating a query as verified.

## Extending the library

1. Give each case study a unique sequential filename.
2. Start with a concise business question and state important interpretation caveats.
3. Keep result grain explicit in the SELECT and GROUP BY clauses.
4. Handle zero denominators with `NULLIF` and include deterministic tie-breakers for window ordering.
5. Distinguish transaction attempts from successful activity.
6. Add representative synthetic fixtures or a documented manual verification query when introducing new schema dependencies.
