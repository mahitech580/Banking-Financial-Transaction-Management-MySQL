-- Business question: What activity is associated with merchants flagged HIGH risk?
SELECT m.merchant_name, m.merchant_category,
       COUNT(t.transaction_id) AS transaction_count,
       SUM(t.status = 'SUCCESS') AS successful_count,
       SUM(t.status = 'FAILED') AS failed_count,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
FROM merchants m
LEFT JOIN transactions t ON t.merchant_id = m.merchant_id
WHERE m.risk_level = 'HIGH'
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
ORDER BY successful_value DESC;