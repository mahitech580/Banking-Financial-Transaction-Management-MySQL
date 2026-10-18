-- Business question: What account counts and balances exist by account type and status?
SELECT account_type, status, COUNT(*) AS account_count,
       SUM(current_balance) AS total_balance,
       AVG(current_balance) AS average_balance,
       MIN(current_balance) AS minimum_balance,
       MAX(current_balance) AS maximum_balance
FROM accounts
GROUP BY account_type, status
ORDER BY account_type, status;