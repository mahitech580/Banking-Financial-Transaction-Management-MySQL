-- Business question: Compare customer transaction frequency and value month by month.
SELECT c.customer_number,
       DATE_FORMAT(t.transaction_time, '%Y-%m') AS transaction_month,
       COUNT(*) AS successful_transaction_count,
       COUNT(DISTINCT a.account_id) AS active_accounts_used,
       COUNT(DISTINCT t.channel) AS channels_used,
       SUM(t.amount) AS successful_value,
       ROUND(AVG(t.amount), 2) AS average_ticket
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
JOIN transactions AS t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number, DATE_FORMAT(t.transaction_time, '%Y-%m')
ORDER BY transaction_month DESC, successful_value DESC;
