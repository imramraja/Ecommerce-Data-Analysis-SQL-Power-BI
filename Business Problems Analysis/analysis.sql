-- ========================================================================
-- BUSINESS ANALYSIS QUERIES (20 PROBLEMS)
-- ========================================================================
PRINT 'Running 20 business analysis queries...';
GO

-- ------------------------------------------------------------------------
-- Problem 1: Monthly revenue and order volume trend
-- ------------------------------------------------------------------------
SELECT
    YEAR(order_purchase_timestamp) AS Year,
    MONTH(order_purchase_timestamp) AS Month,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.price + ISNULL(oi.freight_value, 0)) AS TotalRevenue
FROM orders_clean o
JOIN order_items_clean oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY Year, Month;
GO

-- ------------------------------------------------------------------------
-- Problem 2: Top 10 best‑selling products by quantity and revenue
-- ------------------------------------------------------------------------
SELECT TOP 10
    p.product_id,
    p.product_category_name,
    COUNT(*) AS QuantitySold,
    SUM(oi.price + ISNULL(oi.freight_value, 0)) AS Revenue
FROM order_items_clean oi
JOIN products_clean p ON oi.product_id = p.product_id
JOIN orders_clean o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_id, p.product_category_name
ORDER BY Revenue DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 3: Customer order frequency distribution
-- ------------------------------------------------------------------------
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders_clean
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    order_count,
    COUNT(*) AS number_of_customers
FROM customer_orders
GROUP BY order_count
ORDER BY order_count;
GO

-- ------------------------------------------------------------------------
-- Problem 4: Average delivery time by customer state
-- ------------------------------------------------------------------------
SELECT
    c.customer_state,
    AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM orders_clean o
JOIN customers_clean c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;
GO

-- ------------------------------------------------------------------------
-- Problem 5: Payment method popularity
-- ------------------------------------------------------------------------
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    AVG(payment_installments) AS avg_installments,
    SUM(payment_value) AS total_value
FROM order_payments_clean
GROUP BY payment_type
ORDER BY payment_count DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 6: Seller performance ranking (by revenue and review score)
-- ------------------------------------------------------------------------
WITH seller_revenue AS (
    SELECT
        oi.seller_id,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS total_revenue,
        AVG(CAST(r.review_score AS FLOAT)) AS avg_review_score
    FROM order_items_clean oi
    JOIN orders_clean o ON oi.order_id = o.order_id
    LEFT JOIN order_reviews_clean r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    total_revenue,
    avg_review_score,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY avg_review_score DESC) AS review_rank
FROM seller_revenue
ORDER BY revenue_rank;
GO

-- ------------------------------------------------------------------------
-- Problem 7: Product category revenue contribution
-- ------------------------------------------------------------------------
WITH category_revenue AS (
    SELECT
        p.product_category_name,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS category_revenue
    FROM order_items_clean oi
    JOIN products_clean p ON oi.product_id = p.product_id
    JOIN orders_clean o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.product_category_name
)
SELECT
    product_category_name,
    category_revenue,
    ROUND(100.0 * category_revenue / SUM(category_revenue) OVER (), 2) AS revenue_percentage
FROM category_revenue
ORDER BY category_revenue DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 8: Customer lifetime value (CLV) segmentation
-- ------------------------------------------------------------------------
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    SUM(oi.price + ISNULL(oi.freight_value, 0)) AS total_spent,
    CASE
        WHEN SUM(oi.price + ISNULL(oi.freight_value, 0)) < 500 THEN 'Low'
        WHEN SUM(oi.price + ISNULL(oi.freight_value, 0)) <= 2000 THEN 'Medium'
        ELSE 'High'
    END AS value_segment
FROM customers_clean c
JOIN orders_clean o ON c.customer_id = o.customer_id
JOIN order_items_clean oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_city, c.customer_state
ORDER BY total_spent DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 9: Repeat purchase rate
-- ------------------------------------------------------------------------
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders_clean
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT
    COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(CASE WHEN order_count > 1 THEN 1 END) / COUNT(*), 2) AS repeat_rate
FROM customer_order_counts;
GO

-- ------------------------------------------------------------------------
-- Problem 10: Order funnel conversion / cancellation rate by category
-- ------------------------------------------------------------------------
SELECT
    p.product_category_name,
    COUNT(*) AS total_orders_in_category,
    SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancellation_rate
FROM orders_clean o
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY cancellation_rate DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 11: 3‑month moving average of revenue
-- ------------------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        YEAR(order_purchase_timestamp) AS Year,
        MONTH(order_purchase_timestamp) AS Month,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS revenue
    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
)
SELECT
    Year,
    Month,
    revenue,
    AVG(revenue) OVER (ORDER BY Year, Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3months
FROM monthly_revenue
ORDER BY Year, Month;
GO

-- ------------------------------------------------------------------------
-- Problem 12: First vs. repeat order value comparison
-- ------------------------------------------------------------------------
WITH customer_order_sequence AS (
    SELECT
        customer_id,
        order_id,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS order_value,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS order_seq
    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY customer_id, order_id, order_purchase_timestamp
)
SELECT
    CASE WHEN order_seq = 1 THEN 'First' ELSE 'Repeat' END AS order_type,
    AVG(order_value) AS avg_order_value,
    COUNT(*) AS order_count
FROM customer_order_sequence
GROUP BY CASE WHEN order_seq = 1 THEN 'First' ELSE 'Repeat' END;
GO

-- ------------------------------------------------------------------------
-- Problem 13: Product affinity analysis (frequently bought together)
-- ------------------------------------------------------------------------
-- Find pairs of products that appear together in at least 10 orders
SELECT
    p1.product_id AS product_A,
    p2.product_id AS product_B,
    COUNT(*) AS times_bought_together
FROM order_items_clean oi1
JOIN order_items_clean oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN products_clean p1 ON oi1.product_id = p1.product_id
JOIN products_clean p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_id, p2.product_id
HAVING COUNT(*) >= 10
ORDER BY times_bought_together DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 14: Seller rating vs. delivery time correlation
-- ------------------------------------------------------------------------
SELECT
    oi.seller_id,
    AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days,
    AVG(CAST(r.review_score AS FLOAT)) AS avg_review_score
FROM order_items_clean oi
JOIN orders_clean o ON oi.order_id = o.order_id
LEFT JOIN order_reviews_clean r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
HAVING COUNT(*) >= 10   -- only sellers with enough orders
ORDER BY avg_delivery_days;
GO

-- ------------------------------------------------------------------------
-- Problem 15: Customer segmentation by RFM (Recency, Frequency, Monetary)
-- ------------------------------------------------------------------------
WITH rfm_raw AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(order_purchase_timestamp), (SELECT MAX(order_purchase_timestamp) FROM orders_clean)) AS recency,
        COUNT(*) AS frequency,
        SUM(oi.price + ISNULL(oi.freight_value, 0)) AS monetary
    FROM orders_clean o
    JOIN order_items_clean oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC) AS recency_score,   -- lower recency = better
        NTILE(4) OVER (ORDER BY frequency) AS frequency_score,    -- higher frequency = better
        NTILE(4) OVER (ORDER BY monetary) AS monetary_score       -- higher monetary = better
    FROM rfm_raw
)
SELECT
    customer_id,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_cell,
    CASE
        WHEN recency_score = 4 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Loyal'
        WHEN recency_score = 1 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'At Risk'
        ELSE 'Other'
    END AS customer_segment
FROM rfm_scores;
GO

-- ------------------------------------------------------------------------
-- Problem 16: Geolocation heat map (customer density by state)
-- ------------------------------------------------------------------------
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.price + ISNULL(oi.freight_value, 0)) AS total_revenue
FROM customers_clean c
LEFT JOIN orders_clean o ON c.customer_id = o.customer_id
LEFT JOIN order_items_clean oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY customer_count DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 17: Delivery delay root cause analysis (by product category and seller state)
-- ------------------------------------------------------------------------
SELECT
    p.product_category_name,
    s.seller_state,
    AVG(DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date)) AS avg_delay_days,
    COUNT(*) AS order_count
FROM orders_clean o
JOIN order_items_clean oi ON o.order_id = oi.order_id
JOIN products_clean p ON oi.product_id = p.product_id
JOIN sellers_clean s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY p.product_category_name, s.seller_state
HAVING COUNT(*) >= 5
ORDER BY avg_delay_days DESC;
GO

-- ------------------------------------------------------------------------
-- Problem 18: Example usage of stored procedure (for November 2017)
-- ------------------------------------------------------------------------
EXEC sp_GetMonthlySalesReport @Year = 2017, @Month = 11;
GO

-- ------------------------------------------------------------------------
-- Problem 19: Example usage of scalar function (customer tier for one customer)
-- ------------------------------------------------------------------------
SELECT TOP 10
    customer_id,
    dbo.fn_GetCustomerTier(customer_id) AS customer_tier
FROM customers_clean;
GO

-- ------------------------------------------------------------------------
-- Problem 20: Example usage of table‑valued function (product sales for 2017)
-- ------------------------------------------------------------------------
SELECT TOP 10 *
FROM tvf_GetProductSales('2017-01-01', '2017-12-31')
ORDER BY revenue DESC;
GO

PRINT 'All 20 queries executed.';
