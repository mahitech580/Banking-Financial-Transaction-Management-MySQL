-- Scalar, IN, EXISTS, NOT EXISTS and correlated subqueries.
USE banking_financial_management;

-- 1. Accounts above the overall average balance
SELECT account_number, account_type, current_balance
FROM accounts
WHERE current_balance > (SELECT AVG(current_balance) FROM accounts)
ORDER BY current_balance DESC;

-- 2. Customers with at least one active loan
SELECT c.customer_id, c.customer_number, c.first_name, c.last_name
FROM customers AS c
WHERE c.customer_id IN (
  SELECT l.customer_id FROM loans AS l WHERE l.status = 'ACTIVE'
)
ORDER BY c.customer_id;

-- 3. Merchants with at least one successful transaction above ₹50,000
SELECT m.merchant_id, m.merchant_name, m.risk_level
FROM merchants AS m
WHERE EXISTS (
  SELECT 1 FROM transactions AS t
  WHERE t.merchant_id = m.merchant_id
    AND t.status = 'SUCCESS'
    AND t.amount > 50000
);

-- 4. Customers with no transactions (anti-join via NOT EXISTS)
SELECT c.customer_number, c.first_name, c.last_name
FROM customers AS c
WHERE NOT EXISTS (
  SELECT 1
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  WHERE a.customer_id = c.customer_id
);

-- 5. Correlated subquery: successful transactions exceeding that account's own average
SELECT t.account_id, t.reference_code, t.amount, t.transaction_time
FROM transactions AS t
WHERE t.status = 'SUCCESS'
  AND t.amount > (
    SELECT AVG(t2.amount)
    FROM transactions AS t2
    WHERE t2.account_id = t.account_id
      AND t2.status = 'SUCCESS'
  )
ORDER BY t.account_id, t.amount DESC;

-- 6. Loans above the average principal for their own loan type
SELECT l.loan_id, l.loan_type, l.principal, l.interest_rate
FROM loans AS l
WHERE l.principal > (
  SELECT AVG(l2.principal)
  FROM loans AS l2
  WHERE l2.loan_type = l.loan_type
)
ORDER BY l.principal DESC;
