-- Chapter 13: Guided In-Class OLAP Practice
-- CSCI 480 / CIS 680
-- Complete the TODO sections. All queries use the existing SALECO data.
SET search_path TO ch13_saleco, public;

-- Exercise 1 (8 min): Revenue by product category, highest first.
-- TODO: Replace the placeholders with the correct SQL expressions.
-- SELECT p.p_category, SUM( /* TODO: revenue expression */ ) AS total_revenue
-- FROM dwdaysalesfact f
-- JOIN dwproduct p ON /* TODO: join condition */
-- GROUP BY /* TODO */
-- ORDER BY total_revenue DESC;

-- Exercise 2 (10 min): Revenue by category and product, with category subtotals and grand total.
-- TODO: Complete the ROLLUP and revenue calculation.
-- SELECT p.p_category, f.p_code,
--        SUM( /* TODO */ ) AS total_revenue
-- FROM dwdaysalesfact f
-- JOIN dwproduct p ON f.p_code = p.p_code
-- GROUP BY ROLLUP ( /* TODO: category first, product second */ )
-- ORDER BY p.p_category NULLS LAST, f.p_code NULLS LAST;

-- Exercise 3 (10 min): CUBE revenue by month and category.
-- TODO: Add both joins, the aggregate expression, and CUBE dimensions.
-- SELECT t.tm_month, p.p_category,
--        SUM( /* TODO */ ) AS total_revenue
-- FROM dwdaysalesfact f
-- JOIN dwtime t ON /* TODO */
-- JOIN dwproduct p ON /* TODO */
-- GROUP BY CUBE ( /* TODO */ )
-- ORDER BY t.tm_month NULLS LAST, p.p_category NULLS LAST;

-- Exercise 4 (12 min): Only month totals, category totals, and grand total.
-- TODO: Use GROUPING SETS; exclude the (month, category) detail grouping.
-- SELECT t.tm_month, p.p_category,
--        SUM(f.sale_units * f.sale_price) AS total_revenue
-- FROM dwdaysalesfact f
-- JOIN dwtime t ON f.tm_id = t.tm_id
-- JOIN dwproduct p ON f.p_code = p.p_code
-- GROUP BY GROUPING SETS ( /* TODO: month, category, grand total */ )
-- ORDER BY t.tm_month NULLS LAST, p.p_category NULLS LAST;

-- Exercise 5 (15 min): Create, query, and refresh a materialized view.
-- TODO: Uncomment and complete each statement.
-- DROP MATERIALIZED VIEW IF EXISTS mv_class_category_revenue;
-- CREATE MATERIALIZED VIEW mv_class_category_revenue AS
-- SELECT p.p_category,
--        SUM( /* TODO */ ) AS total_revenue
-- FROM dwdaysalesfact f
-- JOIN dwproduct p ON f.p_code = p.p_code
-- GROUP BY /* TODO */;
-- SELECT * FROM mv_class_category_revenue ORDER BY p_category;
-- REFRESH MATERIALIZED VIEW mv_class_category_revenue;
-- SELECT * FROM mv_class_category_revenue ORDER BY p_category;

-- Exercise 6 (10 min): Respond in SQL comments below.
-- 1. Why does ROLLUP column order matter?
-- Answer:
-- 2. Which grouping combinations does CUBE(A, B) generate?
-- Answer:
-- 3. When is GROUPING SETS preferable to CUBE?
-- Answer:
-- 4. How does a materialized view differ from an ordinary view?
-- Answer:
