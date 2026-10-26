# SQL Portfolio

Practice queries and projects from the Microsoft Data Analysis with SQL, Excel & Power BI specialization on Coursera.

Each file is meant to work both as a showcase and as a reference I can come back to: every query has a comment header with the question, the concepts used, and a sample of the result.

## Contents

### `01_foundations_mysql/` (MySQL 8.0, Chinook database)
| File | What it covers |
|---|---|
| `01_basic_select_filter.sql` | Retrieving, filtering and sorting data: SELECT, WHERE, DISTINCT, LIKE, IN, BETWEEN, IS NULL, ORDER BY, LIMIT |
| `02_aggregate_join.sql` | Aggregation and joins: COUNT, SUM, AVG, GROUP BY, HAVING, INNER JOIN, LEFT JOIN |
| `03_transformations.sql` | Transformations: string and date functions, CASE, COALESCE, subqueries, CTEs, window functions |

### `02_sql_server/` (SQL Server / T-SQL, PracticeShop database)
| File | What it covers |
|---|---|
| `00_setup.sql` | Creates the `PracticeShop` practice database (customers, products, orders, accounts) and loads starter data |
| `01_dml_basics.sql` | INSERT, UPDATE, DELETE, OUTPUT, and foreign key constraints, each change checked with a SELECT |
| `02_transactions.sql` | BEGIN TRANSACTION, COMMIT, ROLLBACK, TRY...CATCH, savepoints, multi-table transactions |
| `03_concurrency_isolation.sql` | Dirty reads, blocking, non-repeatable reads, phantoms, isolation levels, deadlocks |

## How to run the queries

**MySQL files (`01_foundations_mysql/`)**
1. Install MySQL 8.0 and load the Chinook sample database (https://github.com/lerocha/chinook-database).
2. Open any `.sql` file in VS Code (SQLTools) or MySQL Workbench and run it against the `Chinook` database.

**SQL Server files (`02_sql_server/`)**
1. Install SQL Server and SQL Server Management Studio (SSMS).
2. Run `00_setup.sql` first. It is safe to re-run and resets the data.
3. Run `01_dml_basics.sql`, then `02_transactions.sql`, in order, since later files build on the data left by earlier ones.
4. `03_concurrency_isolation.sql` is not run as a whole. Each demo is a step-by-step script for two query windows open at once, as explained in the file header.

## Notes
- MySQL and SQL Server differ in places (for example `LIMIT` vs `TOP`, `AUTO_INCREMENT` vs `IDENTITY`, `START TRANSACTION` vs `BEGIN TRANSACTION`). Differences are noted in the comments where they matter.
- Invoice dates in this copy of Chinook run from 2021 to 2025, so date filters use those years.
- Queries were written with AI assistance. I ran each one myself and checked its output against what it should return.