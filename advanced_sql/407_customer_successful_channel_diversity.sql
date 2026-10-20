-- Business question: Which customers use the widest mix of successful transaction channels?
SELECT c.customer_id, c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(t.transaction_id) AS successful_transactions,
       COUNT(DISTINCT t.channel) AS channels_used,
       GROUP_CONCAT(DISTINCT t.channel ORDER BY t.channel SEPARATOR ', ') AS channel_mix,
       SUM(t.amount) AS successful_value
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
JOIN transactions AS t ON t.account_id = a.account_id AND t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
ORDER BY channels_used DESC, successful_value DESC;
