-- Business question: Which account states have a non-zero or negative stored balance worth reviewing?
-- Policy differs by product; this report surfaces candidates and does not label them invalid automatically.
SELECT account_id,account_number,account_type,status,current_balance,opened_at,
       CASE WHEN status='CLOSED' AND current_balance<>0 THEN 'CLOSED_WITH_NONZERO_BALANCE'
            WHEN status='FROZEN' AND current_balance<0 THEN 'FROZEN_WITH_NEGATIVE_BALANCE'
            WHEN status='ACTIVE' AND current_balance<0 THEN 'ACTIVE_NEGATIVE_BALANCE'
            ELSE 'REVIEW' END review_candidate
FROM accounts
WHERE (status='CLOSED' AND current_balance<>0)
   OR (status='FROZEN' AND current_balance<0)
   OR (status='ACTIVE' AND current_balance<0)
ORDER BY ABS(current_balance) DESC,account_id;