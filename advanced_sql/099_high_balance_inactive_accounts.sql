-- Business question: Which accounts have a material stored balance but no successful activity in the last 90 days?
-- Tune the balance threshold to the synthetic dataset; this report is a review queue, not a risk verdict.
WITH recent AS (
  SELECT DISTINCT account_id FROM transactions
  WHERE status='SUCCESS' AND transaction_time>=CURRENT_DATE-INTERVAL 90 DAY
)
SELECT a.account_id,a.account_number,a.account_type,a.status,a.current_balance,a.opened_at,
       MAX(t.transaction_time) last_transaction_attempt
FROM accounts a LEFT JOIN recent r ON r.account_id=a.account_id
LEFT JOIN transactions t ON t.account_id=a.account_id
WHERE r.account_id IS NULL AND a.current_balance>=1000
GROUP BY a.account_id,a.account_number,a.account_type,a.status,a.current_balance,a.opened_at
ORDER BY a.current_balance DESC;