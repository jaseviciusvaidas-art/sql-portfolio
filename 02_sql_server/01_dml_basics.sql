-- Database: PracticeShop (SQL Server / T-SQL)
-- Topic: DML (INSERT, UPDATE, DELETE), each change checked with a SELECT
-- Run 00_setup.sql first. Re-run it any time to reset the data.

USE PracticeShop;
GO

-- Q1. Add a new customer.
-- Concepts: INSERT ... VALUES. The IDENTITY column (CustomerId) fills itself in.
-- Dialect: SQL Server uses IDENTITY; MySQL uses AUTO_INCREMENT.
INSERT INTO Customers (FirstName, LastName, Country, Email)
VALUES (N'Liisa', N'Tamm', N'Estonia', N'liisa.tamm@example.com');

SELECT * FROM Customers;
/* Result: 4 rows, the new customer has CustomerId 4
CustomerId | FirstName | LastName | Country   | Email
1          | Anna      | Kask     | Estonia   | anna.kask@example.com
2          | Jonas     | Petras   | Lithuania | jonas.petras@example.com
3          | Marta     | Berg     | Sweden    | marta.berg@example.com
4          | Liisa     | Tamm     | Estonia   | liisa.tamm@example.com
*/
GO

-- Q2. Add two products in a single statement.
-- Concepts: INSERT with several rows; the Stock default is not used here
INSERT INTO Products (ProductName, Price, Stock)
VALUES (N'Pencil case', 6.50, 60),
       (N'Water bottle', 12.00, 35);

SELECT * FROM Products;
/* Result: 5 rows, the new products have ProductId 4 and 5
ProductId | ProductName  | Price | Stock
1         | Notebook     | 4.50  | 100
2         | Backpack     | 39.90 | 25
3         | Desk lamp    | 18.00 | 40
4         | Pencil case  | 6.50  | 60
5         | Water bottle | 12.00 | 35
*/
GO

-- Q3. Record four orders.
-- Concepts: INSERT into a table with foreign keys; OrderDate fills itself in (DEFAULT GETDATE())
INSERT INTO Orders (CustomerId, ProductId, Quantity)
VALUES (1, 1, 10),
       (1, 3, 2),
       (2, 2, 1),
       (3, 1, 5);

SELECT * FROM Orders;
/* Result: 4 rows (OrderDate shows the day the script was run)
OrderId | CustomerId | ProductId | Quantity | OrderDate
1       | 1          | 1         | 10       | 2026-10-26
2       | 1          | 3         | 2        | 2026-10-26
3       | 2          | 2         | 1        | 2026-10-26
4       | 3          | 1         | 5        | 2026-10-26
*/
GO

-- Q4. Correct the price of one product.
-- Concepts: UPDATE with WHERE. Habit: run the SELECT first, then change it.
SELECT ProductName, Price FROM Products WHERE ProductName = N'Notebook';

UPDATE Products
SET Price = 4.90
WHERE ProductName = N'Notebook';

SELECT ProductName, Price FROM Products WHERE ProductName = N'Notebook';
/* Result:
before: Notebook | 4.50
after:  Notebook | 4.90
*/
GO

-- Q5. Raise the price of every product under 10 by 10%.
-- Concepts: UPDATE with a calculation, and a WHERE that hits several rows
UPDATE Products
SET Price = ROUND(Price * 1.10, 2)
WHERE Price < 10;

SELECT ProductName, Price FROM Products ORDER BY ProductId;
/* Result: Notebook and Pencil case went up, the others did not
ProductName  | Price
Notebook     | 5.39
Backpack     | 39.90
Desk lamp    | 18.00
Pencil case  | 7.15
Water bottle | 12.00
*/
GO

-- Q6. Reduce stock by the quantities that have been ordered.
-- Concepts: UPDATE ... FROM with a JOIN to an aggregated subquery (T-SQL syntax)
-- Dialect: MySQL writes this as UPDATE ... JOIN ... SET
UPDATE p
SET p.Stock = p.Stock - o.Ordered
FROM Products p
JOIN (
    SELECT ProductId, SUM(Quantity) AS Ordered
    FROM Orders
    GROUP BY ProductId
) o ON o.ProductId = p.ProductId;

SELECT ProductName, Stock FROM Products ORDER BY ProductId;
/* Result: only products that have orders lose stock
ProductName  | Stock
Notebook     | 85
Backpack     | 24
Desk lamp    | 38
Pencil case  | 60
Water bottle | 35
*/
GO

-- Q7. Delete the customer we added in Q1 (they have no orders).
-- Concepts: DELETE with WHERE
DELETE FROM Customers
WHERE Email = N'liisa.tamm@example.com';

SELECT * FROM Customers;
/* Result: back to 3 customers (Anna Kask, Jonas Petras, Marta Berg) */
GO

-- Q8. Delete a product and see exactly what was removed.
-- Concepts: OUTPUT deleted.* (T-SQL only, handy for checking a change as it happens)
DELETE FROM Products
OUTPUT deleted.ProductId, deleted.ProductName
WHERE ProductName = N'Water bottle';
/* Result: one row showing what was removed
ProductId | ProductName
5         | Water bottle
*/
GO

-- Q9. What happens if we delete a customer who has orders?
-- Concepts: foreign key constraint. The database refuses to leave orphaned rows.
-- The DELETE is commented out so a full re-run does not stop on the error.
-- To see it, remove the "--" and run only that line.
-- DELETE FROM Customers WHERE CustomerId = 1;
/* Result:
Msg 547, Level 16, State 0
The DELETE statement conflicted with the REFERENCE constraint "FK__Orders__Customer__4F7CD00D".
The conflict occurred in database "PracticeShop", table "dbo.Orders", column 'CustomerId'.
The statement has been terminated.
Customer 1 stays in the table: you can't delete a parent row while child rows reference it.
*/
GO