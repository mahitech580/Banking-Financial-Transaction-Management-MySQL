-- Business question: Which accounts have repeated amounts on the same calendar date?
SELECT account_id, DATE(transaction_time) AS activity_day, amount,
       COUNT(*) AS repeat_count,
       GROUP_CONCAT(reference_code ORDER BY transaction_time SEPARATOR ', ') AS references_seen
FROM transactions
GROUP BY account_id, DATE(transaction_time), amount
HAVING COUNT(*) > 1
ORDER BY repeat_count DESC, activity_day DESC, account_id;
