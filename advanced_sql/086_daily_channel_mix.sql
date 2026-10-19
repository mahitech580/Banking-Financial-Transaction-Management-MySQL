-- Daily channel-level volume and successful value for dashboard trend checks.
SELECT DATE(transaction_time) activity_date,channel,COUNT(*) attempts,SUM(status='SUCCESS') successes,
ROUND(SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END),2) successful_value
FROM transactions GROUP BY DATE(transaction_time),channel ORDER BY activity_date,channel;