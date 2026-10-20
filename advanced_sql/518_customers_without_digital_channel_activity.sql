-- Business question: Identify customers with ledger history but no online or mobile channel attempts.
WITH customer_channel AS (
  SELECT a.customer_id,
         COUNT(*) AS all_attempts,
         SUM(t.channel IN ('ONLINE','MOBILE')) AS digital_attempts,
         SUM(CASE WHEN t.status = 'SUCCESS' AND t.channel IN ('ONLINE','MOBILE')
                  THEN t.amount ELSE 0 END) AS digital_successful_value
  FROM accounts AS a
  JOIN transactions AS t ON t.account_id = a.account_id
  GROUP BY a.customer_id
)
SELECT c.customer_number, c.risk_level,
       cc.all_attempts, cc.digital_attempts, cc.digital_successful_value
FROM customers AS c
JOIN customer_channel AS cc ON cc.customer_id = c.customer_id
WHERE cc.digital_attempts = 0
ORDER BY cc.all_attempts DESC, c.customer_number;
