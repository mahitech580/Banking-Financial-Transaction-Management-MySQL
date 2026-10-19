-- Business question: Compare card-purchase stream and ledger stream by merchant category and calendar month.
-- These sources may overlap; compare them side by side rather than summing their financial values together.
WITH ledger_monthly AS (
  SELECT m.merchant_category,DATE_FORMAT(t.transaction_time,'%Y-%m') activity_month,
         COUNT(*) ledger_attempts,SUM(t.status='SUCCESS') ledger_successes,
         SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) ledger_success_value
  FROM transactions t JOIN merchants m ON m.merchant_id=t.merchant_id
  GROUP BY m.merchant_category,DATE_FORMAT(t.transaction_time,'%Y-%m')
),
card_monthly AS (
  SELECT m.merchant_category,DATE_FORMAT(ct.transaction_time,'%Y-%m') activity_month,
         COUNT(*) card_attempts,SUM(ct.status='SUCCESS') card_successes,
         SUM(CASE WHEN ct.status='SUCCESS' THEN ct.amount ELSE 0 END) card_success_value
  FROM card_transactions ct JOIN merchants m ON m.merchant_id=ct.merchant_id
  GROUP BY m.merchant_category,DATE_FORMAT(ct.transaction_time,'%Y-%m')
)
SELECT COALESCE(l.merchant_category,c.merchant_category) merchant_category,
       COALESCE(l.activity_month,c.activity_month) activity_month,
       COALESCE(l.ledger_attempts,0) ledger_attempts,COALESCE(l.ledger_successes,0) ledger_successes,
       ROUND(COALESCE(l.ledger_success_value,0),2) ledger_success_value,
       COALESCE(c.card_attempts,0) card_attempts,COALESCE(c.card_successes,0) card_successes,
       ROUND(COALESCE(c.card_success_value,0),2) card_success_value
FROM ledger_monthly l LEFT JOIN card_monthly c
  ON c.merchant_category=l.merchant_category AND c.activity_month=l.activity_month
UNION ALL
SELECT c.merchant_category,c.activity_month,0,0,0,c.card_attempts,c.card_successes,ROUND(c.card_success_value,2)
FROM card_monthly c LEFT JOIN ledger_monthly l
  ON l.merchant_category=c.merchant_category AND l.activity_month=c.activity_month
WHERE l.merchant_category IS NULL
ORDER BY activity_month,merchant_category;