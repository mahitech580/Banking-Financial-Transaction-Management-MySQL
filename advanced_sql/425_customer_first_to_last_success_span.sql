-- Business question: Measure the observed time span between each customer's first and last successful ledger event.
SELECT c.customer_id, c.customer_number,
       MIN(t.transaction_time) AS first_success_at,
       MAX(t.transaction_time) AS last_success_at,
       COUNT(*) AS successful_transactions,
       SUM(t.amount) AS successful_value,
       TIMESTAMPDIFF(DAY, MIN(t.transaction_time), MAX(t.transaction_time)) AS observed_active_span_days
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
JOIN transactions AS t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number
ORDER BY observed_active_span_days DESC, successful_value DESC;
