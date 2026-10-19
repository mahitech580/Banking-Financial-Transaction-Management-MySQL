-- Business question: Do completed transfer records have a nearby matching successful credit on the destination account?
-- The model links the transfer row to the source debit; the receiving credit is matched by account, amount, and time.
SELECT tr.transfer_id,tr.transaction_id source_transaction_id,tr.from_account_id,tr.to_account_id,
       tr.transfer_amount,tr.initiated_at,tr.status,
       (SELECT t2.transaction_id
        FROM transactions t2
        WHERE t2.account_id=tr.to_account_id AND t2.transaction_type='CREDIT'
          AND t2.status='SUCCESS' AND t2.amount=tr.transfer_amount
          AND ABS(TIMESTAMPDIFF(SECOND,tr.initiated_at,t2.transaction_time))<=60
        ORDER BY ABS(TIMESTAMPDIFF(SECOND,tr.initiated_at,t2.transaction_time)),t2.transaction_id
        LIMIT 1) candidate_credit_transaction_id
FROM transfers tr
WHERE tr.status='COMPLETED'
  AND NOT EXISTS (
    SELECT 1 FROM transactions t2
    WHERE t2.account_id=tr.to_account_id AND t2.transaction_type='CREDIT'
      AND t2.status='SUCCESS' AND t2.amount=tr.transfer_amount
      AND ABS(TIMESTAMPDIFF(SECOND,tr.initiated_at,t2.transaction_time))<=60
  )
ORDER BY tr.initiated_at DESC,tr.transfer_id;