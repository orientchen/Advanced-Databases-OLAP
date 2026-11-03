# Chapter 13 Lab: Data Warehousing and OLAP with PostgreSQL

## Purpose

In this lab, you will query a small sales data warehouse using PostgreSQL. You will practice joining fact and dimension tables, calculating aggregate measures, and using `ROLLUP` to produce subtotals and grand totals.

**Your task is to write the SQL queries yourself.** This guide provides setup instructions, syntax reminders, and hints; it does not contain solutions to Problems 5–11.

## Learning objectives

By the end of the lab, you should be able to:

- Identify fact tables, dimension tables, and their relationships.
- Use `JOIN` to combine attributes from multiple tables.
- Use `SUM()` and `COUNT(*)` to calculate measures.
- Use `GROUP BY ROLLUP (...)` to generate hierarchical subtotals and a grand total.
- Interpret `NULL` values in subtotal rows and explain why grouping-column order matters.

## 1. Open PostgreSQL in GitHub Codespaces

1. Open the [Advanced-Databases-OLAP repository](https://github.com/orientchen/Advanced-Databases-OLAP).
2. Select **Code → Codespaces → Create codespace on main** (or reopen your existing Codespace).
3. Wait for the development environment to finish starting.
4. Open a terminal using **Terminal → New Terminal**. The terminal should show a Linux prompt ending in `$`.
5. Connect to PostgreSQL:

   ```bash
   PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
   ```

   You should see a prompt similar to `objectdb=>` or `objectdb=#`. **Do not include the prompt itself when entering commands.**

> **Terminal versus PostgreSQL:** Enter the `psql` connection command at the Linux `$` prompt. Enter SQL statements and commands beginning with `\` at the PostgreSQL prompt. To leave PostgreSQL, enter `\q`.

### If the output seems stuck at `(END)`

You are viewing PostgreSQL's output pager. Press `q` (without Enter) to exit it. To prevent the pager from appearing, run `\pset pager off` at the PostgreSQL prompt, or connect using `-P pager=off` as shown above. If needed, open a fresh terminal and reconnect.

## 2. Create the SALECO database tables

The repository contains `ch13_saleco_postgresql_setup.sql`, which creates and populates the Chapter 13 sample data.

From the PostgreSQL prompt, run:

```sql
\i /workspaces/Advanced-Databases-OLAP/ch13_saleco_postgresql_setup.sql
```

The script creates tables inside the `ch13_saleco` schema. **You only need to run it once when setting up your database. Running it again resets the sample tables and data.**

Then choose the schema for your current PostgreSQL session:

```sql
SET search_path TO ch13_saleco, public;
```

Verify the import:

```sql
SELECT COUNT(*) FROM dwdaysalesfact;
```

The supplied dataset contains **36 sales fact records**. If you see an error such as `relation "dwdaysalesfact" does not exist`, check whether the setup script ran and whether you set the search path. You can also refer to a table by its full name, for example `ch13_saleco.dwdaysalesfact`.

**Note:** The textbook sample stores year, month, and day in separate integer columns. One sample record uses September 31, which is not a valid calendar date; do not convert these fields into PostgreSQL `DATE` values for this lab.

## 3. Understand the warehouse schema

The central **fact table** records sales; the surrounding **dimension tables** describe products, customers, time, and regions.

| Table | Important columns | Role |
|---|---|---|
| `dwdaysalesfact` | `tm_id`, `cus_code`, `p_code`, `sale_units`, `sale_price` | Fact table: each record is a product sale entry |
| `dwtime` | `tm_id`, `tm_year`, `tm_month`, `tm_day`, `tm_qtr` | Time dimension |
| `dwproduct` | `p_code`, `p_descript`, `p_category`, `v_code` | Product dimension |
| `dwcustomer` | `cus_code`, `cus_lname`, `cus_fname`, `reg_id` | Customer dimension |
| `dwregion` | `reg_id`, `reg_name` | Region dimension |
| `dwvendor` | `v_code`, `v_name`, `v_state` | Vendor information |

**Relationships to examine:**

- A sales record's `tm_id` identifies a row in `dwtime`.
- A sales record's `p_code` identifies a row in `dwproduct`.
- A sales record's `cus_code` identifies a row in `dwcustomer`.
- A customer's `reg_id` identifies a row in `dwregion`.

To inspect table definitions in `psql`, use:

```sql
\dt ch13_saleco.*
\d ch13_saleco.dwdaysalesfact
```

To preview data, use a query such as:

```sql
SELECT * FROM ch13_saleco.dwproduct LIMIT 5;
```

## 4. Review the SQL building blocks

### 4.1 Aggregate functions

`SUM()` adds numeric values. `COUNT(*)` counts rows. For this dataset:

- **Revenue for one fact record** = `sale_units * sale_price`.
- **Number of sales records** = `COUNT(*)`.
- **Number of units sold** = `SUM(sale_units)`.

These measures answer different questions. Read each exercise carefully to decide which is required.

### 4.2 Ordinary `GROUP BY`

Here is a practice example using **vendors**, not one of the assigned sales-report questions:

```sql
SELECT v_state, COUNT(*) AS vendor_count
FROM dwvendor
GROUP BY v_state
ORDER BY v_state;
```

Try running it. What does one result row represent? What changes if you remove `GROUP BY`?

### 4.3 Joining tables

A `JOIN` combines rows using matching keys. For example, this query displays product descriptions alongside their vendors:

```sql
SELECT p.p_code, p.p_descript, v.v_name
FROM dwproduct p
JOIN dwvendor v ON p.v_code = v.v_code
LIMIT 5;
```

Here, `p` and `v` are short table aliases. In your exercises, first identify which table contains each requested column, then decide which joins are needed. A query using only columns from the fact table may not require a join.

### 4.4 How `ROLLUP` works

General syntax:

```sql
SELECT dimension_a, dimension_b, AGGREGATE_FUNCTION(measure)
FROM some_table
GROUP BY ROLLUP (dimension_a, dimension_b);
```

This is a **syntax illustration**, not a runnable query for the SALECO schema.

For two grouping expressions, `ROLLUP(A, B)` conceptually produces:

| Grouping level | Meaning |
|---|---|
| `(A, B)` | Detail totals for each A–B combination |
| `(A)` | Subtotal for each A |
| `()` | Grand total |

For three expressions, `ROLLUP(A, B, C)` produces `(A, B, C)`, `(A, B)`, `(A)`, and `()`.

**Important:** The order matters. `ROLLUP(A, B)` and `ROLLUP(B, A)` produce different subtotals. Decide the intended hierarchy **before** writing the SQL.

### 4.5 Recognizing subtotal rows

PostgreSQL typically displays an omitted grouping value as `NULL` (often a blank cell in `psql`). In this dataset, the grouping attributes used in the exercises have values, so blank grouping columns usually identify subtotal or grand-total rows.

For a more reliable distinction, PostgreSQL supports `GROUPING(expression)`: it returns `1` when the expression is omitted at the current aggregation level, and `0` when it is included. You may explore this function, but it is not required unless your instructor requests it.

### 4.6 Sorting results

Use `ORDER BY` to make results easier to read. PostgreSQL supports `NULLS LAST` to place subtotal rows after their corresponding detail rows when sorting ascending.

## 5. Complete Problems 5–11

Open **`rollup_exercises_student_template.sql`** in Codespaces. It contains the full problem statements and spaces for your SQL queries. Write each answer directly below its corresponding problem comment. **Do not replace the exercise descriptions with solution text.**

Use this problem-solving approach for each exercise:

1. **Identify the requested output:** Which dimensions and measures must appear?
2. **Find the columns:** Which tables contain those attributes?
3. **Plan the joins:** How do the relevant tables connect?
4. **Choose aggregates:** Do you need revenue, a row count, or both?
5. **Plan the hierarchy:** Which grouping levels and subtotals are required?
6. **Write and run the query:** Check that it produces detail rows, requested subtotals, and a grand total.
7. **Explain the result:** Be prepared to identify which rows represent subtotals.

### Progressive hints

| Problem | Guidance (not the answer) |
|---|---|
| **5** | Start with the fact table. Both requested grouping attributes are already there. |
| **6** | Locate the month attribute. Think about how three grouping expressions form a hierarchy. |
| **7** | Follow the path from a sale to its customer, then from the customer to a region. |
| **8** | The month and product category come from different dimensions. Plan both joins. |
| **9** | The question asks for two measures: a count of rows and a revenue total. |
| **10** | Combine the ideas from Problems 8 and 9. |
| **11** | Decide which subtotal should be nested inside which other subtotal before ordering the grouping expressions. |

**Do not rely only on the number of output rows.** Inspect whether the aggregation levels are correct and whether the grand total agrees with the underlying fact data.

## 6. Run your SQL file

Save your changes with **Ctrl+S**. At the PostgreSQL prompt, run:

```sql
\i /workspaces/Advanced-Databases-OLAP/rollup_exercises_student_template.sql
```

The file executes statements from top to bottom. A syntax error in one query does not necessarily stop later statements, so **read the output carefully**. You can also paste and run one `SELECT` statement at a time while developing your solution.

If you reconnect to PostgreSQL, the session's `search_path` may return to its default. Run `SET search_path TO ch13_saleco, public;` again, or keep that command at the top of your SQL file.

## 7. Troubleshooting

| Symptom | What to check |
|---|---|
| `psql: command not found` | Wait for the Codespace setup to finish; reopen the terminal if necessary. |
| Connection refused or host `postgres` not found | Ensure the Codespace development container has started correctly. |
| `relation ... does not exist` | Run the setup script and set the schema search path. |
| `column ... does not exist` | Check spelling and which table contains the column; qualify it with a table alias if needed. |
| `column reference ... is ambiguous` | Prefix the column with its table alias, such as `p.p_code`. |
| `must appear in the GROUP BY clause` | Check that every nonaggregated selected expression is included in the appropriate grouping operation. |
| Unexpected subtotal rows | Revisit the order of expressions inside `ROLLUP`. |
| Output stuck at `(END)` | Press `q`, or disable the pager using `\pset pager off`. |
| `syntax error at or near ...` | Check commas, parentheses, aliases, and the terminating semicolon. |

## 8. Submission and reflection

Submit your completed **`rollup_exercises_student_template.sql`** file as directed by your instructor. It should contain a working SQL statement for **each of Problems 5–11**. End each SQL statement with a semicolon.

At the bottom of the file, answer these questions using SQL comments:

1. How can you distinguish a detail row, a subtotal row, and a grand-total row?
2. Why does the order of grouping expressions inside `ROLLUP` matter?
3. What is the difference between `COUNT(*)` and `SUM(sale_units)`?

**Academic work:** Use the examples and hints to guide your reasoning, but write and test your own solutions. The setup script and the student template are provided; a completed solution file is not.

---

*Course materials adapted for PostgreSQL from the Chapter 13 SALECO example in Coronel/Morris, Database Systems. This guide covers the ROLLUP portion of the Chapter 13 lab; separate exercises may address CUBE, GROUPING SETS, and materialized views.*
