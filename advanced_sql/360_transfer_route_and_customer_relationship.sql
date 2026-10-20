-- Business question: Which branch-to-branch transfer routes are most active, and how often do they cross customer ownership?
-- Grain: one source/destination branch pair. A cross-customer transfer is common and is not inherently suspicious.
SELECT source_branch.branch_id AS source_branch_id, source_branch.branch_name AS source_branch,
  destination_branch.branch_id AS destination_branch_id, destination_branch.branch_name AS destination_branch,
  CASE WHEN source_account.customer_id = destination_account.customer_id
    THEN 'SAME_CUSTOMER' ELSE 'DIFFERENT_CUSTOMERS' END AS ownership_relationship,
  COUNT(*) AS transfer_count,
  SUM(tr.status = 'COMPLETED') AS completed_count,
  SUM(tr.status = 'FAILED') AS failed_count,
  SUM(tr.status = 'PENDING') AS pending_count,
  COALESCE(SUM(CASE WHEN tr.status = 'COMPLETED' THEN tr.transfer_amount ELSE 0 END), 0.00)
    AS completed_gross_transfer_value,
  ROUND(AVG(tr.transfer_amount), 2) AS average_transfer_amount
FROM transfers tr
JOIN accounts source_account ON source_account.account_id = tr.from_account_id
JOIN accounts destination_account ON destination_account.account_id = tr.to_account_id
JOIN branches source_branch ON source_branch.branch_id = source_account.branch_id
JOIN branches destination_branch ON destination_branch.branch_id = destination_account.branch_id
GROUP BY source_branch.branch_id, source_branch.branch_name,
  destination_branch.branch_id, destination_branch.branch_name, ownership_relationship
ORDER BY transfer_count DESC, completed_gross_transfer_value DESC;
