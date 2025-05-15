CREATE DATABASE IF NOT EXISTS DmartSales ;


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
payment_method VARCHAR(10),
cogs DECIMAL(10,2),
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12,4),
rating FLOAT(2,1)
);

-- ---------------------------------------------------------------
-- ---------------FEATURE ENGINEERING-----------------------------

-- TIME OF SALE --


SELECT 
     time,
     (CASE
          WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "morning"
		  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "afternoon"
          ELSE "evening"     
      END
     ) AS time_of_sale
FROM sales;
 
ALTER TABLE sales add column time_of_sale VARCHAR(20);

UPDATE sales 
      SET time_of_sale = 
      (
      CASE
          WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "morning"
		  WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "afternoon"
          ELSE "evening"     
      END
      );
      
-- ------------------------------------------------------------------
-- ------------------day_name---------------------------------------

SELECT 
	DATE,DAYNAME(`date`) 
FROM sales

ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales 
SET day_name = DAYNAME(`date`) 

-- ----------------------------------------------------------------
-- ------------------MONTH_NAME------------------------------------

SELECT 
    DATE,MONTHNAME(DATE)
FROM SALES;

ALTER TABLE sales 
ADD COLUMN MONTH_NAME VARCHAR(10)

UPDATE sales 
set month_name = MONTHNAME(`DATE`)

-- -------------------------------------------------------------------
-- -------------------"GENERIC"---------------------------------------


-- HOW MANY UNIQUE CITIES DOES THE DATA HAVE ?


SELECT 
     DISTINCT city 
FROM sales;

-- IN WHICH CITY IN EACH BRANCH



-- ----------------------------PRODUCT----------------------------------------

-- How many unique product lines does the data have?

SELECT
     COUNT(DISTINCT product_line) 
FROM sales;
\
-- What is the most common payment method?

SELECT 
     payment_method , count(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY COUNT DESC limit 1

-- What is the most selling product line?

SELECT 
     product_line, count(product_line) AS count
FROM sales
GROUP BY product_line
ORDER BY COUNT DESC limit 1

-- What is the total revenue by month?

SELECT 
     month_name,sum(total) as total 
FROM sales 
GROUP BY month_name 
ORDER BY total DESC

-- Which month had the largest COGS?

SELECT 
     month_name AS month , sum(cogs) 
FROM SALES 
GROUP BY month_name
ORDER BY SUM(cogs) DESC

-- What product line had the largest revenue?



-- What is the city with the largest revenue?

SELECT 
    city,SUM(TOTAL) AS revenue 
FROM sales 
GROUP BY city 
ORDER BY revenue DESC 

-- What product line had the largest VAT?

SELECT 
     product_line,SUM(vat) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT 
     AVG(quantity) AS avg_qnty  
FROM sales 

SELECT 
     product_line,(
     CASE
     WHEN AVG(quantity)<5.5 THEN "good"
     ELSE "bad"
     END
     ) AS avg_sales   
FROM sales
GROUP BY product_line

-- Which branch sold more products than average product sold?

SELECT 
     branch,SUM(quantity) as qnty
FROM sales 
GROUP BY branch 
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?

SELECT 
    product_line, gender ,count(gender) 
FROM sales 
GROUP BY gender,product_line 
ORDER BY count(gender) DESC

-- What is the average rating of each product line?

SELECT product_line,ROUND(avg(rating),2) AS avg_rating FROM sales GROUP BY product_line ORDER BY avg_rating desc



     
     
     
     




     





        
     



     

