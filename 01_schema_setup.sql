CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    gender TEXT,
    location TEXT,
    tenure_months INTEGER
);

CREATE TABLE products (
    product_sku TEXT PRIMARY KEY,
    product_description TEXT,
    product_category TEXT,
    avg_price REAL
);

CREATE TABLE transactions (
    transaction_id INTEGER,
    customer_id INTEGER,
    product_sku TEXT,
    transaction_date DATE,
    quantity INTEGER,
    delivery_charges REAL,
    coupon_status TEXT,
    coupon_code TEXT,
    discount_pct REAL,
    gst REAL,
    offline_spend REAL,
    online_spend REAL,
    PRIMARY KEY (transaction_id, product_sku),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_sku) REFERENCES products(product_sku)
);

INSERT INTO customers (customer_id, gender, location, tenure_months)
SELECT DISTINCT CustomerID, Gender, Location, Tenure_Months
FROM raw_online_shopping
WHERE CustomerID IS NOT NULL;

INSERT INTO products (product_sku, product_description, product_category, avg_price)
SELECT
    Product_SKU,
    MAX(Product_Description),
    MAX(Product_Category),
    AVG(Avg_Price)
FROM raw_online_shopping
WHERE Product_SKU IS NOT NULL
GROUP BY Product_SKU;

INSERT INTO transactions (
    transaction_id, customer_id, product_sku, transaction_date, quantity,
    delivery_charges, coupon_status, coupon_code, discount_pct, gst, offline_spend, online_spend
)
SELECT
    Transaction_ID, CustomerID, Product_SKU, Transaction_Date, Quantity,
    Delivery_Charges, Coupon_Status, Coupon_Code, Discount_pct, GST, Offline_Spend, Online_Spend
FROM raw_online_shopping
WHERE Transaction_ID IS NOT NULL;