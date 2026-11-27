/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/* Segment products into cost ranges and count how many products fall into each segment*/

with product_segment as (
	select 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 then 'Below 100'
		 WHEN cost between 100 and 500 then '100-500'
		 when cost between 500 and 1000 then '500-1000'
		 when cost between 1000 and 1500 then '1000-1500'
		 when cost between 1500 and 2000 then '1500-2000'
		 else 'above 2000'
	end cost_range
	from dbo.[gold.dim_products]
) 
select 
distinct cost_range,
count(distinct product_key) as total_products
from product_segment
group by cost_range
order by total_products desc;


/*
Group customers into three segments based on their spending behavior: 
	- VIP: Customers with atleast 12 months of history and spending more than 5,000
	- Regular: Customers with atleast 12 months of history but spending 5,000 or less
	- New: Customers with a lifespan less than 12 months
And find the total number of customers by each group
*/

select * from dbo.[gold.dim_customers];
select * from dbo.[gold.fact_sales] 
order by customer_key;

with customer_segments as (
	select
	c.customer_key,
	sum(f.sales_amount) as total_spending,
	min(order_date) as first_order,
	max(order_date) as last_order,
	datediff(month, min(order_date), max(order_date)) as life_span
	from dbo.[gold.fact_sales] as f
	LEFT JOIN dbo.[gold.dim_customers] as c
	on f.customer_key = c.customer_key
	group by c.customer_key
)
select 
group_customer,
count(customer_key) as total_customers
from (
	select 
	customer_key,
	total_spending,
	life_span,
	case when life_span >= 12 and total_spending > 5000 then 'VIP'
		 when life_span >=12 and total_spending <= 5000 then 'Regular'
		 else 'New'
	end group_customer
	from customer_segments) t
group by group_customer order by total_customers desc;
