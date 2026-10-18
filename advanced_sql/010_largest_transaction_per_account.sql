-- Business question: What is the largest successful transaction recorded for each account?
WITH ranked AS (
  SELECT t.account_id, t.transaction_id, t.reference_code, t.amount, t.transaction_time,
         ROW_NUMBER() OVER (
           PARTITION BY t.account_id ORDER BY t.amount DESC, t.transaction_time DESC, t.transaction_id DESC
         ) AS row_num
  FROM transactions t
  WHERE t.status = 'SUCCESS'
)
SELECT a.account_number, r.transaction_id, r.reference_code, r.amount, r.transaction_time
FROM ranked r
JOIN accounts a ON a.account_id = r.account_id
WHERE r.row_num = 1
ORDER BY r.amount DESC;