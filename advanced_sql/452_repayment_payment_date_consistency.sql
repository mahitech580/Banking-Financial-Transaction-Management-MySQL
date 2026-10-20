-- Business question: Find repayment rows whose status and paid-date fields appear inconsistent.
SELECT lp.payment_id, lp.loan_id, lp.due_date, lp.paid_date,
       lp.amount_due, lp.amount_paid, lp.status,
       CASE WHEN lp.status = 'PAID' AND (lp.paid_date IS NULL OR lp.amount_paid < lp.amount_due)
              THEN 'PAID_WITH_MISSING_DATE_OR_SHORT_PAYMENT'
            WHEN lp.status IN ('DUE','LATE','MISSED') AND lp.paid_date IS NOT NULL
              THEN 'UNPAID_STATUS_WITH_PAYMENT_DATE'
            WHEN lp.paid_date > CURRENT_DATE THEN 'FUTURE_PAYMENT_DATE'
            ELSE 'NO_BASIC_DATE_STATUS_CONFLICT' END AS review_reason
FROM loan_payments AS lp
WHERE (lp.status = 'PAID' AND (lp.paid_date IS NULL OR lp.amount_paid < lp.amount_due))
   OR (lp.status IN ('DUE','LATE','MISSED') AND lp.paid_date IS NOT NULL)
   OR lp.paid_date > CURRENT_DATE
ORDER BY lp.due_date, lp.payment_id;
