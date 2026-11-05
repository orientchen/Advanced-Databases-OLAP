# Chapter 13 — Guided In-Class OLAP Practice

**CSCI 480 / CIS 680 | PostgreSQL | Approx. 65 minutes**

## Goal
Use one sales warehouse to move from ordinary aggregation to `ROLLUP`, `CUBE`, `GROUPING SETS`, and a materialized view. These are new guided practice questions, not replacements for the existing topic labs.

## Getting started
1. Open your existing Codespace for `Advanced-Databases-OLAP`.
2. Open **Terminal → New Terminal** and connect:
   ```bash
   PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
   ```
3. At the PostgreSQL prompt, enter:
   ```sql
   SET search_path TO ch13_saleco, public;
   SELECT COUNT(*) FROM dwdaysalesfact;
   ```
   Expect **36 rows**. If tables are missing, run `\i /workspaces/Advanced-Databases-OLAP/ch13_saleco_postgresql_setup.sql` once, then set the search path again. **Do not rerun setup if the tables already exist:** it resets sample data.
4. Open `chapter13_inclass_practice.sql`. Complete each `TODO` and run the queries one at a time, or run the entire file with `\i /workspaces/Advanced-Databases-OLAP/chapter13_inclass_practice.sql` after saving.

## Schema reminder
- `dwdaysalesfact(tm_id, cus_code, p_code, sale_units, sale_price)` — sales fact table
- `dwproduct(p_code, p_descript, p_category, v_code)` — product dimension
- `dwtime(tm_id, tm_year, tm_month, tm_day, tm_qtr)` — time dimension

Revenue per fact row is `sale_units * sale_price`. Use `SUM(...)` for total revenue. Finish SQL statements with semicolons.

## Exercise 1 — Ordinary aggregation 
**Question:** Find total sales revenue by product category, highest first. Show `p_category` and `total_revenue`.

**Hints:** Category is in `dwproduct`, but revenue is in `dwdaysalesfact`. Join on `p_code`; group by category. Fill in the missing pieces of the provided query.

**Check:** You should see four categories (`CAT1`–`CAT4`). Which category has the highest revenue?

## Exercise 2 — Hierarchical subtotals with ROLLUP 
**Question:** Starting from Exercise 1, show revenue by **category and product**, category subtotals, and the grand total.

**Hints:** Use `ROLLUP(p.p_category, f.p_code)` and `SUM(f.sale_units * f.sale_price)`. In what order are grouping expressions removed?

**Check:** Find a detail row, a category subtotal, and the grand total. Explain why `ROLLUP(f.p_code, p.p_category)` is not equivalent.

## Exercise 3 — All combinations with CUBE 
**Question:** Analyze sales revenue by **month and product category**. Include month-category totals, month-only subtotals, category-only subtotals, and the grand total.

**Hints:** Join the fact table to `dwtime` and `dwproduct`. Use `CUBE(t.tm_month, p.p_category)`.

**Check:** Which subtotal grouping appears in CUBE but not `ROLLUP(t.tm_month, p.p_category)`?

## Exercise 4 — Selected grouping sets 
**Question:** The manager only needs **revenue by month**, **revenue by category**, and the **overall total**. Do not return month-category detail combinations.

**Hints:** Reuse the joins from Exercise 3. Use `GROUPING SETS ((t.tm_month), (p.p_category), ())`.

**Check:** Why is `GROUPING SETS` more targeted than `CUBE` here? How many different grouping levels does your query request?

## Exercise 5 — Materialized view 
**Question:** Store total revenue by product category in a materialized view called `mv_class_category_revenue`. Query the view and then refresh it.

**Hints:** `CREATE MATERIALIZED VIEW ... AS SELECT ...`; query it with `SELECT * FROM ...`; refresh with `REFRESH MATERIALIZED VIEW ...`. Use `DROP MATERIALIZED VIEW IF EXISTS ...` first so the practice can be repeated.

**Check:** Why does the materialized view need a refresh when its source data changes? **Do not modify the sample fact table for this practice.**

## Exercise 6 — Interpret the results 
Answer briefly in SQL comments at the end of your file:
1. Why is the `ROLLUP` column order important?
2. What grouping combinations does `CUBE(A, B)` generate?
3. When would `GROUPING SETS` be preferable to `CUBE`?
4. What is the difference between an ordinary view and a materialized view?

## Submission
Save your completed `chapter13_inclass_practice.sql` file. Follow your instructor's directions for sharing or submitting it. The existing ROLLUP, CUBE, GROUPING SETS, and materialized-view labs remain separate.

## Troubleshooting
- `relation does not exist`: run `SET search_path TO ch13_saleco, public;` and verify setup.
- `column reference is ambiguous`: qualify columns with `f.`, `p.`, or `t.`.
- A blank grouping column in a subtotal row may indicate a dimension omitted by the aggregation; it does not necessarily mean the original data contains `NULL`.
- To distinguish subtotal `NULL` from source-data `NULL`, use `GROUPING(column)` (`1` means omitted, `0` means included).
- To exit `psql`, type `\q`.
