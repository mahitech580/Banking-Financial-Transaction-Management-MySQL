-- Business question: Review transfer records whose source or destination account is now frozen or closed.
SELECT tr.transfer_id, tr.initiated_at, tr.status AS transfer_status,
       tr.transfer_amount, source.account_number AS source_account,
       source.status AS source_current_status, destination.account_number AS destination_account,
       destination.status AS destination_current_status
FROM transfers AS tr
JOIN accounts AS source ON source.account_id = tr.from_account_id
JOIN accounts AS destination ON destination.account_id = tr.to_account_id
WHERE source.status <> 'ACTIVE' OR destination.status <> 'ACTIVE'
ORDER BY tr.initiated_at DESC, tr.transfer_id DESC;
