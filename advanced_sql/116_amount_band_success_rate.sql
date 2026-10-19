-- Business question: How do transaction completion rates vary by transaction amount band and channel?
WITH banded AS (
  SELECT channel,status,amount,
         CASE WHEN amount<100 THEN 'UNDER_100'
              WHEN amount<1000 THEN '100_TO_999_99'
              WHEN amount<10000 THEN '1000_TO_9999_99'
              ELSE '10000_OR_MORE' END amount_band
  FROM transactions
)
SELECT channel,amount_band,COUNT(*) attempts,SUM(status='SUCCESS') successes,SUM(status='FAILED') failures,
       ROUND(100*SUM(status='SUCCESS')/NULLIF(COUNT(*),0),2) success_rate_pct,
       ROUND(SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END),2) successful_value
FROM banded GROUP BY channel,amount_band
ORDER BY channel,FIELD(amount_band,'UNDER_100','100_TO_999_99','1000_TO_9999_99','10000_OR_MORE');