-- Business question: After a customer's first successful transaction, in which later calendar months do they return?
-- Grain: signup-to-success cohort month and active month. This is transaction-based retention, not account logins or overall customer engagement.
WITH first_success AS (
  SELECT a.customer_id, MIN(DATE_FORMAT(t.transaction_time, '%Y-%m-01')) AS cohort_month
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
  GROUP BY a.customer_id
),
monthly_active AS (
  SELECT DISTINCT a.customer_id, DATE_FORMAT(t.transaction_time, '%Y-%m-01') AS activity_month
  FROM accounts a JOIN transactions t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS'
),
cohort_activity AS (
  SELECT fs.cohort_month, ma.activity_month, fs.customer_id,
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(fs.cohort_month, '%Y-%m-%d'),
      STR_TO_DATE(ma.activity_month, '%Y-%m-%d')) AS months_since_cohort
  FROM first_success fs JOIN monthly_active ma ON ma.customer_id = fs.customer_id
  WHERE ma.activity_month >= fs.cohort_month
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
  FROM first_success GROUP BY cohort_month
)
SELECT ca.cohort_month, ca.activity_month, ca.months_since_cohort,
  cs.cohort_customers, COUNT(DISTINCT ca.customer_id) AS active_customers,
  ROUND(100.0 * COUNT(DISTINCT ca.customer_id) / NULLIF(cs.cohort_customers, 0), 2) AS retention_pct
FROM cohort_activity ca JOIN cohort_sizes cs ON cs.cohort_month = ca.cohort_month
GROUP BY ca.cohort_month, ca.activity_month, ca.months_since_cohort, cs.cohort_customers
ORDER BY ca.cohort_month, ca.months_since_cohort;
