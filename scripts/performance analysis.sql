/*
=================================================================================
Performance analysis of the SQL query:
		comparing the current value with the target value
=================================================================================
*/
WITH [yearly product sales] as (
SELECT
YEAR(f.order_date) AS ORDER_YEAR,
p.product_name,
SUM(f.sales_amount) AS current_sales
from gold.fact_sales f
left join gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date is not null
group by 
	YEAR(f.order_date) ,
	p.product_name)
	select 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) over (partition by product_name),
	current_sales - AVG(current_sales) over (partition by product_name) as diff_flag,
	case when 	current_sales - AVG(current_sales) over (partition by product_name) > 0 then 'ABOVE AVERAGE'
		when 	current_sales - AVG(current_sales) over (partition by product_name) < 0 then 'below AVERAGE'
		else 'AVG'

	end  avg_change,
	-- year over year analysis
	LAG (current_sales) over (partition by product_name order by order_year ) py_year,
	current_sales - 	LAG (current_sales) over (partition by product_name order by order_year )  as diff_py,
	case when 	current_sales - LAG (current_sales) over (partition by product_name order by order_year ) > 0 then 'incrase'
		when 	current_sales -LAG (current_sales) over (partition by product_name order by order_year ) < 0 then 'decrease'
		else 'no change'
		end py_change
	from [yearly product sales]
	order by product_name, ORDER_YEAR