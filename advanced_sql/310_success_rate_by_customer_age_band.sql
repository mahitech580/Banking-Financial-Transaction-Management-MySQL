-- Business question: Does observed transaction success rate differ by customer age band?
-- Age is calculated at the transaction date for each attempt, not today's age.
WITH attempts AS (
  SELECT c.customer_id,t.status,t.amount,t.transaction_time,t.transaction_type,t.channel,
         TIMESTAMPDIFF(YEAR,c.date_of_birth,DATE(t.transaction_time)) customer_age_at_attempt
  FROM customers c JOIN accounts a ON a.customer_id=c.customer_id
  JOIN transactions t ON t.account_id=a.account_id
)
SELECT CASE WHEN customer_age_at_attempt<25 THEN 'UNDER_25'
            WHEN customer_age_at_attempt<35 THEN '25_TO_34'
            WHEN customer_age_at_attempt<45 THEN '35_TO_44'
            WHEN customer_age_at_attempt<60 THEN '45_TO_59'
            ELSE '60_PLUS' END customer_age_band,
       channel,COUNT(*) attempts,SUM(status='SUCCESS') successes,SUM(status='FAILED') failures,
       ROUND(100*SUM(status='SUCCESS')/NULLIF(COUNT(*),0),2) success_rate_pct,
       ROUND(SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END),2) successful_value
FROM attempts GROUP BY customer_age_band,channel
ORDER BY customer_age_band,channel;