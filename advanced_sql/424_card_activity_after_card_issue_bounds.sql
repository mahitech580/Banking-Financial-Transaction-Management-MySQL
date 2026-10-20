-- Business question: Flag card transaction timestamps that predate card issuance.
SELECT ct.card_transaction_id, ct.reference_code, c.card_number,
       c.issued_at, ct.transaction_time, ct.amount, ct.status,
       DATEDIFF(DATE(ct.transaction_time), c.issued_at) AS days_from_issue
FROM card_transactions AS ct
JOIN cards AS c ON c.card_id = ct.card_id
WHERE DATE(ct.transaction_time) < c.issued_at
ORDER BY ct.transaction_time, ct.card_transaction_id;
