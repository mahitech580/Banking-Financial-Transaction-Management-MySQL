-- Account balance, utilization, status and activity analysis.
USE banking_financial_management;

-- 1. Balance distribution by account type and status
SELECT account_type, status, COUNT(*) AS account_count,
       ROUND(AVG(current_balance), 2) AS average_balance,
       MIN(current_balance) AS minimum_balance,
       MAX(current_balance) AS maximum_balance,
       SUM(current_balance) AS total_balance
FROM accounts
GROUP BY account_type, status
ORDER BY total_balance DESC;

-- 2. Combine current balance with a separately aggregated ledger.
WITH account_activity AS (
  SELECT account_id,
         COUNT(*) AS transaction_count,
         SUM(status = 'SUCCESS') AS successful_count,
         SUM(status = 'FAILED') AS failed_count,
         MAX(transaction_time) AS last_activity
  FROM transactions
  GROUP BY account_id
)
SELECT a.account_number, a.account_type, a.status, a.current_balance,
       COALESCE(x.transaction_count, 0) AS transaction_count,
       COALESCE(x.successful_count, 0) AS successful_count,
       COALESCE(x.failed_count, 0) AS failed_count,
       x.last_activity
FROM accounts AS a
LEFT JOIN account_activity AS x ON x.account_id = a.account_id
ORDER BY a.current_balance DESC;

-- 3. Accounts dormant for 90 days. The rule is illustrative and should be tuned to policy.
SELECT a.account_number, a.account_type, a.status, a.current_balance,
       MAX(t.transaction_time) AS last_successful_activity
FROM accounts AS a
LEFT JOIN transactions AS t
  ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY a.account_id, a.account_number, a.account_type, a.status, a.current_balance
HAVING MAX(t.transaction_time) IS NULL
    OR MAX(t.transaction_time) < CURRENT_DATE - INTERVAL 90 DAY
ORDER BY last_successful_activity;
