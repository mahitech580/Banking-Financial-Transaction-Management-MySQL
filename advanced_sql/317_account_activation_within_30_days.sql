-- Business question: What share of accounts record a successful transaction within 30 days of opening?
WITH first_success AS (
  SELECT account_id,MIN(transaction_time) first_success_at
  FROM transactions WHERE status='SUCCESS' GROUP BY account_id
)
SELECT DATE_FORMAT(a.opened_at,'%Y-%m') opening_cohort,a.account_type,
       COUNT(*) accounts_opened,
       SUM(fs.first_success_at IS NOT NULL) accounts_with_success,
       SUM(fs.first_success_at>=a.opened_at AND fs.first_success_at<a.opened_at+INTERVAL 31 DAY) activated_within_30_days,
       ROUND(100*SUM(fs.first_success_at>=a.opened_at AND fs.first_success_at<a.opened_at+INTERVAL 31 DAY)/NULLIF(COUNT(*),0),2) activation_rate_pct
FROM accounts a LEFT JOIN first_success fs ON fs.account_id=a.account_id
GROUP BY DATE_FORMAT(a.opened_at,'%Y-%m'),a.account_type
ORDER BY opening_cohort,a.account_type;