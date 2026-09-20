-- =============================================================================
-- DATABASE SYSTEMS LAB 11: SCALAR FUNCTIONS PART 02 — NUMERIC, DATE/TIME & ASSESSMENT
-- Reference: LAB_10___11_Manual.pdf (Section 8: Part B & Section 9: Assessment Problem)
-- Objectives:
-- 1. Apply numeric functions: ROUND, CEIL, FLOOR, TRUNCATE, MOD, POWER
-- 2. Apply date/time functions: CURDATE, YEAR, MONTH, MONTHNAME, DAYNAME
-- 3. Date arithmetic: DATEDIFF, TIMESTAMPDIFF, DATE_ADD, DATE_SUB
-- 4. Custom date formatting with DATE_FORMAT
-- 5. Graded Assessment Problem (Employee Database: Q1 - Q10)
-- =============================================================================

USE scalar_lab;

-- =============================================================================
-- PART B — NUMERIC AND DATE/TIME FUNCTIONS
-- =============================================================================

-- Task B1: Apply a 15% discount to every product. Show ProdName, Price, DiscountedPrice rounded to 2 decimals.
SELECT 
    ProdName,
    Price,
    ROUND(Price * 0.85, 2) AS DiscountedPrice
FROM Product;

-- Task B2: For each product, compute 17% sales tax and the final price (price + tax).
-- Show ProdName, Tax, PriceWithTax.
SELECT 
    ProdName,
    Price,
    ROUND(Price * 0.17, 2) AS Tax,
    ROUND(Price * 1.17, 2) AS PriceWithTax
FROM Product;

-- Task B3: Compute the floor and ceiling of every product's price divided by 1000.
-- Show ProdName, Price, FloorVal, CeilVal.
SELECT 
    ProdName,
    Price,
    FLOOR(Price / 1000) AS FloorVal,
    CEIL(Price / 1000) AS CeilVal
FROM Product;

-- Task B4: Round each product's price to the nearest hundred.
-- (Hint: ROUND with negative second argument, e.g. ROUND(Price, -2).)
SELECT 
    ProdName,
    Price,
    ROUND(Price, -2) AS PriceNearestHundred
FROM Product;

-- Task B5: List products with an odd ProdID. (Hint: MOD.)
SELECT 
    ProdID,
    ProdName,
    Price
FROM Product
WHERE MOD(ProdID, 2) != 0;

-- Task B6: For each customer, show the year, month name, and day of the week they joined.
SELECT 
    TRIM(CustName) AS CustName,
    JoinDate,
    YEAR(JoinDate) AS JoinYear,
    MONTHNAME(JoinDate) AS JoinMonthName,
    DAYNAME(JoinDate) AS JoinDayOfWeek
FROM Customer;

-- Task B7: Display each customer's date of birth formatted as 'DD-Month-YYYY' (e.g. '12-April-1995').
SELECT 
    TRIM(CustName) AS CustName,
    DOB,
    DATE_FORMAT(DOB, '%d-%M-%Y') AS FormattedDOB
FROM Customer;

-- Task B8: Compute each customer's current age in years. Show CustName, DOB, Age. (Use TIMESTAMPDIFF.)
SELECT 
    TRIM(CustName) AS CustName,
    DOB,
    TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
FROM Customer;

-- Task B9: Compute how many days ago each customer joined (from today). Show CustName, JoinDate, DaysSinceJoin.
SELECT 
    TRIM(CustName) AS CustName,
    JoinDate,
    DATEDIFF(CURDATE(), JoinDate) AS DaysSinceJoin
FROM Customer;

-- Task B10: List customers who joined in the year 2023. Use a date function, not BETWEEN.
SELECT 
    TRIM(CustName) AS CustName,
    JoinDate
FROM Customer
WHERE YEAR(JoinDate) = 2023;

-- Task B11: List products launched in any year's Q4 (October, November, December).
SELECT 
    ProdID,
    ProdName,
    LaunchDate
FROM Product
WHERE MONTH(LaunchDate) IN (10, 11, 12);

-- Task B12: Find customers who joined within the last 6 months from today. Use DATE_SUB.
SELECT 
    TRIM(CustName) AS CustName,
    JoinDate
FROM Customer
WHERE JoinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- Task B13: Calculate each product's 'age' in days (days since launch). Show ProdName, LaunchDate, AgeInDays.
SELECT 
    ProdName,
    LaunchDate,
    DATEDIFF(CURDATE(), LaunchDate) AS AgeInDays
FROM Product;

-- Task B14: Compute the date exactly 90 days from each product's LaunchDate.
-- Show ProdName, LaunchDate, NinetyDaysLater.
SELECT 
    ProdName,
    LaunchDate,
    DATE_ADD(LaunchDate, INTERVAL 90 DAY) AS NinetyDaysLater
FROM Product;

-- Task B15: Combined challenge: produce a single column called 'Summary' formatted as
-- 'Hello ALI KHAN, age 31, joined Jan 2022' for every customer.
-- (Hint: CONCAT + UPPER + TRIM + TIMESTAMPDIFF + DATE_FORMAT.)
SELECT 
    CONCAT(
        'Hello ', 
        UPPER(TRIM(CustName)), 
        ', age ', 
        TIMESTAMPDIFF(YEAR, DOB, CURDATE()), 
        ', joined ', 
        DATE_FORMAT(JoinDate, '%b %Y')
    ) AS Summary
FROM Customer;


-- =============================================================================
-- SECTION 9: GRADED ASSESSMENT PROBLEM — EMPLOYEE DATABASE
-- =============================================================================

CREATE DATABASE IF NOT EXISTS emp_lab;
USE emp_lab;

DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    FullName VARCHAR(60) NOT NULL,
    Email VARCHAR(80),
    Phone VARCHAR(20),
    DOB DATE,
    HireDate DATE,
    Salary DECIMAL(10,2),
    City VARCHAR(30),
    JobTitle VARCHAR(40)
);

INSERT INTO Employee VALUES
(2001,' ahmad raza',   'ahmad@firm.com',   '0300-1112233','1990-04-12','2018-09-01',120000.50,'Lahore',   'Senior Engineer'),
(2002,'Sara Imran',    'SARA@FIRM.COM',    '0301-4445566','1992-11-20','2019-03-15',95000.00, 'Karachi',  'Software Engineer'),
(2003,'BILAL KHAN',    'bilal@firm.com',   '0302-7778899','1993-08-05','2020-01-20',85000.75, 'Lahore',   'QA Engineer'),
(2004,'Fatima Ali',    NULL,               '0303-1234567','1991-02-14','2017-11-10',110000.00,'Islamabad','Manager'),
(2005,'Hira Yousaf',   'hira@firm.com',    NULL,         '1995-06-30','2021-04-05',70000.00, NULL,        'Accountant'),
(2006,'Zain Abbas ',   'zain@firm.com',    '0305-3456789','1994-10-25','2022-08-30',78000.40, 'Karachi',  'Designer'),
(2007,'Mehwish Anwar', 'mehwish@FIRM.com', '0306-4567890','1989-12-09','2016-07-22',125000.00,'Lahore',   'Director'),
(2008,'Talha Hussain', 'talha@firm.com',   '0307-5678901','1996-03-18','2023-01-09',60000.00, 'Islamabad','HR Officer'),
(2009,'Areeba Yasin',  'areeba@firm.com',  '0308-6789012','1990-07-22','2019-09-12',90000.99, 'Lahore',   'Analyst'),
(2010,'Hassan Ahmed',  'hassan@firm.com',  '0309-7890123','1997-01-30','2024-02-18',65000.00, 'Karachi',  'Junior Developer');

-- Verify dataset
SELECT * FROM Employee;

-- -----------------------------------------------------------------------------
-- Assessment Questions (Q1 to Q10)
-- -----------------------------------------------------------------------------

-- Q1: Display each employee's full name with leading/trailing spaces removed and in proper UPPERCASE.
-- Show EmpID, original FullName, CleanedName.
SELECT 
    EmpID,
    FullName AS OriginalFullName,
    UPPER(TRIM(FullName)) AS CleanedName
FROM Employee;

-- Q2: For employees with a recorded email, extract the username (part before '@'). Show FullName and Username.
SELECT 
    TRIM(FullName) AS FullName,
    SUBSTRING(Email, 1, LOCATE('@', Email) - 1) AS Username
FROM Employee
WHERE Email IS NOT NULL;

-- Q3: Mask each phone number: show the first 4 characters then 'XXX-XXXX'. Skip employees with no phone.
SELECT 
    TRIM(FullName) AS FullName,
    Phone AS OriginalPhone,
    CONCAT(LEFT(Phone, 4), '-XXX-XXXX') AS MaskedPhone
FROM Employee
WHERE Phone IS NOT NULL;

-- Q4: Generate a corporate email for each employee: lowercase the trimmed FullName, replace spaces with dots,
-- then append '@company.com'. (e.g. 'AHMAD RAZA' -> 'ahmad.raza@company.com'.)
-- Show FullName and GeneratedEmail.
SELECT 
    TRIM(FullName) AS FullName,
    CONCAT(LOWER(REPLACE(TRIM(FullName), ' ', '.')), '@company.com') AS GeneratedEmail
FROM Employee;

-- Q5: Apply a 12.5% pay raise to every employee. Show FullName, Salary, NewSalary rounded to 2 decimals.
SELECT 
    TRIM(FullName) AS FullName,
    Salary,
    ROUND(Salary * 1.125, 2) AS NewSalary
FROM Employee;

-- Q6: Round every salary down to the nearest thousand. Show FullName, Salary, RoundedSalary.
SELECT 
    TRIM(FullName) AS FullName,
    Salary,
    FLOOR(Salary / 1000) * 1000 AS RoundedSalary
FROM Employee;

-- Q7: Compute each employee's current age and years of service. Show FullName, AgeYears, YearsOfService.
-- (Use TIMESTAMPDIFF.)
SELECT 
    TRIM(FullName) AS FullName,
    TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS AgeYears,
    TIMESTAMPDIFF(YEAR, HireDate, CURDATE()) AS YearsOfService
FROM Employee;

-- Q8: Format every employee's HireDate as 'DD-Mon-YYYY' (e.g. '01-Sep-2018'). Show FullName and FormattedHireDate.
SELECT 
    TRIM(FullName) AS FullName,
    HireDate,
    DATE_FORMAT(HireDate, '%d-%b-%Y') AS FormattedHireDate
FROM Employee;

-- Q9: List employees who were hired in the year 2019 or later. Use a date function rather than BETWEEN.
SELECT 
    TRIM(FullName) AS FullName,
    HireDate
FROM Employee
WHERE YEAR(HireDate) >= 2019
ORDER BY HireDate ASC;

-- Q10: Combined challenge: produce a single column 'Profile' formatted as:
-- 'AHMAD RAZA | Lahore | Senior Engineer | Joined: 01-Sep-2018 | Age: 35'.
-- Use CONCAT, UPPER, TRIM, DATE_FORMAT, TIMESTAMPDIFF.
SELECT 
    CONCAT(
        UPPER(TRIM(FullName)), ' | ',
        COALESCE(City, 'N/A'), ' | ',
        JobTitle, ' | ',
        'Joined: ', DATE_FORMAT(HireDate, '%d-%b-%Y'), ' | ',
        'Age: ', TIMESTAMPDIFF(YEAR, DOB, CURDATE())
    ) AS Profile
FROM Employee;

-- =============================================================================
-- End of LAB 11 Scalar Functions Part 02 Script
-- =============================================================================
