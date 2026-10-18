-- Business question: Which successful transactions exceed their customer's average amount?
WITH customer_txn AS (
  SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
         t.transaction_id, t.reference_code, t.amount, t.transaction_time,
         AVG(t.amount) OVER (PARTITION BY c.customer_id) AS customer_avg
  FROM customers c
  JOIN accounts a ON a.customer_id = c.customer_id
  JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
)
SELECT customer_id, customer_name, reference_code, amount,
       ROUND(customer_avg, 2) AS customer_average, transaction_time
FROM customer_txn
WHERE amount > customer_avg
ORDER BY amount DESC;