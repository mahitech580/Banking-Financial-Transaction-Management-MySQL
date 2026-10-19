-- inter-account transfer flow grouped by branch route type; read-only analysis over the banking demo schema.
SELECT CASE WHEN fa.branch_id=ta.branch_id THEN 'Same branch' ELSE 'Cross branch' END AS grouping_value,
  COUNT(*) AS transfer_count,
  SUM(tr.status='COMPLETED') AS completed_count,
  SUM(tr.status='FAILED') AS failed_count,
  SUM(tr.status='REVERSED') AS reversed_count,
  ROUND(SUM(tr.transfer_amount),2) AS transfer_value,
  ROUND(AVG(tr.transfer_amount),2) AS average_transfer,
  COUNT(DISTINCT fc.customer_id) AS distinct_senders,
  COUNT(DISTINCT tc.customer_id) AS distinct_recipients
FROM transfers tr JOIN accounts fa ON fa.account_id=tr.from_account_id JOIN accounts ta ON ta.account_id=tr.to_account_id JOIN customers fc ON fc.customer_id=fa.customer_id JOIN customers tc ON tc.customer_id=ta.customer_id LEFT JOIN branches fb ON fb.branch_id=fa.branch_id LEFT JOIN branches tb ON tb.branch_id=ta.branch_id
GROUP BY 1
ORDER BY 2 DESC;
