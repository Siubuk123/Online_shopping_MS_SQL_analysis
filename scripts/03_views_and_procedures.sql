USE EcommerceDB;
GO

CREATE VIEW vw_CustomerRFM AS
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
FROM RFM_Scoring;


CREATE OR ALTER VIEW vw_TopProductsPerCategory AS
WITH ProductSales AS (
    SELECT
        p.product_category,
        p.product_sku,
        MAX(p.product_description) AS product_name,
        SUM(t.quantity) AS total_quantity_sold,
        SUM(t.online_spend + t.offline_spend) AS total_revenue
    FROM transactions t
    JOIN products p
        ON t.product_sku = p.product_sku
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
WHERE category_rank <= 3;
GO

SELECT * FROM vw_TopProductsPerCategory;

-- Stored procedures
CREATE OR ALTER PROCEDURE sp_GetCouponReportByMonth
    @ReportMonth INT
AS
BEGIN

    SELECT
        coupon_code,
        COUNT(*) AS usage_count,
        SUM(online_spend + offline_spend) AS total_revenue
    FROM transactions
    WHERE coupon_code IS NOT NULL
      AND MONTH(transaction_date) = @ReportMonth
    GROUP BY coupon_code
    ORDER BY total_revenue DESC;
END;
GO
EXEC sp_GetCouponReportByMonth @ReportMonth = 8;
