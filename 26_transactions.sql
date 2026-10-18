-- Demonstrate atomic transfer processing through a stored procedure.
-- This mutates demo account balances and creates ledger entries; execute only when intended.
USE banking_financial_management;

-- The procedure begins a transaction, locks both accounts in ascending ID order,
-- validates account status and available funds, posts debit + credit entries,
-- records the transfer, and commits. SQL exceptions cause ROLLBACK.
CALL sp_transfer_funds(1, 2, 250.00);

-- Verify the paired ledger rows and transfer metadata.
SELECT tr.transfer_id, tr.transfer_amount, tr.status AS transfer_status,
       out_tx.reference_code AS debit_reference, out_tx.amount AS debit_amount,
       in_tx.reference_code AS credit_reference, in_tx.amount AS credit_amount,
       tr.initiated_at
FROM transfers AS tr
JOIN transactions AS out_tx ON out_tx.transaction_id = tr.transaction_id
JOIN transactions AS in_tx
  ON in_tx.account_id = tr.to_account_id
 AND in_tx.transaction_type = 'CREDIT'
 AND in_tx.amount = tr.transfer_amount
 AND in_tx.transaction_time BETWEEN tr.initiated_at AND tr.initiated_at + INTERVAL 5 SECOND
WHERE tr.from_account_id = 1 AND tr.to_account_id = 2
ORDER BY tr.transfer_id DESC
LIMIT 10;

-- Compare before/after account balance totals.
SELECT account_number, current_balance, status
FROM accounts
WHERE account_id IN (1, 2)
ORDER BY account_id;


-- Inspect account balances after the transfer procedure has committed.
SELECT account_id,account_number,current_balance,status FROM accounts WHERE account_id IN (1,2) ORDER BY account_id;


-- Compare recorded transfer metadata to the originating debit ledger row.
SELECT tr.transfer_id,tr.transfer_amount,tr.status AS transfer_status,tx.reference_code,tx.amount AS ledger_amount,tx.transaction_type,tx.status AS ledger_status FROM transfers tr JOIN transactions tx ON tx.transaction_id=tr.transaction_id ORDER BY tr.transfer_id DESC LIMIT 25;


-- For a disposable test database, capture the two account balances before a deliberately
-- invalid transfer, invoke the procedure with an insufficient amount, and verify that
-- balances, transaction count and transfer count remain unchanged after the expected error.
-- This is a manual QA scenario; it intentionally does not execute a failing CALL here.
