CREATE DATABASE IF NOT EXISTS WalmartSalesData;

CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR (30) PRIMARY KEY NOT NULL,
branch VARCHAR (30) NOT NULL,
city VARCHAR (20) NOT NULL,
customer_type VARCHAR (30) NOT NULL,
gender VARCHAR (10) NOT NULL,
product_line VARCHAR (100) NOT NULL,
unit_price DECIMAL (10,2) NOT NULL,
quantity INT NOT NULL,
vat FLOAT (8,4) NOT NULL,
total DECIMAL (10,2) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR (20) NOT NULL,
cogs DECIMAL (10,2) NOT NULL,
gross_margin_per FLOAT (8,4) NOT NULL,
gross_income DECIMAL (10,2) NOT NULL,
rating FLOAT (2,1)
);


-- --------------------------------------------------------------------------------------------------- --
-- ------------------------------------Feature Engineering-------------------------------------------- --

-- time_of_day

SELECT
    time,
    (CASE
     WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
     WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN 'Afternoon'
     ELSE 'Evening'
     END) AS time_of_day
FROM 
    sales;
    
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR (20);

UPDATE sales
SET time_of_day = (CASE
     WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
     WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN 'Afternoon'
     ELSE 'Evening'
     END);
     
-- day_name

SELECT
   date,
   DAYNAME(date)
FROM
    sales;
    
ALTER TABLE sales ADD COLUMN day_name VARCHAR (20);

UPDATE sales
SET day_name = DAYNAME(date);


-- month_name

SELECT
     date,
     MONTHNAME(date)
FROM
    sales;
    
ALTER TABLE sales ADD COLUMN month_name VARCHAR (20);

UPDATE sales
SET month_name =  MONTHNAME(date);
-- ----------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------- --
-- --------------------------------------------------Generic ------------------------------------------------------ --

-- How many unique cities does the data have?
SELECT
     DISTINCT city
FROM
     sales;
     
-- In which city is each branch?

SELECT
     DISTINCT branch
FROM
    sales;
    
SELECT
    DISTINCT city,branch
FROM
   sales;


-- --------------------------------------------------------------------------------------------------- --
-- ------------------------------------------Product Line--------------------------------------------- --

-- How many unique product lines does the data have?

SELECT
    COUNT(DISTINCT product_line)
FROM
    sales;
    

-- What is the most common payment method?

SELECT
    payment_method,
    COUNT(payment_method) as cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?

SELECT
    product_line,
    count(quantity) as cnt
FROM
  sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month?

SELECT
    month_name as month,
    SUM(total) as total_revenue
FROM
   sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?

SELECT
    month_name AS month,
    SUM(cogs) AS cogs
FROM
    sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?

SELECT
    product_line,
    SUM(total) AS revenue
FROM
   sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?

SELECT
    branch,
    city,
    SUM(total) as revenue
FROM
    sales
GROUP BY city,branch
ORDER BY revenue DESC;

-- What product line had the largest VAT?
SELECT
   product_line,
   AVG(vat) AS avg_vat
FROM
   sales
GROUP BY product_line
ORDER BY avg_vat DESC;

--  Which branch sold more products than average product sold?

SELECT
   branch,
   SUM(quantity) AS quantity
FROM
    sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?

SELECT
    gender,
    product_line,
    COUNT(gender) as total_cnt
FROM
   sales
GROUP BY gender,product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?

SELECT
  product_line,
  ROUND(AVG(rating), 2) AS avg_rating
FROM
  sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT
   product_line,
   SUM(total) AS total_sales,
   AVG(total) as avg_sales,
   (CASE
   WHEN SUM(total) > (SELECT AVG(total) FROM sales) THEN "Good"
   ELSE "Bad"
   END) AS Sales_Feedback
FROM
   sales
GROUP BY product_line
ORDER BY avg_sales;

-- ------------------------------------------------------------------------------------------------------
-- -------------------------------------------Sales------------------------------------------------------

-- Number of sales made in each time of the day per weekday

SELECT
   time_of_day,
   COUNT(*) AS total_sales
FROM
   sales
WHERE day_name = "Tuesday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
  customer_type,
  SUM(total) as total_revenue
FROM
	sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
   city,
   AVG(vat) as vat
FROM
   sales
GROUP BY city
ORDER BY vat DESC;

-- Which customer type pays the most in VAT?

SELECT
  customer_type,
  AVG(vat) as vat
FROM
   sales
GROUP BY customer_type
ORDER BY vat DESC;

-- ------------------------------------------------------------------------------------------------------
-- -----------------------------------------  Customer --------------------------------------------------

-- How many unique customer types does the data have?
SELECT
    DISTINCT customer_type
FROM
   sales;
   
-- How many unique payment methods does the data have?
SELECT
    DISTINCT payment_method
FROM
sales;

-- Which customer type buys the most?
SELECT
    customer_type,
    COUNT(customer_type) as type_count
FROM
   sales
GROUP BY customer_type
ORDER BY type_count DESC;

-- What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*) AS gender_cnt
FROM
   sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
    COUNT(*) AS gender_cnt
FROM
   sales
WHERE branch = "B"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT
    time_of_day,
    AVG(rating) AS rating_avg
FROM
  sales
GROUP BY time_of_day
ORDER BY rating_avg;

-- Which time of the day do customers give most ratings per branch?
SELECT
    time_of_day,
    AVG(rating) AS rating_avg
FROM
  sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY rating_avg;

-- Which day of the week has the best avg ratings?
SELECT
   day_name,
   AVG(rating) AS avg_rating
FROM
   sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
   day_name,
   AVG(rating) AS avg_rating
FROM
   sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- -----------------------------------------------------------------------------------------------------
-- ------------------------------------ Revenue And Profit Calculations --------------------------------

-- Calculate Net sales
SELECT
    total - vat AS Net_Sales
FROM
    sales;

-- Calculate Gross Profit and add the column of the same.
SELECT
   total - cogs AS Gross_profit
FROM
   Sales;

ALTER TABLE sales ADD COLUMN Gross_Profit INT;

UPDATE sales
SET Gross_Profit = total - cogs;

-- Calculate Gross Margin Percentage(the ratio of gross profit to total sales)
SELECT
    (Gross_profit / total) * 100 AS Gross_Margin_Per
FROM
   sales;

-- Calculate Total Revenue
SELECT
    SUM(total) AS Total_Revenue
FROM
   sales;

-- -------------------------------------------------------------------------------------------------------

