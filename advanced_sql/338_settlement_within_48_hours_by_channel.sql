-- Business question: What fraction of settled records reached settlement within 48 hours of transaction time?
-- This is a timestamp-based measure, not an assertion about a provider contract SLA.
SELECT t.channel,COUNT(*) settled_records,
       SUM(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at) BETWEEN 0 AND 48) settled_within_48h,
       SUM(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at)>48) settled_after_48h,
       SUM(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at)<0) settled_before_transaction_timestamp,
       ROUND(100*SUM(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at) BETWEEN 0 AND 48)/NULLIF(COUNT(*),0),2) within_48h_pct,
       ROUND(AVG(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at)),2) average_settlement_delay_hours,
       MAX(TIMESTAMPDIFF(HOUR,t.transaction_time,s.settled_at)) maximum_delay_hours
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
WHERE s.status='SETTLED' AND s.settled_at IS NOT NULL
GROUP BY t.channel ORDER BY within_48h_pct DESC;