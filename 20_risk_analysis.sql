-- Transparent rule-based risk indicators assembled from existing relational data.
-- These are illustrative business rules, not a production credit/fraud scoring model.
USE banking_financial_management;

WITH transaction_metrics AS (
  SELECT a.customer_id,
         COUNT(t.transaction_id) AS transaction_count,
         SUM(t.status = 'FAILED') AS failed_count,
         SUM(t.status = 'REVERSED') AS reversed_count,
         SUM(CASE WHEN t.status = 'SUCCESS' THEN t.amount ELSE 0 END) AS successful_value,
         MAX(t.amount) AS maximum_attempt_amount
  FROM accounts AS a
  LEFT JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.customer_id
),
repayment_metrics AS (
  SELECT l.customer_id,
         SUM(lp.status = 'LATE') AS late_installments,
         SUM(lp.status = 'MISSED') AS missed_installments,
         SUM(lp.amount_due - lp.amount_paid) AS scheduled_outstanding
  FROM loans AS l
  LEFT JOIN loan_payments AS lp ON lp.loan_id = l.loan_id
  GROUP BY l.customer_id
),
fraud_metrics AS (
  SELECT a.customer_id, COUNT(f.fraud_event_id) AS flagged_events,
         MAX(f.risk_score) AS maximum_flag_score
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  JOIN fraud_events AS f ON f.transaction_id = t.transaction_id
  GROUP BY a.customer_id
)
SELECT c.customer_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.risk_level AS stored_customer_risk,
       COALESCE(tm.transaction_count, 0) AS transaction_count,
       COALESCE(tm.failed_count, 0) AS failed_count,
       COALESCE(tm.reversed_count, 0) AS reversed_count,
       COALESCE(rm.late_installments, 0) AS late_installments,
       COALESCE(rm.missed_installments, 0) AS missed_installments,
       COALESCE(fm.flagged_events, 0) AS flagged_events,
       COALESCE(fm.maximum_flag_score, 0) AS maximum_flag_score,
       CASE
         WHEN COALESCE(fm.maximum_flag_score, 0) >= 90
           OR COALESCE(rm.missed_installments, 0) >= 2 THEN 'HIGH REVIEW'
         WHEN COALESCE(fm.flagged_events, 0) > 0
           OR COALESCE(tm.failed_count, 0) >= 2
           OR COALESCE(rm.late_installments, 0) > 0 THEN 'REVIEW'
         ELSE 'STANDARD'
       END AS rule_based_review_band
FROM customers AS c
LEFT JOIN transaction_metrics AS tm ON tm.customer_id = c.customer_id
LEFT JOIN repayment_metrics AS rm ON rm.customer_id = c.customer_id
LEFT JOIN fraud_metrics AS fm ON fm.customer_id = c.customer_id
ORDER BY CASE rule_based_review_band
           WHEN 'HIGH REVIEW' THEN 1 WHEN 'REVIEW' THEN 2 ELSE 3 END,
         maximum_flag_score DESC, customer_name;
