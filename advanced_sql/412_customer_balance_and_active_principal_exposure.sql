-- Business question: Compare each customer's account balances with outstanding active loan principal.
WITH balances AS (
  SELECT customer_id, SUM(current_balance) AS total_balance, COUNT(*) AS account_count
  FROM accounts GROUP BY customer_id
),
loans_exposure AS (
  SELECT customer_id, SUM(CASE WHEN status = 'ACTIVE' THEN principal ELSE 0 END) AS active_principal,
         SUM(status = 'ACTIVE') AS active_loan_count
  FROM loans GROUP BY customer_id
)
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.risk_level, COALESCE(b.account_count, 0) AS account_count,
       COALESCE(b.total_balance, 0) AS total_balance,
       COALESCE(l.active_loan_count, 0) AS active_loan_count,
       COALESCE(l.active_principal, 0) AS active_principal,
       COALESCE(l.active_principal, 0) - COALESCE(b.total_balance, 0) AS principal_minus_deposits
FROM customers AS c
LEFT JOIN balances AS b ON b.customer_id = c.customer_id
LEFT JOIN loans_exposure AS l ON l.customer_id = c.customer_id
ORDER BY principal_minus_deposits DESC, c.customer_number;
