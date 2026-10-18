-- Business question: Which customers and references are connected to disputes?
SELECT d.dispute_id, d.opened_at, d.reason, d.disputed_amount, d.status,
       t.reference_code, t.transaction_time, t.channel,
       a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM disputes d
JOIN transactions t ON t.transaction_id = d.transaction_id
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
ORDER BY d.opened_at DESC;