-- database explorations

SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- EXPLORE ALL THE COLUMNS IN THE TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers' 


-- explore dimensions

select distinct country from gold.dim_customers;
select distinct category, subcategory , product_name from gold.dim_products
order by 1,2,3

--explore dates
-- find the first and last order date in the fact_sales table
-- find the range of order dates in years

select 
	min(order_date) as first_orderdate, 
	max(order_date) as last_orderdate,
	datediff(YEAR, min(order_date), max(order_date)) as orderdate_range_years
from gold.fact_sales
--find the youngest and oldest customer
select 
	min(birthdate) as oldest_customer, 
	max(birthdate) as youngest_customer,
	datediff(YEAR, min(birthdate), max(birthdate)) as customer_age_range_years
from gold.dim_customers

-- find the total sales
SELECT SUM(sales_amount) as total_sales FROM gold.fact_sales;
-- find how many items are sold
SELECT SUM(quantity) as total_items_sold FROM gold.fact_sales;
-- find the average sales price
SELECT AVG(price) as average_sales_price FROM gold.fact_sales;
-- find the total number of orders
SELECT COUNT(DISTINCT order_number) as total_orders FROM gold.fact_sales;
-- find the total number of products sold
SELECT COUNT(DISTINCT product_key) as total_products_sold FROM gold.dim_products;
-- find the total number of customers
SELECT COUNT(DISTINCT customer_key) as total_customers FROM gold.dim_customers;
--find the total number of customers that have made a purchase
SELECT COUNT(DISTINCT customer_key) as total_customers_with_purchases FROM gold.fact_sales;
--generate a report that shows all key matrics on business
SELECT 'TOTAL SALES' as measure_name, SUM(sales_amount) as value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL QUANTITY' as measure_name, SUM(quantity) as value FROM gold.fact_sales
UNION ALL
SELECT 'AVERAGE SALES PRICE' as measure_name, AVG(price) as value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL ORDERS' as measure_name, COUNT(DISTINCT order_number) as value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL PRODUCTS SOLD' as measure_name, COUNT(DISTINCT product_key) as value FROM gold.dim_products
UNION ALL
SELECT 'TOTAL CUSTOMERS' as measure_name, COUNT(DISTINCT customer_key) as value FROM gold.dim_customers
UNION ALL
SELECT 'TOTAL CUSTOMERS WITH PURCHASES' as measure_name, COUNT(DISTINCT customer_key) as value FROM gold.fact_sales
--==========================================================================================================
-- Magnitude : 
--==========================================================================================================
--find the total customers by countries
SELECT 
country,
 COUNT(DISTINCT customer_key) as total_customers
FROM gold.dim_customers
GROUP BY country
order by total_customers DESC
--FIND THE TOTAL CUSTOMERS BY GENDER
SELECT
gender,
 COUNT(DISTINCT customer_key) as total_customers
FROM gold.dim_customers
GROUP BY gender
order by total_customers DESC
--find the total products by category
SELECT
category,
COUNT(DISTINCT product_key) as total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC
--What is the average cost in each category
SELECT
category,
AVG(cost) as average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC
--find the total revenue by category
SELECT
dp.category,
SUM(fs.sales_amount) as total_revenue
FROM gold.fact_sales fs
JOIN gold.dim_products dp 
ON fs.product_key = dp.product_key
GROUP BY dp.category
order by total_revenue DESC
--what is the total revenue by each customer
SELECT 
c.customer_id,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
GROUP BY c.customer_id ,c.first_name,c.last_name
order by total_revenue DESC
-- what is the distribution od sold items across countries
SELECT 
c.country,
SUM(f.quantity) as total_sales_quantity
FROM gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
GROUP BY c.country
order by total_sales_quantity DESC
--==========================================================================================================
-- Ranking : 
--==========================================================================================================
--which 5 products generate the most revenue
SELECT top 5
p.product_name,
SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
left join gold.dim_products p 
on f.product_key = p.product_key
GROUP BY p.product_name
order by total_revenue DESC

--what are worse 5 products in terms of revenue
SELECT top 5
p.product_name,
SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
left join gold.dim_products p 
on f.product_key = p.product_key
GROUP BY p.product_name
order by total_revenue ASC
-- by windows
select * from (
SELECT 
p.product_name,
SUM(f.sales_amount) as total_revenue,
row_number() over (order by SUM(f.sales_amount) DESC) as revenue_rank_product
FROM gold.fact_sales f
left join gold.dim_products p 
on f.product_key = p.product_key
GROUP BY p.product_name
)t 
	where revenue_rank_product <= 5
	--find the top 10 customers in terms of revenue
	SELECT  top 10
c.customer_id,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
GROUP BY c.customer_id ,c.first_name,c.last_name
order by total_revenue DESC