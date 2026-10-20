-- Business question: Compare merchant transaction amount spread and successful-value concentration.
SELECT m.merchant_id, m.merchant_name, m.merchant_category,
       COUNT(t.transaction_id) AS attempts,
       ROUND(AVG(t.amount), 2) AS mean_attempt_amount,
       ROUND(STDDEV_POP(t.amount), 2) AS amount_stddev,
       MIN(t.amount) AS minimum_attempt_amount,
       MAX(t.amount) AS maximum_attempt_amount,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
FROM merchants AS m
LEFT JOIN transactions AS t ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
ORDER BY amount_stddev DESC, attempts DESC;
