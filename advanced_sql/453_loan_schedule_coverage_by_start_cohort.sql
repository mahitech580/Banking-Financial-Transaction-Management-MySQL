-- Business question: Compare loan schedule rows and outstanding installment exposure across start cohorts.
WITH schedule AS (
  SELECT loan_id, COUNT(*) AS installment_rows,
         SUM(amount_due) AS scheduled_amount,
         SUM(amount_paid) AS paid_amount,
         SUM(amount_due - amount_paid) AS unpaid_amount
  FROM loan_payments GROUP BY loan_id
)
SELECT DATE_FORMAT(l.start_date, '%Y-%m') AS origination_cohort,
       l.loan_type, l.status AS loan_status,
       COUNT(*) AS loans,
       SUM(COALESCE(s.installment_rows, 0)) AS installment_rows,
       SUM(l.tenure_months) AS contracted_months,
       SUM(COALESCE(s.unpaid_amount, 0)) AS unpaid_schedule_amount
FROM loans AS l
LEFT JOIN schedule AS s ON s.loan_id = l.loan_id
GROUP BY DATE_FORMAT(l.start_date, '%Y-%m'), l.loan_type, l.status
ORDER BY origination_cohort DESC, unpaid_schedule_amount DESC;
