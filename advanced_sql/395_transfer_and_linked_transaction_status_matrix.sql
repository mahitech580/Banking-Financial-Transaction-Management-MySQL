-- Business question: Which combinations of transfer lifecycle status and linked ledger transaction status occur?
-- Grain: one transfer-status/transaction-status pair. Different state names are not necessarily equivalent lifecycle milestones.
SELECT tr.status AS transfer_status, t.status AS linked_transaction_status,
  COUNT(*) AS transfer_count,
  SUM(tr.transfer_amount) AS transfer_record_amount,
  COALESCE(SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END), 0.00)
    AS linked_successful_transaction_amount,
  SUM(tr.status = 'COMPLETED' AND t.status <> 'SUCCESS') AS completed_with_non_success_link,
  SUM(tr.status <> 'COMPLETED' AND t.status = 'SUCCESS') AS noncompleted_with_success_link
FROM transfers tr JOIN transactions t ON t.transaction_id = tr.transaction_id
GROUP BY tr.status, t.status
ORDER BY tr.status, t.status;
