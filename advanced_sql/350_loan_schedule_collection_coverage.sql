-- Business question: How much of each loan's scheduled due amount has been collected, and what remains overdue?
-- Grain: one row per loan. Status and paid amounts are both shown because operational labels can lag the numeric amounts.
SELECT l.loan_id, l.customer_id, l.loan_type, l.status AS loan_status, l.principal,
  COUNT(lp.payment_id) AS scheduled_installments,
  SUM(lp.status = 'PAID') AS installments_labeled_paid,
  SUM(lp.status = 'LATE') AS installments_labeled_late,
  SUM(lp.status = 'MISSED') AS installments_labeled_missed,
  COALESCE(SUM(lp.amount_due), 0.00) AS scheduled_amount_due,
  COALESCE(SUM(lp.amount_paid), 0.00) AS recorded_amount_paid,
  COALESCE(SUM(lp.amount_due - lp.amount_paid), 0.00) AS outstanding_scheduled_amount,
  COALESCE(SUM(CASE WHEN lp.due_date < CURRENT_DATE AND lp.amount_paid < lp.amount_due
    THEN lp.amount_due - lp.amount_paid ELSE 0 END), 0.00) AS overdue_unpaid_amount,
  ROUND(100.0 * SUM(lp.amount_paid) / NULLIF(SUM(lp.amount_due), 0), 2) AS collection_coverage_pct
FROM loans l
LEFT JOIN loan_payments lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_id, l.customer_id, l.loan_type, l.status, l.principal
ORDER BY overdue_unpaid_amount DESC, outstanding_scheduled_amount DESC, l.loan_id;
