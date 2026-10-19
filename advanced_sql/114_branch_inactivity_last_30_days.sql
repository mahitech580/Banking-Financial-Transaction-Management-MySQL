-- Business question: Which branches have accounts but no transaction attempt in the last 30 days?
WITH recent_branches AS (
  SELECT DISTINCT a.branch_id
  FROM accounts a JOIN transactions t ON t.account_id=a.account_id
  WHERE t.transaction_time>=CURRENT_DATE-INTERVAL 30 DAY
)
SELECT b.branch_id,b.branch_code,b.branch_name,b.city,b.state,
       COUNT(DISTINCT a.account_id) account_count,
       MAX(t.transaction_time) last_transaction_attempt
FROM branches b JOIN accounts a ON a.branch_id=b.branch_id
LEFT JOIN transactions t ON t.account_id=a.account_id
LEFT JOIN recent_branches rb ON rb.branch_id=b.branch_id
WHERE rb.branch_id IS NULL
GROUP BY b.branch_id,b.branch_code,b.branch_name,b.city,b.state
ORDER BY last_transaction_attempt,b.branch_id;