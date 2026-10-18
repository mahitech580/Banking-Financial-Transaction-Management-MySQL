-- Business question: What is the monthly successful gross value by branch?
SELECT b.branch_name,
       DATE_FORMAT(t.transaction_time, '%Y-%m') AS month,
       COUNT(*) AS successful_transactions,
       SUM(t.amount) AS successful_value
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
JOIN transactions t ON t.account_id = a.account_id
WHERE t.status = 'SUCCESS'
GROUP BY b.branch_id, b.branch_name, DATE_FORMAT(t.transaction_time, '%Y-%m')
ORDER BY b.branch_name, month;