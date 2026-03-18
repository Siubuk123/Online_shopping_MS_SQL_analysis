## About the Project
The project presents an end-to-end data analysis process for a fictional online store. The main goal was to transform raw, "dirty" data from a CSV file into a professional, normalized relational database and extract key business insights.
**Data source:** [Online Shopping Dataset (Kaggle)](https://www.kaggle.com/datasets/jacksondivakarr/online-shopping-dataset)


## Stage 1: Architecture Design and ETL (`01_schema_setup.sql`)

The first part of the project focuses on transforming a flat file with raw data (imported as the table `Online_shop_data`) into a normalized, relational database ready for analysis. The script performs **ETL (Extract, Transform, Load)** processes with an emphasis on rigorous data cleaning.

### Data Model
The schema is based on three relationally connected tables:
1. **`customers`** (Customer dimension): Stores unique demographic data (`customer_id` as Primary Key).
2. **`products`** (Product dimension): A product dictionary with description, category, and average price (`product_sku` as Primary Key).
3. **`transactions`** (Fact table): The central table storing purchase details, connected to the dimensions using foreign keys (`FOREIGN KEY`). A composite primary key (`transaction_id`, `product_sku`) is used here.

### Technical Challenges and Data Cleaning
Due to the strictness of the **MS SQL Server** engine when handling raw data types (e.g., the imported `text` type), the script uses advanced transformation techniques:
* **"Double Casting" (Double casting):** A solution to the problem of type incompatibility through intermediate conversion (e.g. `CAST(CAST(CustomerID AS VARCHAR(50)) AS INT)`), which allowed correct formatting of integer and floating-point numbers (`DECIMAL`).
* **Safe date parsing:** The use of the `TRY_CAST(... AS DATE)` function protects the migration process from interruption when a corrupted date format is encountered (it returns `NULL` instead of an error).
* **Data deduplication:** The use of the `DISTINCT` statement for customers and the `GROUP BY` clause with aggregation functions (`MAX`, `AVG`) for products ensured record uniqueness and the integrity of primary keys before loading the data into the target tables.

## Stage 2: Business Analysis (`02_business_analysis.sql`)

The second phase of the project focuses on extracting actionable business value from the newly structured database. By leveraging advanced T-SQL querying techniques, the script uncovers customer behavior patterns, revenue drivers, and product performance.

### Key Analytical Reports

## Stage 2: Business Analysis (`02_business_analysis.sql`)

The second phase of the project is dedicated to extracting actionable business intelligence from the structured database. The analysis covers sales trends, product performance, purchasing behavior, and advanced customer segmentation.

### Key Analytical Reports & Insights

1. **Core Business Metrics & Seasonality:**
   * **Technical Implementation:** Utilized `SUM()` and `COUNT()` aggregations along with `FORMAT(transaction_date, 'yyyy-MM')` for time-series grouping.
   * **Business Insight:** The dataset reveals a massive total revenue of approximately **$250 Million**. The sales trend shows significant spikes in **August ($28.3M)** and **December ($28.9M)**, aligning with "Back to School/Office" preparations and the holiday gifting season.

2. **Sales Channels & Product Categories:**
   * **Technical Implementation:** Combined `JOIN` operations to link transactions with the product dictionary and aggregated revenue by category and sales channel (online vs. offline).
   * **Business Insight:** Across all top-performing categories (e.g., "Apparel" with ~$84M total revenue, "Nest-USA" with ~$67M), **offline spending consistently outperforms online spending** (e.g., in Apparel: $50.4M offline vs. $33.7M online). This strong offline presence, combined with high total revenue, confirms a **B2B (wholesale) business model**.

3. **Order Size Categorization (Logistics Insight):**
   * **Technical Implementation:** Applied conditional logic (`CASE WHEN`) to bucket transactions based on the physical `quantity` of items purchased, followed by a secondary aggregation `GROUP BY`.
   * **Business Insight:** Although "Small / Retail Orders" (<20 items) generate the vast majority of revenue (~$238M), the "Bulk / Wholesale" (100+ items) and "Large Orders" account for over 130,000 physical items shipped. This is a critical insight for warehouse and logistics planning.

4. **Product Bestsellers & Coupon Impact:**
   * **Technical Implementation:** Used `TOP N` clauses and `GROUP BY` to rank items and evaluate promotional codes.
   * **Business Insight:** The most frequently used coupons are broad, generic codes (SALE20, SALE30, SALE10), which collectively drove nearly **$84 Million** in revenue. Top-selling products by quantity include everyday corporate merchandise like the "Maze Pen" (16,234 units) and "Google 22 oz Water Bottle" (14,282 units).

5. **Advanced Customer Segmentation (RFM Analysis):**
   * **Objective:** Score customers based on Recency (Days since last order), Frequency (Total orders), and Monetary value (Total spend) to build actionable marketing segments.
   * **Technical Implementation:** Leveraged advanced T-SQL **Window Functions**, specifically `NTILE(4)`, to automatically distribute the customer base into quartiles for R, F, and M without hardcoding arbitrary thresholds. `DATEDIFF` and subqueries were used to establish a dynamic "current date" baseline.
   * **Business Insight:** The model successfully identified key segments, pinpointing elite **"1. VIPs"** (scoring 4-4-4). For example, top VIP customers generated individual lifetime values exceeding $2.5M to $3M across hundreds of separate orders, indicating highly lucrative, long-term corporate partnerships.


### SQL Techniques Highlighted
* **Window Functions:** `ROW_NUMBER()`, `OVER()`, and `PARTITION BY` for complex, localized ranking without losing row-level details.
  * **Common Table Expressions (CTEs):** `WITH` clause used extensively to break down multi-step calculations into readable, modular blocks and avoid code duplication in `GROUP BY` clauses.
* **Advanced Aggregation & Logics:** Combining `COUNT(DISTINCT ...)`, `SUM()`, and `CASE WHEN` for dynamic data bucketing.