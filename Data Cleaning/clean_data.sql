-- ====================================================
-- Clean the imported Olist data
-- Run this AFTER importing all CSVs using SSMS Import Wizard
-- ====================================================

-- ====================================================
-- 1. CUSTOMERS
-- ====================================================
IF OBJECT_ID('customers_clean', 'U') IS NOT NULL DROP TABLE customers_clean;

SELECT
    customer_id = LTRIM(RTRIM(customer_id)),
    customer_unique_id = LTRIM(RTRIM(customer_unique_id)),
    customer_zip_code_prefix = CASE WHEN LTRIM(RTRIM(customer_zip_code_prefix)) = '' THEN NULL ELSE LTRIM(RTRIM(customer_zip_code_prefix)) END,
    customer_city = CASE WHEN LTRIM(RTRIM(customer_city)) = '' THEN NULL ELSE LTRIM(RTRIM(customer_city)) END,
    customer_state = CASE WHEN LTRIM(RTRIM(customer_state)) = '' THEN NULL ELSE UPPER(LTRIM(RTRIM(customer_state))) END
INTO customers_clean
FROM customers
WHERE customer_id IS NOT NULL AND LTRIM(RTRIM(customer_id)) <> '';

-- Remove duplicates (if any) – keep first occurrence
WITH dup AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS rn
    FROM customers_clean
)
DELETE FROM dup WHERE rn > 1;

-- ====================================================
-- 2. SELLERS
-- ====================================================
IF OBJECT_ID('sellers_clean', 'U') IS NOT NULL DROP TABLE sellers_clean;

SELECT
    seller_id = LTRIM(RTRIM(seller_id)),
    seller_zip_code_prefix = CASE WHEN LTRIM(RTRIM(seller_zip_code_prefix)) = '' THEN NULL ELSE LTRIM(RTRIM(seller_zip_code_prefix)) END,
    seller_city = CASE WHEN LTRIM(RTRIM(seller_city)) = '' THEN NULL ELSE LTRIM(RTRIM(seller_city)) END,
    seller_state = CASE WHEN LTRIM(RTRIM(seller_state)) = '' THEN NULL ELSE UPPER(LTRIM(RTRIM(seller_state))) END
INTO sellers_clean
FROM sellers
WHERE seller_id IS NOT NULL AND LTRIM(RTRIM(seller_id)) <> '';

WITH dup AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY seller_id) AS rn
    FROM sellers_clean
)
DELETE FROM dup WHERE rn > 1;

-- ====================================================
-- 3. PRODUCTS
-- ====================================================
IF OBJECT_ID('products_clean', 'U') IS NOT NULL DROP TABLE products_clean;

SELECT
    product_id = LTRIM(RTRIM(product_id)),
    product_category_name = CASE 
        WHEN LTRIM(RTRIM(product_category_name)) = '' THEN 'unknown' 
        ELSE LOWER(LTRIM(RTRIM(product_category_name))) 
    END,
    product_name_length = TRY_CAST(product_name_length AS INT),
    product_description_length = TRY_CAST(product_description_length AS INT),
    product_photos_qty = TRY_CAST(product_photos_qty AS INT),
    product_weight_g = TRY_CAST(product_weight_g AS DECIMAL(10,2)),
    product_length_cm = TRY_CAST(product_length_cm AS DECIMAL(10,2)),
    product_height_cm = TRY_CAST(product_height_cm AS DECIMAL(10,2)),
    product_width_cm = TRY_CAST(product_width_cm AS DECIMAL(10,2))
INTO products_clean
FROM products
WHERE product_id IS NOT NULL AND LTRIM(RTRIM(product_id)) <> '';

-- Fix bad numbers (negative or zero dimensions become NULL)
UPDATE products_clean SET
    product_weight_g = NULLIF(product_weight_g, 0),
    product_length_cm = NULLIF(product_length_cm, 0),
    product_height_cm = NULLIF(product_height_cm, 0),
    product_width_cm = NULLIF(product_width_cm, 0)
WHERE product_weight_g <= 0 OR product_length_cm <= 0 OR product_height_cm <= 0 OR product_width_cm <= 0;

-- Add a column for volume (optional)
ALTER TABLE products_clean ADD product_volume_cm3 AS (product_length_cm * product_height_cm * product_width_cm);

-- ====================================================
-- 4. ORDERS
-- ====================================================
IF OBJECT_ID('orders_clean', 'U') IS NOT NULL DROP TABLE orders_clean;

SELECT
    order_id = LTRIM(RTRIM(order_id)),
    customer_id = LTRIM(RTRIM(customer_id)),
    order_status = CASE WHEN LTRIM(RTRIM(order_status)) = '' THEN NULL ELSE LTRIM(RTRIM(order_status)) END,
    order_purchase_timestamp = TRY_CONVERT(DATETIME2, order_purchase_timestamp, 120),
    order_approved_at = TRY_CONVERT(DATETIME2, order_approved_at, 120),
    order_delivered_carrier_date = TRY_CONVERT(DATETIME2, order_delivered_carrier_date, 120),
    order_delivered_customer_date = TRY_CONVERT(DATETIME2, order_delivered_customer_date, 120),
    order_estimated_delivery_date = TRY_CONVERT(DATETIME2, order_estimated_delivery_date, 120)
INTO orders_clean
FROM orders
WHERE order_id IS NOT NULL AND LTRIM(RTRIM(order_id)) <> '';

-- Remove future purchase dates (if any)
UPDATE orders_clean SET order_purchase_timestamp = NULL 
WHERE order_purchase_timestamp > GETDATE();

-- Add year, month, date columns for easy analysis
ALTER TABLE orders_clean ADD 
    order_year AS YEAR(order_purchase_timestamp),
    order_month AS MONTH(order_purchase_timestamp),
    order_date AS CAST(order_purchase_timestamp AS DATE),
    delivery_delay_days AS DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date);

-- ====================================================
-- 5. ORDER ITEMS
-- ====================================================
IF OBJECT_ID('order_items_clean', 'U') IS NOT NULL DROP TABLE order_items_clean;

SELECT
    order_id = LTRIM(RTRIM(order_id)),
    order_item_id = TRY_CAST(order_item_id AS INT),
    product_id = LTRIM(RTRIM(product_id)),
    seller_id = LTRIM(RTRIM(seller_id)),
    shipping_limit_date = TRY_CONVERT(DATETIME2, shipping_limit_date, 120),
    price = TRY_CAST(price AS DECIMAL(10,2)),
    freight_value = TRY_CAST(freight_value AS DECIMAL(10,2))
INTO order_items_clean
FROM order_items
WHERE order_id IS NOT NULL AND LTRIM(RTRIM(order_id)) <> '';

-- Remove rows where price is missing or zero
DELETE FROM order_items_clean WHERE price <= 0 OR price IS NULL;

-- Add total item value
ALTER TABLE order_items_clean ADD total_item_value AS (price + ISNULL(freight_value, 0));

-- ====================================================
-- 6. ORDER PAYMENTS
-- ====================================================
IF OBJECT_ID('order_payments_clean', 'U') IS NOT NULL DROP TABLE order_payments_clean;

SELECT
    order_id = LTRIM(RTRIM(order_id)),
    payment_sequential = TRY_CAST(payment_sequential AS INT),
    payment_type = CASE WHEN LTRIM(RTRIM(payment_type)) = '' THEN 'unknown' ELSE LOWER(LTRIM(RTRIM(payment_type))) END,
    payment_installments = TRY_CAST(payment_installments AS INT),
    payment_value = TRY_CAST(payment_value AS DECIMAL(10,2))
INTO order_payments_clean
FROM order_payments
WHERE order_id IS NOT NULL AND LTRIM(RTRIM(order_id)) <> '';

-- Set installments to at least 1
UPDATE order_payments_clean SET payment_installments = 1 
WHERE payment_installments <= 0 OR payment_installments IS NULL;

-- Remove payments with zero value
DELETE FROM order_payments_clean WHERE payment_value <= 0 OR payment_value IS NULL;

-- ====================================================
-- 7. ORDER REVIEWS
-- ====================================================
IF OBJECT_ID('order_reviews_clean', 'U') IS NOT NULL DROP TABLE order_reviews_clean;

SELECT
    review_id = LTRIM(RTRIM(review_id)),
    order_id = LTRIM(RTRIM(order_id)),
    review_score = TRY_CAST(review_score AS INT),
    review_comment_title = LTRIM(RTRIM(review_comment_title)),
    review_comment_message = LTRIM(RTRIM(review_comment_message)),
    review_creation_date = TRY_CONVERT(DATETIME2, review_creation_date, 120),
    review_answer_timestamp = TRY_CONVERT(DATETIME2, review_answer_timestamp, 120)
INTO order_reviews_clean
FROM order_reviews
WHERE review_id IS NOT NULL AND LTRIM(RTRIM(review_id)) <> '';

-- Keep only scores 1–5
DELETE FROM order_reviews_clean WHERE review_score < 1 OR review_score > 5;

-- Add response time in days
ALTER TABLE order_reviews_clean ADD response_days AS DATEDIFF(day, review_creation_date, review_answer_timestamp);

-- ====================================================
-- 8. GEOLOCATION
-- ====================================================
IF OBJECT_ID('geolocation_clean', 'U') IS NOT NULL DROP TABLE geolocation_clean;

-- Deduplicate by zip code (keep first row per zip)
WITH geodata AS (
    SELECT
        geolocation_zip_code_prefix = LTRIM(RTRIM(geolocation_zip_code_prefix)),
        geolocation_lat = TRY_CAST(geolocation_lat AS DECIMAL(10,8)),
        geolocation_lng = TRY_CAST(geolocation_lng AS DECIMAL(11,8)),
        geolocation_city = CASE WHEN LTRIM(RTRIM(geolocation_city)) = '' THEN NULL ELSE LTRIM(RTRIM(geolocation_city)) END,
        geolocation_state = CASE WHEN LTRIM(RTRIM(geolocation_state)) = '' THEN NULL ELSE UPPER(LTRIM(RTRIM(geolocation_state))) END,
        rn = ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(geolocation_zip_code_prefix)) ORDER BY (SELECT NULL))
    FROM geolocation
    WHERE geolocation_zip_code_prefix IS NOT NULL AND LTRIM(RTRIM(geolocation_zip_code_prefix)) <> ''
)
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
INTO geolocation_clean
FROM geodata
WHERE rn = 1;

-- ====================================================
-- 9. PRODUCT CATEGORY TRANSLATION
-- ====================================================
IF OBJECT_ID('product_category_translation_clean', 'U') IS NOT NULL DROP TABLE product_category_translation_clean;

SELECT
    product_category_name = LOWER(LTRIM(RTRIM(product_category_name))),
    product_category_name_english = LOWER(LTRIM(RTRIM(product_category_name_english)))
INTO product_category_translation_clean
FROM product_category_name_translation
WHERE product_category_name IS NOT NULL AND product_category_name <> '';

-- ====================================================
-- 10. REMOVE ORPHANED RECORDS (optional but good)
-- ====================================================
-- Delete orders that don't have a matching customer
DELETE o FROM orders_clean o
LEFT JOIN customers_clean c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Delete order items that don't have a matching order
DELETE oi FROM order_items_clean oi
LEFT JOIN orders_clean o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Similarly for payments and reviews
DELETE op FROM order_payments_clean op
LEFT JOIN orders_clean o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

DELETE r FROM order_reviews_clean r
LEFT JOIN orders_clean o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ====================================================
-- 11. ADD INDEXES FOR FASTER QUERIES
-- ====================================================
CREATE INDEX IX_orders_customer ON orders_clean(customer_id);
CREATE INDEX IX_orders_purchase ON orders_clean(order_purchase_timestamp);
CREATE INDEX IX_order_items_order ON order_items_clean(order_id);
CREATE INDEX IX_order_items_product ON order_items_clean(product_id);
CREATE INDEX IX_order_items_seller ON order_items_clean(seller_id);
CREATE INDEX IX_order_payments_order ON order_payments_clean(order_id);
CREATE INDEX IX_order_reviews_order ON order_reviews_clean(order_id);

-- ====================================================
-- 12. DONE!
-- ====================================================
PRINT 'Data cleaning complete!';
PRINT 'Now use the tables with _clean suffix for your analysis.';
