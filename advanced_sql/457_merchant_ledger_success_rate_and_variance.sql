-- Business question: Compare merchant outcome rates and the spread of attempted versus successful amount values.
SELECT m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level,
       COUNT(t.transaction_id) AS attempts,
       SUM(t.status = 'SUCCESS') AS successes,
       ROUND(100.0 * SUM(t.status = 'SUCCESS') / NULLIF(COUNT(t.transaction_id), 0), 2) AS success_rate_pct,
       ROUND(AVG(t.amount), 2) AS average_attempt_amount,
       ROUND(AVG(CASE WHEN t.status = 'SUCCESS' THEN t.amount END), 2) AS average_success_amount,
       MIN(t.amount) AS minimum_attempt,
       MAX(t.amount) AS maximum_attempt
FROM merchants AS m
LEFT JOIN transactions AS t ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category, m.risk_level
ORDER BY attempts DESC, success_rate_pct;
