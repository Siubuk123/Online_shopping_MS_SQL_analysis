USE EcommerceDB;
GO

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    gender VARCHAR(20),
    location VARCHAR(100),
    tenure_months INT
);

CREATE TABLE products (
    product_sku VARCHAR(50) PRIMARY KEY,
    product_description VARCHAR(MAX),
    product_category VARCHAR(100),
    avg_price DECIMAL(18, 2)
);

CREATE TABLE transactions (
    transaction_id INT,
    customer_id INT,
    product_sku VARCHAR(50),
    transaction_date DATE,
    quantity INT,
    delivery_charges DECIMAL(18, 2),
    coupon_status VARCHAR(50),
    coupon_code VARCHAR(50),
    discount_pct DECIMAL(5, 2),
    gst DECIMAL(5, 2),
    offline_spend DECIMAL(18, 2),
    online_spend DECIMAL(18, 2),
    CONSTRAINT PK_Transactions PRIMARY KEY (transaction_id, product_sku),
    CONSTRAINT FK_Customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT FK_Product FOREIGN KEY (product_sku) REFERENCES products(product_sku)
);
GO

INSERT INTO customers (customer_id, gender, location, tenure_months)
SELECT DISTINCT
    CAST(CAST(CustomerID AS VARCHAR(50)) AS INT),
    CAST(Gender AS VARCHAR(20)),
    CAST(Location AS VARCHAR(100)),
    CAST(CAST(Tenure_Months AS VARCHAR(50)) AS INT)
FROM Online_shop_data
WHERE CustomerID IS NOT NULL;

INSERT INTO products (product_sku, product_description, product_category, avg_price)
SELECT
    CAST(Product_SKU AS VARCHAR(50)),
    MAX(CAST(Product_Description AS VARCHAR(MAX))),
    MAX(CAST(Product_Category AS VARCHAR(100))),
    AVG(CAST(CAST(Avg_Price AS VARCHAR(50)) AS DECIMAL(18, 2)))
FROM Online_shop_data
WHERE Product_SKU IS NOT NULL
GROUP BY CAST(Product_SKU AS VARCHAR(50));

INSERT INTO transactions (
    transaction_id, customer_id, product_sku, transaction_date, quantity,
    delivery_charges, coupon_status, coupon_code, discount_pct, gst, offline_spend, online_spend
)
SELECT
    CAST(CAST(Transaction_ID AS VARCHAR(50)) AS INT),
    CAST(CAST(CustomerID AS VARCHAR(50)) AS INT),
    CAST(Product_SKU AS VARCHAR(50)),
    TRY_CAST(CAST(Transaction_Date AS VARCHAR(50)) AS DATE),
    CAST(CAST(Quantity AS VARCHAR(50)) AS INT),
    CAST(CAST(Delivery_Charges AS VARCHAR(50)) AS DECIMAL(18, 2)),
    CAST(Coupon_Status AS VARCHAR(50)),
    CAST(Coupon_Code AS VARCHAR(50)),
    CAST(CAST(Discount_pct AS VARCHAR(50)) AS DECIMAL(5, 2)),
    CAST(CAST(GST AS VARCHAR(50)) AS DECIMAL(5, 2)),
    CAST(CAST(Offline_Spend AS VARCHAR(50)) AS DECIMAL(18, 2)),
    CAST(CAST(Online_Spend AS VARCHAR(50)) AS DECIMAL(18, 2))
FROM Online_shop_data
WHERE Transaction_ID IS NOT NULL;
GO