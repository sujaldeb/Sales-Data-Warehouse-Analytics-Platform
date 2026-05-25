# Sales Data Warehouse & Analytics Platform
### End-to-End Data Engineering Project | Medallion Architecture
**MySQL · SQL · Stored Procedures · Window Functions · Data Modeling**

---

## One-Line Summary

> Built a production-style data warehouse on real-world CRM and ERP sales data — designing a three-layer medallion architecture (Bronze → Silver → Gold), engineering a clean star schema with surrogate keys, applying rigorous data quality checks, and delivering a full analytics layer covering cumulative trends, year-over-year performance, customer segmentation, and product reporting.

---
## Live Architecture

```
Source Systems (CSV)
        │
        ▼
┌───────────────┐
│    BRONZE     │  Raw ingestion — exact copy of source data
│  (6 tables)   │  CRM: cust_info, prd_info, sales_details
│               │  ERP: cust_az12, loc_a101, px_cat_g1v2
└──────┬────────┘
       │  Stored Procedure: bronze.load_bronze()
       ▼
┌───────────────┐
│    SILVER     │  Cleansed & standardized — business rules applied
│  (6 tables)   │  Deduplication · Type normalization · Null handling
│               │  Derived fields · Referential integrity checks
└──────┬────────┘
       │  INSERT ... SELECT transformations
       ▼
┌───────────────┐
│     GOLD      │  Business-ready — star schema views
│  (3 views +   │  dim_customers · dim_products · fact_sales
│   1 report)   │  report_products (analytical summary)
└───────────────┘
       │
       ▼
  Analytics Layer (14 SQL analysis scripts)
```

---

## Problem Statement

Real-world data from CRM and ERP systems is messy — inconsistent codes, invalid dates, duplicate records, negative prices, and mismatched keys across sources. Without a structured transformation pipeline, analysts work on unreliable data and business decisions suffer.

**This project solves three things:**
- **Data Engineering** — Build a robust pipeline that ingests raw CSV data and produces a clean, queryable warehouse
- **Data Modeling** — Design a star schema that makes analytics fast, intuitive, and join-friendly
- **Business Analytics** — Answer real business questions across sales performance, customer behavior, and product profitability

---

## Repository Structure

```
DataWarehouse/
│
├── bronze/
│   ├── BRONZE_DDL.sql                        # Table definitions for raw layer
│   └── BRONZE_DATA_LOADING.sql               # Stored procedure: load_bronze()
│
├── silver/
│   ├── SILVER_DDL.sql                        # Table definitions for clean layer
│   ├── SILVER_DATA_TRANSFORMATION.sql        # All transformation logic
│   ├── SILVER_DATA_CHECKS.sql                # Quality checks: crm_cust_info
│   ├── SILVER_DATA_CHECKS_ERP.sql            # Quality checks: ERP tables
│   └── SILVER_DATA_CHECKS_sales_details.sql  # Quality checks: sales_details
│
├── gold/
│   ├── dim_customers.sql                     # Customer dimension view
│   ├── dim_products.sql                      # Product dimension view
│   ├── fact_sales.sql                        # Fact table view
│   └── final_analysis.sql                    # report_products analytical view
│
└── analytics/
    ├── measures_analysis.sql                 # Core KPI metrics
    ├── dim_analysis.sql                      # Date & demographic ranges
    ├── magnitude_analysis.sql                # Volume & revenue by dimension
    ├── top_N.sql                             # Top/bottom performers
    ├── cumulative_analysis.sql               # Running totals & moving averages
    ├── performance_analysis.sql              # Year-over-year product analysis
    ├── part_to_whole_analysis.sql            # Category contribution %
    └── segmentation_analysis.sql            # Cost tiers & customer segments
```

---

## Data Description

| Source | System | Tables | Key Content |
|---|---|---|---|
| `cust_info.csv` | CRM | `crm_cust_info` | Customer ID, name, gender, marital status, create date |
| `prd_info.csv` | CRM | `crm_prd_info` | Product ID, name, cost, line, validity dates |
| `sales_details.csv` | CRM | `crm_sales_details` | Orders, quantities, prices, ship/due dates |
| `CUST_AZ12.csv` | ERP | `erp_cust_az12` | Customer birth dates, gender (alternate source) |
| `LOC_A101.csv` | ERP | `erp_loc_a101` | Customer country/location codes |
| `PX_CAT_G1V2.csv` | ERP | `erp_px_cat_g1v2` | Product categories and subcategories |

**Star Schema (Gold Layer):**

```
                    ┌──────────────────┐
                    │  dim_customers   │
                    │  customer_key PK │
                    └────────┬─────────┘
                             │
┌──────────────────┐   ┌─────▼──────────┐   ┌──────────────────┐
│  dim_products    │   │   fact_sales   │   │  (report view)   │
│  product_key  PK ├───┤  product_key  FK│   │ report_products  │
└──────────────────┘   │  customer_key FK│   └──────────────────┘
                        │  order_number  │
                        │  sales_amount  │
                        │  quantity      │
                        │  price         │
                        └────────────────┘
```

---

## Methodology

### Stage 1 — Bronze Layer: Raw Ingestion

- Six source CSV files loaded via a single callable stored procedure: `CALL bronze.load_bronze()`
- Tables mirror source schemas exactly — no transformation, no business logic
- `LOAD DATA LOCAL INFILE` with proper field delimiters and header-skip handling
- Acts as an auditable snapshot of what arrived from source systems

### Stage 2 — Silver Layer: Cleansing & Standardization

This is where all the real data engineering happens. Key transformations applied per table:

**`crm_cust_info` — Customer Master**
- Deduplicated on `cst_id` using `ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_dt DESC)` — keeps the most recent record per customer
- Normalized gender: `'M'` → `'Male'`, `'F'` → `'Female'`, anything else → `'N/A'`
- Normalized marital status: `'M'` → `'Married'`, `'S'` → `'Single'`
- `TRIM()` applied to all name fields to remove leading/trailing spaces
- Filtered out null and zero `cst_id` values

**`crm_prd_info` — Product Master**
- Extracted `cat_id` from the first 5 characters of `prd_key` using `SUBSTRING` + `REPLACE`
- Derived `prd_end_dt` using `LEAD()` window function — calculates one day before the next product version's start date (handles slowly changing dimensions)
- Mapped product line codes: `'R'` → `'Road'`, `'M'` → `'Mountain'`, `'T'` → `'Touring'`, etc.
- `COALESCE(prd_cost, 0)` handles null costs

**`crm_sales_details` — Transactional Data**
- Replaced invalid zero-dates (`'0000-00-00'`) with `NULL` for order, ship, and due dates
- Recalculated `sls_sales` when corrupted: `sls_quantity × ABS(sls_price)` used as ground truth
- Recalculated `sls_price` when null or negative: derived from `sls_sales / NULLIF(sls_quantity, 0)`
- Filtered rows where `sls_ord_num != TRIM(sls_ord_num)` to remove whitespace-padded keys

**ERP Tables**
- `erp_cust_az12`: Stripped `'NAS'` prefix from customer IDs; validated birth dates against `[1900-01-01, CURDATE()]`; normalized gender values from multiple spellings
- `erp_loc_a101`: Removed hyphens from customer IDs via `REPLACE(cid, '-', '')`; mapped country codes (`'DE'` → `'Germany'`, `'US'`/`'USA'` → `'United States'`)

### Stage 3 — Gold Layer: Star Schema Views

**`dim_customers`**
- Joins `crm_cust_info` ← `erp_cust_az12` ← `erp_loc_a101`
- Gender conflict resolution: CRM value takes priority; ERP fills in when CRM is `'N/A'`
- Surrogate key generated via `ROW_NUMBER() OVER (ORDER BY cst_key)`

**`dim_products`**
- Joins `crm_prd_info` ← `erp_px_cat_g1v2` on extracted `cat_id`
- Filters `WHERE prd_end_dt IS NULL` — exposes only current, active product versions
- Surrogate key ordered by `prd_start_dt, prd_key` for deterministic assignment

**`fact_sales`**
- Bridges `crm_sales_details` to both dimensions via foreign key lookups
- Resolves natural keys (`sls_prd_key`, `sls_cust_id`) to surrogate keys from dimensions
- Pure join view — no aggregation, full grain at order-line level

**`report_products` (analytical view)**
- Two-CTE structure: `base_query` (flat join) → `product_aggregations` (group-level metrics) → final SELECT with business logic
- Computes: lifespan in months, recency, total orders/customers/revenue/quantity, average selling price, average monthly revenue
- Adds product performance segment: `High-Performer` (>$50K), `Mid-Range` (≥$10K), `Low-Performer`

### Stage 4 — Analytics Layer

Eight analysis scripts covering the full spectrum of business questions:

| Script | Technique | Business Question |
|---|---|---|
| `measures_analysis.sql` | Aggregate functions | Total sales, orders, customers, avg price — KPI dashboard |
| `dim_analysis.sql` | MIN/MAX + TIMESTAMPDIFF | Sales date range, customer age range |
| `magnitude_analysis.sql` | GROUP BY + ORDER BY | Revenue/volume by country, gender, category, customer |
| `top_N.sql` | ORDER BY + LIMIT | Top 5 revenue products, bottom 5, least-active customers |
| `cumulative_analysis.sql` | SUM() OVER + AVG() OVER | Running total sales, moving average price by year |
| `performance_analysis.sql` | LAG() + AVG() OVER PARTITION | YoY product sales change, vs product historical average |
| `part_to_whole_analysis.sql` | SUM() OVER () (no partition) | Category share of total revenue as % |
| `segmentation_analysis.sql` | CASE + TIMESTAMPDIFF | Product cost tiers; VIP / Regular / New customer segments |

---

## Key Findings (Sample Outputs)

1. **Customer segmentation** — Customers are classified into three tiers: VIP (≥12 months history, >$5,000 spend), Regular (≥12 months, ≤$5,000), and New (<12 months) — enabling targeted marketing and retention strategies

2. **Product lifecycle insight** — Using `LEAD()` on product start dates reveals when products were superseded, allowing accurate historical analysis without phantom records

3. **Engineered sales integrity** — A 3-way consistency check (`sales = quantity × |price|`) catches and corrects corrupted transaction records that would silently distort revenue reporting

4. **Gender resolution across systems** — CRM and ERP store conflicting gender values; a priority-based `CASE` logic produces a single trusted field with explicit `'N/A'` where neither source is reliable

5. **Year-over-year performance** — `LAG()` window function enables product-level YoY comparison without self-joins, cleanly tagging each year as `Increase`, `Decrease`, or `No Change`

6. **Domain-knowledge clipping in dimensions** — Filtering `prd_end_dt IS NULL` in `dim_products` is functionally equivalent to a Type 2 SCD current-row filter, keeping the gold layer free from historical noise

---

## Data Quality Checks

Separate check scripts were written and validated before any transformation was committed:

| Check Type | Tables Covered | Examples |
|---|---|---|
| **Duplicate detection** | `crm_cust_info` | `GROUP BY cst_id HAVING COUNT(*) > 1` |
| **Null / zero ID filtering** | `crm_cust_info` | `WHERE cst_id IS NULL OR cst_id = 0` |
| **Whitespace validation** | All text fields | `WHERE col != TRIM(col)` |
| **Invalid date detection** | `crm_sales_details` | `WHERE sls_order_dt <= 0` |
| **Date logic violations** | `crm_sales_details` | `WHERE order_dt > due_dt OR order_dt > ship_dt` |
| **Sales math validation** | `crm_sales_details` | `WHERE sls_sales != sls_quantity * sls_price` |
| **Referential integrity** | `crm_sales_details` | `WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)` |
| **Outlier birth dates** | `erp_cust_az12` | `WHERE bdate < '1900-01-01' OR bdate > CURDATE()` |
| **Country code normalization** | `erp_loc_a101` | `DISTINCT cntry` review before mapping |

---

## Tech Stack

| Category | Tools |
|---|---|
| Database | MySQL 8.x |
| IDE | MySQL Workbench |
| Query Language | SQL (DDL, DML, Window Functions, CTEs, Stored Procedures) |
| Data Modeling | Star Schema (Fact + Dimensions) |
| Architecture Pattern | Medallion Architecture (Bronze / Silver / Gold) |
| Version Control | Git, GitHub |

---

## Setup & Installation

```sql
-- 1. Create the three schema layers
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;

-- 2. Run DDL scripts in order
SOURCE bronze/BRONZE_DDL.sql;
SOURCE silver/SILVER_DDL.sql;

-- 3. Load raw data into Bronze
SOURCE bronze/BRONZE_DATA_LOADING.sql;

-- Update file paths in BRONZE_DATA_LOADING.sql to match your local CSV location
-- Then execute:
CALL bronze.load_bronze();

-- 4. Run data quality checks (optional but recommended)
SOURCE silver/SILVER_DATA_CHECKS.sql;
SOURCE silver/SILVER_DATA_CHECKS_ERP.sql;
SOURCE silver/SILVER_DATA_CHECKS_sales_details.sql;

-- 5. Transform Bronze → Silver
SOURCE silver/SILVER_DATA_TRANSFORMATION.sql;

-- 6. Create Gold views
SOURCE gold/dim_customers.sql;
SOURCE gold/dim_products.sql;
SOURCE gold/fact_sales.sql;
SOURCE gold/final_analysis.sql;

-- 7. Run analytics
SOURCE analytics/measures_analysis.sql;
-- ... (run any analysis script independently)
```

> **Note:** Update the `INFILE` paths in `BRONZE_DATA_LOADING.sql` to match your local dataset directory. `LOCAL INFILE` must be enabled on your MySQL server (`local_infile = ON`).

---

## Limitations & Future Work

- The Bronze load procedure uses hardcoded file paths — parameterizing via a config table or shell script would improve portability
- `sls_sales` and `sls_price` stored as `INT` lose decimal precision; migrating to `DECIMAL(10,2)` would improve accuracy for fractional pricing
- A Silver → Gold refresh procedure (similar to `load_bronze()`) would complete the automated pipeline pattern
- Adding indexes on foreign key columns (`customer_id`, `product_number`) would accelerate analytical query performance at scale
- Implementing slowly changing dimension (SCD Type 2) tracking formally using effective/expiry date columns in the Gold layer

---

## Author

**[Your Name]** — [GitHub](https://github.com/yourusername) · [LinkedIn](https://linkedin.com/in/yourprofile)
