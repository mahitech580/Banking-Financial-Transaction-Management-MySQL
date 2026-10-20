-- Business question: Compare successful ATM and branch-channel activity for each customer.
SELECT c.customer_number,
       COUNT(CASE WHEN t.channel = 'ATM' THEN 1 END) AS atm_attempts,
       SUM(CASE WHEN t.channel = 'ATM' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS atm_successful_value,
       COUNT(CASE WHEN t.channel = 'BRANCH' THEN 1 END) AS branch_attempts,
       SUM(CASE WHEN t.channel = 'BRANCH' AND t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS branch_successful_value,
       COUNT(DISTINCT CASE WHEN t.status = 'SUCCESS' THEN t.channel END) AS successful_channels_used
FROM customers AS c
JOIN accounts AS a ON a.customer_id = c.customer_id
LEFT JOIN transactions AS t ON t.account_id = a.account_id
GROUP BY c.customer_id, c.customer_number
ORDER BY atm_successful_value + branch_successful_value DESC;
