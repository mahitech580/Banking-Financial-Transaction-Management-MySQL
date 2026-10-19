-- Business question: Which active accounts have not had successful activity, but do have recorded attempts?
SELECT a.account_id,a.account_number,a.account_type,a.opened_at,a.current_balance,
       COUNT(t.transaction_id) total_attempts,SUM(t.status='FAILED') failed_attempts,
       SUM(t.status='PENDING') pending_attempts,SUM(t.status='REVERSED') reversed_attempts,
       MAX(t.transaction_time) latest_attempt_at
FROM accounts a JOIN transactions t ON t.account_id=a.account_id
WHERE a.status='ACTIVE'
GROUP BY a.account_id,a.account_number,a.account_type,a.opened_at,a.current_balance
HAVING SUM(t.status='SUCCESS')=0
ORDER BY total_attempts DESC,a.current_balance DESC;