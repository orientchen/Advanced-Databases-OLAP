# Chapter 13: Browse the SALECO Database Schema in GitHub Codespaces

This guide shows how to connect SQLTools to PostgreSQL and inspect the SALECO database structure. You do not need to rerun the setup script if the database is already populated.

## 1. Open SQLTools

1. Open the `Advanced-Databases-OLAP` repository in GitHub Codespaces.
2. In the left Activity Bar, click the database cylinder icon to open **SQLTools**.
3. Under **Connections**, click **Add New Connection**.
4. Select **PostgreSQL**. If PostgreSQL is not available, install the **SQLTools PostgreSQL/Cockroach Driver** extension and try again.

## 2. Add the PostgreSQL connection

Enter these settings:

| Setting | Value |
| --- | --- |
| Connection name | `SALECO` |
| Driver | PostgreSQL |
| Server / Host | `postgres` |
| Port | `5432` |
| Database | `objectdb` |
| Username | `student` |
| Password | `studentpass` |

Use `postgres` as the host because the database server runs as a separate container in this Codespaces setup. Other connection fields can remain at their defaults unless the connection test indicates otherwise.

1. Click **Test Connection**.
2. If the test succeeds, click **Save Connection**.
3. Connect to the saved `SALECO` connection.

If the connection fails, check that the Codespace and PostgreSQL container are running, that the host is `postgres` (not `localhost`), and that the settings match the table above.

## 3. Explore the schema in SQLTools

1. Expand the saved `SALECO` connection in the SQLTools sidebar.
2. Locate the `ch13_saleco` schema. The exact arrangement of folders depends on the SQLTools driver.
3. Expand its database objects and look for tables such as `dwdaysalesfact`, `dwproduct`, and `dwtime`.
4. Look for views and materialized views. If you completed the guided in-class materialized-view exercise, look for `mv_class_category_revenue`.
5. Select a table or view to inspect its columns and other available metadata.

A materialized view appears only after it has been created; it is not created merely by opening the database connection.

## 4. Verify the schema using the PostgreSQL terminal

Open **Terminal > New Terminal**, then connect from the Linux shell:

```bash
PGPASSWORD=studentpass psql -h postgres -U student -d objectdb -P pager=off
```

At the `psql` prompt, use the following commands (backslash commands do not need semicolons):

```text
\dn                    -- List schemas
\dt ch13_saleco.*      -- List SALECO tables
\dv ch13_saleco.*      -- List regular views
\dm ch13_saleco.*      -- List materialized views
\d ch13_saleco.dwdaysalesfact  -- Describe the fact table
```

Set the schema search path before running unqualified SQL table names:

```sql
SET search_path TO ch13_saleco, public;
SELECT COUNT(*) FROM dwdaysalesfact;
```

The supplied SALECO dataset should return **36** fact records. The `search_path` setting affects the current PostgreSQL session; it does not move tables or change databases.

To check the active search path:

```sql
SHOW search_path;
```

To leave `psql`, type `\q`.

## 5. Inspect the materialized view

After completing the in-class materialized-view exercise, run:

```text
\dm ch13_saleco.*
\d ch13_saleco.mv_class_category_revenue
```

Then query the stored results:

```sql
SELECT *
FROM ch13_saleco.mv_class_category_revenue
ORDER BY p_category;
```

If PostgreSQL reports that the materialized view does not exist, first complete the exercise that creates it. Do not rerun the database setup script just to find a missing materialized view: the setup script resets sample data.

## 6. Quick reference

| Command | Purpose |
| --- | --- |
| `\dn` | List schemas (namespaces) |
| `\dt ch13_saleco.*` | List tables in SALECO |
| `\dv ch13_saleco.*` | List regular views in SALECO |
| `\dm ch13_saleco.*` | List materialized views in SALECO |
| `\d ch13_saleco.dwdaysalesfact` | Describe the fact table |
| `SHOW search_path;` | Display the current schema search order |
| `\q` | Exit `psql` |

**Note:** SQLTools is a visual database browser; `psql` is the command-line PostgreSQL client. Both connect to the same `objectdb` database.
