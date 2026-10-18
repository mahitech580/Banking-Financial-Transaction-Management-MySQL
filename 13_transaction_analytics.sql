-- Transaction KPIs, time trends, channel mix and outcome quality.
USE banking_financial_management;

-- 1. Daily transaction performance
SELECT DATE(transaction_time) AS transaction_day,
       COUNT(*) AS ledger_rows,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(status = 'FAILED') AS failed_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(CASE WHEN status = 'SUCCESS' THEN amount END), 2) AS average_successful_amount
FROM transactions
GROUP BY DATE(transaction_time)
ORDER BY transaction_day;

-- 2. Success rate by channel
SELECT channel, COUNT(*) AS attempts,
       SUM(status = 'SUCCESS') AS successful,
       ROUND(100.0 * SUM(status = 'SUCCESS') / NULLIF(COUNT(*), 0), 2) AS success_rate_pct,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY channel
ORDER BY successful_value DESC;

-- 3. Hour-of-day pattern; use as an investigation signal, not proof of fraud.
SELECT HOUR(transaction_time) AS hour_of_day,
       COUNT(*) AS attempts,
       SUM(status = 'SUCCESS') AS successful_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value
FROM transactions
GROUP BY HOUR(transaction_time)
ORDER BY hour_of_day;

-- 4. Transaction type mix
SELECT transaction_type, COUNT(*) AS transaction_count,
       SUM(CASE WHEN status = 'SUCCESS' THEN amount ELSE 0 END) AS successful_value,
       ROUND(AVG(CASE WHEN status = 'SUCCESS' THEN amount END), 2) AS average_successful_amount
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;

-- 5. Large successful transactions that merit review based on a simple rule.
SELECT reference_code, account_id, amount, transaction_time, channel
FROM transactions
WHERE status = 'SUCCESS' AND amount >= 50000
ORDER BY amount DESC, transaction_time DESC;


-- Daily success rate uses all ledger rows as the denominator
SELECT DATE(transaction_time) AS event_day,COUNT(*) AS attempts,SUM(status='SUCCESS') AS successes,ROUND(100.0*SUM(status='SUCCESS')/NULLIF(COUNT(*),0),2) AS success_rate_pct FROM transactions GROUP BY DATE(transaction_time) ORDER BY event_day;


-- ISO-week bucket for a compact reporting trend
SELECT YEARWEEK(transaction_time,3) AS iso_year_week,COUNT(*) AS attempts,SUM(CASE WHEN status='SUCCESS' THEN amount ELSE 0 END) AS successful_value FROM transactions GROUP BY YEARWEEK(transaction_time,3) ORDER BY iso_year_week;


-- Branch rollup joins transaction facts to the branch owning each account
SELECT b.branch_name,COUNT(t.transaction_id) AS attempts,SUM(t.status='SUCCESS') AS successes,SUM(t.status='FAILED') AS failures,SUM(CASE WHEN t.status='SUCCESS' THEN t.amount ELSE 0 END) AS successful_value FROM branches b LEFT JOIN accounts a ON a.branch_id=b.branch_id LEFT JOIN transactions t ON t.account_id=a.account_id GROUP BY b.branch_id,b.branch_name ORDER BY successful_value DESC;
