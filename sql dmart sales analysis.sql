-- DATABASE CREATION
CREATE DATABASE IF NOT EXISTS DmartSales;

-- SELECT THE DATABASE
USE DmartSales;

-- TABLE CREATION
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(20) NOT NULL PRIMARY KEY,
    branch VARCHAR(10) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,3) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4),
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(20),
    cogs DECIMAL(10,2),
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4),
    rating FLOAT(2,1)
);

-- ----------------------------------------------------------------
-- FEATURE ENGINEERING
-- ----------------------------------------------------------------

-- TIME OF SALE
ALTER TABLE sales ADD COLUMN time_of_sale VARCHAR(20);

UPDATE sales 
SET time_of_sale = CASE
    WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'morning'
    WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'afternoon'
    ELSE 'evening'
END;

-- DAY NAME
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales SET day_name = DAYNAME(`date`);

-- MONTH NAME
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales SET month_name = MONTHNAME(`date`);

-- ----------------------------------------------------------------
-- ANALYSIS QUERIES
-- ----------------------------------------------------------------

-- 1. Unique Cities
SELECT DISTINCT city FROM sales;

-- 2. Branches in Each City
SELECT DISTINCT branch, city FROM sales;

-- 3. Unique Product Lines
SELECT COUNT(DISTINCT product_line) AS unique_product_lines FROM sales;

-- 4. Most Common Payment Method
SELECT payment_method, COUNT(*) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1;

-- 5. Most Selling Product Line
SELECT product_line, COUNT(*) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC
LIMIT 1;

-- 6. Total Revenue by Month
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 7. Month with Highest COGS
SELECT month_name AS month, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- 8. Product Line with Highest Revenue
SELECT product_line, SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- 9. City with Highest Revenue
SELECT city, SUM(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- 10. Product Line with Highest VAT
SELECT product_line, SUM(VAT) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 11. Tag Product Lines as "Good" or "Bad" based on Average Quantity
SELECT 
    product_line,
    AVG(quantity) AS avg_quantity,
    CASE 
        WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN 'Good'
        ELSE 'Bad'
    END AS sales_performance
FROM sales
GROUP BY product_line;

-- 12. Branches That Sold More Than Average Quantity
SELECT branch, SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING total_quantity > (SELECT AVG(quantity) FROM sales);

-- 13. Most Common Product Line by Gender
SELECT gender, product_line, COUNT(*) AS count
FROM sales
GROUP BY gender, product_line
ORDER BY count DESC;

-- 14. Average Rating of Each Product Line
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;
