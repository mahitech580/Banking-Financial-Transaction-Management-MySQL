-- Business question: Compare completed transfers sent and received across customer accounts.
WITH transfer_flows AS (
  SELECT a.customer_id, 'OUTGOING' AS direction, tr.transfer_amount, tr.status
  FROM transfers AS tr
  JOIN accounts AS a ON a.account_id = tr.from_account_id
  UNION ALL
  SELECT a.customer_id, 'INCOMING' AS direction, tr.transfer_amount, tr.status
  FROM transfers AS tr
  JOIN accounts AS a ON a.account_id = tr.to_account_id
)
SELECT c.customer_number, f.direction,
       COUNT(*) AS transfer_count,
       SUM(f.transfer_amount) AS all_transfer_value,
       SUM(CASE WHEN f.status = 'COMPLETED' THEN f.transfer_amount ELSE 0 END) AS completed_transfer_value
FROM transfer_flows AS f
JOIN customers AS c ON c.customer_id = f.customer_id
GROUP BY c.customer_id, c.customer_number, f.direction
ORDER BY completed_transfer_value DESC;
