-- Business question: Find dispute rows where disputed amount exceeds the linked ledger amount.
SELECT d.dispute_id, d.reason, d.status AS dispute_status, d.disputed_amount,
       t.reference_code, t.amount AS source_amount,
       d.disputed_amount - t.amount AS excess_disputed_amount, t.channel, t.transaction_time
FROM disputes AS d
JOIN transactions AS t ON t.transaction_id = d.transaction_id
WHERE d.disputed_amount > t.amount
ORDER BY excess_disputed_amount DESC, d.dispute_id;
