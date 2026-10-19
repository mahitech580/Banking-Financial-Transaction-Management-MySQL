-- Business question: How does settled amount compare with the linked transaction amount by settlement month?
-- Aggregate differences are reconciliation indicators; fees or partial settlements may be valid.
SELECT DATE_FORMAT(s.settled_at,'%Y-%m') settlement_month,t.channel,t.transaction_type,
       COUNT(*) settled_records,COUNT(DISTINCT s.transaction_id) distinct_transactions,
       ROUND(SUM(s.settlement_amount),2) settlement_value,
       ROUND(SUM(t.amount),2) linked_transaction_value,
       ROUND(SUM(s.settlement_amount-t.amount),2) net_recorded_difference,
       ROUND(SUM(ABS(s.settlement_amount-t.amount)),2) gross_absolute_difference
FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id
WHERE s.status='SETTLED' AND s.settled_at IS NOT NULL
GROUP BY DATE_FORMAT(s.settled_at,'%Y-%m'),t.channel,t.transaction_type
ORDER BY settlement_month,t.channel,t.transaction_type;