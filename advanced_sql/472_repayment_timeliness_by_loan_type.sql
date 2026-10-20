-- Business question: Measure recorded payment punctuality after the installment due date.
SELECT l.loan_type,
       CASE WHEN lp.paid_date IS NULL THEN 'NOT_RECORDED_PAID'
            WHEN lp.paid_date <= lp.due_date THEN 'ON_OR_BEFORE_DUE'
            ELSE 'PAID_AFTER_DUE' END AS payment_timing,
       COUNT(*) AS installment_count,
       SUM(lp.amount_due) AS scheduled_amount,
       SUM(lp.amount_paid) AS paid_amount,
       ROUND(AVG(CASE WHEN lp.paid_date IS NOT NULL
                      THEN DATEDIFF(lp.paid_date, lp.due_date) END), 1) AS average_days_from_due
FROM loans AS l
JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_type, payment_timing
ORDER BY l.loan_type, payment_timing;
