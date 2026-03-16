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