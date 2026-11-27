/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales to both the average sales performance
of the product and previous year's sale */

with yearly_product_sales as (
	select 
	YEAR(f.order_date) as order_year,
	p.product_name,
	SUM(f.sales_amount) as current_sales
	from dbo.[gold.fact_sales] as f
	LEFT JOIN dbo.[gold.dim_products] as p
	on f.product_key = p.product_key
	where order_date is not null
	group by YEAR(order_date), p.product_name	
)
select
order_year,
product_name,
current_sales,
AVG(current_sales) over (PARTITION BY product_name) as avg_sales,
current_sales - AVG(current_sales) over (PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) over (PARTITION BY product_name) > 0 THEN 'Above avg'
	 WHEN current_sales - AVG(current_sales) over (PARTITION BY product_name) < 0 THEN 'Below avg'
	 ELSE 'Avg'
END avg_change,
-- YEAR over YEAR analysis
LAG(current_sales) over (PARTITION BY product_name ORDER BY order_year) as previous_year_sales,
current_sales - LAG(current_sales) over (PARTITION BY product_name ORDER BY order_year) as diff_py,
CASE WHEN current_sales - LAG(current_sales) over (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) over (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No change'
END py_change
from yearly_product_sales
order by product_name, order_year;
