-- Business question: Which source-to-destination branch routes handle the most transfer volume?
SELECT source_branch.branch_id source_branch_id,source_branch.branch_name source_branch,
       destination_branch.branch_id destination_branch_id,destination_branch.branch_name destination_branch,
       tr.status,COUNT(*) transfer_count,COUNT(DISTINCT tr.from_account_id) source_accounts,
       COUNT(DISTINCT tr.to_account_id) destination_accounts,
       ROUND(SUM(tr.transfer_amount),2) gross_transfer_value,
       ROUND(AVG(tr.transfer_amount),2) average_transfer_amount
FROM transfers tr
JOIN accounts source_account ON source_account.account_id=tr.from_account_id
JOIN branches source_branch ON source_branch.branch_id=source_account.branch_id
JOIN accounts destination_account ON destination_account.account_id=tr.to_account_id
JOIN branches destination_branch ON destination_branch.branch_id=destination_account.branch_id
GROUP BY source_branch.branch_id,source_branch.branch_name,
         destination_branch.branch_id,destination_branch.branch_name,tr.status
ORDER BY transfer_count DESC,gross_transfer_value DESC;