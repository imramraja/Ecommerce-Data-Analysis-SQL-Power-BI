-- ====================================================
-- Create raw tables for Olist dataset
-- Run this BEFORE importing data via SSMS Import Wizard
-- ====================================================

-- Drop tables if they already exist (to start fresh)
IF OBJECT_ID('order_reviews', 'U') IS NOT NULL DROP TABLE order_reviews;
IF OBJECT_ID('order_payments', 'U') IS NOT NULL DROP TABLE order_payments;
IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('sellers', 'U') IS NOT NULL DROP TABLE sellers;
IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers;
IF OBJECT_ID('geolocation', 'U') IS NOT NULL DROP TABLE geolocation;
IF OBJECT_ID('product_category_name_translation', 'U') IS NOT NULL DROP TABLE product_category_name_translation;
GO

-- Customers table
CREATE TABLE customers (
    customer_id                 NVARCHAR(50),
    customer_unique_id          NVARCHAR(50),
    customer_zip_code_prefix    NVARCHAR(10),
    customer_city               NVARCHAR(100),
    customer_state              NVARCHAR(10)
);

-- Sellers table
CREATE TABLE sellers (
    seller_id                   NVARCHAR(50),
    seller_zip_code_prefix      NVARCHAR(10),
    seller_city                 NVARCHAR(100),
    seller_state                NVARCHAR(10)
);

-- Products table
CREATE TABLE products (
    product_id                  NVARCHAR(50),
    product_category_name       NVARCHAR(100),
    product_name_length         NVARCHAR(10),        -- keep as string for now, convert later
    product_description_length  NVARCHAR(10),
    product_photos_qty          NVARCHAR(10),
    product_weight_g            NVARCHAR(20),
    product_length_cm           NVARCHAR(20),
    product_height_cm           NVARCHAR(20),
    product_width_cm            NVARCHAR(20)
);

-- Orders table
CREATE TABLE orders (
    order_id                    NVARCHAR(50),
    customer_id                 NVARCHAR(50),
    order_status                NVARCHAR(50),
    order_purchase_timestamp    NVARCHAR(30),
    order_approved_at           NVARCHAR(30),
    order_delivered_carrier_date NVARCHAR(30),
    order_delivered_customer_date NVARCHAR(30),
    order_estimated_delivery_date NVARCHAR(30)
);

-- Order items table
CREATE TABLE order_items (
    order_id                    NVARCHAR(50),
    order_item_id               NVARCHAR(10),
    product_id                  NVARCHAR(50),
    seller_id                   NVARCHAR(50),
    shipping_limit_date         NVARCHAR(30),
    price                       NVARCHAR(20),
    freight_value               NVARCHAR(20)
);

-- Order payments table
CREATE TABLE order_payments (
    order_id                    NVARCHAR(50),
    payment_sequential          NVARCHAR(10),
    payment_type                NVARCHAR(50),
    payment_installments        NVARCHAR(10),
    payment_value               NVARCHAR(20)
);

-- Order reviews table
CREATE TABLE order_reviews (
    review_id                   NVARCHAR(50),
    order_id                    NVARCHAR(50),
    review_score                NVARCHAR(10),
    review_comment_title        NVARCHAR(MAX),
    review_comment_message      NVARCHAR(MAX),
    review_creation_date        NVARCHAR(30),
    review_answer_timestamp     NVARCHAR(30)
);

-- Geolocation table
CREATE TABLE geolocation (
    geolocation_zip_code_prefix NVARCHAR(10),
    geolocation_lat             NVARCHAR(30),
    geolocation_lng             NVARCHAR(30),
    geolocation_city            NVARCHAR(100),
    geolocation_state           NVARCHAR(10)
);

-- Product category name translation table
CREATE TABLE product_category_name_translation (
    product_category_name           NVARCHAR(100),
    product_category_name_english   NVARCHAR(100)
);

PRINT 'Raw tables created. Now import data';
