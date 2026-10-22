# SQL Portfolio

Practice queries and projects from the Microsoft Data Analysis with SQL, Excel & Power BI specialization on Coursera.

## Contents
| File | What it covers |
|---|---|
| `01_foundations_mysql/01_basic_select_filter.sql` | Retrieving, filtering and sorting data: SELECT, WHERE, DISTINCT, LIKE, IN, BETWEEN, IS NULL, ORDER BY, LIMIT |
| `01_foundations_mysql/02_aggregate_join.sql` | Aggregation and joins: COUNT, SUM, AVG, GROUP BY, HAVING, INNER JOIN, LEFT JOIN |
| `01_foundations_mysql/03_transformations.sql` | Transformations: string and date functions, CASE, COALESCE, subqueries, CTEs, window functions |

## How to run the queries
1. Install MySQL 8.0 and load the Chinook sample database (https://github.com/lerocha/chinook-database).
2. Open any `.sql` file in VS Code (SQLTools) or MySQL Workbench and run it against the `Chinook` database.

## Notes
- Each query has a comment with the business question, the SQL concepts used, and a sample of the result.
- All queries were run on MySQL 8.0.
- Invoice dates in this copy of Chinook run from 2021 to 2025, so date filters use those years.