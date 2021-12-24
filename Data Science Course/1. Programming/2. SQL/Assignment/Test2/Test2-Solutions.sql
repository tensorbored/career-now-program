1. Write an SQL query to find the number of unique customers with sku sales > $100 montly, for each month of 2020.
 Sort the result table by month. This table contains information about the orders made by customer_id.
select aa.mnth, count(aa.customer_id) 
    from
    (
      Select 
          --distinct EXTRACT('month' FROM order_date::DATE) AS mnth
          distinct DATE_TRUNC('month', order_date::DATE) AS mnth
          , customer_id
          , sum(sales)
      from orders
          Group by mnth, customer_id
          having sum(sales) > 100
      ) aa
group by aa.mnth
order by aa.mnth


2. Write an SQL query to return the top 3 skus sold (in terms of $ amount) in each division in AUG and SEP?

select * from (
Select 
     o.Sku
    ,o.Sales
    ,pr.division
    ,ROW_NUMBER() over (partition by pr.division order by o.sales desc) as num
From (
        SELECT   sku
                ,sum(sales) as sales
                ,EXTRACT('month' FROM order_date::DATE) AS mnth
        FROM orders
            where EXTRACT('month' FROM order_date::DATE)=10
                group by sku, mnth
      )o
    left join product pr
          On pr.sku = o.sku
Order by division
) fnl
where num<4