/*

Quality Checks

Script Purpose:
	This script performs various quality checks for data consistency, accuracy,
	and standardization across the 'silver schemas. It includes checks for:
	- Null or duplicate primary keys
	- Unwanted spaces in string fields
	- Data standardization and consistency
	- Invalid date ranges and orders.
	- Data consistency between related fields

Usage Notes:
	- Run these checks after data loading silver layer
	- Investigate and resolve any discrepancies found during the checks

*/

-- Checking 'silver.crm_cust_info'
-- Check for NULLS or duplicates in Primary Key
-- Expectations: No Results
SELECT
	cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
--Check for unwanted Spaces
-- Expectations: No Results
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM (cst_key);
--Check Standarization & Consistency
SELECT DISTINCT 
	cst_marital_status
FROM silver.crm_cust_info

-- Checking 'silver.crm_prd_info'
-- Check for NULLS or duplicates in Primary Key
-- Expectations: No Results
SELECT
	prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
--Check for unwanted Spaces
-- Expectations: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM (prd_nm);
--Check for NULLS or Negative Numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Check Standarization & Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info

--Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Checking 'silver.crm_sales_details'
--Check for invalid dates
SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) !=8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101
--Check for Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
	OR sls_order_dt > sls_due_dt

--Check Standarization & Consistency = Quantity*Price
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Checking 'silver.erp_cust_az12'

--Identify out of range dates
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
	OR bdate > GETDATE();
--Check Standarization & Consistency
SELECT DISTINCT
gen
FROM silver.erp_cust_az12;

-- Checking 'silver.erp_loc_a101'
--Check Standarization & Consistency
SELECT DISTINCT
cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- Checking 'silver.erp_loc_a101'
-- Check for unwanted spaces
SELECT
*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
	OR subcat != TRIM(cat)
	OR maintenance != TRIM(maintenance)
-- Check Standarization & Consistency
SELECT DISTINCT
maintenance
FROM silver.erp_px_cat_g1v2;
