-- Business question: Which merchants have higher mean transaction amounts than their category peers?
WITH merchant_means AS (
  SELECT m.merchant_id,m.merchant_name,m.merchant_category,
         COUNT(t.transaction_id) transaction_count,AVG(t.amount) mean_amount
  FROM merchants m JOIN transactions t ON t.merchant_id=m.merchant_id AND t.status='SUCCESS'
  GROUP BY m.merchant_id,m.merchant_name,m.merchant_category
),
category_means AS (
  SELECT merchant_category,AVG(mean_amount) category_mean_of_merchant_means
  FROM merchant_means GROUP BY merchant_category
)
SELECT mm.merchant_id,mm.merchant_name,mm.merchant_category,mm.transaction_count,
       ROUND(mm.mean_amount,2) merchant_mean_amount,
       ROUND(cm.category_mean_of_merchant_means,2) category_peer_mean,
       ROUND(mm.mean_amount-cm.category_mean_of_merchant_means,2) difference
FROM merchant_means mm JOIN category_means cm USING(merchant_category)
ORDER BY difference DESC;