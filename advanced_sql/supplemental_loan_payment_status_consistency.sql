-- Business question: Do loan-payment status, paid amount, and paid date tell a consistent story?
SELECT payment_id,loan_id,due_date,paid_date,amount_due,amount_paid,status,
       CASE WHEN status='PAID' AND amount_paid<amount_due THEN 'PAID_BUT_SHORT'
            WHEN status<>'PAID' AND amount_paid=amount_due THEN 'FULLY_PAID_STATUS_NOT_PAID'
            WHEN amount_paid>0 AND paid_date IS NULL THEN 'PAYMENT_AMOUNT_WITHOUT_PAID_DATE'
            WHEN status='PAID' AND paid_date IS NULL THEN 'PAID_STATUS_WITHOUT_DATE'
            ELSE 'REVIEW' END AS consistency_candidate
FROM loan_payments
WHERE (status='PAID' AND amount_paid<amount_due)
   OR (status<>'PAID' AND amount_paid=amount_due)
   OR (amount_paid>0 AND paid_date IS NULL)
   OR (status='PAID' AND paid_date IS NULL)
ORDER BY due_date,payment_id;