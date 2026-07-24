/*
=================================================================================
 BUILD CUSTOMER REPORT:
=================================================================================
purpose:
	This report consolidates the key customer matrix and behaviors.
Highlights:
1. Gather the essential fields such as names, ages, and transaction details.
2. Segment the customers into categories: (VIP, regular, New) and age groups.
3. Aggregate the customer-level matrix:
	total order, 
	total sales,
	total quantity purchased,
	total products 
	lifespan in months.
4. Calculate the valuable KPIs:
	recency months since last order,
	average order value, 
	average monthly spend.
=================================================================================
*/
CREATE VIEW gold.customer_report AS
 WITH base_query as(
/*------------------------------------------------------------------------------------
 1) Base Query : Retrives core columns from tables
 -------------------------------------------------------------------------------------*/

select
	F.order_number,
	F.product_key,
	F.order_date,
	F.sales_amount,
	F.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name ,' ',c.last_name) as customer_name,
	DATEDIFF(YEAR,c.birthdate,GETDATE()) AS customer_age
from gold.fact_sales f 
left join gold.dim_customers c
ON c.customer_key = f.customer_key
where order_date is not null )

, customer_aggregation as (
/*------------------------------------------------------------------------------------
 1) customer aggregations: Summarizes key matrics at the customer level
 -------------------------------------------------------------------------------------*/

SELECT
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	count(DISTINCT order_number) as total_orders,
	SUM(sales_amount) as total_sales,
	SUM(quantity) as total_quantity,
	count(product_key) as total_products,
	MAX(ORDER_DATE) as last_order,
	datediff(month, MIN(order_date), MAX(order_date)) as lifespan

FROM base_query
group by 
	customer_key,
	customer_number,
	customer_name,
	customer_age
	)
SELECT
		customer_key,
		customer_number,
		customer_name,
		customer_age,
	case 
		when customer_age < 20 then 'inder 20'
		when customer_age between 20 and 29 then '20-29'
		when customer_age between 30 and 39 then '30-39'
		when customer_age between 40 and 49 then '40-49'
	ELSE '50 AND ABOVE'
	end age_group,

	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'NEW'
	END as customer_segment,
		last_order,
		datediff(month, last_order, GETDATE()) as recency,
		total_orders,
		total_sales,
		total_quantity,
		total_products,
		lifespan,
-- compute average orde value AVO
	CASE WHEN total_orders =0 then 0
	ELSE total_sales / total_orders 
	end  avg_ordeer_value,
-- compute avg monthly spent
	CASE WHEN lifespan = 0 then total_sales
	else total_sales / lifespan 
	END AS avg_monthly_spent
	

from customer_aggregation