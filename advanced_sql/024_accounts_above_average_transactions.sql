-- Business question: Which accounts have more transactions than the average account?
WITH account_counts AS (
  SELECT a.account_id, a.account_number, COUNT(t.transaction_id) AS txn_count
  FROM accounts a LEFT JOIN transactions t ON t.account_id = a.account_id
  GROUP BY a.account_id, a.account_number
)
SELECT account_id, account_number, txn_count
FROM account_counts
WHERE txn_count > (SELECT AVG(txn_count) FROM account_counts)
ORDER BY txn_count DESC;