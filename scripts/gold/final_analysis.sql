CREATE OR REPLACE VIEW gold.report_products AS
WITH base_query AS (
    SELECT 
        f.order_number, -- Fixed: added underscore
        f.order_date, 
        f.customer_key, 
        f.sales_amount, 
        f.quantity, 
        p.product_key, 
        p.product_name, 
        p.category, 
        p.subcategory, 
        p.cost 
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key 
    WHERE f.order_date IS NOT NULL 
),
product_aggregations AS (
    SELECT 
        product_key, 
        product_name, 
        category, 
        subcategory, 
        cost, 
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date, 
        COUNT(DISTINCT order_number) AS total_orders, -- Fixed: added underscore
        COUNT(DISTINCT customer_key) AS total_customers, 
        SUM(sales_amount) AS total_sales, 
        SUM(quantity) AS total_quantity, 
        ROUND(AVG(sales_amount / NULLIF(quantity, 0)), 1) AS avg_selling_price 
    FROM base_query 
    GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT 
    product_key, 
    product_name, 
    category, 
    subcategory, 
    cost, 
    last_sale_date, 
    TIMESTAMPDIFF(MONTH, last_sale_date, NOW()) AS recency_in_months,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer' 
        WHEN total_sales >= 10000 THEN 'Mid-Range' 
        ELSE 'Low-Performer' 
    END AS product_segment, 
    lifespan, 
    total_orders, 
    total_sales, 
    total_quantity, 
    total_customers, 
    avg_selling_price, 
    CASE 
        WHEN lifespan = 0 THEN total_sales 
        ELSE total_sales / lifespan 
    END AS avg_monthly_revenue 
FROM product_aggregations;
