-- Business question: Compare scheduled, paid, and unpaid instalment value by stored customer risk label.
SELECT c.risk_level, l.loan_type,
       COUNT(DISTINCT l.loan_id) AS loan_count,
       COUNT(lp.payment_id) AS installment_count,
       COALESCE(SUM(lp.amount_due), 0) AS amount_due,
       COALESCE(SUM(lp.amount_paid), 0) AS amount_paid,
       COALESCE(SUM(lp.amount_due - lp.amount_paid), 0) AS unpaid_amount,
       ROUND(100 * SUM(lp.amount_paid) / NULLIF(SUM(lp.amount_due), 0), 2) AS collection_pct
FROM customers AS c
JOIN loans AS l ON l.customer_id = c.customer_id
LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY c.risk_level, l.loan_type
ORDER BY unpaid_amount DESC;
