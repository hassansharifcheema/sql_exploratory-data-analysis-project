/*
=================================================================================
 DATA SEGMENTATION:
	analyze how a person is performing compared to the overall 
	performance of a group or population.
	([measure] / [MEASURE])
	First we are gonna convert one of the measure to a dimension and then compare it 
	>> we are gonna use case when statments
=================================================================================
*/
with product_segments as (
select 
product_key,
product_name,
cost,
CASE
	when cost< 100 then 'below 100'
	when cost between 100 and 500 then '100-500'
	when cost between 500 and 1000 then '500-1000'
	else 'above 1000'
end as cost_range
from gold.dim_products
) 
select 
cost_range,
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc
/*
 Group up the customers into three segments based on their spending behavior:
- VIP customers with at least 12 months of history and spending more than €5,000
- Regular customers with at least 12 months of history but spending €5,000 or less
- New customers with a lifespan of less than 12 months
- The total number of customers in each group
> and also find the number of customers in each group.
*/
with customer_spending as (
select 
c.customer_key,
SUM(f.sales_amount) as total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
datediff(month, MIN(order_date), MAX(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c
on f.customer_key = c.customer_key
group by c.customer_key  
)

select
customer_segment,
COUNT(Customer_key) as total_customers
from(
select
customer_key,
CASE 
	WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	ELSE 'NEW'
END as customer_segment
from customer_spending
)t
group by customer_segment
order by total_customers desc
