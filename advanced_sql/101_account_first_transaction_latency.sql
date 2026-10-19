-- Business question: How long after account opening does the first transaction attempt occur?
WITH first_attempt AS (
  SELECT account_id,MIN(transaction_time) first_transaction_at,COUNT(*) transaction_count
  FROM transactions GROUP BY account_id
)
SELECT a.account_id,a.account_number,a.opened_at,f.first_transaction_at,
       TIMESTAMPDIFF(DAY,a.opened_at,f.first_transaction_at) days_until_first_attempt,
       COALESCE(f.transaction_count,0) transaction_count
FROM accounts a LEFT JOIN first_attempt f ON f.account_id=a.account_id
ORDER BY days_until_first_attempt DESC,a.account_id;