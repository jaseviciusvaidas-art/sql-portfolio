-- Database: Chinook, MySQL 8.0
-- Topic: retrieving, filtering and sorting data

-- Q1. Which are the 10 longest tracks, in minutes?
-- Concepts: SELECT, calculated column, ORDER BY, LIMIT
SELECT Name, ROUND(Milliseconds / 60000, 2) AS minutes
FROM Track
ORDER BY Milliseconds DESC
LIMIT 10;
/* Result (first 5 rows):
Name                          | minutes
Occupation / Precipice        | 88.12
Through a Looking Glass       | 84.81
Greetings from Earth, Pt. 1   | 49.34
The Man With Nine Lives       | 49.28
Battlestar Galactica, Pt. 2   | 49.27
*/

-- Q2. Which customers live in Germany?
-- Concepts: WHERE
SELECT FirstName, LastName, City, Email
FROM Customer
WHERE Country = 'Germany';
/* Result (first 4 rows):
FirstName | LastName    | City      | Email
Leonie    | Köhler      | Stuttgart | leonekohler@surfeu.de
Hannah    | Schneider   | Berlin    | hannah.schneider@yahoo.de
Fynn      | Zimmermann  | Frankfurt | fzimmermann@yahoo.de
Niklas    | Schröder    | Berlin    | nschroder@surfeu.de
*/

-- Q3. In which countries do we have customers?
-- Concepts: DISTINCT, ORDER BY
SELECT DISTINCT Country
FROM Customer
ORDER BY Country;
/* Result (first 5 of 24 rows):
Country
Argentina
Australia
Austria
Belgium
Brazil
*/

-- Q4. Which invoices are worth more than 10, largest first?
-- Concepts: WHERE with comparison, ORDER BY DESC
SELECT InvoiceId, InvoiceDate, BillingCountry, Total
FROM Invoice
WHERE Total > 10
ORDER BY Total DESC;
/* Result (first 5 rows):
InvoiceId | InvoiceDate | BillingCountry | Total
404       | 2025-11-13  | Czech Republic | 25.86
299       | 2024-08-05  | USA            | 23.86
194       | 2023-04-28  | Ireland        | 21.86
96        | 2022-02-18  | Hungary        | 21.86
201       | 2023-05-29  | USA            | 18.86
*/

-- Q5. Which tracks have a name starting with 'Love'?
-- Concepts: LIKE with wildcard
SELECT TrackId, Name, UnitPrice
FROM Track
WHERE Name LIKE 'Love%';
/* Result (first 5 rows):
TrackId | Name                  | UnitPrice
24      | Love In An Elevator   | 0.99
56      | Love, Hate, Love      | 0.99
413     | Loverman              | 0.99
440     | Love Gun              | 0.99
493     | Love Is Blind         | 0.99
*/

-- Q6. Which customers have no company recorded?
-- Concepts: IS NULL
SELECT FirstName, LastName, Country
FROM Customer
WHERE Company IS NULL
LIMIT 10;
/* Result (first 5 rows):
FirstName | LastName | Country
Leonie    | Köhler   | Germany
François  | Tremblay | Canada
Bjørn     | Hansen   | Norway
Helena    | Holý     | Czech Republic
Astrid    | Gruber   | Austria
*/

-- Q7. List all employees from the longest-serving to the newest.
-- Concepts: ORDER BY on a date column
SELECT FirstName, LastName, Title, HireDate
FROM Employee
ORDER BY HireDate;
/* Result (first 5 of 8 rows):
FirstName | LastName | Title                | HireDate
Jane      | Peacock  | Sales Support Agent  | 2002-04-01
Nancy     | Edwards  | Sales Manager        | 2002-05-01
Andrew    | Adams    | General Manager      | 2002-08-14
Margaret  | Park     | Sales Support Agent  | 2003-05-03
Steve     | Johnson  | Sales Support Agent  | 2003-10-17
*/

-- Q8. Which customers are in the USA or Canada?
-- Concepts: IN
SELECT FirstName, LastName, Country
FROM Customer
WHERE Country IN ('USA', 'Canada')
ORDER BY Country, LastName;
/* Result (first 5 rows):
FirstName | LastName | Country
Robert    | Brown    | Canada
Edward    | Francis  | Canada
Aaron     | Mitchell | Canada
Jennifer  | Peterson | Canada
Mark      | Philips  | Canada
*/

-- Q9. Which invoices were issued during 2022?
-- Concepts: BETWEEN on dates
SELECT InvoiceId, InvoiceDate, Total
FROM Invoice
WHERE InvoiceDate BETWEEN '2022-01-01' AND '2022-12-31 23:59:59'
ORDER BY InvoiceDate;
/* Result (first 5 rows):
InvoiceId | InvoiceDate | Total
84        | 2022-01-08  | 1.98
85        | 2022-01-08  | 1.98
86        | 2022-01-09  | 3.96
87        | 2022-01-10  | 6.94
88        | 2022-01-13  | 17.91
*/

-- Q10. Which tracks cost more than the standard 0.99 price?
-- Concepts: WHERE, ORDER BY, LIMIT
SELECT Name, UnitPrice
FROM Track
WHERE UnitPrice > 0.99
ORDER BY Name
LIMIT 10;
/* Result (first 5 rows):
Name                          | UnitPrice
"?"                           | 1.99
...And Found                  | 1.99
...In Translation             | 1.99
.07%                          | 1.99
A Benihana Christmas, Pts. 1 & 2 | 1.99
*/