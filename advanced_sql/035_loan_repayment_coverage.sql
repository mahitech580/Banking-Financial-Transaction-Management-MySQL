-- Business question: What proportion of scheduled amounts has been paid per loan?
SELECT l.loan_id, l.loan_type, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COALESCE(SUM(lp.amount_due), 0) AS total_due,
       COALESCE(SUM(lp.amount_paid), 0) AS total_paid,
       ROUND(100 * COALESCE(SUM(lp.amount_paid), 0) / NULLIF(SUM(lp.amount_due), 0), 2) AS repayment_coverage_pct
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
LEFT JOIN loan_payments lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_id, l.loan_type, c.first_name, c.last_name
ORDER BY repayment_coverage_pct, l.loan_id;