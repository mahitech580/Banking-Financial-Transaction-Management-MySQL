-- Business question: Which branches hold the greatest active loan principal?
SELECT b.branch_name, b.city,
       COUNT(DISTINCT l.loan_id) AS active_loans,
       SUM(l.principal) AS active_principal
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
JOIN loans l ON l.account_id = a.account_id
WHERE l.status = 'ACTIVE'
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY active_principal DESC;