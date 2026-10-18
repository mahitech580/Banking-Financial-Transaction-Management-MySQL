-- Business question: What share of the recorded account balance belongs to each account?
SELECT account_number, account_type, current_balance,
       ROUND(100 * current_balance / NULLIF(SUM(current_balance) OVER (), 0), 2) AS pct_of_recorded_balance,
       RANK() OVER (ORDER BY current_balance DESC) AS balance_rank
FROM accounts
ORDER BY current_balance DESC;