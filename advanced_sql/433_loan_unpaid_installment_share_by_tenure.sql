-- Business question: Compare outstanding scheduled installment amounts by loan tenure band.
SELECT l.loan_type,
       CASE WHEN l.tenure_months < 12 THEN 'UNDER_12_MONTHS'
            WHEN l.tenure_months < 36 THEN '12_TO_35_MONTHS'
            WHEN l.tenure_months < 60 THEN '36_TO_59_MONTHS'
            ELSE '60_MONTHS_PLUS' END AS tenure_band,
       COUNT(DISTINCT l.loan_id) AS loans,
       COUNT(lp.payment_id) AS installments,
       SUM(lp.amount_due) AS scheduled_amount,
       SUM(lp.amount_paid) AS paid_amount,
       SUM(lp.amount_due - lp.amount_paid) AS unpaid_amount,
       ROUND(100.0 * SUM(lp.amount_due - lp.amount_paid) / NULLIF(SUM(lp.amount_due), 0), 2) AS unpaid_share_pct
FROM loans AS l
LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
GROUP BY l.loan_type, tenure_band
ORDER BY unpaid_amount DESC;
