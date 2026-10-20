-- Business question: What share of currently active cards at each branch recorded successful card activity in the last 30 days?
-- Grain: one branch/card-type group; branch refers to the card account's current branch, not necessarily transaction location.
WITH recent_card_usage AS (
  SELECT card_id, COUNT(*) AS event_count,
    SUM(status = 'SUCCESS') AS successful_event_count,
    MAX(transaction_time) AS last_card_event_at
  FROM card_transactions
  WHERE transaction_time >= CURRENT_DATE - INTERVAL 30 DAY
  GROUP BY card_id
)
SELECT b.branch_id, b.branch_name, c.card_type,
  COUNT(*) AS issued_card_count,
  SUM(c.status = 'ACTIVE') AS currently_active_cards,
  SUM(c.status = 'ACTIVE' AND COALESCE(rc.successful_event_count, 0) > 0) AS active_cards_with_success,
  ROUND(100.0 * SUM(c.status = 'ACTIVE' AND COALESCE(rc.successful_event_count, 0) > 0)
    / NULLIF(SUM(c.status = 'ACTIVE'), 0), 2) AS active_card_success_coverage_pct,
  SUM(COALESCE(rc.event_count, 0)) AS observed_card_events_last_30_days
FROM cards c
JOIN accounts a ON a.account_id = c.account_id
JOIN branches b ON b.branch_id = a.branch_id
LEFT JOIN recent_card_usage rc ON rc.card_id = c.card_id
GROUP BY b.branch_id, b.branch_name, c.card_type
ORDER BY active_card_success_coverage_pct, b.branch_id, c.card_type;
