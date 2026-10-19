-- Business question: Which cards repeat the same merchant, amount, and purchase channel within five minutes?
-- Repeated purchases can be legitimate; use this as an investigation shortlist, not an automatic decline rule.
SELECT x.card_id,x.merchant_id,x.channel,x.amount,
       x.card_transaction_id first_card_transaction_id,
       y.card_transaction_id second_card_transaction_id,
       x.transaction_time first_time,y.transaction_time second_time,
       TIMESTAMPDIFF(SECOND,x.transaction_time,y.transaction_time) seconds_apart,
       x.status first_status,y.status second_status
FROM card_transactions x JOIN card_transactions y
  ON y.card_id=x.card_id AND y.merchant_id=x.merchant_id
 AND y.channel=x.channel AND y.amount=x.amount
 AND y.transaction_time>=x.transaction_time
 AND y.transaction_time<=x.transaction_time+INTERVAL 5 MINUTE
 AND y.card_transaction_id>x.card_transaction_id
ORDER BY seconds_apart,x.card_id LIMIT 200;