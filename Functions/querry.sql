-- ========================================================================
-- FUNCTIONS
-- ========================================================================

-- ------------------------------------------------------------------------
-- Function: fn_GetCustomerTier
-- Returns customer tier (Bronze/Silver/Gold) based on total spend.
-- ------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_GetCustomerTier
(
    @CustomerID NVARCHAR(50)
)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @TotalSpend DECIMAL(10,2);
    DECLARE @Tier NVARCHAR(10);

    SELECT @TotalSpend = SUM(oi.price + ISNULL(oi.freight_value, 0))
    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @CustomerID
      AND o.order_status = 'delivered';

    IF @TotalSpend IS NULL
        SET @Tier = 'No Orders';
    ELSE IF @TotalSpend < 500
        SET @Tier = 'Bronze';
    ELSE IF @TotalSpend <= 2000
        SET @Tier = 'Silver';
    ELSE
        SET @Tier = 'Gold';

    RETURN @Tier;
END;
GO

-- ------------------------------------------------------------------------
-- Function: tvf_GetProductSales
-- Returns product sales summary for a given date range.
-- ------------------------------------------------------------------------
CREATE OR ALTER FUNCTION tvf_GetProductSales
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.product_id,
        p.product_category_name,
        COUNT(*) AS quantity_sold,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS revenue
    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    JOIN products_clean p ON oi.product_id = p.product_id
    WHERE CAST(o.order_purchase_timestamp AS DATE) BETWEEN @StartDate AND @EndDate
      AND o.order_status = 'delivered'
    GROUP BY p.product_id, p.product_category_name
);
GO
