-- DDL
-- CREATING CUST.INFO table
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
cst_id INT,
cst_key VARCHAR(50),
cst_firtname varchar (50),
cst_lastname VARCHAR (50),
cst_marital_status VARCHAR(50),
cst_gender VARCHAR (50),
cst_create_dt DATE);

-- CREATING PRD.INFO
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key VARCHAR (50),
prd_nm VARCHAR (50),
prd_cost INT,
prd_line VARCHAR (50),
prd_start_dt DATE,
prd_end_dt DATE);

-- CREATING SALES_DETAILS
DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num VARCHAR (50),
sls_prd_key VARCHAR (50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT);


-- CREATING FROM SOURCE ERP
-- CREATING loc_a101
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid VARCHAR (50),
cntry VARCHAR (50)
);

-- CREATING TABLE CUST_AZ12
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid VARCHAR (50),
bdate DATE,
gen VARCHAR(50)
);

-- CREATING TABLE PX_CAT_G1V2
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
id VARCHAR (50),
cat VARCHAR (50),
subcat VARCHAR (50),
maintenance VARCHAR (50)
);
