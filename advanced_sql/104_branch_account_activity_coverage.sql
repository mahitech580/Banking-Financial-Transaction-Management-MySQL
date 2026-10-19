-- Business question: What share of each branch's accounts recorded successful transactions?
WITH account_activity AS (
  SELECT a.account_id,a.branch_id,
         MAX(CASE WHEN t.status='SUCCESS' THEN 1 ELSE 0 END) has_success
  FROM accounts a LEFT JOIN transactions t ON t.account_id=a.account_id
  GROUP BY a.account_id,a.branch_id
)
SELECT b.branch_id,b.branch_code,b.branch_name,COUNT(*) total_accounts,
       SUM(aa.has_success) accounts_with_success,
       ROUND(100*SUM(aa.has_success)/NULLIF(COUNT(*),0),2) activity_coverage_pct
FROM branches b JOIN account_activity aa ON aa.branch_id=b.branch_id
GROUP BY b.branch_id,b.branch_code,b.branch_name
ORDER BY activity_coverage_pct DESC,b.branch_id;