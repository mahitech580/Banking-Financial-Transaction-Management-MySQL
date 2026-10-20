-- Business question: Which card-activity events are linked to cards currently marked blocked or expired?
-- Grain: one card event. The schema stores only current card status, so do not infer the status that applied at event time.
SELECT c.card_id, c.customer_id, c.card_type, c.status AS current_card_status,
  ct.card_transaction_id, ct.reference_code, ct.transaction_time, ct.channel,
  ct.status AS activity_status, ct.amount, m.merchant_name, m.merchant_category,
  CASE WHEN ct.status = 'SUCCESS' THEN 'SUCCESS_RECORDED_FOR_NONACTIVE_CARD'
    ELSE 'NONACTIVE_CARD_ACTIVITY_RECORDED' END AS review_reason
FROM cards c
JOIN card_transactions ct ON ct.card_id = c.card_id
JOIN merchants m ON m.merchant_id = ct.merchant_id
WHERE c.status IN ('BLOCKED', 'EXPIRED')
ORDER BY ct.transaction_time DESC, c.card_id, ct.card_transaction_id;
