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

-- RFM analysis
WITH RFM_Base AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(transaction_date), (SELECT MAX(transaction_date) FROM transactions)) AS Recency_Days,
        COUNT(DISTINCT transaction_id) AS Frequency_Orders,
        SUM(online_spend + offline_spend) AS Monetary_Spend
    FROM transactions
    GROUP BY customer_id
),
RFM_Scoring AS (
    SELECT
        customer_id,
        Recency_Days,
        Frequency_Orders,
        Monetary_Spend,
        NTILE(4) OVER (ORDER BY Recency_Days DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency_Orders ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary_Spend ASC) AS M_Score
    FROM RFM_Base
)
SELECT
    customer_id,
    Recency_Days,
    Frequency_Orders,
    Monetary_Spend,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Cell,
    CASE
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN '1. VIPs'
        WHEN R_Score >= 3 AND F_Score >= 3 THEN '2. Loyal Customers'
        WHEN R_Score >= 3 AND F_Score <= 2 THEN '3. Potential / New'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN '4. At Risk (Big Spenders)'
        WHEN R_Score <= 2 AND F_Score <= 2 THEN '5. Lost Customers'
        ELSE '6. Average / Regular'
    END AS RFM_Segment
FROM RFM_Scoring
ORDER BY RFM_Segment, Monetary_Spend DESC;

