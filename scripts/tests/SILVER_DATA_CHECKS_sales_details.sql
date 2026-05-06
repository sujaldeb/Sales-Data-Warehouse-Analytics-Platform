-- DATA CHECKS sales details

SELECT sls_ord_num,COUNT(*)
FROM bronze.crm_sales_details
GROUP BY sls_ord_num HAVING COUNT(*) > 1;

SELECT 
NULLIF(sls_order_dt,0)
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;

SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0;

SELECT * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt; 

SELECT 	
		sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_price,
        sls_quantity
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT DISTINCT 
	sls_sales AS old_sales,
    sls_quantity,
    sls_price AS old_price,
    CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != ABS(sls_price) * sls_quantity
		 THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
	END AS sls_sales,
    ROUND(CASE WHEN sls_price IS NULL OR sls_price <= 0
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
	END) AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR  sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT 	
		sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_price,
        sls_quantity
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN  (SELECT cst_id FROM silver.crm_cust_info);

SELECT 	
		sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 THEN NULL 
        ELSE sls_order_dt 
        END AS sls_order_dt,
        
        CASE WHEN sls_ship_dt = 0 THEN NULL 
        ELSE sls_ship_dt 
        END AS sls_ship_dt,
        
        CASE WHEN sls_due_dt = 0 THEN NULL 
        ELSE sls_due_dt 
        END AS sls_due_dt,
        
        CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != ABS(sls_price) * sls_quantity
		 THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
		END AS sls_sales,
		ROUND(CASE WHEN sls_price IS NULL OR sls_price <= 0
			 THEN sls_sales / NULLIF(sls_quantity, 0)
			 ELSE sls_price
		END) AS sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);