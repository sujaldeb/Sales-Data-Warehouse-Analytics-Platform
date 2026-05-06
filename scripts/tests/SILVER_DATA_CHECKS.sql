DROP SCHEMA  IF EXISTS silver;
CREATE SCHEMA SILVER;
USE silver;

-- CHECKING FOR duplicates
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- CHECKING for UNWANTED SPACES

SELECT COUNT(cst_lastname)
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- CHECKING FOR NULLS

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL OR cst_id =0;

-- CHECKING DISTINCT GENDER
SELECT cst_gender, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_gender;

-- CHECKING DISTINCT marital status
SELECT COUNT(cst_marital_status),cst_marital_status
FROM silver.crm_cust_info
GROUP BY cst_marital_status;

SELECT 
    COUNT(*) AS total_rows,
    SUM(cst_marital_status IS NULL) AS null_count,
    SUM(TRIM(cst_marital_status) = '') AS blank_count
FROM silver.crm_cust_info;

SELECT * 
FROM silver.crm_cust_info
WHERE cst_id IS NULL OR cst_id = 0;

SELECT *
FROM silver.crm_cust_info
WHERE TRIM(cst_marital_status) = '';

SELECT  cst_gender,COUNT(cst_gender)
FROM silver.crm_cust_info
GROUP BY cst_gender;

SELECT COUNT(*)
FROM silver.crm_cust_info
WHERE 
    cst_firstname != TRIM(cst_firstname)
 OR cst_lastname  != TRIM(cst_lastname);
 
 SELECT *
FROM silver.crm_cust_info
WHERE 
    cst_firstname = ''
 OR cst_lastname = '';
 
 SELECT *
 FROM silver.crm_cust_info 
 WHERE cst_gender IS NULL or TRIM(cst_gender) = '';
 
 SELECT COUNT(*)
FROM silver.crm_cust_info
WHERE cst_create_dt IS NULL;

SELECT *
FROM silver.crm_cust_info
WHERE cst_create_dt > CURRENT_DATE();

SELECT *
FROM silver.crm_cust_info
WHERE cst_create_dt < '1900-01-01';

SELECT 
    MIN(cst_create_dt) AS min_date,
    MAX(cst_create_dt) AS max_date,
    COUNT(*) AS total_rows
FROM silver.crm_cust_info;

SELECT *
FROM silver.crm_cust_info
WHERE CAST(cst_create_dt AS CHAR) = '0000-00-00';

