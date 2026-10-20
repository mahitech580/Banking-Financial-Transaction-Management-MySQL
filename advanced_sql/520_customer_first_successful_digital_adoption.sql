-- Business question: Measure the elapsed time from customer onboarding to first successful online or mobile transaction.
WITH first_digital_success AS (
  SELECT a.customer_id, MIN(t.transaction_time) AS first_digital_success_at
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  WHERE t.status = 'SUCCESS' AND t.channel IN ('ONLINE','MOBILE')
  GROUP BY a.customer_id
)
SELECT c.customer_number, c.risk_level, c.customer_since,
       fs.first_digital_success_at,
       DATEDIFF(DATE(fs.first_digital_success_at), c.customer_since) AS days_from_onboarding_to_digital_success,
       CASE WHEN fs.first_digital_success_at IS NULL THEN 'NO_SUCCESSFUL_DIGITAL_EVENT'
            WHEN DATE(fs.first_digital_success_at) < c.customer_since THEN 'CHECK_DATE_ORDER'
            WHEN DATEDIFF(DATE(fs.first_digital_success_at), c.customer_since) <= 30 THEN 'WITHIN_30_DAYS'
            WHEN DATEDIFF(DATE(fs.first_digital_success_at), c.customer_since) <= 180 THEN '31_TO_180_DAYS'
            ELSE 'OVER_180_DAYS' END AS digital_adoption_band
FROM customers AS c
LEFT JOIN first_digital_success AS fs ON fs.customer_id = c.customer_id
ORDER BY days_from_onboarding_to_digital_success, c.customer_number;
