# EDA-SSMS

SQL Exploratory Data Analysis on a Sales Data Warehouse

An EDA project on a star schema sales data warehouse using SQL Server. Covers database setup from CSV files, database exploration, and business questions from basic KPIs to product and customer ranking.

Project Structure

EDA.sql — Database setup, data loading, and exploratory analysis

What's Inside

1. Database and Table Setup
Drops and recreates a database called DataWarehouseAnalytics, then creates a schema called gold with three tables: dim_customers, dim_products, and fact_sales.

2. Data Loading
Each table is truncated and loaded from a CSV file using BULK INSERT. The file paths point to a local folder and need to be updated to match your own machine.

3. Database Exploration
Lists all tables, checks columns in dim_customers, and looks at distinct values like countries and product categories.

4. Date and Range Exploration
Finds first and last order dates, order date range, and youngest and oldest customers by birthdate.

5. Key Metrics
Total sales, total quantity sold, average price, total orders, total products, and total customers, plus a combined report using UNION ALL.

6. Magnitude Analysis
Breaks numbers down by group: customers by country, customers by gender, products by category, average cost by category, and revenue by category.

7. Ranking Analysis
Revenue per customer, sold items by country, top 5 products by revenue, 5 worst performing products, top 10 customers by revenue, and 3 customers with fewest orders. Includes a version of the top 5 products query using the ROW_NUMBER window function as an alternative to TOP.

