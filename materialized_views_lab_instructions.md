# Chapter 13 Lab — PostgreSQL Materialized Views

**Course:** CSCI 480 / CIS 680 — Advanced Databases  
**Database:** SALECO (`ch13_saleco` schema)  
**Platform:** PostgreSQL 17 in GitHub Codespaces  
**Exercises:** Problems 17–20

## 1. Learning objectives

After this lab, you should be able to:

1. Explain how a regular SQL view differs from a materialized view.
2. Create a materialized view that stores an aggregate query result.
3. Query a materialized view as though it were a table.
4. Demonstrate that changes to underlying tables do not automatically update an existing materialized view.
5. Refresh a materialized view and compare query execution plans using `EXPLAIN ANALYZE`.

**Academic work:** Write your own solutions in `materialized_views_exercises_student_template.sql`. The examples below demonstrate the syntax using different aggregations; they do not solve Problems 17–20.

## 2. Open your Codespace and connect

1. Open <https://github.com/orientchen/Advanced-Databases-OLAP>.
2. Select **Code → Codespaces** and open your Codespace.
3. Select **Terminal → New Terminal**.
4. From the Linux shell (`$`), connect to PostgreSQL:

```bash
PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
```

When you see `objectdb=#`, you can enter SQL and `psql` commands. To leave `psql`, type `\q`.

### Prepare the database

If you already loaded SALECO in this Codespace, do **not** rerun its setup script unnecessarily; doing so recreates the exercise tables and discards modifications.

If it is not yet loaded, at the `objectdb=#` prompt run:

```text
\i /workspaces/Advanced-Databases-OLAP/ch13_saleco_postgresql_setup.sql
```

Then set the schema search path:

```sql
SET search_path TO ch13_saleco, public;
```

Verify the original sample dataset:

```sql
SELECT COUNT(*) AS sales_rows FROM dwdaysalesfact;
SELECT SUM(sale_units * sale_price) AS sales_revenue FROM dwdaysalesfact;
```

For an unchanged dataset, the checks should report **36** rows and **2252.06** in sales revenue. If your earlier exercises modified the fact table, consult your instructor before resetting it.

## 3. Relevant SALECO tables

| Table | Relevant columns | Purpose |
|---|---|---|
| `dwdaysalesfact` | `tm_id`, `cus_code`, `p_code`, `sale_units`, `sale_price` | Sales fact records |
| `dwtime` | `tm_id`, `tm_year`, `tm_month`, `tm_day`, `tm_qtr` | Time dimension |
| `dwproduct` | `p_code`, `p_category`, `p_descript` | Product dimension |
| `dwcustomer` | `cus_code`, `reg_id` | Customer dimension |
| `dwregion` | `reg_id`, `reg_name` | Region dimension |

Useful joins:

```text
dwdaysalesfact.tm_id   = dwtime.tm_id
dwdaysalesfact.p_code  = dwproduct.p_code
dwdaysalesfact.cus_code = dwcustomer.cus_code
dwcustomer.reg_id      = dwregion.reg_id
```

Sales revenue for one fact record is `sale_units * sale_price`. Remember that `COUNT(*)` counts rows, not units sold.

## 4. Regular views versus materialized views

A **regular view** stores a query definition. When you query the view, PostgreSQL evaluates its underlying query against the current data.

A **materialized view** stores the result of a query. PostgreSQL can read those stored rows without recalculating the full source query each time, but changes to source tables are **not automatically reflected**. You must refresh the materialized view.

| Feature | Regular view | Materialized view |
|---|---|---|
| Stores a query definition | Yes | Yes |
| Stores the query result as rows | No | Yes |
| Reflects source-table changes on next query | Yes | No, until refresh |
| Can be queried with `SELECT` | Yes | Yes |
| Typical use | Reusable current-data query | Repeated reporting on a precomputed result |

### Practice example (not an assignment solution)

Create a materialized view that counts products by category:

```sql
CREATE MATERIALIZED VIEW practice_product_counts AS
SELECT
    p_category,
    COUNT(*) AS product_count
FROM dwproduct
GROUP BY p_category;
```

Query the stored results:

```sql
SELECT *
FROM practice_product_counts
ORDER BY p_category;
```

Refresh the stored results:

```sql
REFRESH MATERIALIZED VIEW practice_product_counts;
```

Remove the practice view when finished:

```sql
DROP MATERIALIZED VIEW IF EXISTS practice_product_counts;
```

**Do not use the practice view name for your assignment.** Problem 17 specifies a different materialized view and aggregation.

## 5. Important PostgreSQL commands

```sql
-- Create a regular view.
CREATE VIEW example_view AS
SELECT p_category, COUNT(*) AS product_count
FROM dwproduct
GROUP BY p_category;

-- Query it.
SELECT * FROM example_view;

-- Remove it.
DROP VIEW IF EXISTS example_view;
```

For a materialized view, use `CREATE MATERIALIZED VIEW`, `REFRESH MATERIALIZED VIEW`, and `DROP MATERIALIZED VIEW` instead. These are distinct PostgreSQL object types.

### Inspect existing views

Inside `psql`:

```text
\dv ch13_saleco.*
\dm ch13_saleco.*
```

`\dv` lists regular views; `\dm` lists materialized views.

## 6. Understand refresh and data changes

Suppose a materialized view has already been created from a base table:

1. Query the base table and materialized view to establish the initial values.
2. Change the base table (for example, by inserting a new valid record).
3. Query both again. The base table reflects the change, but the materialized view still contains the previously stored result.
4. Execute `REFRESH MATERIALIZED VIEW view_name;`.
5. Query the materialized view again to observe the updated result.

### Safe experimentation with transactions

Use a transaction to keep temporary test changes from permanently altering your data:

```sql
BEGIN;
-- Make your test change and run comparisons here.
-- Refresh the materialized view if required.
ROLLBACK;
```

`ROLLBACK` reverses changes made in that transaction, including a refresh performed within it. **Do not run `COMMIT` for the temporary experiment in Problem 19.**

PostgreSQL `psql` executes statements one at a time; remember to check for error messages before continuing.

## 7. Exercise guidance

### Problem 17 — Create a monthly category sales materialized view

Create a materialized view named `monthly_category_sales` that stores total sales revenue grouped by **month** and **product category**.

Hints:

- Which table supplies the revenue measures?
- Which dimensions supply the month and category?
- Which joins are needed?
- Use `SUM()` and ordinary `GROUP BY` to build the aggregated query.
- The required object is a **materialized view**, not a regular view.
- Run a `SELECT` afterward to verify the view contains data.

### Problem 18 — Analyze stored sales data

Query `monthly_category_sales` to identify the highest-revenue product category for **each month**.

Hints:

- Start by examining the columns stored in the materialized view.
- Sort by revenue to see which categories lead.
- To return one winner per month, consider a window function such as `ROW_NUMBER()` with `PARTITION BY`, or PostgreSQL's `DISTINCT ON`.
- Explain why reading a precomputed aggregate can be useful for repeated reports.

### Problem 19 — Demonstrate refresh behavior

Insert one new, valid sales record into the fact table as a **temporary experiment**, then compare the base-table aggregation and the materialized view before and after a refresh.

Hints:

- A fact record must use existing `tm_id`, `cus_code`, and `p_code` values.
- The fact table has a **composite primary key** on those three columns. Choose a combination not already present.
- Use a transaction: `BEGIN;` before the insertion and `ROLLBACK;` after your comparison.
- Verify that your insertion succeeded before refreshing.
- Compare the relevant month/category total in the base tables with the stored materialized-view total.
- Use `REFRESH MATERIALIZED VIEW monthly_category_sales;` to update the stored result.
- After `ROLLBACK`, verify that your temporary sales record was removed.

**Do not delete existing sales rows to make room for the new record.** Ask your instructor for help if you cannot find an unused valid key combination.

### Problem 20 — Compare a regular view with a materialized view

Create a regular view named `monthly_category_view` using the **same aggregation** as Problem 17. Compare the two objects.

Hints:

- Replace `CREATE MATERIALIZED VIEW` with `CREATE VIEW`, keeping the aggregation equivalent.
- Compare the behavior after changing source data in a controlled experiment.
- Use `EXPLAIN ANALYZE` on `SELECT` queries against each view to inspect the execution plans.
- Explain why the materialized view needs refreshing.
- A faster runtime is **not guaranteed** on this small dataset. Focus on the plan and the difference between stored and recalculated results.

## 8. Running your work

Open `materialized_views_exercises_student_template.sql`, add your solutions, and save it (`Ctrl+S`). At the PostgreSQL prompt:

```text
\i /workspaces/Advanced-Databases-OLAP/materialized_views_exercises_student_template.sql
```

You may also execute one completed query at a time. **Important:** Re-running the entire script may cause “already exists” errors for views created earlier. Use `DROP ... IF EXISTS` deliberately when testing, and do not place the Problem 19 insertion outside its transaction.

## 9. Troubleshooting

- **`relation does not exist`** — Run `SET search_path TO ch13_saleco, public;` and check the spelling.
- **`relation already exists`** — You may have run a `CREATE VIEW` or `CREATE MATERIALIZED VIEW` statement earlier. Inspect the object before dropping or replacing it.
- **`duplicate key value violates unique constraint`** — Your new fact record uses an existing `(tm_id, cus_code, p_code)` combination.
- **Materialized view seems outdated** — Check whether it was refreshed after the source change.
- **`current transaction is aborted`** — An earlier statement failed inside `BEGIN;`. Run `ROLLBACK;` and retry the experiment.
- **`EXPLAIN ANALYZE` gives unexpected timing** — On 36 fact records, measurement noise and overhead can dominate. Interpret the plan rather than asserting a speedup.
- **Output stuck at `(END)`** — Press `q` to exit the pager, or reconnect with `-P pager=off`.

## 10. Submission

Submit your completed `materialized_views_exercises_student_template.sql` containing Problems 17–20 and short comments explaining:

- How the materialized view was created.
- Which category leads in each month and how you determined this.
- What changed before and after `REFRESH MATERIALIZED VIEW`.
- The differences between regular and materialized views, including what you observed with `EXPLAIN ANALYZE`.

Do **not** include the instructor solution file. Make sure your Problem 19 transaction ends with `ROLLBACK;` and your sample data remains intact.

### Final checklist

- [ ] I can connect to PostgreSQL and find the SALECO tables.
- [ ] My materialized view stores month/category sales aggregates.
- [ ] I can query the highest-revenue category per month.
- [ ] I demonstrated stale results and refreshed results without permanently changing the data.
- [ ] I created and compared an equivalent regular view.
- [ ] I explained the observed execution plans without assuming a guaranteed performance advantage.

**Reference:** <https://www.postgresql.org/docs/17/rules-materializedviews.html>
