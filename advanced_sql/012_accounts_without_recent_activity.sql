-- Business question: Which active accounts have no transaction in the last 90 days?
SELECT a.account_id, a.account_number, a.current_balance, a.opened_at
FROM accounts a
WHERE a.status = 'ACTIVE'
  AND NOT EXISTS (
    SELECT 1 FROM transactions t
    WHERE t.account_id = a.account_id
      AND t.transaction_time >= CURRENT_DATE - INTERVAL 90 DAY
  )
ORDER BY a.current_balance DESC;