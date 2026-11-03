-- Chapter 13: Data Warehousing and OLAP
-- PostgreSQL ROLLUP Exercises — Student Template
-- Problems 5–11
--
-- Instructions:
-- 1. Load ch13_saleco_postgresql_setup.sql before starting.
-- 2. Write a complete PostgreSQL SELECT statement for each problem.
-- 3. Use ROLLUP to produce the requested subtotals and grand totals.
-- 4. End every SQL statement with a semicolon.
-- 5. Run and inspect each query; explain the meaning of subtotal rows.
--
-- Useful schema reference:
--   dwdaysalesfact(tm_id, cus_code, p_code, sale_units, sale_price)
--   dwtime(tm_id, tm_year, tm_month, tm_day, tm_qtr)
--   dwproduct(p_code, p_descript, p_category, v_code)
--   dwcustomer(cus_code, cus_lname, cus_fname, cus_initial, cus_state, reg_id)
--   dwregion(reg_id, reg_name)
--
-- Revenue per sales record = sale_units * sale_price.
-- COUNT(*) counts sales records, not units sold.

SET search_path TO ch13_saleco, public;

-- Problem 5
-- Report total sales by customer and product.
-- Include a subtotal for each customer and a grand total.
-- Hint: Both grouping columns are available in the fact table.

-- Write your SQL query below:


-- Problem 6
-- Report total sales by customer, month, and product.
-- Include customer-month subtotals, customer subtotals, and a grand total.
-- Hint: Find the table containing tm_month. Consider grouping order.

-- Write your SQL query below:


-- Problem 7
-- Report total sales by region and customer.
-- Include region subtotals and a grand total.
-- Hint: Trace the relationship from sales to customer to region.

-- Write your SQL query below:


-- Problem 8
-- Report total sales by month and product category.
-- Include monthly subtotals and a grand total.
-- Hint: Which tables supply the time and product-category attributes?

-- Write your SQL query below:


-- Problem 9
-- Report the number of sales records and total sales by month.
-- Include a grand total across all months.
-- Hint: You need two different aggregate functions.

-- Write your SQL query below:


-- Problem 10
-- Report the number of sales records and total sales by month and
-- product category. Include monthly subtotals and a grand total.
-- Hint: Build on the ideas from Problems 8 and 9.

-- Write your SQL query below:


-- Problem 11
-- Report the number of sales records and total sales by month,
-- product category, and product. Include category subtotals within
-- each month, monthly subtotals, and a grand total.
-- Hint: Determine the grouping hierarchy before writing the query.

-- Write your SQL query below:


-- Reflection (answer separately or as SQL comments):
-- A. What distinguishes a detail row, subtotal row, and grand-total row?
-- B. Why does the order of expressions inside ROLLUP matter?
-- C. How is COUNT(*) different from SUM(sale_units)?
