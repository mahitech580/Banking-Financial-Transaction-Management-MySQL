-- Business question: Are settlement statuses aligned with the presence of a settlement timestamp?
SELECT settlement_id,transaction_id,status,settled_at,settlement_amount,
       CASE WHEN status='SETTLED' AND settled_at IS NULL THEN 'SETTLED_WITHOUT_TIMESTAMP'
            WHEN status<>'SETTLED' AND settled_at IS NOT NULL THEN 'TIMESTAMP_WITH_NONSETTLED_STATUS'
            ELSE 'REVIEW' END AS integrity_candidate
FROM settlements
WHERE (status='SETTLED' AND settled_at IS NULL)
   OR (status<>'SETTLED' AND settled_at IS NOT NULL)
ORDER BY settlement_id;