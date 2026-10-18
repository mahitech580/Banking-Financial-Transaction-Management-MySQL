-- Financial operations metrics: cash movement, branch performance and product mix.
USE banking_financial_management;

-- 1. Monthly credits, debits and net ledger movement (successful rows only).
SELECT DATE_FORMAT(transaction_time, '%Y-%m') AS month_key,
       SUM(CASE WHEN transaction_type = 'CREDIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS credits,
       SUM(CASE WHEN transaction_type = 'DEBIT' AND status = 'SUCCESS' THEN amount ELSE 0 END) AS debits,
       SUM(CASE WHEN transaction_type = 'CREDIT' AND status = 'SUCCESS' THEN amount
                WHEN transaction_type = 'DEBIT' AND status = 'SUCCESS' THEN -amount
                ELSE 0 END) AS net_flow
FROM transactions
GROUP BY DATE_FORMAT(transaction_time, '%Y-%m')
ORDER BY month_key;

-- 2. Branch performance. Aggregate account balances and ledger facts independently.
WITH branch_balances AS (
  SELECT branch_id, COUNT(*) AS account_count, SUM(current_balance) AS total_balance
  FROM accounts
  GROUP BY branch_id
),
branch_transactions AS (
  SELECT a.branch_id, COUNT(t.transaction_id) AS ledger_rows,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_gross_value
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.branch_id
)
SELECT b.branch_code, b.branch_name, COALESCE(bb.account_count, 0) AS account_count,
       COALESCE(bb.total_balance, 0) AS total_balance,
       COALESCE(bt.ledger_rows, 0) AS ledger_rows,
       COALESCE(bt.successful_gross_value, 0) AS successful_gross_value
FROM branches AS b
LEFT JOIN branch_balances AS bb ON bb.branch_id = b.branch_id
LEFT JOIN branch_transactions AS bt ON bt.branch_id = b.branch_id
ORDER BY successful_gross_value DESC;

-- 3. Customer product exposure from independent account and loan aggregates.
WITH balances AS (
  SELECT customer_id, SUM(current_balance) AS deposit_balance
  FROM accounts GROUP BY customer_id
),
loan_exposure AS (
  SELECT customer_id, SUM(principal) AS principal_exposure
  FROM loans WHERE status = 'ACTIVE'
  GROUP BY customer_id
)
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COALESCE(b.deposit_balance, 0) AS deposit_balance,
       COALESCE(le.principal_exposure, 0) AS active_loan_principal,
       COALESCE(b.deposit_balance, 0) - COALESCE(le.principal_exposure, 0) AS simple_net_position
FROM customers AS c
LEFT JOIN balances AS b ON b.customer_id = c.customer_id
LEFT JOIN loan_exposure AS le ON le.customer_id = c.customer_id
ORDER BY active_loan_principal DESC;

-- 4. Settlement value by month and processing state
SELECT DATE_FORMAT(COALESCE(settled_at, transaction_time), '%Y-%m') AS reporting_month,
       s.status, COUNT(*) AS settlement_count, SUM(s.settlement_amount) AS settlement_value
FROM settlements AS s
JOIN transactions AS t ON t.transaction_id = s.transaction_id
GROUP BY DATE_FORMAT(COALESCE(settled_at, transaction_time), '%Y-%m'), s.status
ORDER BY reporting_month, s.status;


WITH monthly AS (SELECT DATE_FORMAT(transaction_time,'%Y-%m') AS month_key,SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END) AS successful_value FROM transactions GROUP BY DATE_FORMAT(transaction_time,'%Y-%m')) SELECT month_key,successful_value,SUM(successful_value) OVER(ORDER BY month_key ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_successful_value FROM monthly ORDER BY month_key;


SELECT transaction_type,COUNT(*) AS attempted_count,SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END) AS successful_value,ROUND(100.0*SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END)/NULLIF((SELECT SUM(amount) FROM transactions WHERE status='SUCCESS'),0),2) AS share_of_successful_value_pct FROM transactions GROUP BY transaction_type ORDER BY successful_value DESC;
