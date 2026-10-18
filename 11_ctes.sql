-- Common Table Expressions (CTEs) improve readability for multi-stage analysis.
USE banking_financial_management;

-- 1. Summarize ledger activity per customer before joining to descriptive fields.
WITH customer_activity AS (
  SELECT a.customer_id,
         COUNT(t.transaction_id) AS transaction_count,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_gross_value,
         SUM(CASE WHEN t.status = 'FAILED' THEN 1 ELSE 0 END) AS failed_count
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.customer_id
)
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       ca.transaction_count, COALESCE(ca.successful_gross_value, 0) AS successful_gross_value,
       COALESCE(ca.failed_count, 0) AS failed_count
FROM customers AS c
LEFT JOIN customer_activity AS ca ON ca.customer_id = c.customer_id
ORDER BY successful_gross_value DESC, c.customer_id;

-- 2. Month-by-month cash movement, expressed as credits minus debits.
WITH monthly_flow AS (
  SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month_key,
         SUM(CASE WHEN transaction_type = 'CREDIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS credits,
         SUM(CASE WHEN transaction_type = 'DEBIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS debits
  FROM transactions
  GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
)
SELECT month_key, credits, debits, credits - debits AS net_flow
FROM monthly_flow
ORDER BY month_key;

-- 3. Recursive CTE creates a reusable 1–12 month dimension.
WITH RECURSIVE months AS (
  SELECT 1 AS month_no
  UNION ALL
  SELECT month_no + 1 FROM months WHERE month_no < 12
)
SELECT month_no, LPAD(month_no, 2, '0') AS month_label
FROM months
ORDER BY month_no;

-- 4. Branch summary assembled in stages (transaction facts, then branch attributes).
WITH branch_activity AS (
  SELECT a.branch_id, COUNT(t.transaction_id) AS ledger_rows,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.branch_id
)
SELECT b.branch_code, b.branch_name, COALESCE(ba.ledger_rows, 0) AS ledger_rows,
       COALESCE(ba.successful_value, 0) AS successful_value
FROM branches AS b
LEFT JOIN branch_activity AS ba ON ba.branch_id = b.branch_id
ORDER BY successful_value DESC;


-- Stage the aggregate before ranking customers
WITH customer_value AS (SELECT a.customer_id,SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) AS successful_value FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id GROUP BY a.customer_id) SELECT c.customer_number,CONCAT(c.first_name,' ',c.last_name) AS customer_name,COALESCE(cv.successful_value,0) AS successful_value,DENSE_RANK() OVER(ORDER BY COALESCE(cv.successful_value,0) DESC) AS value_rank FROM customers c LEFT JOIN customer_value cv ON cv.customer_id=c.customer_id ORDER BY value_rank,customer_name;


-- Aggregate first, calculate month-over-month change second
WITH monthly AS (SELECT DATE_FORMAT(transaction_time,'%Y-%m') AS month_key,SUM(CASE WHEN status='SUCCESS' AND transaction_type='CREDIT' THEN amount ELSE 0 END) AS credits,SUM(CASE WHEN status='SUCCESS' AND transaction_type='DEBIT' THEN amount ELSE 0 END) AS debits FROM transactions GROUP BY DATE_FORMAT(transaction_time,'%Y-%m')) SELECT month_key,credits,debits,credits-debits AS net_flow,LAG(credits-debits) OVER(ORDER BY month_key) AS previous_net_flow FROM monthly ORDER BY month_key;
