-- Business question: Are ledger rows typed TRANSFER missing transfer metadata, or transfer metadata linked to another transaction type?
-- Grain: one linkage exception. Transfer posting conventions may use a dedicated originating debit row, so review project rules before correction.
WITH linkage_exceptions AS (
  SELECT t.transaction_id, t.reference_code, t.transaction_type, t.status AS transaction_status,
    t.amount, tr.transfer_id, tr.status AS transfer_status, 'TRANSFER_TRANSACTION_WITHOUT_TRANSFER_ROW' AS exception_type
  FROM transactions t LEFT JOIN transfers tr ON tr.transaction_id = t.transaction_id
  WHERE t.transaction_type = 'TRANSFER' AND tr.transfer_id IS NULL
  UNION ALL
  SELECT t.transaction_id, t.reference_code, t.transaction_type, t.status,
    t.amount, tr.transfer_id, tr.status, 'TRANSFER_ROW_LINKED_TO_NON_TRANSFER_TYPE'
  FROM transfers tr JOIN transactions t ON t.transaction_id = tr.transaction_id
  WHERE t.transaction_type <> 'TRANSFER'
)
SELECT transaction_id, reference_code, transaction_type, transaction_status,
  amount, transfer_id, transfer_status, exception_type
FROM linkage_exceptions
ORDER BY exception_type, transaction_id;
