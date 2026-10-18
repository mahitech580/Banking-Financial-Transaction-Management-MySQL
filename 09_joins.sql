-- INNER, LEFT, SELF and multi-table JOIN patterns.
USE banking_financial_management;

-- 1. Customer-to-account relationship
SELECT c.customer_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       a.account_number, a.account_type, a.status, a.current_balance
FROM customers AS c
INNER JOIN accounts AS a ON a.customer_id = c.customer_id
ORDER BY c.customer_id, a.account_id;

-- 2. Ledger with customer, account and optional merchant details
SELECT t.reference_code, t.transaction_type, t.amount, t.transaction_time,
       t.channel, t.status, a.account_number,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COALESCE(m.merchant_name, 'Direct / non-merchant') AS merchant
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
JOIN customers AS c ON c.customer_id = a.customer_id
LEFT JOIN merchants AS m ON m.merchant_id = t.merchant_id
ORDER BY t.transaction_time DESC, t.transaction_id DESC;

-- 3. Preserve customers with no loan or repayment rows.
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(DISTINCT l.loan_id) AS loan_count,
       COUNT(lp.payment_id) AS installment_count,
       COALESCE(SUM(lp.amount_due), 0) AS total_due,
       COALESCE(SUM(lp.amount_paid), 0) AS total_paid
FROM customers AS c
LEFT JOIN loans AS l ON l.customer_id = c.customer_id
LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
ORDER BY total_due DESC;

-- 4. SELF JOIN: customers registered at the same branch (each pair appears once).
SELECT b.branch_name,
       CONCAT(c1.first_name, ' ', c1.last_name) AS customer_one,
       CONCAT(c2.first_name, ' ', c2.last_name) AS customer_two
FROM customers AS c1
JOIN customers AS c2
  ON c1.branch_id = c2.branch_id
 AND c1.customer_id < c2.customer_id
JOIN branches AS b ON b.branch_id = c1.branch_id
ORDER BY b.branch_name, customer_one, customer_two;

-- 5. CROSS JOIN: all combinations for a simple reporting matrix.
SELECT ch.channel, s.status
FROM (SELECT 'BRANCH' AS channel UNION ALL SELECT 'ATM' UNION ALL SELECT 'ONLINE'
      UNION ALL SELECT 'MOBILE' UNION ALL SELECT 'POS') AS ch
CROSS JOIN (SELECT 'SUCCESS' AS status UNION ALL SELECT 'PENDING'
            UNION ALL SELECT 'FAILED' UNION ALL SELECT 'REVERSED') AS s
ORDER BY ch.channel, s.status;


-- Branch and account join
SELECT b.branch_code, b.branch_name, a.account_type,
       COUNT(a.account_id) AS account_count,
       COALESCE(SUM(a.current_balance), 0) AS total_balance
FROM branches AS b
LEFT JOIN accounts AS a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_code, b.branch_name, a.account_type
ORDER BY b.branch_name, total_balance DESC;


-- Branch and account rollup
SELECT b.branch_code, b.branch_name, a.account_type, COUNT(a.account_id) AS account_count, COALESCE(SUM(a.current_balance),0) AS total_balance FROM branches b LEFT JOIN accounts a ON a.branch_id=b.branch_id GROUP BY b.branch_id,b.branch_code,b.branch_name,a.account_type ORDER BY b.branch_name,total_balance DESC;
