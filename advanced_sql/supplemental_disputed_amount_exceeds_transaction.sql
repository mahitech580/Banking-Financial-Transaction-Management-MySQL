-- Business question: Which dispute amounts exceed the original transaction amount?
-- Currency conversion, partial disputes, and fee rules can affect valid amounts; review context before correction.
SELECT d.dispute_id,d.transaction_id,t.reference_code,d.status,
       d.disputed_amount,t.amount AS transaction_amount,
       ROUND(d.disputed_amount-t.amount,2) excess_amount,
       ROUND(100*d.disputed_amount/NULLIF(t.amount,0),2) disputed_pct_of_transaction
FROM disputes d JOIN transactions t ON t.transaction_id=d.transaction_id
WHERE d.disputed_amount>t.amount
ORDER BY excess_amount DESC,d.dispute_id;