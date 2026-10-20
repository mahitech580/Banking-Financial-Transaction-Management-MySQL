-- Business question: Compare unpaid late or missed installments across loan products.
SELECT l.loan_type,
       COUNT(lp.payment_id) AS total_installments,
       SUM(lp.status = 'MISSED') AS missed_installments,
       SUM(lp.status = 'LATE') AS late_installments,
       SUM(lp.amount_due - lp.amount_paid) AS outstanding_scheduled_amount,
       ROUND(100.0 * SUM(lp.status IN ('MISSED','LATE')) / NULLIF(COUNT(lp.payment_id), 0), 2) AS late_or_missed_share_pct
FROM loans AS l
JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_type
ORDER BY outstanding_scheduled_amount DESC;
