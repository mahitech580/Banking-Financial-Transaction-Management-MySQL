-- Business question: How long after customer onboarding does their first successful transaction occur?
WITH first_success AS (
  SELECT a.customer_id,MIN(t.transaction_time) first_success_at
  FROM accounts a JOIN transactions t ON t.account_id=a.account_id
  WHERE t.status='SUCCESS'
  GROUP BY a.customer_id
)
SELECT c.customer_id,c.customer_number,c.customer_since,fs.first_success_at,
       TIMESTAMPDIFF(DAY,c.customer_since,fs.first_success_at) days_to_first_success,
       CASE WHEN fs.first_success_at IS NULL THEN 'NO_SUCCESSFUL_ACTIVITY'
            WHEN fs.first_success_at<c.customer_since THEN 'SUCCESS_BEFORE_ONBOARDING_DATE'
            ELSE 'SUCCESS_ON_OR_AFTER_ONBOARDING' END chronology_check
FROM customers c LEFT JOIN first_success fs ON fs.customer_id=c.customer_id
ORDER BY days_to_first_success DESC,c.customer_id;