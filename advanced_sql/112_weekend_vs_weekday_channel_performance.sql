-- Business question: Compare attempt volume and completion rates on weekdays versus weekends by channel.
SELECT channel,
       CASE WHEN DAYOFWEEK(transaction_time) IN (1,7) THEN 'WEEKEND' ELSE 'WEEKDAY' END day_type,
       COUNT(*) attempts,SUM(status='SUCCESS') successes,SUM(status='FAILED') failures,
       ROUND(100*SUM(status='SUCCESS')/NULLIF(COUNT(*),0),2) success_rate_pct,
       ROUND(SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END),2) successful_value
FROM transactions
GROUP BY channel,CASE WHEN DAYOFWEEK(transaction_time) IN (1,7) THEN 'WEEKEND' ELSE 'WEEKDAY' END
ORDER BY channel,day_type;