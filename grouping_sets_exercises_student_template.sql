-- Chapter 13: Data Warehousing and OLAP
-- PostgreSQL GROUPING SETS Exercises (Problems 15-16)
-- STUDENT TEMPLATE: Complete the queries below.
-- Name:
-- Date:
--
-- Before running: initialize SALECO if necessary.
-- See grouping_sets_lab_instructions.md for setup and examples.

SET search_path TO ch13_saleco, public;

-- ============================================================
-- Problem 15: Selected month and product-category aggregations
-- ============================================================
-- Report total sales revenue for ONLY these grouping sets:
--   (month, product category)
--   (month)
--   (product category)
--   () -- grand total
--
-- Hints:
--   * Sales measures are in dwdaysalesfact.
--   * Find month in dwtime and category in dwproduct.
--   * SUM(sale_units * sale_price) calculates sales revenue.
--   * Specify the four grouping sets explicitly.
--
-- YOUR SQL:

-- TODO: Write your SELECT statement here.

-- Reflection: Why are the aggregation levels equivalent to
-- those of CUBE(month, product category)?
-- Answer:


-- ============================================================
-- Problem 16: Region and category totals without cross-groups
-- ============================================================
-- Report total sales revenue for ONLY these grouping sets:
--   (region)
--   (product category)
--   () -- grand total
--
-- Do NOT include (region, product category) detail groups.
--
-- Hints:
--   * Region is reached through dwcustomer and dwregion.
--   * Category is reached through dwproduct.
--   * Use GROUPING SETS to request only the needed levels.
--
-- YOUR SQL:

-- TODO: Write your SELECT statement here.

-- Reflection: Why would CUBE(region, product category)
-- produce more information than this report requires?
-- Answer:
