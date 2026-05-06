-- Find the date of the first and last order
-- How many years of sales are avaiable
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and the oldest customer
SELECT
	MIN(birth_date) AS oldest_birthdate,
	MAX(birth_date) AS youngest_birthdate
FROM gold.dim_customers;

