-- Business question: How does monthly active-account coverage relate to successful flow across account types?
WITH monthly AS (
  SELECT DATE_FORMAT(t.transaction_time,'%Y-%m-01') month_start,a.account_type,
         COUNT(DISTINCT a.account_id) accounts_with_attempts,
         COUNT(DISTINCT CASE WHEN t.status='SUCCESS' THEN a.account_id END) accounts_with_success,
         COUNT(*) transaction_attempts,SUM(t.status='SUCCESS') successful_transactions,
         SUM(CASE WHEN t.status='SUCCESS' AND t.transaction_type='CREDIT' THEN t.amount
                  WHEN t.status='SUCCESS' AND t.transaction_type='DEBIT' THEN -t.amount ELSE 0 END) successful_net_flow
  FROM transactions t JOIN accounts a ON a.account_id=t.account_id
  GROUP BY DATE_FORMAT(t.transaction_time,'%Y-%m-01'),a.account_type
)
SELECT month_start,account_type,accounts_with_attempts,accounts_with_success,
       ROUND(100*accounts_with_success/NULLIF(accounts_with_attempts,0),2) account_success_coverage_pct,
       transaction_attempts,successful_transactions,ROUND(successful_net_flow,2) successful_net_flow
FROM monthly ORDER BY month_start,account_type;