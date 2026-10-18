-- Business question: Which merchants have the greatest successful transaction value?
SELECT m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level,
       COUNT(t.transaction_id) AS transactions,
       SUM(t.amount) AS successful_value
FROM merchants m
JOIN transactions t ON t.merchant_id = m.merchant_id
WHERE t.status = 'SUCCESS'
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level
ORDER BY successful_value DESC
LIMIT 10;