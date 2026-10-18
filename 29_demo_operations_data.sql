-- Optional demo records for the cards, loans, repayments, fraud, disputes and settlement screens.
-- Safe to re-run: each synthetic record is inserted only when its identifying record is absent.
USE banking_financial_management;

INSERT INTO cards (card_number, customer_id, account_id, card_type, issued_at, credit_limit, status)
SELECT 'DEMO-CARD-10001', c.customer_id, a.account_id, 'DEBIT', '2024-02-01', 0.00, 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'SB100001'
  AND NOT EXISTS (SELECT 1 FROM cards WHERE card_number = 'DEMO-CARD-10001')
UNION ALL
SELECT 'DEMO-CARD-10002', c.customer_id, a.account_id, 'DEBIT', '2024-03-14', 0.00, 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'SB100002'
  AND NOT EXISTS (SELECT 1 FROM cards WHERE card_number = 'DEMO-CARD-10002')
UNION ALL
SELECT 'DEMO-CARD-10003', c.customer_id, a.account_id, 'CREDIT', '2024-04-22', 250000.00, 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'CA100003'
  AND NOT EXISTS (SELECT 1 FROM cards WHERE card_number = 'DEMO-CARD-10003')
UNION ALL
SELECT 'DEMO-CARD-10005', c.customer_id, a.account_id, 'CREDIT', '2023-11-05', 500000.00, 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'CA100005'
  AND NOT EXISTS (SELECT 1 FROM cards WHERE card_number = 'DEMO-CARD-10005')
UNION ALL
SELECT 'DEMO-CARD-10009', c.customer_id, a.account_id, 'DEBIT', '2025-06-11', 0.00, 'BLOCKED'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'SB100009'
  AND NOT EXISTS (SELECT 1 FROM cards WHERE card_number = 'DEMO-CARD-10009');

INSERT INTO loans (customer_id, account_id, loan_type, principal, interest_rate, tenure_months, start_date, status)
SELECT c.customer_id, a.account_id, 'PERSONAL', 250000.00, 11.500, 36, '2025-01-15', 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'SB100002'
  AND NOT EXISTS (SELECT 1 FROM loans WHERE customer_id = c.customer_id AND loan_type = 'PERSONAL')
UNION ALL
SELECT c.customer_id, a.account_id, 'BUSINESS', 800000.00, 10.250, 60, '2024-06-01', 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'CA100003'
  AND NOT EXISTS (SELECT 1 FROM loans WHERE customer_id = c.customer_id AND loan_type = 'BUSINESS')
UNION ALL
SELECT c.customer_id, a.account_id, 'BUSINESS', 650000.00, 12.000, 48, '2025-02-01', 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'CA100005'
  AND NOT EXISTS (SELECT 1 FROM loans WHERE customer_id = c.customer_id AND loan_type = 'BUSINESS')
UNION ALL
SELECT c.customer_id, a.account_id, 'EDUCATION', 350000.00, 8.750, 60, '2024-08-10', 'ACTIVE'
FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_number = 'SB100006'
  AND NOT EXISTS (SELECT 1 FROM loans WHERE customer_id = c.customer_id AND loan_type = 'EDUCATION');

INSERT INTO loan_payments (loan_id, due_date, paid_date, amount_due, amount_paid, status)
SELECT l.loan_id, '2026-09-05', '2026-09-04', 8500.00, 8500.00, 'PAID'
FROM loans l WHERE l.loan_type = 'PERSONAL'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-09-05')
UNION ALL
SELECT l.loan_id, '2026-10-05', NULL, 8500.00, 0.00, 'DUE'
FROM loans l WHERE l.loan_type = 'PERSONAL'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-10-05')
UNION ALL
SELECT l.loan_id, '2026-09-10', '2026-09-12', 19500.00, 19500.00, 'LATE'
FROM loans l WHERE l.loan_type = 'BUSINESS'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-09-10')
UNION ALL
SELECT l.loan_id, '2026-10-10', NULL, 19500.00, 0.00, 'DUE'
FROM loans l WHERE l.loan_type = 'BUSINESS'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-10-10')
UNION ALL
SELECT l.loan_id, '2026-09-15', '2026-09-14', 6100.00, 6100.00, 'PAID'
FROM loans l WHERE l.loan_type = 'EDUCATION'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-09-15')
UNION ALL
SELECT l.loan_id, '2026-10-15', NULL, 6100.00, 0.00, 'DUE'
FROM loans l WHERE l.loan_type = 'EDUCATION'
  AND NOT EXISTS (SELECT 1 FROM loan_payments p WHERE p.loan_id = l.loan_id AND p.due_date = '2026-10-15');

INSERT INTO fraud_events (transaction_id, detected_at, fraud_type, risk_score, action_taken)
SELECT t.transaction_id, '2026-10-12 02:20:00', 'Unusual high-value online transaction', 88.00, 'REVIEW'
FROM transactions t WHERE t.reference_code = 'TX10011'
  AND NOT EXISTS (SELECT 1 FROM fraud_events f WHERE f.transaction_id = t.transaction_id AND f.fraud_type = 'Unusual high-value online transaction')
UNION ALL
SELECT t.transaction_id, '2026-10-14 01:50:00', 'Unusual transaction time', 64.00, 'REVIEW'
FROM transactions t WHERE t.reference_code = 'TX10015'
  AND NOT EXISTS (SELECT 1 FROM fraud_events f WHERE f.transaction_id = t.transaction_id AND f.fraud_type = 'Unusual transaction time')
UNION ALL
SELECT t.transaction_id, '2026-10-17 18:20:00', 'Merchant risk review', 73.00, 'BLOCK'
FROM transactions t WHERE t.reference_code = 'TX10021'
  AND NOT EXISTS (SELECT 1 FROM fraud_events f WHERE f.transaction_id = t.transaction_id AND f.fraud_type = 'Merchant risk review');

INSERT INTO disputes (transaction_id, opened_at, reason, disputed_amount, status)
SELECT t.transaction_id, '2026-10-18 10:00:00', 'Customer reported an unrecognized purchase', 98000.00, 'OPEN'
FROM transactions t WHERE t.reference_code = 'TX10011'
  AND NOT EXISTS (SELECT 1 FROM disputes d WHERE d.transaction_id = t.transaction_id AND d.reason = 'Customer reported an unrecognized purchase')
UNION ALL
SELECT t.transaction_id, '2026-10-18 14:30:00', 'Duplicate merchant charge investigation', 12500.00, 'WON'
FROM transactions t WHERE t.reference_code = 'TX10019'
  AND NOT EXISTS (SELECT 1 FROM disputes d WHERE d.transaction_id = t.transaction_id AND d.reason = 'Duplicate merchant charge investigation');

INSERT INTO settlements (transaction_id, settled_at, settlement_amount, status)
SELECT t.transaction_id, '2026-10-03 12:00:00', t.amount, 'SETTLED'
FROM transactions t WHERE t.reference_code = 'TX10001'
  AND NOT EXISTS (SELECT 1 FROM settlements s WHERE s.transaction_id = t.transaction_id)
UNION ALL
SELECT t.transaction_id, '2026-10-05 20:00:00', t.amount, 'SETTLED'
FROM transactions t WHERE t.reference_code = 'TX10002'
  AND NOT EXISTS (SELECT 1 FROM settlements s WHERE s.transaction_id = t.transaction_id)
UNION ALL
SELECT t.transaction_id, NULL, t.amount, 'PENDING'
FROM transactions t WHERE t.reference_code = 'TX10011'
  AND NOT EXISTS (SELECT 1 FROM settlements s WHERE s.transaction_id = t.transaction_id);
