1. Which store of merchant 43 is having maximum sale? Write SQL query.
SELECT store_id,
       SUM(pay_amount) AS total_sales
FROM orders
WHERE merchant_id = 43
GROUP BY store_id
ORDER BY total_sales DESC LIMIT 1;



2a. Provide payment methods and their count with having pay_amount Rs. 250.98 in orders table.
SELECT payment_method,
       COUNT(payment_method)
FROM orders
WHERE pay_amount = '250.98'
GROUP BY payment_method;

2b. Count of distinct payment method with pay_amount Rs. 250.98 in orders table.
SELECT COUNT(DISTINCT payment_method)
FROM orders
WHERE pay_amount = '250.98';



3. For store 71, give a list of top paying customer.
SELECT user_phone,
       SUM(pay_amount)
FROM orders
WHERE store_id = 71
GROUP BY user_phone
ORDER BY SUM(pay_amount) DESC LIMIT 5;



4. We identify user by phone number. Write SQL query to find which user frequently eats Paan Kulfi (itemID-4774).[in last 50 days]
SELECT o.user_phone,
       COUNT(oi.item_id) AS freq
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.item_id = 4774
    AND oi.created_at::TIMESTAMP >= (
                                         (SELECT MAX(created_at)
                                          FROM order_items)::TIMESTAMP) - interval '50 days'
GROUP BY o.user_phone
ORDER BY freq DESC LIMIT 1;



Payment Status info 
payment status 2,3,4 are initiated, successful and failed respectively.

5. Write a query to find 5th highest "PAID" order.
SELECT order_id,
       pay_amount
FROM orders
WHERE payment_status = 3
ORDER BY pay_amount DESC 
LIMIT 1 OFFSET 4;



6. Which payment method is most successful (success rate i.e. success transactions / total transactions).

APPROACH1:
SELECT payment_method ,
       count(payment_status) AS Total ,
       sum(success) AS success ,
       sum(success)*100 / count(payment_status) AS Success_Rate
FROM
    (SELECT payment_method ,
            payment_status ,
            CASE
                WHEN payment_status=3 THEN 1
                ELSE 0
            END success
     FROM orders
 ) aa
GROUP BY payment_method

APPROACH2:
SELECT payment_method ,
       sum(success) ,
       sum(initiated) ,
       sum(failed) ,
       sum(success)*100.0 / (sum(success)+sum(initiated)+sum(failed)) AS sr
FROM
    (SELECT payment_method,
            CASE
                WHEN payment_status = '2' THEN 1
                ELSE 0
            END AS initiated,
            CASE
                WHEN payment_status = '3' THEN 1
                ELSE 0
            END AS success,
            CASE
                WHEN payment_status = '4' THEN 1
                ELSE 0
            END AS failed
     FROM orders
) aa
GROUP BY payment_method



7. What are the top selling items for merchant ID 43 in last 7 days? Write the SQL query. 
[5 top selling items (item_id,name,count) of last 7 days.]

SELECT oi.item_id,
       oi.name,
       COUNT(oi.item_id)
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.merchant_id = 43
    AND oi.created_at::TIMESTAMP >= (
                                         (SELECT MAX(created_at)
                                          FROM order_items)::TIMESTAMP) - interval '7 days'
GROUP BY oi.name,
         oi.item_id
ORDER BY COUNT(oi.item_id) DESC 
LIMIT 5;



8. For store 74, give a list of top 2 paying customer for each day for last 3 days.
SELECT date_num,
       user_phone,
       total
FROM
    (SELECT date_num,
            user_phone,
            total ,
            DENSE_RANK() over (partition BY aa.date_num
                               ORDER BY total DESC) AS rnk
     FROM
         (SELECT EXTRACT('day'
                         FROM created_at::date) AS date_num,
                 user_phone ,
                 SUM(pay_amount) AS total
          FROM orders
          WHERE store_id = 74
              AND created_at::TIMESTAMP > ((
                                                (SELECT MAX(created_at::TIMESTAMP)
                                                 FROM orders)::TIMESTAMP) - interval '3 days')
          GROUP BY date_num ,
                   user_phone
          ORDER BY SUM(pay_amount) DESC --limit 1;
) aa)bb
WHERE rnk <3