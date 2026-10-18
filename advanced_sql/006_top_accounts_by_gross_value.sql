-- Business question: Which accounts process the most successful transaction value?
SELECT a.account_id, a.account_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(t.transaction_id) AS transaction_count,
       SUM(t.amount) AS successful_gross_value
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id
JOIN transactions t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY a.account_id, a.account_number, c.first_name, c.last_name
ORDER BY successful_gross_value DESC
LIMIT 10;