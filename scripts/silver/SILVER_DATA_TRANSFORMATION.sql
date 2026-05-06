TRUNCATE TABLE silver.crm_cust_info;

-- CUST_INFO
-- TRANSFORMATION

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gender,
    cst_create_dt)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
	CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        ELSE 'N/A'
    END,
    CASE 
        WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
        ELSE 'N/A'
    END,
	cst_create_dt
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id 
               ORDER BY cst_create_dt DESC
           ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL AND cst_id != 0
) t
WHERE rn = 1;

-- PRD_INFO
-- TRANSFORMATION
INSERT INTO silver.crm_prd_info(
		prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt)
SELECT 
    prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-', '_') AS cat_id,
    SUBSTRING(prd_key,7) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other sales'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        ELSE 'N/A'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST( DATE_SUB( LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY
				   ) AS DATE
		) AS prd_end_dt
FROM bronze.crm_prd_info;

-- SALES DETAILS
-- TRANSFORMATION
INSERT INTO silver.crm_sales_details( 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT 	
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	CASE 
        WHEN CAST(sls_order_dt AS CHAR) = '0000-00-00' THEN NULL 
        ELSE sls_order_dt 
    END AS sls_order_dt,

    CASE 
        WHEN CAST(sls_ship_dt AS CHAR) = '0000-00-00' THEN NULL 
        ELSE sls_ship_dt 
    END AS sls_ship_dt,

    CASE 
        WHEN CAST(sls_due_dt AS CHAR) = '0000-00-00' THEN NULL 
        ELSE sls_due_dt 
    END AS sls_due_dt,

    CASE 
        WHEN sls_sales IS NULL 
          OR sls_sales <= 0 
          OR ROUND(sls_sales,2) != ROUND(ABS(sls_price) * sls_quantity,2)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
	sls_quantity,
    ROUND(
        CASE 
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END, 2
    ) AS sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num = TRIM(sls_ord_num);

-- ERP CUST AZ12 TABLE
-- TRANSFORMATION

INSERT INTO silver.erp_cust_az12(
cid,
bdate,
gen)
SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
			 ELSE cid
		END AS cid,
        
   CASE WHEN STR_TO_DATE(bdate, '%Y-%m-%d') IS NULL THEN NULL
        WHEN STR_TO_DATE(bdate, '%Y-%m-%d') < '1900-01-01' THEN NULL
        WHEN STR_TO_DATE(bdate, '%Y-%m-%d') > CURDATE() THEN NULL
        ELSE STR_TO_DATE(bdate, '%Y-%m-%d')
    END AS bdate,
        
        CASE WHEN UPPER(TRIM(gen)) IN  ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN  ('M','MALE') THEN 'Male'
             ELSE 'N/A'
        END  AS gen
FROM bronze.erp_cust_az12;

-- silver erp_loc_a101
-- TRANSFORMATION
INSERT INTO silver.erp_loc_a101(
cid,
cntry)
SELECT 
		REPLACE(cid,'-',''),

        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
             WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'N/A' 
             ELSE TRIM(cntry)
		END AS cntry
FROM bronze.erp_loc_a101;

-- SILVER erp_px_cat_g1v2
-- TRANSFORMATION

INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance)
SELECT
		id,
        cat,
        subcat,
        maintenance
FROM bronze.erp_px_cat_g1v2;