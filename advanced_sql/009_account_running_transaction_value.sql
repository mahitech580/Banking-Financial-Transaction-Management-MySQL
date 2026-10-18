-- Business question: How does cumulative successful gross activity evolve for each account?
SELECT account_id, transaction_id, transaction_time, transaction_type, amount,
       SUM(amount) OVER (
         PARTITION BY account_id
         ORDER BY transaction_time, transaction_id
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_gross_value
FROM transactions
WHERE status = 'SUCCESS'
ORDER BY account_id, transaction_time, transaction_id;