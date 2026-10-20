-- Business question: Which fraud decisions appear inconsistent with configurable example score bands?
-- These illustrative bands are review prompts only, not a validated fraud policy.
SELECT fraud_event_id,transaction_id,fraud_type,risk_score,action_taken,detected_at,
       CASE WHEN risk_score>=80 AND action_taken='ALLOW' THEN 'HIGH_SCORE_ALLOWED'
            WHEN risk_score<=20 AND action_taken='BLOCK' THEN 'LOW_SCORE_BLOCKED'
            ELSE 'REVIEW' END AS policy_review_candidate
FROM fraud_events
WHERE (risk_score>=80 AND action_taken='ALLOW')
   OR (risk_score<=20 AND action_taken='BLOCK')
ORDER BY risk_score DESC,detected_at DESC;