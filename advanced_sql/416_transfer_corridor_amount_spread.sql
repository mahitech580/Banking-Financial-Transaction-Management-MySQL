-- Business question: What transfer amounts and volumes move between branch corridors?
SELECT source_branch.branch_name AS source_branch,
       destination_branch.branch_name AS destination_branch,
       tr.status, COUNT(*) AS transfer_count,
       SUM(tr.transfer_amount) AS total_transfer_amount,
       MIN(tr.transfer_amount) AS minimum_transfer,
       ROUND(AVG(tr.transfer_amount), 2) AS average_transfer,
       MAX(tr.transfer_amount) AS maximum_transfer
FROM transfers AS tr
JOIN accounts AS source_account ON source_account.account_id = tr.from_account_id
JOIN branches AS source_branch ON source_branch.branch_id = source_account.branch_id
JOIN accounts AS destination_account ON destination_account.account_id = tr.to_account_id
JOIN branches AS destination_branch ON destination_branch.branch_id = destination_account.branch_id
GROUP BY source_branch.branch_name, destination_branch.branch_name, tr.status
ORDER BY total_transfer_amount DESC;
