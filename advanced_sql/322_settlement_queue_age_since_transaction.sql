-- Business question: How old are pending/failed settlement records relative to their linked transaction time?
-- The schema has no settlement-created timestamp; this measures elapsed time from the original transaction.
SELECT s.status,
       CASE WHEN TIMESTAMPDIFF(HOUR,t.transaction_time,CURRENT_TIMESTAMP)<24 THEN 'UNDER_24_HOURS'
            WHEN TIMESTAMPDIFF(HOUR,t.transaction_time,CURRENT_TIMESTAMP)<72 THEN '24_TO_72_HOURS'
            WHEN TIMESTAMPDIFF(DAY,t.transaction_time,CURRENT_TIMESTAMP)<7 THEN '3_TO_7_DAYS'
            ELSE '7_DAYS_OR_MORE' END transaction_age_band,
       COUNT(*) settlement_records,COUNT(DISTINCT s.transaction_id) distinct_transactions,
       ROUND(SUM(s.settlement_amount),2) settlement_amount,
       MIN(t.transaction_time) oldest_transaction_time,
       MAX(TIMESTAMPDIFF(HOUR,t.transaction_time,CURRENT_TIMESTAMP)) maximum_age_hours
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
WHERE s.status IN ('PENDING','FAILED')
GROUP BY s.status,transaction_age_band
ORDER BY s.status,FIELD(transaction_age_band,'UNDER_24_HOURS','24_TO_72_HOURS','3_TO_7_DAYS','7_DAYS_OR_MORE');