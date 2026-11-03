# Chapter 13 Lab: PostgreSQL GROUPING SETS

**Course:** CSCI 480 / CIS 680 — Advanced Databases  
**Database:** SALECO (`ch13_saleco`)  
**Exercises:** Problems 15–16  
**Prerequisite:** ROLLUP and CUBE exercises

## 1. Learning objectives

By the end of this lab, you should be able to:

1. Explain the differences among `GROUP BY`, `ROLLUP`, `CUBE`, and `GROUPING SETS`.
2. Choose exactly which subtotal levels a report needs.
3. Join a sales fact table to the relevant dimension tables.
4. Identify subtotal and grand-total rows using `GROUPING()`.
5. Verify that aggregated sales totals are consistent with the underlying data.

## 2. Open the PostgreSQL Codespace

1. Open https://github.com/orientchen/Advanced-Databases-OLAP.
2. Select **Code → Codespaces**, and open or create a Codespace.
3. Select **Terminal → New Terminal**.
4. From the Linux shell (`$`), connect to PostgreSQL:

```bash
PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
```

You should see the PostgreSQL prompt `objectdb=#`. To leave `psql`, type `\q`.

If the SALECO tables have not been loaded into this Codespace, run the following **once** at the PostgreSQL prompt:

```text
\i /workspaces/Advanced-Databases-OLAP/ch13_saleco_postgresql_setup.sql
```

**Caution:** The setup script recreates the exercise tables. Do not rerun it if you need to preserve changes to those tables.

Set the schema for this PostgreSQL session:

```sql
SET search_path TO ch13_saleco, public;
```

Verify that the sales fact table exists:

```sql
SELECT COUNT(*) FROM dwdaysalesfact;
```

The original dataset contains **36 sales records**. You can check the original total sales revenue with:

```sql
SELECT SUM(sale_units * sale_price) AS total_sales
FROM dwdaysalesfact;
```

The original dataset total is **2252.06**. These are database setup checks, **not answers to Problems 15–16**.

## 3. Tables and relationships

The data warehouse uses a sales fact table and descriptive dimension tables.

| Table | Useful columns | Purpose |
|---|---|---|
| `dwdaysalesfact` | `tm_id`, `cus_code`, `p_code`, `sale_units`, `sale_price` | Sales measures and dimension keys |
| `dwtime` | `tm_id`, `tm_month` | Month dimension |
| `dwproduct` | `p_code`, `p_category`, `v_code` | Product category dimension |
| `dwcustomer` | `cus_code`, `reg_id` | Customer and region relationship |
| `dwregion` | `reg_id`, `reg_name` | Region dimension |
| `dwvendor` | `v_code`, `v_state` | Vendor information for practice |

Useful relationships:

```text
dwdaysalesfact.tm_id    = dwtime.tm_id
dwdaysalesfact.p_code   = dwproduct.p_code
dwdaysalesfact.cus_code = dwcustomer.cus_code
dwcustomer.reg_id       = dwregion.reg_id
dwproduct.v_code        = dwvendor.v_code
```

A row's sales revenue is `sale_units * sale_price`. For total revenue over several rows, apply `SUM(...)`.

## 4. Why GROUPING SETS?

Ordinary `GROUP BY (A, B)` returns groups based on both columns. `ROLLUP(A, B)` generates `(A, B)`, `(A)`, and `()`. `CUBE(A, B)` generates `(A, B)`, `(A)`, `(B)`, and `()`.

`GROUPING SETS` allows you to specify only the grouping combinations needed for a report:

```sql
GROUP BY GROUPING SETS (
    (column_a, column_b),
    (column_a),
    ()
)
```

Here, `()` means the grand total. The example above describes the **syntax**, not a solution to the assigned problems.

### Practice example (not an assigned solution)

Suppose a report needs the number of products by vendor state, the number by product category, and the total number of products—but does **not** need every state/category combination:

```sql
SELECT
    v.v_state,
    p.p_category,
    COUNT(*) AS product_count
FROM dwproduct p
JOIN dwvendor v ON p.v_code = v.v_code
GROUP BY GROUPING SETS (
    (v.v_state),
    (p.p_category),
    ()
)
ORDER BY
    v.v_state NULLS LAST,
    p.p_category NULLS LAST;
```

Observe that this query uses `COUNT(*)` for **products**, not `SUM(...)` for **sales revenue**. Your assigned problems use sales data and require you to select different grouping combinations.

## 5. Understanding subtotal rows

When a column is omitted from a grouping set, PostgreSQL generally displays `NULL` for that column in the corresponding subtotal row. `GROUPING(column)` helps distinguish these subtotal markers from actual `NULL` data:

```sql
SELECT
    p.p_category,
    GROUPING(p.p_category) AS category_aggregated,
    COUNT(*) AS product_count
FROM dwproduct p
GROUP BY GROUPING SETS ((p.p_category), ());
```

- `GROUPING(column) = 0`: the column participates in this row's grouping.
- `GROUPING(column) = 1`: the column was omitted from this row's grouping.

You may include `GROUPING()` indicators in your solutions, but they are not required unless specified by your instructor.

## 6. Your assignments

Write your SQL in `grouping_sets_exercises_student_template.sql`. **Do not copy the practice example as your answer.**

### Problem 15 — Selected month and category subtotals

Write one query reporting sales revenue using **only** these grouping combinations:

- `(month, product category)`
- `(month)`
- `(product category)`
- `()` (grand total)

**Hints:**

1. Start with the sales fact table.
2. Identify which dimension tables supply the month and category.
3. Join on the corresponding keys.
4. Write the requested grouping combinations explicitly inside `GROUPING SETS`.
5. Consider whether these combinations are equivalent to a two-dimensional `CUBE`.

**Explain:** Why does this query produce the same aggregation levels as a two-dimensional CUBE, even though it uses different syntax?

### Problem 16 — A report with deliberately omitted combinations

Write one query reporting sales revenue using **only** these grouping combinations:

- `(region)`
- `(product category)`
- `()` (grand total)

**Do not include** `(region, product category)` detail groups.

**Hints:**

1. Trace the relationship from the sales fact table to region through customer.
2. Trace the relationship from the sales fact table to product category through product.
3. Specify exactly the three requested grouping sets.
4. Check that your query does not generate region/category combination rows.

**Explain:** Why would `CUBE(region, category)` return information that this report does not request?

## 7. Running and debugging

Save your SQL file using **Ctrl+S**. At the `objectdb=#` prompt, execute:

```text
\i /workspaces/Advanced-Databases-OLAP/grouping_sets_exercises_student_template.sql
```

You can also paste one completed statement at a time into `psql` to test it.

Common issues:

- **`relation does not exist`**: Run `SET search_path TO ch13_saleco, public;` in the current connection.
- **`column reference is ambiguous`**: Prefix shared column names with table aliases.
- **Incorrect totals**: Review the join conditions; missing joins can multiply rows.
- **Unexpected subtotals**: Review the grouping-set list and distinguish omitted grouping columns from data values.
- **`syntax error at or near ...`**: Check parentheses, commas, and terminating semicolons.

**Tip:** Each grouping set produces its own aggregate rows. Do not sum every subtotal and detail row together: that would double-count the same underlying sales.

## 8. Submission

Submit:

1. Your completed `grouping_sets_exercises_student_template.sql`, containing working queries for Problems 15 and 16.
2. Brief answers to the explanation question for each problem, either as SQL comments or in a separate document.

Before submitting, confirm that both statements execute, the requested grouping sets are present, and the unwanted grouping combinations are absent.

## 9. Reference

PostgreSQL 17 documentation: https://www.postgresql.org/docs/17/queries-table-expressions.html#QUERIES-GROUPING-SETS

**Next lab topic:** Materialized views and refreshing stored query results.
