-- Flag transfer metadata disagreements for human reconciliation; do not auto-correct ledger records.
SELECT tr.transfer_id,tr.transaction_id,tr.from_account_id,tr.to_account_id,tr.transfer_amount,tr.status transfer_status,
t.account_id transaction_account_id,t.amount transaction_amount,t.status transaction_status,
CASE WHEN t.account_id<>tr.from_account_id THEN 'SOURCE_ACCOUNT_MISMATCH' WHEN ABS(t.amount-tr.transfer_amount)>=0.01 THEN 'AMOUNT_MISMATCH' ELSE 'STATUS_MISMATCH' END review_reason
FROM transfers tr JOIN transactions t ON t.transaction_id=tr.transaction_id
WHERE t.account_id<>tr.from_account_id OR ABS(t.amount-tr.transfer_amount)>=0.01 OR (tr.status='COMPLETED' AND t.status<>'SUCCESS')
ORDER BY tr.initiated_at DESC,tr.transfer_id;