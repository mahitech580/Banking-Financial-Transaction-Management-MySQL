-- Business question: How old are pending transaction attempts?
SELECT transaction_id, reference_code, account_id, amount, transaction_time,
       TIMESTAMPDIFF(HOUR, transaction_time, CURRENT_TIMESTAMP) AS age_hours,
       CASE
         WHEN transaction_time >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 HOUR) THEN 'UNDER_1_HOUR'
         WHEN transaction_time >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 24 HOUR) THEN '1_TO_24_HOURS'
         WHEN transaction_time >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 7 DAY) THEN '1_TO_7_DAYS'
         ELSE 'OVER_7_DAYS'
       END AS age_band
FROM transactions
WHERE status = 'PENDING'
ORDER BY transaction_time;
