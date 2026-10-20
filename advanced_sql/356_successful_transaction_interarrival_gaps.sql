-- Business question: How long did each account wait between consecutive successful ledger transactions?
-- Grain: one successful transaction after the first successful event for an account; gaps are descriptive, not fraud evidence.
WITH ordered_success AS (
  SELECT t.account_id, t.transaction_id, t.reference_code, t.transaction_time, t.amount, t.channel,
    LAG(t.transaction_time) OVER (
      PARTITION BY t.account_id ORDER BY t.transaction_time, t.transaction_id
    ) AS previous_success_at
  FROM transactions t
  WHERE t.status = 'SUCCESS'
)
SELECT account_id, transaction_id, reference_code, previous_success_at, transaction_time,
  TIMESTAMPDIFF(SECOND, previous_success_at, transaction_time) AS seconds_since_previous_success,
  ROUND(TIMESTAMPDIFF(SECOND, previous_success_at, transaction_time) / 60.0, 2) AS minutes_since_previous_success,
  amount, channel
FROM ordered_success
WHERE previous_success_at IS NOT NULL
ORDER BY seconds_since_previous_success DESC, account_id, transaction_time;
