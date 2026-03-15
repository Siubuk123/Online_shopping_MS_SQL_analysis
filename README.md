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