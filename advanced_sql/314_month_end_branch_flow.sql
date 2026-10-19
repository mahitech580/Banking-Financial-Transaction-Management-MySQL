-- Business question: What are month-end successful credit/debit flows and cumulative net flow by branch?
WITH monthly AS (
  SELECT b.branch_id,b.branch_name,DATE_FORMAT(t.transaction_time,'%Y-%m-01') month_start,
         SUM(CASE WHEN t.transaction_type='CREDIT' THEN t.amount ELSE 0 END) credits,
         SUM(CASE WHEN t.transaction_type='DEBIT' THEN t.amount ELSE 0 END) debits,
         COUNT(*) ledger_rows
  FROM transactions t JOIN accounts a ON a.account_id=t.account_id
  JOIN branches b ON b.branch_id=a.branch_id
  WHERE t.status='SUCCESS' AND t.transaction_type IN ('CREDIT','DEBIT')
  GROUP BY b.branch_id,b.branch_name,DATE_FORMAT(t.transaction_time,'%Y-%m-01')
)
SELECT branch_id,branch_name,month_start,ledger_rows,ROUND(credits,2) credits,ROUND(debits,2) debits,
       ROUND(credits-debits,2) net_flow,
       ROUND(SUM(credits-debits) OVER(PARTITION BY branch_id ORDER BY month_start),2) cumulative_observed_net_flow
FROM monthly ORDER BY branch_name,month_start;