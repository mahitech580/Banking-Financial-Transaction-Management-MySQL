-- Business question: Compare recent successful gross purchase flow with each credit card's configured limit.
-- This is a spend-to-limit proxy, not revolving credit utilization or a statement balance.
WITH purchases AS (
  SELECT card_id,COUNT(*) successful_purchase_count,SUM(amount) recent_gross_purchase_value,
         MAX(transaction_time) latest_successful_purchase_at
  FROM card_transactions
  WHERE status='SUCCESS' AND transaction_time>=CURRENT_DATE-INTERVAL 90 DAY
  GROUP BY card_id
)
SELECT cd.card_id,cd.status card_status,cd.credit_limit,
       COALESCE(p.successful_purchase_count,0) successful_purchases_90d,
       ROUND(COALESCE(p.recent_gross_purchase_value,0),2) gross_purchase_value_90d,
       ROUND(100*COALESCE(p.recent_gross_purchase_value,0)/NULLIF(cd.credit_limit,0),2) gross_purchase_to_limit_pct,
       p.latest_successful_purchase_at
FROM cards cd LEFT JOIN purchases p ON p.card_id=cd.card_id
WHERE cd.card_type='CREDIT'
ORDER BY gross_purchase_to_limit_pct DESC,cd.card_id;