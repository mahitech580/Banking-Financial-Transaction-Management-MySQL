-- Business question: Summarize loan principal and repayment collection by branch without join fan-out.
WITH loan_totals AS (
  SELECT c.branch_id, COUNT(l.loan_id) AS loan_count,
         SUM(CASE WHEN l.status = 'ACTIVE' THEN l.principal ELSE 0 END) AS active_principal
  FROM customers AS c
  JOIN loans AS l ON l.customer_id = c.customer_id
  GROUP BY c.branch_id
), repayment_totals AS (
  SELECT c.branch_id, SUM(lp.amount_due) AS scheduled_amount,
         SUM(lp.amount_paid) AS paid_amount
  FROM customers AS c
  JOIN loans AS l ON l.customer_id = c.customer_id
  JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
  GROUP BY c.branch_id
)
SELECT b.branch_id, b.branch_name,
       COALESCE(lt.loan_count, 0) AS loan_count,
       COALESCE(lt.active_principal, 0) AS active_principal,
       COALESCE(rt.scheduled_amount, 0) AS scheduled_amount,
       COALESCE(rt.paid_amount, 0) AS paid_amount,
       COALESCE(rt.scheduled_amount, 0) - COALESCE(rt.paid_amount, 0) AS unpaid_scheduled_amount
FROM branches AS b
LEFT JOIN loan_totals AS lt ON lt.branch_id = b.branch_id
LEFT JOIN repayment_totals AS rt ON rt.branch_id = b.branch_id
ORDER BY active_principal DESC;
