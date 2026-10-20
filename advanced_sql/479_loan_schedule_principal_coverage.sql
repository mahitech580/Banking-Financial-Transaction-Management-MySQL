-- Business question: Compare each loan's principal with the sum of its recorded repayment schedule.
WITH payment_summary AS (
  SELECT loan_id, COUNT(*) AS installment_count,
         SUM(amount_due) AS scheduled_total,
         SUM(amount_paid) AS paid_total,
         SUM(amount_due - amount_paid) AS unpaid_schedule_total
  FROM loan_payments
  GROUP BY loan_id
)
SELECT l.loan_id, l.loan_type, l.principal, l.interest_rate, l.tenure_months, l.status,
       COALESCE(p.installment_count, 0) AS installment_count,
       COALESCE(p.scheduled_total, 0) AS scheduled_total,
       COALESCE(p.paid_total, 0) AS paid_total,
       COALESCE(p.unpaid_schedule_total, 0) AS unpaid_schedule_total,
       COALESCE(p.scheduled_total, 0) - l.principal AS schedule_minus_principal
FROM loans AS l
LEFT JOIN payment_summary AS p ON p.loan_id = l.loan_id
ORDER BY ABS(COALESCE(p.scheduled_total, 0) - l.principal) DESC, l.loan_id;
