-- Business question: Which transactions have more than one settlement record?
-- Multiple records can be legitimate lifecycle events in some systems; reconcile against the settlement contract.
SELECT s.transaction_id,t.reference_code,COUNT(*) settlement_record_count,
       ROUND(SUM(s.settlement_amount),2) summed_settlement_amount,
       MIN(s.settled_at) first_settled_at,MAX(s.settled_at) last_settled_at,
       GROUP_CONCAT(DISTINCT s.status ORDER BY s.status) observed_statuses
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
GROUP BY s.transaction_id,t.reference_code
HAVING COUNT(*)>1
ORDER BY settlement_record_count DESC,s.transaction_id;