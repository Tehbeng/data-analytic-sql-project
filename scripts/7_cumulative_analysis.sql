/*
===============================================================================
						Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

List of SQL Functions :
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/


-- Calculating the total sales per month and running total of sales per month
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_total,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
	SELECT 
		DATETRUNC(YEAR,order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date)
)t;
