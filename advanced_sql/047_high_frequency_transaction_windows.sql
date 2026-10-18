-- Business question: Which accounts record three or more transactions within one-hour windows?
SELECT a.account_number, t1.transaction_time AS window_start,
       COUNT(t2.transaction_id) AS transactions_in_next_hour
FROM transactions t1
JOIN transactions t2
  ON t2.account_id = t1.account_id
 AND t2.transaction_time >= t1.transaction_time
 AND t2.transaction_time < t1.transaction_time + INTERVAL 1 HOUR
JOIN accounts a ON a.account_id = t1.account_id
GROUP BY a.account_number, t1.transaction_id, t1.transaction_time
HAVING COUNT(t2.transaction_id) >= 3
ORDER BY transactions_in_next_hour DESC, window_start;