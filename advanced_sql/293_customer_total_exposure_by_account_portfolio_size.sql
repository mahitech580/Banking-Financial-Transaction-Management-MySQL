-- customer total banking exposure grouped by account portfolio size; read-only analysis over the banking demo schema.
WITH account_totals AS (
  SELECT customer_id,COUNT(*) AS account_count,SUM(current_balance) AS total_balance,SUM(status='ACTIVE') AS active_accounts
  FROM accounts GROUP BY customer_id
), loan_totals AS (
  SELECT customer_id,COUNT(*) AS loan_count,SUM(principal) AS loan_principal
  FROM loans GROUP BY customer_id
)
SELECT CASE WHEN COALESCE(at.account_count,0)=0 THEN 'No accounts' WHEN COALESCE(at.account_count,0)=1 THEN 'One account' WHEN COALESCE(at.account_count,0)<=3 THEN '2-3 accounts' ELSE '4+ accounts' END AS grouping_value,
  COUNT(DISTINCT c.customer_id) AS customer_count,
  ROUND(SUM(COALESCE(at.total_balance,0)),2) AS aggregate_account_balance,
  ROUND(SUM(COALESCE(lt.loan_principal,0)),2) AS aggregate_loan_principal,
  ROUND(SUM(COALESCE(at.total_balance,0)+COALESCE(lt.loan_principal,0)),2) AS combined_exposure,
  SUM(COALESCE(lt.loan_count,0)>0) AS customers_with_loans,
  ROUND(AVG(COALESCE(at.total_balance,0)+COALESCE(lt.loan_principal,0)),2) AS average_exposure_per_customer
FROM customers c LEFT JOIN branches b ON b.branch_id=c.branch_id LEFT JOIN account_totals at ON at.customer_id=c.customer_id LEFT JOIN loan_totals lt ON lt.customer_id=c.customer_id
GROUP BY 1
ORDER BY 2 DESC;
