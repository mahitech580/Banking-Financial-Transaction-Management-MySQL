-- Business question: Compare scheduled and collected values based on each installment's due month.
SELECT DATE_FORMAT(due_date, '%Y-%m') AS due_month, status,
       COUNT(*) AS installment_count,
       SUM(amount_due) AS scheduled_amount,
       SUM(amount_paid) AS collected_amount,
       SUM(amount_due - amount_paid) AS remaining_amount,
       ROUND(100.0 * SUM(amount_paid) / NULLIF(SUM(amount_due), 0), 2) AS collection_ratio_pct
FROM loan_payments
GROUP BY DATE_FORMAT(due_date, '%Y-%m'), status
ORDER BY due_month DESC, status;
