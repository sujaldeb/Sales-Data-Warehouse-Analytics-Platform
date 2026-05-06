-- ERP CUST az12
-- DATA checks 

SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
			 ELSE cid
		END AS cid,
        bdate,
        gen
FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';

SELECT cid,
        CASE WHEN bdate < 1900-01-01 OR bdate > curdate() THEN NULL 
			 ELSE bdate
        END AS bdate,
		gen
FROM bronze.erp_cust_az12
WHERE bdate < 1900-01-01 OR bdate > curdate();

SELECT 	
        DISTINCT(gen),
        CASE WHEN UPPER(TRIM(gen)) IN  ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN  ('M','MALE') THEN 'Male'
             ELSE 'N/A'
        END     
FROM bronze.erp_cust_az12;

-- DATA CHECKS erp_loc_a101

SELECT 
		REPLACE(cid,'-',''),

        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
             WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'N/A' 
             ELSE TRIM(cntry)
		END AS cntry
FROM bronze.erp_loc_a101;

SELECT 
       DISTINCT cntry,
       CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
             WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'N/A' 
             ELSE TRIM(cntry)
		END AS new_cntry
FROM bronze.erp_loc_a101;

-- DATA CHECKS 
-- SILVER erp_px_cat_g1v2

SELECT 
		
        DISTINCT cat
FROM bronze.erp_px_cat_g1v2;