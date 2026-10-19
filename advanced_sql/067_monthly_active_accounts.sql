-- Business question: How many distinct accounts had ledger activity each month?
-- Read-only example; failed and reversed attempts remain included in the activity count.
SELECT DATE_FORMAT(transaction_time,'%Y-%m') AS activity_month, COUNT(DISTINCT account_id) AS active_accounts, COUNT(*) AS transaction_rows, SUM(status='SUCCESS') AS successful_rows
FROM transactions
GROUP BY DATE_FORMAT(transaction_time,'%Y-%m')
ORDER BY activity_month;
