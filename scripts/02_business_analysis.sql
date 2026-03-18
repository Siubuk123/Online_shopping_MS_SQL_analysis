USE EcommerceDB
GO

-- Core Business Metrics
SELECT SUM(online_spend + offline_spend) AS total_sales
FROM transactions;

-- Monthly sales:
SELECT FORMAT(transaction_date, 'yyyy-MM') AS month,
       SUM(online_spend + offline_spend) AS revenue
FROM transactions
GROUP BY FORMAT(transaction_date, 'yyyy-MM')
ORDER BY month;

-- Total revenue by category
SELECT p.product_category,
       SUM(t.online_spend + t.offline_spend) AS revenue
FROM transactions t
JOIN products p
    ON t.product_sku = p.product_sku
GROUP BY p.product_category;

-- Sales Channels: Online vs. Offline by Category
SELECT p.product_category,
       SUM(online_spend) AS online,
       SUM(offline_spend) AS offline
FROM transactions t
JOIN products p
    ON t.product_sku = p.product_sku
GROUP BY p.product_category;

-- Top 10 best-selling products (by quantity)
SELECT TOP 10 p.product_description,
       SUM(t.quantity) AS total_sold
FROM transactions t
JOIN products p
    ON t.product_sku = p.product_sku
GROUP BY p.product_description
ORDER BY total_sold DESC;

-- Order size categorization (logistics & purchasing behavior)
SELECT
    CASE
        WHEN quantity >= 100 THEN '3. Bulk / Wholesale (100+ items)'
        WHEN quantity >= 20 AND quantity < 100 THEN '2. Large Order (20-99 items)'
        ELSE '1. Small / Retail Order (<20 items)'
    END AS order_size_category,
    COUNT(transaction_id) AS total_orders,
    SUM(quantity) AS total_items_sold,
    SUM(online_spend + offline_spend) AS total_revenue
FROM transactions
GROUP BY
    CASE
        WHEN quantity >= 100 THEN '3. Bulk / Wholesale (100+ items)'
        WHEN quantity >= 20 AND quantity < 100 THEN '2. Large Order (20-99 items)'
        ELSE '1. Small / Retail Order (<20 items)'
    END
ORDER BY order_size_category;

-- Effectiveness of discount codes (Impact of coupons)
SELECT coupon_code,
       COUNT(*) AS usage_count,
       SUM(online_spend + offline_spend) AS revenue
FROM transactions
WHERE coupon_code IS NOT NULL
GROUP BY coupon_code
ORDER BY revenue DESC;



