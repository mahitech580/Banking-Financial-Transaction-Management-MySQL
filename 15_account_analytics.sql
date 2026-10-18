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


-- Compare successful credits and debits independently of the stored snapshot balance
SELECT a.account_number,SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='CREDIT' THEN t.amount ELSE 0 END) AS successful_credits,SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='DEBIT' THEN t.amount ELSE 0 END) AS successful_debits,SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='CREDIT' THEN t.amount WHEN t.status='SUCCESS' AND t.transaction_type='DEBIT' THEN -t.amount ELSE 0 END) AS net_ledger_flow FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id GROUP BY a.account_id,a.account_number ORDER BY a.account_number;


-- A useful operational segmentation query; thresholds are illustrative
SELECT a.account_number,a.status,MAX(t.transaction_time) AS last_successful_at,CASE WHEN MAX(t.transaction_time) IS NULL THEN 'NEVER ACTIVE' WHEN MAX(t.transaction_time)<CURRENT_DATE-INTERVAL 90 DAY THEN 'DORMANT' WHEN MAX(t.transaction_time)<CURRENT_DATE-INTERVAL 30 DAY THEN 'LOW RECENCY' ELSE 'RECENT ACTIVITY' END AS activity_band FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id AND t.status='SUCCESS' GROUP BY a.account_id,a.account_number,a.status ORDER BY last_successful_at;


SELECT a.account_number,t.channel,COUNT(*) AS transaction_count,SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) AS successful_value FROM accounts a JOIN transactions t ON t.account_id=a.account_id GROUP BY a.account_id,a.account_number,t.channel ORDER BY a.account_number,successful_value DESC;
