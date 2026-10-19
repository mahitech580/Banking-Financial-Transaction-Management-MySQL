-- Business question: Which merchants have the most variable monthly successful ledger value?
WITH monthly AS (
  SELECT m.merchant_id,m.merchant_name,m.merchant_category,
         DATE_FORMAT(t.transaction_time,'%Y-%m-01') month_start,
         SUM(t.status='SUCCESS') successful_transactions,
         SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) successful_value
  FROM merchants m JOIN transactions t ON t.merchant_id=m.merchant_id
  GROUP BY m.merchant_id,m.merchant_name,m.merchant_category,DATE_FORMAT(t.transaction_time,'%Y-%m-01')
)
SELECT merchant_id,merchant_name,merchant_category,COUNT(*) observed_months,
       ROUND(AVG(successful_value),2) average_monthly_successful_value,
       ROUND(STDDEV_POP(successful_value),2) monthly_value_stddev,
       ROUND(MAX(successful_value)-MIN(successful_value),2) monthly_value_range,
       SUM(successful_transactions) total_successful_transactions
FROM monthly GROUP BY merchant_id,merchant_name,merchant_category
HAVING COUNT(*)>=2
ORDER BY monthly_value_stddev DESC,merchant_id;