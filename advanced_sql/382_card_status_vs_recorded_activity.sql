-- Business question: What activity outcomes have been recorded for cards by their current status?
-- Grain: one current-card-status/activity-status group. The card's current state is not a historical snapshot at transaction time.
SELECT c.card_type, c.status AS current_card_status, ct.status AS activity_status,
  ct.channel, COUNT(*) AS activity_count,
  SUM(ct.transaction_time >= CURRENT_DATE - INTERVAL 30 DAY) AS events_in_last_30_days,
  COALESCE(SUM(CASE WHEN ct.status = 'SUCCESS' THEN ct.amount ELSE 0 END), 0.00)
    AS successful_gross_value,
  MAX(ct.transaction_time) AS latest_activity_at
FROM cards c JOIN card_transactions ct ON ct.card_id = c.card_id
GROUP BY c.card_type, c.status, ct.status, ct.channel
ORDER BY c.status, activity_count DESC, ct.channel;
