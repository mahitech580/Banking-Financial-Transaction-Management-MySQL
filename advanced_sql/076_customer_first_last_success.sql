-- Business question: When did each customer first and most recently transact successfully?
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       MIN(t.transaction_time) AS first_successful_transaction,
       MAX(t.transaction_time) AS latest_successful_transaction,
       COUNT(t.transaction_id) AS successful_transaction_count
FROM customers c
LEFT JOIN accounts a ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
ORDER BY latest_successful_transaction IS NULL, latest_successful_transaction DESC;
