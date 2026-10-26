-- Database: PracticeShop (SQL Server / T-SQL)
-- Topic: transactions (BEGIN TRANSACTION, COMMIT, ROLLBACK, TRY...CATCH, savepoints)
-- Idea: a transaction groups several changes so they all succeed or all fail (the "A" in ACID).
-- Dialect: SQL Server uses BEGIN TRANSACTION; MySQL uses START TRANSACTION.
-- Run 00_setup.sql and 01_dml_basics.sql first. This file resets the balances below, so it can be re-run.

USE PracticeShop;
GO

UPDATE Accounts SET Balance = 500.00 WHERE AccountId = 1;
UPDATE Accounts SET Balance = 300.00 WHERE AccountId = 2;
GO

-- Q1. Transfer 100 from Anna to Jonas. Both updates must happen, or neither.
-- Concepts: BEGIN TRANSACTION, COMMIT
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 100 WHERE AccountId = 1;
    UPDATE Accounts SET Balance = Balance + 100 WHERE AccountId = 2;
COMMIT TRANSACTION;

SELECT * FROM Accounts;
/* Result:
AccountId | Owner | Balance
1         | Anna  | 400.00
2         | Jonas | 400.00
*/
GO

-- Q2. Start a change, look at it from inside the transaction, then undo it.
-- Concepts: ROLLBACK, @@TRANCOUNT (how many transactions are open right now)
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 50 WHERE AccountId = 1;
    SELECT AccountId, Owner, Balance, @@TRANCOUNT AS open_transactions
    FROM Accounts WHERE AccountId = 1;      -- inside: 350.00, 1 open transaction
ROLLBACK TRANSACTION;

SELECT AccountId, Owner, Balance, @@TRANCOUNT AS open_transactions
FROM Accounts WHERE AccountId = 1;           -- after: back to 400.00, 0 open transactions
/* Result: two result sets
inside the transaction:  Anna | 350.00 | open_transactions 1
after the rollback:      Anna | 400.00 | open_transactions 0
*/
GO

-- Q3. A transfer that fails halfway: try to move 1000 when Anna only has 400.
-- Concepts: TRY...CATCH, XACT_ABORT, CHECK constraint (Balance >= 0), rollback after an error
-- We credit Jonas first, then debit Anna. The debit breaks the CHECK constraint,
-- so the rollback must also undo Jonas's credit.
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;
        UPDATE Accounts SET Balance = Balance + 1000 WHERE AccountId = 2;
        UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountId = 1;   -- fails here
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS error_number, ERROR_MESSAGE() AS error_message;
END CATCH;

SET XACT_ABORT OFF;

SELECT * FROM Accounts;
/* Result: the CATCH block reports the error, and the balances are unchanged
error_number | error_message
547          | The UPDATE statement conflicted with the CHECK constraint ...

AccountId | Owner | Balance
1         | Anna  | 400.00
2         | Jonas | 400.00
Jonas's +1000 credit was undone along with the failed debit.
*/
GO

-- Q4. Undo only part of a transaction.
-- Concepts: SAVE TRANSACTION (savepoint), ROLLBACK TRANSACTION to a savepoint
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance + 10 WHERE AccountId = 2;
    SAVE TRANSACTION after_first_change;
    UPDATE Accounts SET Balance = Balance + 20 WHERE AccountId = 2;
    ROLLBACK TRANSACTION after_first_change;     -- undoes only the +20
COMMIT TRANSACTION;                              -- keeps the +10

SELECT * FROM Accounts;
/* Result: only the +10 survived the partial rollback
AccountId | Owner | Balance
1         | Anna  | 400.00
2         | Jonas | 410.00
*/
GO

-- Q5. Place an order and reduce stock as one unit of work.
-- Concepts: a transaction across two tables (Orders and Products)
-- Assumes 01_dml_basics.sql has been run once (Desk lamp stock = 38).
BEGIN TRANSACTION;
    INSERT INTO Orders (CustomerId, ProductId, Quantity) VALUES (3, 3, 2);
    UPDATE Products SET Stock = Stock - 2 WHERE ProductId = 3;
COMMIT TRANSACTION;

SELECT ProductName, Stock FROM Products WHERE ProductId = 3;
SELECT TOP 1 * FROM Orders ORDER BY OrderId DESC;
/* Result:
ProductName | Stock
Desk lamp   | 36

OrderId | CustomerId | ProductId | Quantity | OrderDate
5       | 3          | 3         | 2        | 2026-10-26
*/
GO