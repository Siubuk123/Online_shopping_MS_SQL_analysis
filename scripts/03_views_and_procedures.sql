USE EcommerceDB;
GO

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
