-- Business question: Review recent ledger attempts associated with accounts currently frozen or closed.
SELECT a.account_number, a.status AS current_account_status,
       t.reference_code, t.transaction_time, t.transaction_type,
       t.amount, t.channel, t.status AS transaction_status
FROM accounts AS a
JOIN transactions AS t ON t.account_id = a.account_id
WHERE a.status IN ('FROZEN','CLOSED')
  AND t.transaction_time >= CURRENT_DATE - INTERVAL 30 DAY
ORDER BY t.transaction_time DESC, t.transaction_id DESC;
