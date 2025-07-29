-- CREATE DATABASE AND USE IT
CREATE DATABASE IF NOT EXISTS DmartSales;
USE DmartSales;

-- CREATE SALES TABLE
CREATE TABLE IF NOT EXISTS sales(
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

-- ------------------ FEATURE ENGINEERING ------------------

-- 1.Profit Margin Category (Low, Medium, High)
ALTER TABLE sales ADD COLUMN margin_category VARCHAR(10);

UPDATE sales
SET margin_category = CASE
                         WHEN gross_margin_pct < 0.2 THEN 'Low'
                         WHEN gross_margin_pct BETWEEN 0.2 AND 0.4 THEN 'Medium'
                         ELSE 'High'
                      END;

-- 2. TIME OF SALE (Morning, Afternoon, Evening)
ALTER TABLE sales ADD COLUMN time_of_sale VARCHAR(20);

UPDATE sales
SET time_of_sale = CASE
    WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN `time` BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
END;

-- 3. DAY NAME OF SALE
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(`date`);

-- 4. MONTH NAME OF SALE
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(`date`);

-- ------------------ BASIC EXPLORATION ------------------

-- 1. Unique Cities
SELECT DISTINCT city FROM sales;

-- 2. Number of unique product lines
SELECT COUNT(DISTINCT product_line) AS unique_product_lines FROM sales;

-- 3. Most common payment method
SELECT payment_method, COUNT(*) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1;

-- 4. Most selling product line
SELECT product_line, COUNT(*) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC
LIMIT 1;

-- 5. Total revenue by month
SELECT month_name, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 6. Month with largest COGS
SELECT month_name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- 7. City with largest revenue
SELECT city, SUM(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- 8. Product line with largest VAT
SELECT product_line, SUM(VAT) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 9. Product line performance (Good if sales > average quantity)
SELECT product_line,
       CASE 
            WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN 'Good'
            ELSE 'Bad'
       END AS performance
FROM sales
GROUP BY product_line;

-- 10. Branches that sold more than average quantity
SELECT branch, SUM(quantity) AS total_qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. Most common product line by gender
SELECT gender, product_line, COUNT(*) AS count
FROM sales
GROUP BY gender, product_line
ORDER BY count DESC;

-- 12. Average rating by product line
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

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

-- 15.Exclude branches with low sales (< 500 quantity sold)
SELECT branch, SUM(quantity) AS total_qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) >= 500;

-- ---------------- Descriptive Statistics--------------------

-- 1. Minimum and Maximum Date
SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM sales;

-- 2. Total sales (Revenue)
SELECT SUM(total) AS total_revenue FROM sales;

-- 3. Average bill amount
SELECT ROUND(AVG(total),2) AS avg_bill_amount FROM sales;

-- 4. Maximum and Minimum bill amount
SELECT MAX(total) AS max_bill, MIN(total) AS min_bill FROM sales;

-- 5. Average quantity per transaction
SELECT ROUND(AVG(quantity),2) AS avg_quantity FROM sales;

-- 6. Total transactions
SELECT COUNT(invoice_id) AS total_transactions FROM sales;

