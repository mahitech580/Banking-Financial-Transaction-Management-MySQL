-- Business question: Compare recorded card transaction value with credit limit as a simple spend proxy.
-- This is not utilization of an outstanding balance; refunds, repayments, and current balances are not modeled here.
WITH card_spend AS (
  SELECT card_id, COUNT(*) AS attempts,
         SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_spend
  FROM card_transactions
  GROUP BY card_id
)
SELECT c.card_id, c.card_type, c.status, c.credit_limit,
       COALESCE(s.attempts, 0) AS attempts,
       COALESCE(s.successful_spend, 0) AS successful_spend,
       ROUND(100.0 * COALESCE(s.successful_spend, 0) / NULLIF(c.credit_limit, 0), 2) AS spend_to_limit_proxy_pct
FROM cards AS c
LEFT JOIN card_spend AS s ON s.card_id = c.card_id
WHERE c.card_type = 'CREDIT'
ORDER BY spend_to_limit_proxy_pct DESC, successful_spend DESC;
