-- Business question: How many customers in each onboarding cohort transact successfully in later calendar months?
-- Cohort is based on customer_since; this is activity retention, not a causal measure.
WITH customer_months AS (
  SELECT DISTINCT c.customer_id, DATE_FORMAT(c.customer_since,'%Y-%m-01') cohort_month,
         DATE_FORMAT(t.transaction_time,'%Y-%m-01') activity_month
  FROM customers c
  JOIN accounts a ON a.customer_id=c.customer_id
  JOIN transactions t ON t.account_id=a.account_id
  WHERE t.status='SUCCESS'
),
cohort_activity AS (
  SELECT customer_id,cohort_month,activity_month,
         TIMESTAMPDIFF(MONTH,cohort_month,activity_month) months_since_cohort
  FROM customer_months
  WHERE activity_month>=cohort_month
)
SELECT cohort_month,months_since_cohort,COUNT(DISTINCT customer_id) active_customers
FROM cohort_activity
GROUP BY cohort_month,months_since_cohort
ORDER BY cohort_month,months_since_cohort;