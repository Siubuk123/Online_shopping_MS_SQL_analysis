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

## Stage 2: Advanced Business Analysis (`02_business_analysis.sql`)

The second phase of the project focuses on extracting actionable business value from the newly structured database. By leveraging advanced T-SQL querying techniques, the script uncovers customer behavior patterns, revenue drivers, and product performance.

### Key Analytical Reports

1. **Customer Segmentation (RFM-lite Analysis):**
   * **Objective:** Categorize customers based on their total purchasing value and order frequency to identify key revenue drivers.
   * **Technical Implementation:** Utilized **CTEs (Common Table Expressions)** to aggregate total spend and distinct order count per customer, followed by conditional logic (`CASE WHEN`) to assign tiers (e.g., *1. VIP Customer*, *4. One-Time Buyer*). A secondary aggregation was performed to analyze the revenue distribution across these segments.
   * **Business Insight:** The analysis revealed a heavy concentration of revenue within the "VIP" segment with almost no mid-tier consumers. This distribution strongly suggests a **B2B (Business-to-Business) model**, meaning the platform likely serves as a wholesale distributor rather than a standard B2C e-commerce store.

   2. **Product Category Performance (Bestsellers):**
      * **Objective:** Identify the exact top 3 best-selling products within *each* distinct product category to help optimize inventory and targeted promotions.
      * **Technical Implementation:** Applied advanced **Window Functions**, specifically `ROW_NUMBER() OVER(PARTITION BY product_category ORDER BY total_quantity_sold DESC)`. This allowed ranking products locally within their categories rather than globally across the entire store.
      * **Business Insight:** The query results highlighted top-performers such as "Google Twill Cap" and "YouTube Bottle Infuser", confirming the dataset represents an **Official Corporate Merchandise Store**. 

### SQL Techniques Highlighted
* **Window Functions:** `ROW_NUMBER()`, `OVER()`, and `PARTITION BY` for complex, localized ranking without losing row-level details.
  * **Common Table Expressions (CTEs):** `WITH` clause used extensively to break down multi-step calculations into readable, modular blocks and avoid code duplication in `GROUP BY` clauses.
* **Advanced Aggregation & Logics:** Combining `COUNT(DISTINCT ...)`, `SUM()`, and `CASE WHEN` for dynamic data bucketing.