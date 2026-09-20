-- =============================================================================
-- DATABASE SYSTEMS LAB 10: SCALAR FUNCTIONS PART 01 — STRING FUNCTIONS
-- Reference: LAB_10___11_Manual.pdf (Section 3 & Section 8: Part A)
-- Objectives:
-- 1. Setup Customer & Product Database Schema with messy, real-world data
-- 2. Clean and format strings: TRIM, UPPER, LOWER, CHAR_LENGTH
-- 3. String concatenation: CONCAT, CONCAT_WS
-- 4. Text extraction and dissection: SUBSTRING, LOCATE, LEFT, RIGHT
-- 5. Pattern padding and text transformation: LPAD, REPLACE
-- =============================================================================

CREATE DATABASE IF NOT EXISTS scalar_lab;
USE scalar_lab;

-- =============================================================================
-- SCHEMA SETUP & SAMPLE DATA INSERTS
-- =============================================================================

DROP TABLE IF EXISTS Product, Customer;

CREATE TABLE Customer (
    CustID INT PRIMARY KEY,
    CustName VARCHAR(60) NOT NULL,
    Email VARCHAR(80),
    City VARCHAR(30),
    Phone VARCHAR(20),
    JoinDate DATE,
    DOB DATE
);

CREATE TABLE Product (
    ProdID INT PRIMARY KEY,
    ProdName VARCHAR(60) NOT NULL,
    Category VARCHAR(30),
    Price DECIMAL(10,2),
    StockQty INT,
    LaunchDate DATE
);

-- Customers (includes extra spaces, mixed cases, and deliberate NULL values)
INSERT INTO Customer VALUES
(1, ' Ali Khan ',    'ali.khan@MAIL.com',   'Lahore',    '0300-1112233','2022-01-15','1995-04-12'),
(2, 'Sara Iqbal',    'sara@example.com',    'Karachi',   '0301-4445566','2022-04-22','1998-11-20'),
(3, 'HAMZA RAZA',    'hamza@example.com',   'Lahore',    '0302-7778899','2023-02-10','1997-08-05'),
(4, 'Ayesha Noor',   NULL,                  'Islamabad', '0303-1234567','2023-05-18','1999-02-14'),
(5, 'bilal ahmed',   'bilal@MAIL.COM',      'Karachi',   '0304-2345678','2023-09-01','2000-06-30'),
(6, 'Fatima Sheikh', 'fatima@example.com',  NULL,        '0305-3456789','2024-01-12','1996-10-25'),
(7, 'Usman Tariq',   'usman@example.com',   'Lahore',    NULL,         '2024-06-30','2001-03-18'),
(8, 'Maira Javed',   'maira@example.com',   'Islamabad', '0307-5678901','2024-08-25','1994-12-09');

-- Products
INSERT INTO Product VALUES
(101,'Laptop Pro 15',      'Electronics', 185000.00, 12,  '2023-03-10'),
(102,'Wireless Mouse',     'Electronics', 2500.00,   50,  '2022-07-22'),
(103,'USB-C Cable',        'Electronics', 800.00,    100, '2021-11-05'),
(104,'Office Chair',       'Furniture',   18500.00,  8,   '2023-01-15'),
(105,'Standing Desk',      'Furniture',   45000.50,  5,   '2024-02-28'),
(106,'Notebook A4',        'Stationery',  350.00,    200, '2020-04-01'),
(107,'Ballpoint Pen 10pk', 'Stationery',  450.00,    150, '2020-04-01'),
(108,'Coffee Beans 1kg',   'Grocery',     1899.99,   30,  '2023-09-20'),
(109,'Green Tea Box',      'Grocery',     650.00,    45,  '2022-12-12'),
(110,'Bluetooth Speaker',  'Electronics', 7500.00,   18,  '2024-05-18');

-- Verify dataset
SELECT * FROM Customer;
SELECT * FROM Product;

-- =============================================================================
-- PART A — STRING FUNCTIONS
-- =============================================================================

-- Task A1: List each customer's name with leading and trailing spaces removed, alongside the original.
-- Show CustID, original CustName, CleanedName.
SELECT 
    CustID,
    CustName AS OriginalCustName,
    TRIM(CustName) AS CleanedName
FROM Customer;

-- Task A2: Display every customer name in UPPERCASE and the same name in lowercase.
-- Show CustID, UpperName, LowerName.
SELECT 
    CustID,
    UPPER(TRIM(CustName)) AS UpperName,
    LOWER(TRIM(CustName)) AS LowerName
FROM Customer;

-- Task A3: For each customer, show their trimmed name and the number of characters in it.
SELECT 
    TRIM(CustName) AS CleanedName,
    CHAR_LENGTH(TRIM(CustName)) AS NameCharCount
FROM Customer;

-- Task A4: Build a greeting column for each customer: 'Dear <trimmed name>, welcome!'
SELECT 
    CONCAT('Dear ', TRIM(CustName), ', welcome!') AS Greeting
FROM Customer;

-- Task A5: For customers who have an email, extract the part before the '@' (the username).
-- Show CustName and Username.
SELECT 
    TRIM(CustName) AS CustName,
    Email,
    SUBSTRING(Email, 1, LOCATE('@', Email) - 1) AS Username
FROM Customer
WHERE Email IS NOT NULL;

-- Task A6: For customers who have an email, extract the domain (everything after '@').
-- Show CustName and Domain.
SELECT 
    TRIM(CustName) AS CustName,
    Email,
    SUBSTRING(Email, LOCATE('@', Email) + 1) AS Domain
FROM Customer
WHERE Email IS NOT NULL;

-- Task A7: Show each customer's name with the first 3 characters only. (Hint: LEFT.)
SELECT 
    TRIM(CustName) AS CleanedName,
    LEFT(TRIM(CustName), 3) AS First3Chars
FROM Customer;

-- Task A8: Mask each phone number: show the country/area code (first 4 chars), then 'XXX-XXXX'.
-- Skip customers with no phone.
SELECT 
    TRIM(CustName) AS CustName,
    Phone AS OriginalPhone,
    CONCAT(LEFT(Phone, 4), '-XXX-XXXX') AS MaskedPhone
FROM Customer
WHERE Phone IS NOT NULL;

-- Task A9: Show each product name with all spaces replaced by hyphens. Show ProdID and SlugName.
SELECT 
    ProdID,
    ProdName,
    REPLACE(ProdName, ' ', '-') AS SlugName
FROM Product;

-- Task A10: Show each ProdID padded to 5 digits with leading zeros (e.g. 101 -> '00101').
SELECT 
    ProdID,
    LPAD(ProdID, 5, '0') AS PaddedProdID,
    ProdName
FROM Product;

-- Task A11: Show product names that contain the word 'Pro' anywhere (use LIKE OR LOCATE)
-- along with the position of 'Pro'.
SELECT 
    ProdID,
    ProdName,
    LOCATE('Pro', ProdName) AS PositionOfPro
FROM Product
WHERE LOCATE('Pro', ProdName) > 0;

-- Task A12: Display every customer's first name only (the part before the first space in the trimmed name).
-- (Hint: SUBSTRING with LOCATE.)
SELECT 
    CustID,
    TRIM(CustName) AS FullName,
    SUBSTRING(TRIM(CustName), 1, LOCATE(' ', TRIM(CustName)) - 1) AS FirstName
FROM Customer;

-- =============================================================================
-- End of LAB 10 Scalar Functions Part 01 Script
-- =============================================================================
