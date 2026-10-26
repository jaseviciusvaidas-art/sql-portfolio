-- Database: PracticeShop (SQL Server / T-SQL)
-- Topic: concurrency problems, isolation levels, locking and deadlocks
-- HOW TO RUN: do NOT run this whole file. Each query is a script for TWO query windows
-- (A = this file, B = a blank query window, each one its own session).
-- Select the lines of one step, run them in the window the step names, and follow the order.
-- Always end with COMMIT or ROLLBACK in both windows: an open transaction keeps its locks.
-- Dialect note: the default level is READ COMMITTED in SQL Server, REPEATABLE READ in MySQL (InnoDB).
--
-- Summary of what each isolation level allows:
--   READ UNCOMMITTED : dirty reads, non-repeatable reads, phantoms
--   READ COMMITTED   : non-repeatable reads, phantoms (SQL Server default)
--   REPEATABLE READ  : phantoms
--   SERIALIZABLE     : none of the three (the most blocking)

-- Reset (window A)
USE PracticeShop;
GO
UPDATE Accounts SET Balance = 400.00 WHERE AccountId IN (1, 2);
DELETE FROM Orders WHERE Quantity = 99;
GO

-- Q1. Dirty read: seeing a change that has not been committed.
-- Concepts: READ UNCOMMITTED, dirty read, rollback
-- Step 1 (window A)
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountId = 1;      -- not committed yet
-- Step 2 (window B)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT AccountId, Balance FROM Accounts WHERE AccountId = 1;          -- expect 500.00 (a dirty read)
-- Step 3 (window A)
ROLLBACK TRANSACTION;                                                  -- the +100 never really happened
-- Step 4 (window B)
SELECT AccountId, Balance FROM Accounts WHERE AccountId = 1;          -- expect 400.00
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;                       -- back to the default
/* Result:
Step 2 (window B, READ UNCOMMITTED): Balance 500.00, a dirty read of A's uncommitted +100
Step 4 (window B, after A's ROLLBACK): Balance 400.00, the +100 never really happened
Lesson: READ UNCOMMITTED can show data that is later undone.
*/
GO

-- Q2. Blocking: a reader waits for a writer under the default level.
-- Concepts: READ COMMITTED, exclusive lock, LOCK_TIMEOUT, sys.dm_tran_locks
-- Step 1 (window A)
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance + 100 WHERE AccountId = 1;
-- Step 2 (window B)
SET LOCK_TIMEOUT 30000;                                               -- give up after 30 s instead of waiting forever
SELECT AccountId, Balance FROM Accounts WHERE AccountId = 1;          -- hangs: waiting for A
-- Step 3 (window A, while B is hanging): who holds and who waits?
SELECT request_session_id, resource_type, request_mode, request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID('PracticeShop') AND resource_type <> 'DATABASE';
-- expect: A holds an exclusive (X) lock on the row, B has a shared (S) request with status WAIT
-- Step 4 (window A)
ROLLBACK TRANSACTION;                                                  -- B's SELECT now finishes
-- Step 5 (window B)
SET LOCK_TIMEOUT -1;                                                  -- back to the default (wait forever)
/* Result:
Lock list while B was hanging (window A = session 78, window B = session 73):
request_session_id | resource_type | request_mode | request_status
73                 | PAGE          | IS           | GRANT
78                 | PAGE          | IX           | GRANT
78                 | KEY           | X            | GRANT   <- A's exclusive lock on the changed row
73                 | KEY           | S            | WAIT    <- B's read is blocked waiting for it
73                 | OBJECT        | IS           | GRANT
78                 | OBJECT        | IX           | GRANT
Lesson: under READ COMMITTED a reader waits for a writer's uncommitted change.
*/
GO

-- Q3. Non-repeatable read, and how REPEATABLE READ prevents it.
-- Concepts: READ COMMITTED vs REPEATABLE READ, shared locks held until the transaction ends
-- Step 1 (window A)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT Balance FROM Accounts WHERE AccountId = 1;                     -- expect 400.00
-- Step 2 (window B)
UPDATE Accounts SET Balance = Balance + 50 WHERE AccountId = 1;       -- succeeds at once
-- Step 3 (window A)
SELECT Balance FROM Accounts WHERE AccountId = 1;                     -- expect 450.00: same query, different answer
COMMIT TRANSACTION;
-- Step 4 (window A): now the stricter level
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT Balance FROM Accounts WHERE AccountId = 1;                     -- expect 450.00
-- Step 5 (window B)
SET LOCK_TIMEOUT 5000;
UPDATE Accounts SET Balance = Balance + 50 WHERE AccountId = 1;       -- blocked: error 1222 after 5 seconds
-- Step 6 (window A)
SELECT Balance FROM Accounts WHERE AccountId = 1;                     -- still 450.00: the read is repeatable
COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Step 7 (window B)
SET LOCK_TIMEOUT -1;
-- Cleanup (either window)
UPDATE Accounts SET Balance = 400.00 WHERE AccountId = 1;
/* Result:
Part 1, READ COMMITTED (window A, one open transaction):
  step 1: Balance 400.00
  step 3: Balance 450.00 (B's committed +50 showed up mid-transaction: a non-repeatable read)
Part 2, REPEATABLE READ (window A):
  step 4: Balance 450.00
  step 5 (window B): <paste B's error text here, expected Msg 1222, Lock request time out period exceeded>
  step 6: Balance still 450.00 (the row stayed locked, so the read is repeatable)
Lesson: REPEATABLE READ holds read locks until the transaction ends, so writers wait, at the cost of blocking.
*/
GO

-- Q4. Phantom read, and how SERIALIZABLE prevents it.
-- Concepts: REPEATABLE READ vs SERIALIZABLE, range locks
-- Counts below assume files 00-02 were run once; the point is that the count changes, whatever it starts at.
-- Step 1 (window A)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT COUNT(*) AS orders_for_product_1 FROM Orders WHERE ProductId = 1;   -- expect 2
-- Step 2 (window B)
INSERT INTO Orders (CustomerId, ProductId, Quantity) VALUES (2, 1, 99);    -- succeeds: new rows are not locked
-- Step 3 (window A)
SELECT COUNT(*) AS orders_for_product_1 FROM Orders WHERE ProductId = 1;   -- expect 3: a phantom row appeared
COMMIT TRANSACTION;
-- Step 4 (window A): remove the demo row, then use the strictest level
DELETE FROM Orders WHERE Quantity = 99;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT COUNT(*) AS orders_for_product_1 FROM Orders WHERE ProductId = 1;   -- expect 2
-- Step 5 (window B)
SET LOCK_TIMEOUT 5000;
INSERT INTO Orders (CustomerId, ProductId, Quantity) VALUES (2, 1, 99);    -- blocked: error 1222 after 5 seconds
-- Step 6 (window A)
SELECT COUNT(*) AS orders_for_product_1 FROM Orders WHERE ProductId = 1;   -- still 2: no phantoms
COMMIT TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Step 7 (window B)
SET LOCK_TIMEOUT -1;
/* Result:
Part 1, REPEATABLE READ (window A):
  step 1: count 2
  step 3: count 3 (B's new row appeared mid-transaction: a phantom read)
Part 2, SERIALIZABLE (window A):
  step 4: count 2
  step 5 (window B): Msg 1222, Level 16, State 48: Lock request time out period exceeded.
                     The statement has been terminated. (B's insert was blocked for 5 seconds, then gave up)
  step 6: count still 2 (no phantom row)
Lesson: SERIALIZABLE locks the whole range, so even new rows have to wait. It's the safest level and the most blocking.
*/
GO

-- Q5. Deadlock: two transactions each wait for the other, and SQL Server picks a victim.
-- Concepts: deadlock, error 1205, deadlock victim, consistent lock order as the fix
-- Step 1 (window A)
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 10 WHERE AccountId = 1;
-- Step 2 (window B)
SET LOCK_TIMEOUT -1;
BEGIN TRANSACTION;
UPDATE Accounts SET Balance = Balance - 10 WHERE AccountId = 2;
-- Step 3 (window A)
UPDATE Accounts SET Balance = Balance - 10 WHERE AccountId = 2;       -- hangs: waits for B
-- Step 4 (window B)
UPDATE Accounts SET Balance = Balance - 10 WHERE AccountId = 1;       -- circular wait: within a few seconds one window
                                                                       -- fails with error 1205 (chosen as the deadlock victim)
-- Step 5 (BOTH windows): safe to run in either, a victim's transaction is already rolled back
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
-- The fix: make every transaction touch accounts in the same order (lowest AccountId first).
-- Then the second one just waits for the first to finish, and no circle can form.
-- Cleanup
UPDATE Accounts SET Balance = 400.00 WHERE AccountId IN (1, 2);
/* Result:
Step 1 (window A, session 78): locked account 1, 1 row affected
Step 2 (window B, session 73): locked account 2, 1 row affected
Step 3 (window A): hung, waiting for account 2
Step 4 (window B): Msg 1205, Level 13, State 51
  Transaction (Process ID 73) was deadlocked on lock resources with another process and has been
  chosen as the deadlock victim. Rerun the transaction.
Window B (session 73) was the victim and was rolled back; that released account 2, so A's update could proceed.
Lesson: deadlocks happen when two transactions lock the same rows in opposite order. SQL Server
ends one of them with error 1205; the application should catch it and retry. Locking in a consistent order prevents them.
*/
GO