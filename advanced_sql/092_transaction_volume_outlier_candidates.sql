-- Flag unusually high account-day attempt counts using each account's observed distribution.
-- Minimum five observed days is a guard against very small samples; investigate before acting.
WITH daily AS (SELECT account_id,DATE(transaction_time) activity_date,COUNT(*) daily_count FROM transactions GROUP BY account_id,DATE(transaction_time)),
stats AS (SELECT account_id,AVG(daily_count) mean_count,STDDEV_POP(daily_count) sd_count,COUNT(*) observed_days FROM daily GROUP BY account_id)
SELECT d.account_id,d.activity_date,d.daily_count,ROUND(s.mean_count,2) mean_count,ROUND(s.sd_count,2) sd_count,s.observed_days
FROM daily d JOIN stats s ON s.account_id=d.account_id
WHERE s.observed_days>=5 AND s.sd_count>0 AND d.daily_count>s.mean_count+3*s.sd_count ORDER BY d.daily_count DESC;