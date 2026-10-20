-- Business question: How close together in time are recorded fraud events associated with the same customer?
-- Grain: one fraud event after the customer's first recorded event. A short gap is a queue-review signal, not proof of related incidents.
WITH ordered_events AS (
  SELECT a.customer_id, f.fraud_event_id, f.transaction_id, f.detected_at, f.fraud_type,
    f.action_taken, f.risk_score,
    LAG(f.detected_at) OVER (PARTITION BY a.customer_id ORDER BY f.detected_at, f.fraud_event_id) AS prior_event_at
  FROM fraud_events f
  JOIN transactions t ON t.transaction_id = f.transaction_id
  JOIN accounts a ON a.account_id = t.account_id
)
SELECT customer_id, fraud_event_id, transaction_id, prior_event_at, detected_at,
  TIMESTAMPDIFF(SECOND, prior_event_at, detected_at) AS seconds_since_prior_event,
  fraud_type, action_taken, risk_score
FROM ordered_events
WHERE prior_event_at IS NOT NULL
ORDER BY seconds_since_prior_event, customer_id, detected_at;
