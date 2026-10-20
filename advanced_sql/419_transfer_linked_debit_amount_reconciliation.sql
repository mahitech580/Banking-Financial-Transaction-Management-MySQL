-- Business question: Do transfer records agree with their linked transaction amount and status?
SELECT tr.transfer_id, tr.transaction_id, tr.transfer_amount,
       tr.status AS transfer_status, t.amount AS ledger_amount,
       t.transaction_type, t.status AS ledger_status,
       tr.transfer_amount - t.amount AS amount_difference,
       CASE WHEN t.transaction_id IS NULL THEN 'MISSING_LEDGER_ROW'
            WHEN tr.transfer_amount <> t.amount THEN 'AMOUNT_MISMATCH'
            WHEN t.transaction_type <> 'DEBIT' THEN 'EXPECTED_DEBIT_TYPE_MISMATCH'
            WHEN tr.status = 'COMPLETED' AND t.status <> 'SUCCESS' THEN 'STATUS_MISMATCH'
            ELSE 'MATCHES_BASIC_RULES' END AS reconciliation_result
FROM transfers AS tr
LEFT JOIN transactions AS t ON t.transaction_id = tr.transaction_id
ORDER BY (tr.transfer_amount <> COALESCE(t.amount, 0)) DESC, tr.transfer_id DESC;
