/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To find the proportion of each part relative to the whole.
    - To see which categories contribute the most to overall sales.

SQL Functions Used:
    - SUM(): Aggregates values per category.
    - Window Functions: SUM() OVER() for the overall total.
===============================================================================
*/

 -- Which categories contribute the most to overall sales? 

 with category_sales as (
	 select
	 category,
	 --sales_amount,
	 sum(sales_amount) as total_sales
	 from dbo.[gold.fact_sales] as f
	 LEFT JOIN dbo.[gold.dim_products] as p
	 on p.product_key = f.product_key
	 group by category
 )
 select 
 category,
 total_sales,
 SUM(total_sales) OVER () as overall_sales,
 CONCAT(ROUND((CAST(total_sales as float) / SUM(total_sales) OVER ()) * 100, 2), '%') as percentage_contribution
 from category_sales
 order by total_sales desc;
