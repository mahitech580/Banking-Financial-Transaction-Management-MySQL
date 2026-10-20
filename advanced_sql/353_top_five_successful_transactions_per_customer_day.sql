-- Business question: What are each customer's five largest successful ledger transactions per calendar day?
-- Grain: one successful transaction in the top five for its customer and transaction date; ties are resolved by transaction ID.
WITH ranked AS (
  SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATE(t.transaction_time) AS transaction_date, t.transaction_id, t.reference_code,
    t.transaction_type, t.channel, t.amount,
    ROW_NUMBER() OVER (
      PARTITION BY c.customer_id, DATE(t.transaction_time)
      ORDER BY t.amount DESC, t.transaction_id DESC
    ) AS amount_rank
  FROM customers c
  JOIN accounts a ON a.customer_id = c.customer_id
  JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
)
SELECT customer_id, customer_name, transaction_date, amount_rank,
  transaction_id, reference_code, transaction_type, channel, amount
FROM ranked
WHERE amount_rank <= 5
ORDER BY customer_id, transaction_date DESC, amount_rank;
