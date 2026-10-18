-- Customer-level KPIs. Each fact set is aggregated before joining to avoid fan-out.
USE banking_financial_management;

WITH account_metrics AS (
  SELECT customer_id, COUNT(*) AS account_count,
         SUM(current_balance) AS total_balance,
         SUM(status = 'ACTIVE') AS active_accounts
  FROM accounts
  GROUP BY customer_id
),
transaction_metrics AS (
  SELECT a.customer_id, COUNT(t.transaction_id) AS transaction_count,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_gross_value,
         SUM(t.status = 'FAILED') AS failed_count,
         MAX(t.transaction_time) AS last_transaction_at
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.customer_id
),
loan_metrics AS (
  SELECT customer_id, COUNT(*) AS loan_count, SUM(principal) AS total_principal
  FROM loans
  GROUP BY customer_id
)
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.risk_level, COALESCE(am.account_count, 0) AS account_count,
       COALESCE(am.active_accounts, 0) AS active_accounts,
       COALESCE(am.total_balance, 0) AS total_balance,
       COALESCE(tm.transaction_count, 0) AS transaction_count,
       COALESCE(tm.successful_gross_value, 0) AS successful_gross_value,
       COALESCE(tm.failed_count, 0) AS failed_count,
       tm.last_transaction_at, COALESCE(lm.loan_count, 0) AS loan_count,
       COALESCE(lm.total_principal, 0) AS total_loan_principal
FROM customers AS c
LEFT JOIN account_metrics AS am ON am.customer_id = c.customer_id
LEFT JOIN transaction_metrics AS tm ON tm.customer_id = c.customer_id
LEFT JOIN loan_metrics AS lm ON lm.customer_id = c.customer_id
ORDER BY successful_gross_value DESC, c.customer_id;

-- Inactive customers: no successful ledger activity in the last 90 days.
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       MAX(t.transaction_time) AS last_successful_transaction
FROM customers AS c
LEFT JOIN accounts AS a ON a.customer_id = c.customer_id
LEFT JOIN transactions AS t
  ON t.account_id = a.account_id
 AND t.status = 'SUCCESS'
GROUP BY c.customer_id, c.customer_number, c.first_name, c.last_name
HAVING MAX(t.transaction_time) IS NULL
    OR MAX(t.transaction_time) < CURRENT_DATE - INTERVAL 90 DAY
ORDER BY last_successful_transaction;


-- Average ticket is computed only across successful transactions
WITH customer_tx AS (SELECT a.customer_id,COUNT(*) AS successful_count,AVG(t.amount) AS avg_ticket,SUM(t.amount) AS gross_value FROM accounts a JOIN transactions t ON t.account_id=a.account_id WHERE t.status='SUCCESS' GROUP BY a.customer_id) SELECT c.customer_number,CONCAT(c.first_name,' ',c.last_name) AS customer_name,ct.successful_count,ROUND(ct.avg_ticket,2) AS avg_ticket,ct.gross_value FROM customer_tx ct JOIN customers c ON c.customer_id=ct.customer_id ORDER BY ct.avg_ticket DESC;
