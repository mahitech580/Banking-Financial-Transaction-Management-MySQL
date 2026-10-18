-- Business question: Which accounts have identical successful amounts repeated on the same day?
SELECT account_id, DATE(transaction_time) AS transaction_day, amount,
       COUNT(*) AS repeated_count,
       GROUP_CONCAT(reference_code ORDER BY transaction_time SEPARATOR ', ') AS references_found
FROM transactions
WHERE status = 'SUCCESS'
GROUP BY account_id, DATE(transaction_time), amount
HAVING COUNT(*) > 1
ORDER BY repeated_count DESC, transaction_day DESC;