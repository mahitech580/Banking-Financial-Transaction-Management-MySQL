-- Business question: How do successful transaction amount deciles vary by customer-assigned risk label?
-- Risk is a descriptive dataset attribute, not a model output or lending decision.
WITH ranked AS (
  SELECT c.risk_level,t.transaction_id,t.amount,t.channel,
         NTILE(10) OVER(PARTITION BY c.risk_level ORDER BY t.amount,t.transaction_id) amount_decile
  FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
  JOIN transactions t ON t.account_id=a.account_id
  WHERE t.status='SUCCESS'
)
SELECT risk_level,amount_decile,channel,COUNT(*) transaction_count,
       ROUND(MIN(amount),2) minimum_amount,ROUND(MAX(amount),2) maximum_amount,
       ROUND(AVG(amount),2) average_amount
FROM ranked GROUP BY risk_level,amount_decile,channel
ORDER BY risk_level,amount_decile,channel;