-- Business question: Which active credit cards have comparatively high recent successful purchase values against their recorded limits?
-- Grain: one card. The ratio is a spend-to-limit proxy, not revolving-balance utilization because settlement, refunds and repayment balances are not modeled here.
WITH recent_spend AS (
  SELECT card_id,
    SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_spend_30d,
    COUNT(*) AS attempts_30d,
    MAX(transaction_time) AS latest_card_activity
  FROM card_transactions
  WHERE transaction_time >= CURRENT_DATE - INTERVAL 30 DAY
  GROUP BY card_id
)
SELECT c.card_id, c.customer_id, c.account_id, c.status AS card_status,
  c.credit_limit, COALESCE(rs.successful_spend_30d, 0.00) AS successful_spend_30d,
  COALESCE(rs.attempts_30d, 0) AS attempts_30d, rs.latest_card_activity,
  ROUND(100.0 * COALESCE(rs.successful_spend_30d, 0.00) / NULLIF(c.credit_limit, 0), 2)
    AS spend_to_limit_proxy_pct,
  CASE WHEN c.credit_limit <= 0 THEN 'NONPOSITIVE_LIMIT_REVIEW'
    WHEN COALESCE(rs.successful_spend_30d, 0.00) / c.credit_limit >= 0.80 THEN 'AT_LEAST_80_PERCENT'
    WHEN COALESCE(rs.successful_spend_30d, 0.00) / c.credit_limit >= 0.50 THEN '50_TO_79_PERCENT'
    ELSE 'BELOW_50_PERCENT' END AS proxy_band
FROM cards c LEFT JOIN recent_spend rs ON rs.card_id = c.card_id
WHERE c.card_type = 'CREDIT'
ORDER BY spend_to_limit_proxy_pct DESC, c.card_id;
