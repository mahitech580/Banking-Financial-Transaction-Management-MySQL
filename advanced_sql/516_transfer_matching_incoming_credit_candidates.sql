-- Business question: Find a potential destination credit corresponding to a transfer record.
-- Matching amount and timestamp is only a candidate: the schema does not store a direct link to the incoming credit.
SELECT tr.transfer_id, tr.transfer_amount, tr.initiated_at,
       tr.status AS transfer_status,
       source_tx.reference_code AS linked_debit_reference,
       source_tx.status AS linked_debit_status,
       destination.account_number AS destination_account,
       incoming.transaction_id AS candidate_credit_id,
       incoming.reference_code AS candidate_credit_reference,
       incoming.transaction_time AS candidate_credit_time,
       incoming.status AS candidate_credit_status
FROM transfers AS tr
JOIN transactions AS source_tx ON source_tx.transaction_id = tr.transaction_id
JOIN accounts AS destination ON destination.account_id = tr.to_account_id
LEFT JOIN transactions AS incoming
  ON incoming.account_id = tr.to_account_id
 AND incoming.transaction_type = 'CREDIT'
 AND incoming.amount = tr.transfer_amount
 AND incoming.transaction_time BETWEEN tr.initiated_at - INTERVAL 2 MINUTE
                                   AND tr.initiated_at + INTERVAL 5 MINUTE
 AND incoming.transaction_id <> tr.transaction_id
ORDER BY tr.initiated_at DESC, tr.transfer_id;
