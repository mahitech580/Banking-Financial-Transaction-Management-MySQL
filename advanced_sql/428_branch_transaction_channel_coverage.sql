-- Business question: Measure channel diversity and transaction coverage at each branch.
SELECT b.branch_id, b.branch_name,
       COUNT(DISTINCT t.channel) AS observed_channels,
       COUNT(t.transaction_id) AS all_attempts,
       COUNT(DISTINCT a.account_id) AS accounts_with_attempts,
       SUM(t.status = 'SUCCESS') AS successful_attempts,
       SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
FROM branches AS b
LEFT JOIN accounts AS a ON a.branch_id = b.branch_id
LEFT JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY b.branch_id, b.branch_name
ORDER BY observed_channels DESC, successful_value DESC;
