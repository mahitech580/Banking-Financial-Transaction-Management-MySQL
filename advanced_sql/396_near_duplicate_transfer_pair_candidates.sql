-- Business question: Are there transfers with the same source, destination, and amount initiated within 60 seconds?
-- Grain: one transfer pair. Repeated transfers can be valid; compare references, user intent, and lifecycle details before escalation.
SELECT first_tr.from_account_id, first_tr.to_account_id,
  first_tr.transfer_id AS first_transfer_id, first_tr.initiated_at AS first_initiated_at,
  second_tr.transfer_id AS second_transfer_id, second_tr.initiated_at AS second_initiated_at,
  first_tr.transfer_amount, first_tr.status AS first_status, second_tr.status AS second_status,
  ABS(TIMESTAMPDIFF(SECOND, first_tr.initiated_at, second_tr.initiated_at)) AS seconds_apart
FROM transfers first_tr
JOIN transfers second_tr
  ON second_tr.transfer_id > first_tr.transfer_id
  AND second_tr.from_account_id = first_tr.from_account_id
  AND second_tr.to_account_id = first_tr.to_account_id
  AND second_tr.transfer_amount = first_tr.transfer_amount
  AND ABS(TIMESTAMPDIFF(SECOND, first_tr.initiated_at, second_tr.initiated_at)) <= 60
ORDER BY seconds_apart, first_tr.from_account_id, first_tr.initiated_at;
