1. Write an SQL query to find the number of unique customers with sku sales > $100 montly, for each month of 2020.
Sort the result table by month. This table contains information about the orders made by customer_id.
SELECT aa.mnth,
       count(aa.customer_id)
FROM
    (SELECT DISTINCT DATE_TRUNC('month', order_date::DATE) AS mnth ,
                     --distinct EXTRACT('month' FROM order_date::DATE) AS mnth,

                     customer_id ,
                     sum(sales)
     FROM orders
     GROUP BY mnth,
              customer_id HAVING sum(sales) > 100) aa
GROUP BY aa.mnth
ORDER BY aa.mnth


2. Write an SQL query to return the top 3 skus sold (in terms of $ amount) in each division in AUG and SEP?
SELECT *
FROM
    (SELECT o.Sku ,
            o.Sales ,
            pr.division ,
            ROW_NUMBER() over (partition BY pr.division
                               ORDER BY o.sales DESC) AS num
     FROM
         ( SELECT sku ,
                  sum(sales) AS sales ,
                  EXTRACT('month'
                          FROM order_date::DATE) AS mnth
          FROM orders
          WHERE EXTRACT('month'
                        FROM order_date::DATE)=10
          GROUP BY sku,
                   mnth )o
     LEFT JOIN product pr ON pr.sku = o.sku
     ORDER BY division) fnl
WHERE num<4