-- Business question: Measure the gap between consecutive successful transactions for each customer.
WITH ordered_successes AS (
  SELECT c.customer_id, c.customer_number, t.transaction_id, t.transaction_time,
         LAG(t.transaction_time) OVER (
           PARTITION BY c.customer_id ORDER BY t.transaction_time, t.transaction_id
         ) AS previous_success_at
  FROM customers AS c
  JOIN accounts AS a ON a.customer_id = c.customer_id
  JOIN transactions AS t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
)
SELECT customer_number, COUNT(*) AS observed_successes,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, previous_success_at, transaction_time)), 1) AS average_gap_minutes,
       MIN(TIMESTAMPDIFF(MINUTE, previous_success_at, transaction_time)) AS shortest_gap_minutes,
       MAX(TIMESTAMPDIFF(MINUTE, previous_success_at, transaction_time)) AS longest_gap_minutes
FROM ordered_successes
WHERE previous_success_at IS NOT NULL
GROUP BY customer_id, customer_number
ORDER BY average_gap_minutes, observed_successes DESC;
