# Advanced SQL: execution and interpretation guide

## Safe execution

- Use MySQL 8.0.18+ and a disposable development schema.
- Run the core setup scripts in the order documented in the root README before running analytics.
- Load optional operations seed data only when a case study needs cards, loans, repayments, fraud, disputes or settlements.
- Execute one analytical script at a time. These examples are intended to be read-only; do not paste them into a production session without review.
- Use a read-only database user for reporting whenever possible.

## Reading results responsibly

- Counts of attempts are different from successful financial movements.
- Gross transaction value is not net revenue, loss or balance change.
- Card activity and account-ledger activity can overlap. Never sum them without a defined reconciliation model.
- Balance comparisons are diagnostic unless opening balances, transfer posting rules, reversals, fees and ledger completeness are known.
- Statistical outliers and rule-based alerts are review candidates; they do not establish fraud, intent or customer creditworthiness.
- Date-based reports use the database session time zone. Align session time zones before comparing extracts.

## Library organization

- Files named `001_*.sql` through `400_*.sql` form the unique numbered learning path.
- Additional reports use the `supplemental_*.sql` prefix so they never collide with the numbered sequence.
- Each report is a read-only `SELECT` or CTE query. A few use MySQL 8 window functions, `JSON_TYPE`, `GROUP_CONCAT`, or date functions; verify compatibility with the schema and SQL mode in your environment.

## Quality checks

Run the static project checks and test suite:

```bash
npm run check
npm test
```

The Node suite checks sequential filenames, supplemental naming, duplicate contents, introductory comments, obvious destructive SQL statements and basic SELECT/CTE query shape. It does not fully parse MySQL grammar or prove that every report executes successfully against a live schema. Validate schema-sensitive reports in a disposable MySQL database before relying on their output.

## Extending the library

1. Give numbered examples the next available unique sequence; keep exploratory overflow in a clearly named supplemental file until catalogued.
2. Start with a concise business question and state interpretation caveats.
3. Keep the result grain explicit in each `SELECT` and `GROUP BY`.
4. Guard denominators with `NULLIF` and use deterministic tie-breakers in window ordering.
5. Distinguish transaction attempts from successful activity.
6. Add synthetic fixtures or document a manual verification query when adding schema dependencies.
