-- Business question: Identify ledger events whose recorded timestamp predates account opening.
SELECT t.transaction_id, t.reference_code, t.transaction_type, t.amount,
       t.transaction_time, t.status, a.account_id, a.account_number, a.opened_at,
       DATEDIFF(a.opened_at, DATE(t.transaction_time)) AS days_before_opening
FROM transactions AS t
JOIN accounts AS a ON a.account_id = t.account_id
WHERE DATE(t.transaction_time) < a.opened_at
ORDER BY t.transaction_time, t.transaction_id;
