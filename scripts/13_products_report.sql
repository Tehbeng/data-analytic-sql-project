/*
==========================================================================
							Product Report
==========================================================================
Purpose :
	- This report is to consolidate key product metrics and behaviors.

Highlights :
	1. Gathers essential fields such as product name, category, subcategory
	   and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range
	   or Low-Performers.
	3. Aggregates product-level metrics:
		- Total orders
		- Total sales
		- Total quantity sold
		- Total customers (unique)
		- Lifespan (in month)
	4. Calculates valuable KPIs:
		- Recency (months since last sale)
		- Average order revenue (AOR)
		- Average monthly revenue

==========================================================================
*/
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (

/*-------------------------------------------------------------------------------
1) Base query: Retrieve core columns from gold.fact_sales and gold.dim_product
-------------------------------------------------------------------------------*/
	SELECT 
		f.order_number,
		f.customer_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL -- only valid dates
)

/*-------------------------------------------------------------------
2) Product Aggregration: Summarize key metrics at product level
--------------------------------------------------------------------*/

, product_aggregration AS (
	SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		MAX(order_date) AS last_sale_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
		ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),1) AS avg_selling_price
	FROM base_query
	GROUP BY 
		product_key,
		product_name,
		category,
		subcategory,
		cost
)

/*-----------------------------------------------------------------------------------------------
 3) Final Query: Combines all product results into one output
 -----------------------------------------------------------------------------------------------*/
SELECT  
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
	CASE 
		WHEN total_sales > 50000 THEN 'High-Performers'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performers'
	END AS product_segment,
	lifespan,
	total_orders,
	total_quantity,
	total_sales,
	total_customers,
	
	avg_selling_price,

	-- Compute Average Order Revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_orders / total_sales
	END AS avg_order_rev,

	-- Compute average monthly revenue
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_rev
FROM product_aggregration
