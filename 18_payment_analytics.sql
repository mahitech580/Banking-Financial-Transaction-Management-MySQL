-- Analyze loan repayments, settlement processing and customer disputes.
USE banking_financial_management;

-- 1. Installment collection performance
SELECT status, COUNT(*) AS installment_count,
       SUM(amount_due) AS scheduled_amount,
       SUM(amount_paid) AS collected_amount,
       SUM(amount_due - amount_paid) AS remaining_amount
FROM loan_payments
GROUP BY status
ORDER BY installment_count DESC;

-- 2. Settlement pipeline
SELECT status, COUNT(*) AS settlement_count,
       SUM(settlement_amount) AS settlement_value,
       MIN(settled_at) AS first_settlement_at,
       MAX(settled_at) AS latest_settlement_at
FROM settlements
GROUP BY status
ORDER BY settlement_value DESC;

-- 3. Transactions still awaiting settlement
SELECT s.settlement_id, t.reference_code, t.transaction_type, t.amount,
       s.settlement_amount, s.status, s.settled_at
FROM settlements AS s
JOIN transactions AS t ON t.transaction_id = s.transaction_id
WHERE s.status = 'PENDING'
ORDER BY t.transaction_time;

-- 4. Disputes by outcome
SELECT status, COUNT(*) AS dispute_count,
       SUM(disputed_amount) AS disputed_value
FROM disputes
GROUP BY status
ORDER BY disputed_value DESC;

-- 5. Repayment completion rate
SELECT l.loan_id, l.loan_type,
       COUNT(lp.payment_id) AS scheduled_installments,
       SUM(lp.amount_paid >= lp.amount_due) AS fully_paid_installments,
       ROUND(100.0 * SUM(lp.amount_paid >= lp.amount_due) /
             NULLIF(COUNT(lp.payment_id), 0), 2) AS completion_rate_pct
FROM loans AS l
LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_id, l.loan_type
ORDER BY completion_rate_pct, l.loan_id;


SELECT s.settlement_id,t.reference_code,s.status,s.settlement_amount,s.settled_at,DATEDIFF(CURRENT_DATE,DATE(COALESCE(s.settled_at,t.transaction_time))) AS age_days FROM settlements s JOIN transactions t ON t.transaction_id=s.transaction_id WHERE s.status IN ('PENDING','FAILED') ORDER BY age_days DESC,s.settlement_amount DESC;


SELECT status,COUNT(*) AS dispute_count,SUM(disputed_amount) AS disputed_amount,ROUND(AVG(disputed_amount),2) AS average_dispute_amount FROM disputes GROUP BY status ORDER BY disputed_amount DESC;


SELECT loan_id,COUNT(*) AS schedule_rows,SUM(amount_due) AS scheduled_amount,SUM(amount_paid) AS collected_amount,ROUND(100.0*SUM(amount_paid)/NULLIF(SUM(amount_due),0),2) AS collection_pct FROM loan_payments GROUP BY loan_id ORDER BY collection_pct,loan_id;
