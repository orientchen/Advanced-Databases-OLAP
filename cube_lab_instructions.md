# Chapter 13 Lab: CUBE in PostgreSQL

**Repository:** `orientchen/Advanced-Databases-OLAP`  
**Student SQL file:** `cube_exercises_student_template.sql`  
**Exercises:** Problems 12–14  
**Prerequisite:** Complete or review the ROLLUP lab.

## Learning objectives

After this lab, you should be able to:

- Explain how `CUBE` differs from `ROLLUP`.
- Join a fact table to the dimensions needed for an OLAP report.
- Use `SUM()` with `CUBE` to generate detail rows, subtotals, and a grand total.
- Recognize grouping levels and explain subtotal rows.
- Use `GROUPING()` to identify values omitted by an aggregation level.

## 1. Start your Codespace

1. Open the **Advanced-Databases-OLAP** GitHub repository.
2. Choose **Code → Codespaces** and open or create a Codespace.
3. Open **Terminal → New Terminal** in VS Code.
4. Connect to PostgreSQL:

   ```bash
   PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
   ```

   A successful connection displays a prompt similar to `objectdb=>` or `objectdb=#`.

5. If the SALECO tables have not yet been loaded into **this Codespace**, execute the setup script at the PostgreSQL prompt:

   ```sql
   \i /workspaces/Advanced-Databases-OLAP/ch13_saleco_postgresql_setup.sql
   ```

   **Warning:** The setup script recreates the sample tables and resets their data. Do not rerun it after making changes you need to preserve.

6. Select the lab schema and inspect the tables:

   ```sql
   SET search_path TO ch13_saleco, public;
   \dt
   ```

## 2. Understand the SALECO schema

The central fact table is **`dwdaysalesfact`**:

| Column | Meaning |
|---|---|
| `tm_id` | Time dimension key |
| `cus_code` | Customer dimension key |
| `p_code` | Product dimension key |
| `sale_units` | Units sold in the record |
| `sale_price` | Price per unit |

Related dimension tables:

| Table | Useful columns | Relationship |
|---|---|---|
| `dwtime` | `tm_id`, `tm_month` | Fact `tm_id` → Time `tm_id` |
| `dwproduct` | `p_code`, `p_category` | Fact `p_code` → Product `p_code` |
| `dwcustomer` | `cus_code`, `reg_id` | Fact `cus_code` → Customer `cus_code` |
| `dwregion` | `reg_id`, `reg_name` | Customer `reg_id` → Region `reg_id` |

**Sales revenue** for one fact record is `sale_units * sale_price`. To calculate revenue for a group of records, use an aggregate function.

### Warm-up: Explore the dimensions

These queries are **not** solutions to Problems 12–14. Run them to see what values are available:

```sql
SET search_path TO ch13_saleco, public;

SELECT DISTINCT tm_month
FROM dwtime
ORDER BY tm_month;

SELECT DISTINCT p_category
FROM dwproduct
ORDER BY p_category;

SELECT reg_id, reg_name
FROM dwregion
ORDER BY reg_id;
```

## 3. Review GROUP BY and ROLLUP

A regular `GROUP BY` calculates one level of grouping. For example, this query counts products by vendor:

```sql
SELECT v_code, COUNT(*) AS product_count
FROM dwproduct
GROUP BY v_code
ORDER BY v_code;
```

`ROLLUP(a, b)` adds hierarchical grouping levels:

- `(a, b)` — detail groups
- `(a)` — subtotal for each `a`
- `()` — grand total

The **order** of `a` and `b` matters for `ROLLUP`.

## 4. Learn CUBE without solving the assignment

`CUBE(a, b)` generates every combination of the two grouping columns:

- `(a, b)` — detail groups
- `(a)` — totals for each `a`
- `(b)` — totals for each `b`
- `()` — grand total

Unlike `ROLLUP(a, b)`, it includes **totals for `b` across all values of `a`**.

### Practice example: Count products by vendor and category

This example uses the **product dimension only**, rather than sales revenue:

```sql
SELECT
    v_code,
    p_category,
    COUNT(*) AS product_count
FROM dwproduct
GROUP BY CUBE (v_code, p_category)
ORDER BY v_code NULLS LAST, p_category NULLS LAST;
```

Before running it, predict which subtotal rows you expect. After running it, locate:

1. A count for one vendor/category combination.
2. A vendor subtotal across categories.
3. A category subtotal across vendors.
4. The overall total.

**Important:** A blank grouping column in the output usually represents a dimension omitted at that subtotal level. A blank value does not mean that the original data necessarily contains `NULL`.

## 5. Identify subtotals using GROUPING()

`GROUPING(column)` returns `1` when that column was omitted at the current aggregation level and `0` when it participates in that grouping level.

Try the following **product-count** example:

```sql
SELECT
    v_code,
    p_category,
    GROUPING(v_code) AS vendor_grouped,
    GROUPING(p_category) AS category_grouped,
    COUNT(*) AS product_count
FROM dwproduct
GROUP BY CUBE (v_code, p_category)
ORDER BY v_code NULLS LAST, p_category NULLS LAST;
```

Use the two `GROUPING()` columns to identify the four grouping levels. You may use `GROUPING()` in your assignment if it makes your results easier to interpret, but it is not required unless your instructor specifies otherwise.

## 6. Complete the assigned exercises

Open `cube_exercises_student_template.sql`. Work through the problems in order.

### Problem 12 — Two-dimensional sales cube

**Goal:** Calculate sales revenue by month and product category, including subtotals for each dimension and a grand total.

Hints:

1. Start with the fact table, then determine which dimension tables provide month and category.
2. Use the relevant key columns to join those tables.
3. Use `SUM()` to aggregate revenue, not `COUNT(*)`.
4. Decide which two columns belong in `CUBE`.
5. Sort the output so detail rows and subtotal rows are easy to inspect.

### Problem 13 — Compare ROLLUP and CUBE

**Goal:** Write both forms of the sales summary and explain how their subtotal rows differ.

Hints:

1. Keep the tables, joins, and revenue expression the same in both queries.
2. Change only the grouping operator first.
3. Compare the grouping sets generated by `ROLLUP(a, b)` and `CUBE(a, b)`.
4. In SQL comments, identify the **additional subtotal type**, not merely the difference in the number of output rows.

### Problem 14 — Three-dimensional sales cube

**Goal:** Analyze sales by region, month, and product category, including all subtotal combinations.

Hints:

1. Region is not stored directly in the fact table. Find the path through the customer dimension.
2. Draw the join path before writing SQL.
3. A `CUBE` of *n* grouping columns defines `2^n` grouping sets. Some sets can contain several result rows.
4. Check that the grand total matches the revenue calculated from the fact table alone.

## 7. How to run your SQL file

Save your work with **Ctrl+S**. At the PostgreSQL prompt, run:

```sql
\i /workspaces/Advanced-Databases-OLAP/cube_exercises_student_template.sql
```

If a query fails, read the first `ERROR:` message and check the line number. Fix the SQL file, save it, and rerun. PostgreSQL generally continues processing later statements in a script after an error unless configured otherwise.

### Common problems

| Symptom | What to check |
|---|---|
| `relation ... does not exist` | Run `SET search_path TO ch13_saleco, public;` or check the database setup. |
| `column ... does not exist` | Check column spelling and which table alias owns the column. |
| `syntax error at or near ...` | Check commas, parentheses, and the final semicolon. |
| Unexpectedly high totals | Check whether a join duplicates fact rows. |
| Missing subtotals | Check whether you used `GROUP BY`, `ROLLUP`, or `CUBE`. |
| `(END)` appears in terminal | Press `q`, or reconnect with `-P pager=off`. |

## 8. Submission

Submit your completed `cube_exercises_student_template.sql` file. Include both queries for Problem 13 and your comparison as SQL comments. Your SQL should run in the provided SALECO database without modifying the source data.

**Do not submit screenshots instead of SQL unless your instructor requests them.**
