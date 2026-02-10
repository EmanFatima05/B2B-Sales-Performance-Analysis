/* ===================================
   E‑COMMERCE DATA LOADING SCRIPT 
   ===================================
*/
create DATABASE EcommerceAnalytics;
GO

USE EcommerceAnalytics;
GO

-- -----------------------------
-- CUSTOMERS TABLE
-- -----------------------------
CREATE TABLE customers (
    customer_id     VARCHAR(10) PRIMARY KEY,
    full_name       VARCHAR(100),
    segment         VARCHAR(20),
    city            VARCHAR(50),
    state           CHAR(15),
    status          VARCHAR(20)
);

-- -----------------------------
-- PRODUCTS TABLE
-- -----------------------------
CREATE TABLE products (
    product_id      VARCHAR(10) PRIMARY KEY,
    product_name    VARCHAR(150),
    category        VARCHAR(50),
    standard_cost   DECIMAL(10,2),
    list_price      DECIMAL(10,2),
    product_status  VARCHAR(30)
);

-- -----------------------------
-- STORES TABLE
-- -----------------------------

CREATE TABLE stores (
    Store_Name    VARCHAR(150),
    City          VARCHAR(50),
    State         VARCHAR(50),
    Region        VARCHAR(50),
    Store_ID      VARCHAR(30) PRIMARY KEY,
    Store_Status  VARCHAR(20),
    Open_Date     DATE
);

-- -----------------------------
-- SALES TABLE
-- -----------------------------

CREATE TABLE sales(
    order_id      VARCHAR(15) PRIMARY KEY,
    order_date    DATE,
    customer_id   VARCHAR(10),
    product_id    VARCHAR(10),
    store_id      VARCHAR(30),
    uantity      INT,
    unit_price    DECIMAL(10,2),
    discount      DECIMAL(5,2),
    revenue       DECIMAL(12,2),
    cost          DECIMAL(10,2),
    profit        DECIMAL(12,2),
    order_status  VARCHAR(20)
);

-- -----------------------------
-- LOAD CUSTOMERS
-- -----------------------------
BULK INSERT customers
FROM 'C:\Users\imanc\OneDrive\Documents\B2B project\clean\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- -----------------------------
-- LOAD PRODUCTS
-- -----------------------------
BULK INSERT products
FROM 'C:\Users\imanc\OneDrive\Documents\B2B project\clean\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- -----------------------------
-- LOAD STORES
-- -----------------------------
BULK INSERT stores
FROM 'C:\Users\imanc\OneDrive\Documents\B2B project\clean\stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- -----------------------------
-- LOAD SALES
-- -----------------------------
BULK INSERT sales
FROM 'C:\Users\imanc\OneDrive\Documents\B2B project\clean\sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

/* ===============================
   CLEAN ORPHAN SALES ROWS FIRST
   =============================== */

-- Customers
DELETE s
FROM sales s
LEFT JOIN customers c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Products
DELETE s
FROM sales s
LEFT JOIN products p
    ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Stores FIXED COLUMN NAME
DELETE s
FROM sales s
LEFT JOIN stores st
    ON s.store_id = st.Store_ID
WHERE st.Store_ID IS NULL;


/* ===============================
   NOW ADD FOREIGN KEYS
   =============================== */

ALTER TABLE sales
ADD CONSTRAINT fk_sales_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE sales
ADD CONSTRAINT fk_sales_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE sales
ADD CONSTRAINT fk_sales_store
FOREIGN KEY (store_id)
REFERENCES stores(Store_ID);

/* ===================================
    DATA LOAD VALIDATION CHECKS
   =================================== */

-- Row counts
SELECT 'Customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Stores', COUNT(*) FROM stores
UNION ALL
SELECT 'Sales', COUNT(*) FROM sales;

-- ==========================================================
--  E-COMMERCE BUSINESS PERFORMANCE & RISK ANALYSIS 
-- ==========================================================

-- MAIN EDA QUESTION:
-- “Which products, customers, stores, and regions truly drive
--  profitable growth — and where are we leaking revenue or risk?”
-- ==========================================================

-- ===================================
--  OVERALL BUSINESS HEALTH
-- ===================================

-- 1. What is total revenue, total profit, and profit margin?
SELECT 
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)/SUM(revenue)*100,2) AS profit_margin_pct
FROM sales;

-- 2. How many orders were placed each year?
SELECT YEAR(order_date) AS year, COUNT(DISTINCT order_id) AS total_orders
FROM sales
GROUP BY YEAR(order_date);

-- 3. Is revenue growing or declining YoY?
SELECT 
    YEAR(order_date) AS year,
    SUM(revenue) AS revenue
FROM sales
GROUP BY YEAR(order_date)
ORDER BY year;

-- 4. What is the average order value (AOV)?
SELECT ROUND(SUM(revenue)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM sales;

-- 5. How much revenue is lost due to discounts?
SELECT SUM(unit_price * quantity * discount) AS discount_loss
FROM sales;

-- ==============================
-- TIME-BASED PERFORMANCE
-- ==============================

-- 6. Monthly revenue and profit trend
SELECT
    FORMAT(order_date, 'yyyy-MM') AS [month],
    SUM(revenue) AS revenue,
    SUM(profit)  AS profit
FROM sales
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY [month];
 
-- 7. Which months generate peak revenue?
SELECT 
    MONTH(order_date) AS month,
    SUM(revenue) AS revenue
FROM sales
GROUP BY MONTH(order_date)
ORDER BY revenue DESC;

-- 8. Revenue volatility by year
SELECT
    YEAR(order_date) AS [year],
    STDEV(revenue)   AS revenue_volatility
FROM sales
GROUP BY YEAR(order_date)
ORDER BY [year];

-- 9. Order cancellations & returns rate
SELECT 
    order_status,
    COUNT(*) AS orders
FROM sales
GROUP BY order_status;

-- 10. Profitability trend over time
SELECT
    FORMAT(order_date, 'yyyy-MM') AS [month],
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2) AS margin_pct
FROM sales
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY [month];


-- ====================================
-- PRODUCT PERFORMANCE & RISK
-- ====================================

-- 11. Top 10 products by revenue
SELECT TOP 10 product_id, SUM(revenue) AS revenue
FROM sales
GROUP BY product_id
ORDER BY revenue DESC;

-- 12. Bottom 10 products by profit
SELECT top 10 product_id, SUM(profit) AS profit
FROM sales
GROUP BY product_id
ORDER BY profit ASC


-- 13. Which products are loss-making overall?
SELECT product_id, SUM(profit) AS total_profit
FROM sales
GROUP BY product_id
HAVING SUM(profit) < 0;

-- 14. Revenue vs profit mismatch products
SELECT product_id,
       SUM(revenue) AS revenue,
       SUM(profit) AS profit
FROM sales
GROUP BY product_id
HAVING SUM(revenue) > 100000 AND SUM(profit) < 0;

-- 15. Pareto analysis: % of revenue from top 20% products
WITH product_rev AS (
    SELECT product_id, SUM(revenue) AS revenue
    FROM sales
    GROUP BY product_id
), ranked AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY revenue DESC) AS bucket
    FROM product_rev
)
SELECT bucket, SUM(revenue) AS revenue
FROM ranked
GROUP BY bucket;

-- ===============================
-- CUSTOMER ANALYTICS
-- ===============================

-- 16. Revenue by customer segment
SELECT c.segment, SUM(s.revenue) AS revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.segment;

-- 17. Profitability by customer segment
SELECT c.segment, SUM(s.profit) AS profit
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.segment;

-- 18. Top 10 customers by lifetime value
SELECT top 10 customer_id, SUM(revenue) AS lifetime_value
FROM sales
GROUP BY customer_id
ORDER BY lifetime_value DESC;

-- 19. Customers generating losses
SELECT customer_id, SUM(profit) AS profit
FROM sales
GROUP BY customer_id
HAVING sum(profit) < 0;

-- 20. Average discount by customer segment
SELECT c.segment, AVG(s.discount) AS avg_discount
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.segment;

-- ===================================
-- STORE & REGIONAL PERFORMANCE
-- ===================================

-- 21. Revenue by region
SELECT st.region, SUM(s.revenue) AS revenue
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.region;

-- 22. Profit by region
SELECT st.region, SUM(s.profit) AS profit
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.region;

-- 23. Top 5 stores by revenue
SELECT top 5 store_id, SUM(revenue) AS revenue
FROM sales
GROUP BY store_id
ORDER BY SUM(revenue) DESC;

-- 24. Stores with negative profit
SELECT store_id, SUM(profit) AS profit
FROM sales
GROUP BY store_id
HAVING SUM(profit) < 0;

-- 25. Revenue concentration risk (top stores)
WITH store_rev AS (
    SELECT
        store_id,
        SUM(revenue) AS revenue
    FROM sales
    GROUP BY store_id
)
SELECT
    TOP 1
    CAST(revenue * 100.0 /
         (SELECT SUM(revenue) FROM store_rev) AS DECIMAL(5,2)
    ) AS top_store_share
FROM store_rev
ORDER BY revenue DESC;


-- =====================================
-- PRICING, COST & DISCOUNT ABUSE
-- =====================================

-- 26. Average selling price vs list price
SELECT AVG(unit_price) AS avg_sell_price
FROM sales;

-- 27. Products freuently sold below cost
SELECT product_id, COUNT(*) AS loss_orders
FROM sales
WHERE revenue < cost * quantity
GROUP BY product_id;

-- 28. Discount impact on profit
SELECT 
    CASE 
        WHEN discount > 0 THEN 'Discounted' 
        ELSE 'Full Price' 
    END AS [pricing_type],
    SUM(profit) AS profit
FROM sales
GROUP BY 
    CASE 
        WHEN discount > 0 THEN 'Discounted' 
        ELSE 'Full Price' 
    END
ORDER BY [pricing_type];


-- 29. High discount, low profit orders
SELECT *
FROM sales
WHERE discount >= 0.3 AND profit < 0;

-- 30. Correlation proxy: discount bucket vs margin
SELECT 
    CASE 
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.1 THEN 'Low'
        WHEN discount <= 0.3 THEN 'Medium'
        ELSE 'High'
    END AS discount_bucket,
    ROUND(SUM(profit)/SUM(revenue)*100,2) AS margin
FROM sales
GROUP BY
	CASE 
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.1 THEN 'Low'
        WHEN discount <= 0.3 THEN 'Medium'
        ELSE 'High'
    END

-- =====================================
-- OPERATIONAL & RISK ANALYSIS
-- =====================================

-- 31. Cancelled & returned revenue impact
SELECT order_status, SUM(revenue) AS revenue
FROM sales
GROUP BY order_status;

-- 32. Inactive stores still generating sales
SELECT DISTINCT s.store_id
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE st.store_status = 'Inactive';

-- 33. Products discontinued but still selling
SELECT DISTINCT s.product_id
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE p.product_status = 'Discontinued';

-- 34. Customer churn proxy (inactive customers ordering)
SELECT DISTINCT s.customer_id
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
WHERE c.status = 'Inactive';

-- 35. Stores with abnormal profit volatility
SELECT store_id, STDEV(profit) AS profit_volatility
FROM sales
GROUP BY store_id
ORDER BY profit_volatility DESC;

-- =============================================
-- 8ADVANCED WINDOW & RANKING ANALYTICS
-- =============================================

-- 36. Rank products by profit within category
WITH product_profit AS (
    SELECT 
        s.product_id,
        p.category,
        SUM(s.profit) AS total_profit
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY s.product_id, p.category
)
SELECT
    product_id,
    category,
    total_profit,
    RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS rank_in_category
FROM product_profit
ORDER BY category, rank_in_category;


-- 37. Cumulative revenue contribution
SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM sales;

-- 38. Running monthly profit
WITH monthly_profit AS (
    SELECT
        YEAR(order_date) AS yr,
        MONTH(order_date) AS mo,
        SUM(profit) AS monthly_profit
    FROM sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    CONCAT(yr, '-', RIGHT('0' + CAST(mo AS VARCHAR(2)), 2)) AS [month],
    SUM(monthly_profit) OVER (ORDER BY yr, mo ROWS UNBOUNDED PRECEDING) AS running_profit
FROM monthly_profit
ORDER BY yr, mo;

-- 39. Customer purchase freuency ranking
SELECT customer_id,
       COUNT(order_id) AS orders,
       DENSE_RANK() OVER (ORDER BY COUNT(order_id) DESC) AS freuency_rank
FROM sales
GROUP BY customer_id;

-- 40. Store performance percentile
SELECT store_id,
       PERCENT_RANK() OVER (ORDER BY SUM(revenue)) AS revenue_percentile
FROM sales
GROUP BY store_id;

-- ===================================
-- STRATEGIC DECISION SUPPORT
-- ===================================

-- 41. Which regions should be expanded?
SELECT region, SUM(profit) AS profit
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY region
HAVING sum(profit) > 0;

-- 42. Which products should be discontinued?
SELECT product_id, SUM(profit) AS profit
FROM sales
GROUP BY product_id
HAVING sum(profit) < 0;

-- 43. Which customer segment is most price sensitive?
SELECT c.segment, AVG(discount) AS avg_discount
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.segment;

-- 44. Best region-category combinations
SELECT st.region, p.category, SUM(s.profit) AS profit
FROM sales s
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id
GROUP BY st.region, p.category
ORDER BY profit DESC;

-- 45. Worst performing store-product combinations
SELECT top 10 store_id, product_id, SUM(profit) AS profit
FROM sales
GROUP BY store_id, product_id
ORDER BY profit ASC;

-- ===================================
--  FINAL EXECUTIVE QUESTIONS
-- ===================================

-- 46. What % of revenue comes from top 10 customers?
WITH cust_rev AS (
    SELECT customer_id, SUM(revenue) AS revenue
    FROM sales
    GROUP BY customer_id
)
SELECT top 10 (revenue) / (SELECT SUM(revenue) FROM cust_rev) * 100 AS top_customer_share
FROM cust_rev
ORDER BY revenue DESC

-- 47. Are high-volume orders profitable?
SELECT 
    CASE WHEN quantity >= 5 THEN 'High Volume' ELSE 'Low Volume' END AS volume_type,
    SUM(profit) AS profit
FROM sales
GROUP BY CASE WHEN quantity >= 5 THEN 'High Volume' ELSE 'Low Volume' END;

-- 48. Margin by order status
SELECT order_status, ROUND(SUM(profit)/SUM(revenue)*100,2) AS margin
FROM sales
GROUP BY order_status;

-- 49. Store age vs performance
SELECT 
    YEAR(GETDATE()) - YEAR(open_date) AS store_age,
    SUM(s.revenue) AS revenue
FROM stores st
JOIN sales s ON st.Store_ID = s.store_id
GROUP BY YEAR(GETDATE()) - YEAR(open_date)
ORDER BY store_age;

-- 50. Products with extreme discount dependence
SELECT product_id, AVG(discount) AS avg_discount
FROM sales
GROUP BY product_id
ORDER BY avg_discount DESC;

-- 51. Revenue per customer by region
SELECT st.region, SUM(s.revenue)/COUNT(DISTINCT s.customer_id) AS revenue_per_customer
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.region;

-- 52. Profit per order trend
SELECT YEAR(order_date) AS [year], AVG(profit) AS avg_profit
FROM sales
GROUP BY YEAR(order_date);

-- 53. Orders with abnormal profitability
SELECT *
FROM sales
WHERE profit > (SELECT AVG(profit)+3*STDEV(profit) FROM sales);

-- 54. Identify potential fraud / pricing errors
SELECT *
FROM sales
WHERE discount > 0.5 OR revenue = 0;

-- 55. Final executive KPI snapshot
SELECT 
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT product_id) AS products,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit
FROM sales;
