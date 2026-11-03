-- Chapter 13: Data Warehousing and OLAP
-- PostgreSQL CUBE Exercises (Student Template)
-- Problems 12–14
--
-- Instructions:
-- 1. Read cube_lab_instructions.md before beginning.
-- 2. Write your own SQL statements below each problem.
-- 3. End every SQL statement with a semicolon.
-- 4. Do not change the provided SALECO setup data.

SET search_path TO ch13_saleco, public;

-- Problem 12: Two-dimensional sales cube
-- Report total sales revenue by month and product category.
-- Include detail combinations, totals for each month, totals for each
-- category across all months, and the overall grand total.
-- Relevant tables: dwdaysalesfact, dwtime, dwproduct.
-- Hint: CUBE generates subtotals along both grouping dimensions.
-- Write your SQL below:



-- Problem 13: Compare ROLLUP and CUBE
-- Write TWO queries that summarize total sales revenue by month and
-- product category: one using ROLLUP and one using CUBE.
-- Compare the subtotal types and explain which subtotal rows CUBE adds.
-- Hint: Think about the grouping sets produced by each operator.
-- Query A (ROLLUP):



-- Query B (CUBE):



-- Written comparison (add SQL comments below):
--
--


-- Problem 14: Three-dimensional sales cube
-- Report total sales revenue by region, month, and product category.
-- Include all subtotal combinations and the grand total.
-- Relevant tables: dwdaysalesfact, dwcustomer, dwregion, dwtime, dwproduct.
-- Hint: Trace each foreign-key relationship before writing the joins.
-- Think about how many grouping sets a three-column CUBE produces.
-- Write your SQL below:



-- Reflection (answer in SQL comments):
-- 1. Why can subtotal rows contain NULL grouping values?
-- 2. How could GROUPING() distinguish subtotal NULLs from data NULLs?
-- 3. Why does CUBE generally produce more subtotal types than ROLLUP?
--
