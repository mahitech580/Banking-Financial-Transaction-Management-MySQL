-- Business question: Which accounts interact with the widest set of transfer counterparties?
WITH counterparty_edges AS (
  SELECT from_account_id AS account_id, to_account_id AS counterparty_id,
         transfer_amount, initiated_at, status
  FROM transfers
  UNION ALL
  SELECT to_account_id AS account_id, from_account_id AS counterparty_id,
         transfer_amount, initiated_at, status
  FROM transfers
)
SELECT a.account_number, COUNT(*) AS transfer_edges,
       COUNT(DISTINCT e.counterparty_id) AS distinct_counterparties,
       SUM(CASE WHEN e.status = 'COMPLETED' THEN e.transfer_amount ELSE 0 END) AS completed_transfer_value,
       MIN(e.initiated_at) AS first_transfer_at,
       MAX(e.initiated_at) AS last_transfer_at
FROM counterparty_edges AS e
JOIN accounts AS a ON a.account_id = e.account_id
GROUP BY a.account_id, a.account_number
ORDER BY distinct_counterparties DESC, completed_transfer_value DESC;
