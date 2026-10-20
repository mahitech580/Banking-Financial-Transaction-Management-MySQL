-- Business question: Compare completed transfer activity within and across branches.
SELECT source_branch.branch_name AS source_branch,
       destination_branch.branch_name AS destination_branch,
       CASE WHEN source_branch.branch_id = destination_branch.branch_id
            THEN 'SAME_BRANCH' ELSE 'CROSS_BRANCH' END AS route_type,
       COUNT(*) AS transfer_count,
       SUM(tr.transfer_amount) AS completed_value,
       ROUND(AVG(tr.transfer_amount), 2) AS average_transfer_amount
FROM transfers AS tr
JOIN accounts AS source_account ON source_account.account_id = tr.from_account_id
JOIN branches AS source_branch ON source_branch.branch_id = source_account.branch_id
JOIN accounts AS destination_account ON destination_account.account_id = tr.to_account_id
JOIN branches AS destination_branch ON destination_branch.branch_id = destination_account.branch_id
WHERE tr.status = 'COMPLETED'
GROUP BY source_branch.branch_id, source_branch.branch_name,
         destination_branch.branch_id, destination_branch.branch_name, route_type
ORDER BY completed_value DESC;
