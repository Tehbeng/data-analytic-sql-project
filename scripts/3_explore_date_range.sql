/*
==============================================================
			Date Range Exploration
==============================================================
Purpose :
	- Understanding the range of dates in gold.fact_sales.
	- Determine the boundaries of key data points.

List SQL Function :
	- MIN()
	- MAX()
	- DATEDIFF()
==============================================================
*/

-- Determine the order date by first and last and total duration in months
SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the round age of the customer by youngest and oldest
SELECT
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
