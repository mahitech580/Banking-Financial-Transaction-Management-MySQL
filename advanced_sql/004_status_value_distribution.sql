-- Business question: What transaction volume and value are pending, successful, failed, or reversed?
SELECT status, COUNT(*) AS transaction_count,
       SUM(amount) AS gross_amount,
       AVG(amount) AS average_amount,
       MIN(amount) AS smallest_amount,
       MAX(amount) AS largest_amount
FROM transactions
GROUP BY status
ORDER BY transaction_count DESC;