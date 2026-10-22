-- Database: Chinook, MySQL 8.0
-- Topic: aggregation (COUNT, SUM, AVG, GROUP BY, HAVING) and joins

-- Q1. Which 5 countries have the most customers?
-- Concepts: COUNT, GROUP BY, ORDER BY, LIMIT
SELECT Country, COUNT(*) AS customers
FROM Customer
GROUP BY Country
ORDER BY customers DESC, Country
LIMIT 5;
/* Result:
Country | customers
USA     | 13
Canada  | 8
Brazil  | 5
France  | 5
Germany | 4
*/

-- Q2. Which 5 billing countries generate the most revenue?
-- Concepts: SUM, GROUP BY, ROUND
SELECT BillingCountry, ROUND(SUM(Total), 2) AS revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY revenue DESC
LIMIT 5;
/* Result:
BillingCountry | revenue
USA            | 523.06
Canada         | 303.96
France         | 195.10
Brazil         | 190.10
Germany        | 156.48
*/

-- Q3. What is the average invoice value, and how many invoices are there?
-- Concepts: AVG, COUNT without GROUP BY
SELECT ROUND(AVG(Total), 2) AS avg_invoice, COUNT(*) AS invoices
FROM Invoice;
/* Result:
avg_invoice | invoices
5.65        | 412
*/

-- Q4. How much revenue did each year bring in?
-- Concepts: YEAR(), SUM, GROUP BY on an expression
SELECT YEAR(InvoiceDate) AS year, ROUND(SUM(Total), 2) AS revenue
FROM Invoice
GROUP BY YEAR(InvoiceDate)
ORDER BY year;
/* Result:
year | revenue
2021 | 449.46
2022 | 481.45
2023 | 469.58
2024 | 477.53
2025 | 450.58
*/

-- Q5. How many tracks does each genre have? Show the top 10.
-- Concepts: INNER JOIN, COUNT, GROUP BY
SELECT g.Name AS genre, COUNT(*) AS tracks
FROM Track t
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.Name
ORDER BY tracks DESC
LIMIT 10;
/* Result (top 5 of 10 rows):
genre              | tracks
Rock               | 1297
Latin              | 579
Metal              | 374
Alternative & Punk | 332
Jazz               | 130
*/

-- Q6. Which 5 artists have the most albums?
-- Concepts: INNER JOIN, COUNT, GROUP BY
SELECT ar.Name AS artist, COUNT(*) AS albums
FROM Artist ar
JOIN Album al ON al.ArtistId = ar.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY albums DESC, artist
LIMIT 5;
/* Result:
artist       | albums
Iron Maiden  | 21
Led Zeppelin | 14
Deep Purple  | 11
Metallica    | 10
U2           | 10
*/

-- Q7. Who is each customer's support rep? (first 10 customers)
-- Concepts: INNER JOIN with a column alias
SELECT c.FirstName, c.LastName, e.FirstName AS rep_first_name, e.LastName AS rep_last_name
FROM Customer c
JOIN Employee e ON e.EmployeeId = c.SupportRepId
ORDER BY c.LastName
LIMIT 10;
/* Result (first 5 of 10 rows):
FirstName | LastName | rep_first_name | rep_last_name
Roberto   | Almeida  | Jane           | Peacock
Julia     | Barnett  | Steve          | Johnson
Camille   | Bernard  | Margaret       | Park
Michelle  | Brooks   | Jane           | Peacock
Robert    | Brown    | Jane           | Peacock
*/

-- Q8. Who are the 5 customers who spent the most in total?
-- Concepts: JOIN, SUM, GROUP BY on several columns
SELECT c.FirstName, c.LastName, ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC
LIMIT 5;
/* Result:
FirstName | LastName   | total_spent
Helena    | Holý       | 49.62
Richard   | Cunningham | 47.62
Luis      | Rojas      | 46.62
Ladislav  | Kovács     | 45.62
Hugh      | O'Reilly   | 45.62
*/

-- Q9. Which genres have more than 100 tracks?
-- Concepts: HAVING (filters groups, unlike WHERE which filters rows)
SELECT g.Name AS genre, COUNT(*) AS tracks
FROM Track t
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.Name
HAVING COUNT(*) > 100
ORDER BY tracks DESC;
/* Result:
genre              | tracks
Rock               | 1297
Latin              | 579
Metal              | 374
Alternative & Punk | 332
Jazz               | 130
*/

-- Q10. Which artists have no albums in the database?
-- Concepts: LEFT JOIN, IS NULL (finding unmatched rows)
SELECT ar.ArtistId, ar.Name
FROM Artist ar
LEFT JOIN Album al ON al.ArtistId = ar.ArtistId
WHERE al.AlbumId IS NULL
ORDER BY ar.Name
LIMIT 10;
/* Result (first 5 of 10 rows):
ArtistId | Name
43       | A Cor Do Som
239      | Academy of St. Martin in the Fields, Sir Neville Marriner & William Bennett
161      | Aerosmith & Sierra Leone's Refugee Allstars
166      | Avril Lavigne
26       | Azymuth
*/