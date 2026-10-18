-- Business question: Which branches' accounts generate the most successful transaction volume?
SELECT b.branch_name, b.city,
       COUNT(t.transaction_id) AS successful_transactions,
       SUM(t.amount) AS successful_gross_value,
       AVG(t.amount) AS average_transaction_value
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY successful_gross_value DESC;