-- Business question: Which transactions have multiple dispute records requiring case-level reconciliation?
SELECT d.transaction_id,t.reference_code,COUNT(*) dispute_count,
       ROUND(SUM(d.disputed_amount),2) gross_disputed_amount,
       COUNT(DISTINCT d.status) status_count,
       MIN(d.opened_at) first_dispute_opened_at,MAX(d.opened_at) latest_dispute_opened_at
FROM disputes d JOIN transactions t ON t.transaction_id=d.transaction_id
GROUP BY d.transaction_id,t.reference_code
HAVING COUNT(*)>1
ORDER BY dispute_count DESC,gross_disputed_amount DESC;