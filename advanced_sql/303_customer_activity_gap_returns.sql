-- Business question: Which customers return to successful transaction activity after a gap of at least 90 days?
WITH timeline AS (
  SELECT a.customer_id,t.transaction_id,t.transaction_time,
         LAG(t.transaction_time) OVER(PARTITION BY a.customer_id ORDER BY t.transaction_time,t.transaction_id) prior_success_at
  FROM accounts a JOIN transactions t ON t.account_id=a.account_id
  WHERE t.status='SUCCESS'
)
SELECT c.customer_id,c.customer_number,tl.transaction_id return_transaction_id,
       tl.prior_success_at,tl.transaction_time returned_at,
       DATEDIFF(tl.transaction_time,tl.prior_success_at) inactive_days
FROM timeline tl JOIN customers c ON c.customer_id=tl.customer_id
WHERE tl.prior_success_at IS NOT NULL
  AND tl.transaction_time>=tl.prior_success_at+INTERVAL 90 DAY
ORDER BY inactive_days DESC,tl.customer_id;