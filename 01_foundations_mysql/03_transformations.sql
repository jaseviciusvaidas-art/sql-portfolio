-- Database: Chinook, MySQL 8.0
-- Topic: transformations (string/date functions, CASE, subqueries, CTEs, window functions)

-- Q1. Build a full name, an upper-case country and the email domain for 10 customers.
-- Concepts: CONCAT, UPPER, SUBSTRING_INDEX
SELECT CONCAT(FirstName, ' ', LastName) AS full_name,
       UPPER(Country) AS country,
       SUBSTRING_INDEX(Email, '@', -1) AS email_domain
FROM Customer
ORDER BY LastName
LIMIT 10;
/* Result (first 5 of 10 rows):
full_name       | country | email_domain
Roberto Almeida | BRAZIL  | riotur.gov.br
Julia Barnett   | USA     | gmail.com
Camille Bernard | FRANCE  | yahoo.fr
Michelle Brooks | USA     | aol.com
Robert Brown    | CANADA  | shaw.ca
*/

-- Q2. How many tracks are short (under 3 min), medium (3-5 min) or long (over 5 min)?
-- Concepts: CASE, GROUP BY on a derived column
    SELECT CASE
            WHEN Milliseconds < 180000 THEN 'Short'
            WHEN Milliseconds < 300000 THEN 'Medium'
            ELSE 'Long'
        END AS length_category,
        COUNT(*) AS tracks
    FROM Track
    GROUP BY length_category
    ORDER BY tracks DESC;
/* Result:
length_category | tracks
Medium          | 1954
Long            | 1069
Short           | 480
*/

-- Q3. What was the monthly revenue in 2022?
-- Concepts: DATE_FORMAT, SUM, GROUP BY
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
       ROUND(SUM(Total), 2) AS revenue
FROM Invoice
WHERE InvoiceDate >= '2022-01-01' AND InvoiceDate < '2023-01-01'
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY month;
/* Result (first 5 of 12 rows):
month   | revenue
2022-01 | 52.62
2022-02 | 46.62
2022-03 | 44.62
2022-04 | 37.62
2022-05 | 37.62
*/

-- Q4. How many invoices are worth more than the average invoice?
-- Concepts: scalar subquery in WHERE
SELECT COUNT(*) AS invoices_above_avg
FROM Invoice
WHERE Total > (SELECT AVG(Total) FROM Invoice);
/* Result:
invoices_above_avg
179
*/

-- Q5. Show customers' companies, with 'Individual' where none is recorded.
-- Concepts: COALESCE (replacing NULLs)
SELECT FirstName, LastName, COALESCE(Company, 'Individual') AS company
FROM Customer
ORDER BY LastName
LIMIT 10;
/* Result (first 5 of 10 rows):
FirstName | LastName | company
Roberto   | Almeida  | Riotur
Julia     | Barnett  | Individual
Camille   | Bernard  | Individual
Michelle  | Brooks   | Individual
Robert    | Brown    | Individual
*/

-- Q6. Which customers spent more than the average customer?
-- Concepts: CTE (WITH), subquery on a CTE
WITH customer_spend AS (
    SELECT CustomerId, SUM(Total) AS total_spent
    FROM Invoice
    GROUP BY CustomerId
)
SELECT c.FirstName, c.LastName, ROUND(cs.total_spent, 2) AS total_spent
FROM customer_spend cs
JOIN Customer c ON c.CustomerId = cs.CustomerId
WHERE cs.total_spent > (SELECT AVG(total_spent) FROM customer_spend)
ORDER BY cs.total_spent DESC
LIMIT 10;
/* Result (first 5 of 10 rows):
FirstName | LastName   | total_spent
Helena    | Holý       | 49.62
Richard   | Cunningham | 47.62
Luis      | Rojas      | 46.62
Ladislav  | Kovács     | 45.62
Hugh      | O'Reilly   | 45.62
*/

-- Q7. Who is the top-spending customer in each country? (top 10 countries by that spend)
-- Concepts: two CTEs, RANK() window function with PARTITION BY
WITH customer_spend AS (
    SELECT c.CustomerId, c.FirstName, c.LastName, c.Country,
           SUM(i.Total) AS total_spent
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY Country ORDER BY total_spent DESC) AS rnk
    FROM customer_spend
)
SELECT Country, FirstName, LastName, ROUND(total_spent, 2) AS total_spent
FROM ranked
WHERE rnk = 1
ORDER BY total_spent DESC, Country
LIMIT 10;
/* Result (first 5 of 10 rows):
Country        | FirstName | LastName   | total_spent
Czech Republic | Helena    | Holý       | 49.62
USA            | Richard   | Cunningham | 47.62
Chile          | Luis      | Rojas      | 46.62
Hungary        | Ladislav  | Kovács     | 45.62
Ireland        | Hugh      | O'Reilly   | 45.62
*/

-- Q8. What is the revenue per year and its running total?
-- Concepts: subquery in FROM, SUM() OVER (running total)
SELECT year,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY year), 2) AS running_total
FROM (
    SELECT YEAR(InvoiceDate) AS year, SUM(Total) AS revenue
    FROM Invoice
    GROUP BY YEAR(InvoiceDate)
) AS yearly
ORDER BY year;
/* Result:
year | revenue | running_total
2021 | 449.46  | 449.46
2022 | 481.45  | 930.91
2023 | 469.58  | 1400.49
2024 | 477.53  | 1878.02
2025 | 450.58  | 2328.60
*/

-- Q9. Which 5 tracks have the longest names?
-- Concepts: CHAR_LENGTH
SELECT LEFT(Name, 40) AS name_start, CHAR_LENGTH(Name) AS name_length
FROM Track
ORDER BY name_length DESC, Name
LIMIT 5;
/* Result:
name_start                                | name_length
Homecoming / The Death Of St. Jimmy / Ea  | 123
Symphony No. 3 Op. 36 for Orchestra and   | 108
Jesus Of Suburbia / City Of The Damned /  | 101
The Nutcracker, Op. 71a, Act II: Scene 1  | 98
Blind Curve: Vocal Under A Bloodlight /   | 93
*/

-- Q10. Which customers made no purchase in 2025?
-- Concepts: NOT EXISTS (correlated subquery)
SELECT c.FirstName, c.LastName, c.Country
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM Invoice i
    WHERE i.CustomerId = c.CustomerId
      AND i.InvoiceDate >= '2025-01-01'
)
ORDER BY c.LastName
LIMIT 10;
/* Result (first 5 of 10 rows):
FirstName | LastName  | Country
João      | Fernandes | Portugal
Tim       | Goyer     | USA
Joakim    | Johansson | Sweden
Leonie    | Köhler    | Germany
Dominique | Lefebvre  | France
*/