-- Business question: Quantify unpaid scheduled installment balances by days past due.
SELECT CASE WHEN DATEDIFF(CURRENT_DATE, due_date) BETWEEN 1 AND 7 THEN '1_TO_7_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, due_date) BETWEEN 8 AND 30 THEN '8_TO_30_DAYS'
            WHEN DATEDIFF(CURRENT_DATE, due_date) BETWEEN 31 AND 90 THEN '31_TO_90_DAYS'
            ELSE 'OVER_90_DAYS' END AS overdue_age_band,
       status, COUNT(*) AS installment_count,
       SUM(amount_due - amount_paid) AS unpaid_amount,
       MIN(due_date) AS oldest_due_date,
       MAX(DATEDIFF(CURRENT_DATE, due_date)) AS maximum_days_past_due
FROM loan_payments
WHERE due_date < CURRENT_DATE AND amount_paid < amount_due
GROUP BY overdue_age_band, status
ORDER BY unpaid_amount DESC;
