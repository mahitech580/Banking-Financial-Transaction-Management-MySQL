-- Business question: Review successful value and failed-attempt share for high-risk merchants.
SELECT m.merchant_name, m.merchant_category, t.channel,
       COUNT(*) AS attempts,
       SUM(t.status = 'FAILED') AS failed_attempts,
       SUM(t.status = 'SUCCESS') AS successful_attempts,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value,
       ROUND(100.0 * SUM(t.status = 'FAILED') / COUNT(*), 2) AS failed_rate_pct
FROM merchants AS m
JOIN transactions AS t ON t.merchant_id = m.merchant_id
WHERE m.risk_level = 'HIGH'
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category, t.channel
ORDER BY successful_value DESC, failed_rate_pct DESC;
