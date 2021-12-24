1. Which store of merchant 43 is having maximum sale? Write SQL query.
SELECT store_id, SUM(pay_amount) as total_sales
    FROM orders
WHERE merchant_id = 43
        GROUP BY store_id
    ORDER BY total_sales DESC
LIMIT 1;



2a. Provide payment methods and their count with having pay_amount Rs. 250.98 in orders table.
SELECT payment_method, COUNT(payment_method)
FROM orders
WHERE pay_amount = '250.98'
group by payment_method;

2b. Count of distinct payment method with pay_amount Rs. 250.98 in orders table.
SELECT  COUNT(DISTINCT payment_method)
FROM orders
WHERE pay_amount = '250.98';



3. For store 71, give a list of top paying customer.
SELECT user_phone, SUM(pay_amount) 
    FROM orders
        WHERE store_id = 71

    GROUP BY user_phone
    ORDER BY SUM(pay_amount) DESC
LIMIT 5;



4. We identify user by phone number. Write SQL query to find which user frequently eats Paan Kulfi (itemID-4774).[in last 50 days]
SELECT o.user_phone, COUNT(oi.item_id) as freq
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
WHERE
oi.item_id = 4774
AND 
oi.created_at::timestamp >= ((SELECT MAX(created_at) FROM order_items)::timestamp) - interval '50 days'
GROUP BY o.user_phone
ORDER BY freq DESC
LIMIT 1;



Payment Status info 
payment status 2,3,4 are initiated, successful and failed respectively.

5. Write a query to find 5th highest "PAID" order.
SELECT order_id, pay_amount
FROM orders
WHERE payment_status = 3
ORDER BY pay_amount DESC
LIMIT 1 OFFSET 4;



6. Which payment method is most successful (success rate i.e. success transactions / total transactions).
SELECT payment_method, COUNT(payment_status)
FROM orders
WHERE payment_status = 3
GROUP BY payment_method
ORDER BY COUNT(payment_status) DESC
LIMIT 1;

SELECT 
payment_method
,sum(case when payment_status = '2' THEN 1 ELSE 0 END) AS initiated
,sum(case when payment_status = '3' THEN 1 ELSE 0 END) AS success
,sum(case when payment_status = '4' THEN 1 ELSE 0 END) AS failed
--COUNT(payment_status)
FROM orders
--WHERE payment_status = 3
GROUP BY payment_method
--ORDER BY success_rate DESC
--LIMIT 1;

SELECT	
 payment_method
,sum(success)
,sum(initiated)
,sum(failed)
,sum(success) * 100.0 / (sum(success)+sum(initiated)+sum(failed)) as sr
from (
SELECT 
payment_method,
case when payment_status = '2' THEN 1 ELSE 0 END AS initiated,
case when payment_status = '3' THEN 1 ELSE 0 END AS success,
case when payment_status = '4' THEN 1 ELSE 0 END AS failed

--COUNT(payment_status)
FROM orders
--WHERE payment_status = 3
--GROUP BY payment_method
--ORDER BY success_rate DESC
--LIMIT 1;
) aa

group by payment_method



7. What are the top selling items for merchant ID 43 in last 7 days? Write the SQL query. [5 top selling items (item_id,name,count) of last 7 days.]
SELECT oi.item_id, oi.name, COUNT(oi.item_id)
FROM order_items oi
INNER JOIN orders o
ON 
oi.order_id = o.order_id
WHERE 
o.merchant_id = 43
AND 
oi.created_at::timestamp >= ((SELECT MAX(created_at) FROM order_items)::timestamp) - interval '7 days'
GROUP BY oi.name, oi.item_id
ORDER BY COUNT(oi.item_id) DESC
LIMIT 5;



8. For store 74, give a list of top 2 paying customer for each day for last 3 days.

select date_num, user_phone, total
from 
(
select date_num, user_phone, total
,DENSE_RANK() over (partition by aa.date_num order by total desc ) as rnk
from (
SELECT EXTRACT('day' FROM created_at::date) AS date_num, user_phone
  , SUM(pay_amount) as total
FROM orders
WHERE
store_id = 74
AND
created_at::timestamp > (((SELECT MAX(created_at::timestamp) FROM orders)::timestamp) - interval '3 days')

GROUP BY date_num ,user_phone
ORDER BY SUM(pay_amount) DESC
--limit 1;
) aa
)bb
where rnk <3





