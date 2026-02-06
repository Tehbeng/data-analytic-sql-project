/*
==============================================================
				Dimension Exploration
==============================================================
Purpose :
	- Querying to explore the structure of tables dimensions.

List SQL Function:
	- DISTINCT ( To remove duplicate)
	- ORDER BY ( To sort the data)
==============================================================
*/

-- List of unique countries from customer data
SELECT DISTINCT
	country
FROM gold.dim_customers
ORDER BY country;

-- List of unique categories, subcategories and products
SELECT DISTINCT
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;