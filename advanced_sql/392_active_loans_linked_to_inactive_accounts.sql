-- Business question: Which active loans reference accounts that are currently frozen or closed?
-- Grain: one active loan/account relationship. The schema may permit this state, so confirm product servicing and lifecycle policy.
SELECT l.loan_id, l.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  l.loan_type, l.status AS loan_status, l.principal, l.start_date,
  a.account_id, a.account_number, a.account_status, a.account_type
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
JOIN (
  SELECT account_id, account_number, status AS account_status, account_type
  FROM accounts
) a ON a.account_id = l.account_id
WHERE l.status = 'ACTIVE' AND a.account_status IN ('FROZEN', 'CLOSED')
ORDER BY a.account_status, l.start_date, l.loan_id;
