-- Business question: Which customers hold more than one account?
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(a.account_id) AS account_count,
       SUM(a.current_balance) AS combined_balance
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
HAVING COUNT(a.account_id) > 1
ORDER BY account_count DESC, combined_balance DESC;