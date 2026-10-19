-- Business question: Which onboarding cohorts generated successful transaction activity by calendar month?
SELECT DATE_FORMAT(c.customer_since,'%Y-%m') onboarding_cohort,
       DATE_FORMAT(t.transaction_time,'%Y-%m') activity_month,
       COUNT(DISTINCT c.customer_id) active_customers,
       COUNT(DISTINCT t.transaction_id) successful_transactions,
       ROUND(SUM(t.amount),2) successful_value
FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
JOIN transactions t ON t.account_id=a.account_id AND t.status='SUCCESS'
GROUP BY DATE_FORMAT(c.customer_since,'%Y-%m'),DATE_FORMAT(t.transaction_time,'%Y-%m')
HAVING activity_month>=onboarding_cohort
ORDER BY onboarding_cohort,activity_month;