-- Query tuning laboratory. Compare plans before/after indexes; actual gains depend on data size.
USE banking_financial_management;

-- 1. Equality filter + ordered account history. Review key, rows and Extra in the plan.
EXPLAIN
SELECT transaction_id, reference_code, amount, transaction_time, status
FROM transactions
WHERE account_id = 1
ORDER BY transaction_time DESC, transaction_id DESC
LIMIT 25;

-- 2. Outcome/date filter. The composite index may help this access pattern.
EXPLAIN
SELECT transaction_id, amount, transaction_time
FROM transactions
WHERE status = 'SUCCESS'
  AND transaction_time >= '2026-10-01'
  AND transaction_time <  '2026-11-01'
ORDER BY transaction_time DESC;

-- 3. SARGable date range: avoid applying DATE() to the indexed timestamp in WHERE.
-- Less index-friendly: WHERE DATE(transaction_time) = '2026-10-18'
EXPLAIN
SELECT reference_code, amount, transaction_time
FROM transactions
WHERE transaction_time >= '2026-10-18 00:00:00'
  AND transaction_time <  '2026-10-19 00:00:00';

-- 4. Keep a GROUP BY on the fact table narrow and join descriptive data afterward.
EXPLAIN
SELECT account_id, COUNT(*) AS transaction_count, SUM(amount) AS attempted_value
FROM transactions
WHERE status = 'SUCCESS'
GROUP BY account_id;

-- 5. Inspect indexes and optimizer statistics.
SHOW INDEX FROM transactions;
ANALYZE TABLE transactions, accounts, loan_payments, card_transactions;

-- 6. MySQL 8.0.18+: EXPLAIN ANALYZE executes the SELECT and reports actual timing/rows.
-- Run manually on representative data; do not use it for write statements.
-- EXPLAIN ANALYZE
-- SELECT transaction_id, amount, transaction_time
-- FROM transactions
-- WHERE account_id = 1
-- ORDER BY transaction_time DESC, transaction_id DESC
-- LIMIT 25;

-- Tuning checklist:
-- * Add indexes to measured access patterns, not every column.
-- * Check leftmost-prefix order for composite indexes.
-- * Keep timestamp predicates SARGable.
-- * Compare estimated rows with actual rows on realistic data.
-- * Avoid SELECT * in production endpoints.
-- * Re-check write cost and storage after adding indexes.


-- Prefer a half-open range over DATE(transaction_time)=... for index-friendly filtering.
EXPLAIN SELECT reference_code,amount,transaction_time FROM transactions WHERE transaction_time>='2026-10-18 00:00:00' AND transaction_time<'2026-10-19 00:00:00' ORDER BY transaction_time;


-- Inspect the access path for account + status + time predicates.
EXPLAIN SELECT transaction_id,reference_code,amount,transaction_time FROM transactions WHERE account_id=1 AND status='SUCCESS' AND transaction_time>='2026-10-01' AND transaction_time<'2026-11-01' ORDER BY transaction_time DESC LIMIT 30;
