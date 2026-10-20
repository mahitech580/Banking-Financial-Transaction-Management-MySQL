-- Business question: Which transfer-typed ledger transactions lack metadata, or transfer records link to an unexpected transaction type?
-- Grain: one linkage exception. This project intentionally links a transfer record to its originating DEBIT transaction.
-- A DEBIT transaction is therefore an expected source type and must not be flagged merely for not being typed TRANSFER.
WITH linkage_exceptions AS (
  SELECT t.transaction_id, t.reference_code, t.transaction_type, t.status AS transaction_status,
    t.amount, tr.transfer_id, tr.status AS transfer_status,
    'TRANSFER_TRANSACTION_WITHOUT_TRANSFER_ROW' AS exception_type
  FROM transactions t
  LEFT JOIN transfers tr ON tr.transaction_id = t.transaction_id
  WHERE t.transaction_type = 'TRANSFER' AND tr.transfer_id IS NULL

  UNION ALL

  SELECT t.transaction_id, t.reference_code, t.transaction_type, t.status,
    t.amount, tr.transfer_id, tr.status,
    'TRANSFER_ROW_LINKED_TO_UNEXPECTED_TYPE' AS exception_type
  FROM transfers tr
  JOIN transactions t ON t.transaction_id = tr.transaction_id
  WHERE t.transaction_type NOT IN ('DEBIT', 'TRANSFER')
)
SELECT transaction_id, reference_code, transaction_type, transaction_status,
  amount, transfer_id, transfer_status, exception_type
FROM linkage_exceptions
ORDER BY exception_type, transaction_id;
