SELECT 	
	YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


SELECT 
    order_date, 
    total_sales, 
    SUM(total_sales) OVER(ORDER BY order_date) AS cumulative_sales
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS order_date, 
        SUM(sales_amount) AS total_sales 
    FROM gold.fact_sales 
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m') 
) t;

-- RUNNING SALES over time and MOVING AVG
SELECT 
    order_date, 
    total_sales, 
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    SELECT 
        -- Truncates to the first day of the year (e.g., 2011-01-01)
        DATE_FORMAT(order_date, '%Y-01-01') AS order_date, 
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-01-01')
) t;