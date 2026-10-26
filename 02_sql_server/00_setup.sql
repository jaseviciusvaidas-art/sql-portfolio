-- Database: PracticeShop (SQL Server / T-SQL)
-- Topic: setup, the practice database used by every file in this folder
-- Safe to re-run: it recreates the tables, so any data you added is reset.

IF DB_ID('PracticeShop') IS NULL
    CREATE DATABASE PracticeShop;
GO

USE PracticeShop;
GO

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Accounts;
GO

CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName  NVARCHAR(50)  NOT NULL,
    LastName   NVARCHAR(50)  NOT NULL,
    Country    NVARCHAR(50)  NULL,
    Email      NVARCHAR(100) NULL
);

CREATE TABLE Products (
    ProductId   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL DEFAULT 0
);

CREATE TABLE Orders (
    OrderId    INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL REFERENCES Customers(CustomerId),
    ProductId  INT NOT NULL REFERENCES Products(ProductId),
    Quantity   INT NOT NULL,
    OrderDate  DATE NOT NULL DEFAULT GETDATE()
);

-- Used later for the transaction examples (money transfer between two accounts)
CREATE TABLE Accounts (
    AccountId INT PRIMARY KEY,
    Owner     NVARCHAR(50) NOT NULL,
    Balance   DECIMAL(10,2) NOT NULL CHECK (Balance >= 0)
);
GO

-- Starter data (Orders is left empty on purpose; file 01 fills it with INSERTs)
INSERT INTO Customers (FirstName, LastName, Country, Email) VALUES
    (N'Anna',  N'Kask',   N'Estonia',   N'anna.kask@example.com'),
    (N'Jonas', N'Petras', N'Lithuania', N'jonas.petras@example.com'),
    (N'Marta', N'Berg',   N'Sweden',    N'marta.berg@example.com');

INSERT INTO Products (ProductName, Price, Stock) VALUES
    (N'Notebook', 4.50, 100),
    (N'Backpack', 39.90, 25),
    (N'Desk lamp', 18.00, 40);

INSERT INTO Accounts (AccountId, Owner, Balance) VALUES
    (1, N'Anna', 500.00),
    (2, N'Jonas', 300.00);
GO