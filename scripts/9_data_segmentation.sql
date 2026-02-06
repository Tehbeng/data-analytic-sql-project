/*
===============================================================================
                        Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

List 0f SQL Functions :
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

--Segment the products into cost ranges and count how many product fall into each segment
                                   
WITH products_segment AS (
SELECT
product_key,
product_name,
cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products)

SELECT
cost_range,
COUNT(product_key) AS total_product
FROM products_segment
GROUP BY cost_range
ORDER BY total_product DESC;

/* 
Group customers into three segments based on their spending behavior:
	- VIP: at least 12 months of history and spending more than 5000$.
	- Regular: at least 12 months of history but spending 5000$ or less.
	- New: lifespan less than 12 months.			
And find the total number of customers by each group				*/

WITH customer_spending AS (
SELECT
	c.customer_key, 
	SUM(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(month, MIN(order_date),MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customer
FROM (
	SELECT
		customer_key,
		total_spending,
		lifespan,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >=12 AND total_spending <=5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending
	)t
GROUP BY customer_segment
ORDER BY total_customer;
