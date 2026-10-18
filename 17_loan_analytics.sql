-- Loan portfolio, repayments, overdue installments and exposure.
USE banking_financial_management;

-- 1. Portfolio totals by product
SELECT loan_type, status, COUNT(*) AS loan_count,
       SUM(principal) AS principal_exposure,
       ROUND(AVG(interest_rate), 3) AS average_annual_rate_pct,
       ROUND(AVG(tenure_months), 1) AS average_tenure_months
FROM loans
GROUP BY loan_type, status
ORDER BY principal_exposure DESC;

-- 2. Repayment performance by loan. Join pre-aggregated payments to avoid double counting.
WITH repayment_metrics AS (
  SELECT loan_id, COUNT(*) AS installment_count,
         SUM(amount_due) AS total_due,
         SUM(amount_paid) AS total_paid,
         SUM(status IN ('LATE','MISSED')) AS late_or_missed_count,
         SUM(status = 'MISSED') AS missed_count
  FROM loan_payments
  GROUP BY loan_id
)
SELECT l.loan_id, l.loan_type, l.principal, l.status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COALESCE(r.installment_count, 0) AS installment_count,
       COALESCE(r.total_due, 0) AS total_due,
       COALESCE(r.total_paid, 0) AS total_paid,
       COALESCE(r.total_due, 0) - COALESCE(r.total_paid, 0) AS remaining_scheduled_amount,
       COALESCE(r.late_or_missed_count, 0) AS late_or_missed_count,
       COALESCE(r.missed_count, 0) AS missed_count
FROM loans AS l
JOIN customers AS c ON c.customer_id = l.customer_id
LEFT JOIN repayment_metrics AS r ON r.loan_id = l.loan_id
ORDER BY late_or_missed_count DESC, l.principal DESC;

-- 3. Overdue installments by days past due
SELECT lp.payment_id, lp.loan_id, lp.due_date,
       DATEDIFF(CURRENT_DATE, lp.due_date) AS days_past_due,
       lp.amount_due, lp.amount_paid, lp.status
FROM loan_payments AS lp
WHERE lp.due_date < CURRENT_DATE
  AND lp.amount_paid < lp.amount_due
ORDER BY days_past_due DESC, lp.amount_due DESC;


SELECT l.loan_type,COUNT(DISTINCT l.loan_id) AS loan_count,COUNT(lp.payment_id) AS installment_count,SUM(lp.status='LATE') AS late_installments,SUM(lp.status='MISSED') AS missed_installments,SUM(lp.amount_due-lp.amount_paid) AS scheduled_outstanding FROM loans l LEFT JOIN loan_payments lp ON lp.loan_id=l.loan_id GROUP BY l.loan_type ORDER BY missed_installments DESC,scheduled_outstanding DESC;


SELECT c.customer_number,CONCAT(c.first_name,' ',c.last_name) AS customer_name,COUNT(l.loan_id) AS loan_count,SUM(l.principal) AS principal_exposure,ROUND(AVG(l.interest_rate),2) AS average_annual_rate_pct FROM customers c JOIN loans l ON l.customer_id=c.customer_id WHERE l.status='ACTIVE' GROUP BY c.customer_id,c.customer_number,c.first_name,c.last_name ORDER BY principal_exposure DESC;
