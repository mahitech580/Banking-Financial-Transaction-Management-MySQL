-- Business question: Which transaction statuses most often follow other statuses in each account's ledger?
WITH history AS (
  SELECT account_id,transaction_id,transaction_time,status,
         LAG(status) OVER(PARTITION BY account_id ORDER BY transaction_time,transaction_id) previous_status
  FROM transactions
)
SELECT previous_status,current_status,COUNT(*) transition_count,
       COUNT(DISTINCT account_id) accounts_with_transition,
       MIN(transaction_time) first_observed_at,MAX(transaction_time) last_observed_at
FROM (
  SELECT account_id,transaction_id,transaction_time,previous_status,status current_status
  FROM history WHERE previous_status IS NOT NULL
) transitions
GROUP BY previous_status,current_status
ORDER BY transition_count DESC,previous_status,current_status;