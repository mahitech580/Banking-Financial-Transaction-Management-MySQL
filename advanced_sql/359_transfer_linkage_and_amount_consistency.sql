-- Business question: Do transfer records agree with their linked transaction's source account, amount, and lifecycle status?
-- Grain: one transfer record. Status differences are review candidates because lifecycle semantics may legitimately differ.
SELECT tr.transfer_id, tr.transaction_id, t.reference_code, tr.status AS transfer_status,
  t.status AS transaction_status, tr.from_account_id, t.account_id AS linked_transaction_account_id,
  tr.to_account_id, tr.transfer_amount, t.amount AS linked_transaction_amount,
  (tr.from_account_id = t.account_id) AS source_account_matches,
  (tr.transfer_amount = t.amount) AS amounts_match,
  CASE WHEN tr.from_account_id <> t.account_id THEN 'SOURCE_ACCOUNT_MISMATCH'
    WHEN tr.transfer_amount <> t.amount THEN 'AMOUNT_MISMATCH'
    WHEN tr.status = 'COMPLETED' AND t.status <> 'SUCCESS' THEN 'COMPLETED_TRANSFER_NON_SUCCESS_TRANSACTION'
    ELSE 'NO_BASIC_LINKAGE_EXCEPTION' END AS review_reason
FROM transfers tr JOIN transactions t ON t.transaction_id = tr.transaction_id
ORDER BY (tr.from_account_id <> t.account_id) DESC,
  (tr.transfer_amount <> t.amount) DESC, tr.initiated_at DESC, tr.transfer_id;
