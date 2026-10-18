-- Business question: Which active loans have principal greater than the linked account balance?
SELECT l.loan_id, l.loan_type, l.principal, a.account_number, a.current_balance,
       ROUND(l.principal / NULLIF(a.current_balance, 0), 2) AS principal_to_balance_ratio
FROM loans l
JOIN accounts a ON a.account_id = l.account_id
WHERE l.status = 'ACTIVE'
  AND l.principal > a.current_balance
ORDER BY principal_to_balance_ratio DESC;