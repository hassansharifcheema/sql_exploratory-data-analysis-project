/*
=================================================================================
PART TO WHOLE ANALYSIS:
	analyze how a person is performing compared to the overall 
	performance of a group or population.
	([measure] / [total measure]) * 100  by dimension
	([measure] / [total measure]) * 100  by dimension and time period
=================================================================================
*/
-- which category contributes the most to overall sales?
WITH category_sales AS (
SELECT 
P.CATEGORY,
sum(f.sales_amount) total_sales
from gold.fact_sales f
left join gold.dim_products P
on f.product_key = P.product_key
group by P.CATEGORY)
select 
 CATEGORY,
 total_sales,
 sum(total_sales) over() as overall_sales,
 CONCAT(ROUND((cast(total_sales as float) / sum(total_sales) over()) * 100, 2), '%') as percent_contribution
 from category_sales
 ORDER BY total_sales desc