-- Chapter 13: Data Warehousing and OLAP
-- PostgreSQL Materialized Views Exercises (Problems 17-20)
-- STUDENT TEMPLATE: Complete the exercises below.
-- Do not copy the practice examples directly; they use different data.

SET search_path TO ch13_saleco, public;

-- Problem 17: Create a materialized view named monthly_category_sales.
-- Store total sales revenue by month and product category.
-- Relevant tables: dwdaysalesfact, dwtime, dwproduct.
-- Hint: Join the fact table to the dimensions, then GROUP BY month/category.
-- Write your CREATE MATERIALIZED VIEW statement below.

-- YOUR SQL HERE

-- Verify the stored results with a SELECT query.
-- YOUR SQL HERE


-- Problem 18: Find the highest-revenue product category for each month.
-- Query monthly_category_sales, NOT the base fact table.
-- Hint: Consider ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...).
-- Include a short comment explaining why precomputed aggregates can help.

-- YOUR SQL HERE


-- Problem 19: Demonstrate that a materialized view does not update automatically.
-- Requirements:
--   1. BEGIN a transaction.
--   2. Insert one valid new fact record using existing dimension keys.
--      The (tm_id, cus_code, p_code) combination must be unused.
--   3. Compare the changed base-table aggregate with the stored view.
--   4. REFRESH MATERIALIZED VIEW monthly_category_sales.
--   5. Compare again and explain the difference.
--   6. ROLLBACK to avoid permanently modifying the dataset.
-- IMPORTANT: Keep all temporary changes inside the transaction.

-- YOUR SQL HERE


-- Problem 20: Create a regular view named monthly_category_view.
-- Use the same monthly category revenue aggregation as Problem 17.
-- Compare SELECT results and EXPLAIN ANALYZE plans for both view types.
-- Explain freshness, storage, refresh requirements, and performance limits.
-- Hint: EXPLAIN ANALYZE SELECT ... FROM view_name;

-- YOUR SQL HERE
