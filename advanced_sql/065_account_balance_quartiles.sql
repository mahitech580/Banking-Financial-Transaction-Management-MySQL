-- Business question: How are accounts grouped into four balance quartiles?
SELECT account_id, account_number, current_balance,
       NTILE(4) OVER (ORDER BY current_balance DESC) AS balance_quartile
FROM accounts
ORDER BY balance_quartile, current_balance DESC;