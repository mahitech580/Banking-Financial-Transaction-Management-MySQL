-- Business question: Do account-ledger and card-activity rows share a reference, and do their amount/time details agree?
-- Grain: one candidate pair. A matching reference alone does not establish duplication; the sources can represent related events.
SELECT t.transaction_id, t.reference_code, t.status AS ledger_status,
  t.amount AS ledger_amount, t.transaction_time AS ledger_time,
  ct.card_transaction_id, ct.status AS card_status, ct.amount AS card_amount,
  ct.transaction_time AS card_time, ct.channel AS card_channel,
  c.card_type, m.merchant_name,
  (t.amount = ct.amount) AS amounts_equal,
  (ABS(TIMESTAMPDIFF(SECOND, t.transaction_time, ct.transaction_time)) <= 300) AS within_five_minutes,
  CASE WHEN t.amount <> ct.amount THEN 'AMOUNT_DIFFERS'
    WHEN ABS(TIMESTAMPDIFF(SECOND, t.transaction_time, ct.transaction_time)) > 300 THEN 'TIME_DIFFERS'
    ELSE 'REFERENCE_AMOUNT_TIME_ALIGN' END AS review_reason
FROM transactions t
JOIN card_transactions ct ON ct.reference_code = t.reference_code
JOIN cards c ON c.card_id = ct.card_id
JOIN merchants m ON m.merchant_id = ct.merchant_id
ORDER BY t.transaction_time DESC, t.transaction_id, ct.card_transaction_id;
