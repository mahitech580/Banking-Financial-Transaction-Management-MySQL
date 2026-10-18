-- Foundational queries: filtering, sorting, CASE, aggregates and NULL-safe calculations.
USE banking_financial_management;

-- 1. Portfolio snapshot
SELECT
  (SELECT COUNT(*) FROM customers) AS customer_count,
  (SELECT COUNT(*) FROM accounts) AS account_count,
  (SELECT COUNT(*) FROM transactions) AS ledger_rows,
  (SELECT COUNT(*) FROM transactions WHERE status = 'SUCCESS') AS successful_transactions;

-- 2. Accounts by type and status
SELECT account_type, status, COUNT(*) AS account_count,
       ROUND(AVG(current_balance), 2) AS average_balance,
       SUM(current_balance) AS total_balance
FROM accounts
GROUP BY account_type, status
ORDER BY total_balance DESC;

-- 3. Transaction outcome breakdown. Amount totals include only successful value.
SELECT status, COUNT(*) AS transaction_count,
       SUM(amount) AS attempted_value,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct
FROM transactions
GROUP BY status
ORDER BY transaction_count DESC;

-- 4. Channel performance
SELECT channel, COUNT(*) AS transaction_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(CASE WHEN status = 'SUCCESS' THEN amount END), 2) AS average_successful_amount
FROM transactions
GROUP BY channel
ORDER BY successful_value DESC;

-- 5. A CASE expression classifies balances without changing stored data.
SELECT account_number, account_type, current_balance,
       CASE
         WHEN current_balance >= 100000 THEN 'HIGH BALANCE'
         WHEN current_balance >= 50000 THEN 'MEDIUM BALANCE'
         ELSE 'STANDARD BALANCE'
       END AS balance_segment
FROM accounts
ORDER BY current_balance DESC, account_id;

-- 6. Find customers whose email domain is the example test domain.
SELECT customer_number, email
FROM customers
WHERE email LIKE '%@example.com'
ORDER BY customer_number
LIMIT 20;


-- NULL-safe status summary
SELECT COALESCE(status, 'UNSPECIFIED') AS transaction_status,
       COUNT(*) AS row_count,
       COALESCE(SUM(amount), 0) AS attempted_value
FROM transactions
GROUP BY COALESCE(status, 'UNSPECIFIED')
ORDER BY row_count DESC;


-- Conditional outcome aggregation
SELECT channel,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(status = 'FAILED') AS failed_count,
       SUM(status = 'PENDING') AS pending_count,
       SUM(status = 'REVERSED') AS reversed_count
FROM transactions
GROUP BY channel
ORDER BY channel;


-- Half-open timestamp filtering
-- Half-open ranges include the start and exclude the next day; useful for indexed DATETIME columns.
SELECT reference_code, amount, transaction_time, status
FROM transactions
WHERE transaction_time >= '2026-10-01 00:00:00'
  AND transaction_time <  '2026-11-01 00:00:00'
ORDER BY transaction_time DESC;
