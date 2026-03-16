WITH CustomerStats AS (
    SELECT customer_id,
           count(DISTINCT transaction_id) AS total_orders,
           SUM(online_spend + offline_spend) AS total_spent,
           MAX(transaction_date) AS last_purchase_date
    FROM transactions
    GROUP BY  customer_id
)
SELECT
    CASE
        WHEN total_spent >= 5000 THEN '1. VIP Customer'
        WHEN total_spent >= 2000 AND total_spent < 5000 THEN '2. Loyal / High Spender'
        WHEN total_orders = 1 AND total_spent < 2000 THEN '4. One-Time Buyer'
        ELSE '3. Regular / Low Spender'
    END AS customer_segment,
    COUNT(customer_id) AS number_of_customers,
    SUM(total_spent) AS total_revenue
FROM CustomerStats
GROUP BY
    CASE
        WHEN total_spent >= 5000 THEN '1. VIP Customer'
        WHEN total_spent >= 2000 AND total_spent < 5000 THEN '2. Loyal / High Spender'
        WHEN total_orders = 1 AND total_spent < 2000 THEN '4. One-Time Buyer'
        ELSE '3. Regular / Low Spender'
    END
ORDER BY customer_segment;


WITH ProductSales AS (
    SELECT
        p.product_category,
        p.product_sku,
        MAX(p.product_description) AS product_name,
        SUM(t.quantity) AS total_quantity_sold,
        SUM(t.online_spend + t.offline_spend) AS total_revenue
    FROM transactions t
    JOIN products p ON t.product_sku = p.product_sku
    GROUP BY p.product_category, p.product_sku
),
RankedProducts AS (
    SELECT
        product_category,
        product_sku,
        product_name,
        total_quantity_sold,
        total_revenue,
        ROW_NUMBER() OVER(PARTITION BY product_category ORDER BY total_quantity_sold DESC) AS category_rank
    FROM ProductSales
    WHERE product_category IS NOT NULL
)
SELECT
    product_category,
    category_rank,
    product_sku,
    product_name,
    total_quantity_sold,
    total_revenue
FROM RankedProducts
WHERE category_rank <= 3
ORDER BY product_category, category_rank;