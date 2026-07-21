/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\Komal\Downloads\sql-data-analytics-project-main\sql-data-analytics-project-main\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\Komal\Downloads\sql-data-analytics-project-main\sql-data-analytics-project-main\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\Komal\Downloads\sql-data-analytics-project-main\sql-data-analytics-project-main\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

-- Explore All Objects in the Database 
SELECT* FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns in the Database 
SELECT* FROM INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'dim_customers'

-- Explore All Countries our customers come from 
SELECT DISTINCT country FROM gold.dim_customers

-- Explore All categories "The major Divisions"
SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products
Order by 1,2,3

-- Find the date of the first and last order
SELECT MIN(order_date) AS first_order_date , 
MAX(order_date) AS last_order_date,
DATEDIFF(month,Min(order_date) , MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Find the youngest and the oldest customer 
SELECT 
MIN(birthdate) ,
DATEDIFF(year,MIN(birthdate) , GETDATE()) AS oldest_age , 
MAX(birthdate) ,
DATEDIFF(year,MAX(birthdate), GETDATE()) AS youngest_age 
 FROM gold.dim_customers

 -- FInd the total sales 
 SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

 -- Find how many items are sold
  SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales

  -- Find the average selling price
  SELECT AVG(price) AS avg_price FROM  gold.fact_sales

  -- Find the total nummbers of orders 
  SELECT COUNT(order_number) AS total_orders FROM  gold.fact_sales
  SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

  -- Find the total number of products 
   SELECT COUNT(product_number) AS total_products FROM  gold.dim_products
  SELECT COUNT(DISTINCT product_number) AS total_products FROM gold.dim_products


  -- Find the total number of customers
  SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers
  
  -- Find the total number of customers that has placed an order
  SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales
  
  -- Generate a report that shows all key metrics of the business
  SELECT 'Total Sales' as measure_name ,SUM(sales_amount) AS measure_value FROM gold.fact_sales
  UNION ALL 
  SELECT 'Total quantity'  ,SUM(quantity)  FROM gold.fact_sales
  UNION ALL
  SELECT 'Average Price'  ,AVG(price)  FROM gold.fact_sales
  union all 
   SELECT 'Total Nr. Orders'  ,COUNT(DISTINCT order_number)  FROM gold.fact_sales
   union all
    SELECT 'Total Nr. Products'  ,COUNT( product_name) FROM gold.dim_products 
	union all 
	SELECT 'Total Nr. customers'  ,COUNT(customer_key) FROM gold.dim_customers

-- Find total customers by countries
SELECT country , COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country 
Order by total_customers DESC

-- Find total customers by gender
SELECT gender , COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
Order by total_customers DESC


-- Find total products by category
SELECT category , count(product_key) as total_products 
from gold.dim_products 
group by category
Order by total_products desc

-- What is the average costs in each category?
SELECT category , avg(cost) as avg_costs
from gold.dim_products 
group by category
Order by avg_costs desc

-- What is the total revenue generated for each category?
SELECT 
p.category,
sum(f.sales_amount) total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.category
order by total_revenue desc

-- Find total revenue is generated by each customer
select
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by 
c.customer_key,
c.first_name,
c.last_name
order by total_revenue desc


-- What is the distribution of sold items across countries?
select
c.country,
sum(f.quantity) as total_sold_items
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by 
c.country
order by total_sold_items desc

-- Which 5 products generate the highest revenue?
 SELECT top 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY
    p.product_name
ORDER BY
    total_revenue DESC

	-- Window Function
	select* from(
	SELECT
p.product_name,
    SUM(f.sales_amount) AS total_revenue,
	row_number() over(order by sum(f.sales_amount)desc) as rank_products
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY
    p.product_name)t 
	where rank_products <=5




	-- What are the 5 worst-performing products in terms of sales?
	SELECT top 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY
    p.product_name
ORDER BY
    total_revenue ASC

-- Find the top 10 customers who have generated the highest revenue 
select top 10
c.customer_key,
c.first_name,
c.last_name,
sum(f.sales_amount) as total_revenue 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by 
c.customer_key,
c.first_name,
c.last_name
order by total_revenue desc

-- The 3 customers with the fewest oeders placed
select top 3
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as total_revenue 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
group by 
c.customer_key,
c.first_name,
c.last_name
order by total_revenue 