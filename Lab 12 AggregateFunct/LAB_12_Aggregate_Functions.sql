-- =============================================================================
-- DATABASE SYSTEMS LAB 12: AGGREGATE FUNCTIONS — GROUP BY, HAVING & ASSESSMENT
-- Reference: LAB_12_Aggregeate_Functions_Manual.pdf
-- Objectives:
-- 1. Five core aggregate functions: COUNT, SUM, AVG, MIN, MAX
-- 2. NULL handling in aggregates (COUNT(*) vs COUNT(col))
-- 3. Group-level aggregations using GROUP BY (Golden Rule of GROUP BY)
-- 4. Filtering grouped data using HAVING vs WHERE
-- 5. Combining Aggregates with multi-table JOINs
-- 6. Graded Assessment Problem (University Database: Q1 - Q12)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS agg_lab;
USE agg_lab;

-- =============================================================================
-- SCHEMA SETUP & SAMPLE DATA INSERTS
-- =============================================================================

DROP TABLE IF EXISTS OrderItem, Product, Customer;

CREATE TABLE Customer (
    CustID INT PRIMARY KEY,
    CustName VARCHAR(60) NOT NULL,
    City VARCHAR(30),
    JoinDate DATE
);

CREATE TABLE Product (
    ProdID INT PRIMARY KEY,
    ProdName VARCHAR(60) NOT NULL,
    Category VARCHAR(30),
    Price DECIMAL(10,2),
    StockQty INT
);

CREATE TABLE OrderItem (
    OrderID INT PRIMARY KEY,
    CustID INT,
    ProdID INT,
    Quantity INT,
    OrderDate DATE,
    FOREIGN KEY (CustID) REFERENCES Customer(CustID),
    FOREIGN KEY (ProdID) REFERENCES Product(ProdID)
);

-- Customers (Customer 6 has NULL city; Customer 8 has no orders)
INSERT INTO Customer VALUES
(1, 'Ali Khan',      'Lahore',    '2022-01-15'),
(2, 'Sara Iqbal',    'Karachi',   '2022-04-22'),
(3, 'Hamza Raza',    'Lahore',    '2023-02-10'),
(4, 'Ayesha Noor',   'Islamabad', '2023-05-18'),
(5, 'Bilal Ahmed',   'Karachi',   '2023-09-01'),
(6, 'Fatima Sheikh', NULL,        '2024-01-12'),
(7, 'Usman Tariq',   'Lahore',    '2024-06-30'),
(8, 'Maira Javed',   'Islamabad', '2024-08-25');

-- Products
INSERT INTO Product VALUES
(101,'Laptop Pro 15',      'Electronics', 185000.00, 12),
(102,'Wireless Mouse',     'Electronics', 2500.00,   50),
(103,'USB-C Cable',        'Electronics', 800.00,    100),
(104,'Office Chair',       'Furniture',   18500.00,  8),
(105,'Standing Desk',      'Furniture',   45000.50,  5),
(106,'Notebook A4',        'Stationery',  350.00,    200),
(107,'Ballpoint Pen 10pk', 'Stationery',  450.00,    150),
(108,'Coffee Beans 1kg',   'Grocery',     1899.99,   30),
(109,'Green Tea Box',      'Grocery',     650.00,    45),
(110,'Bluetooth Speaker',  'Electronics', 7500.00,   18);

-- OrderItems
INSERT INTO OrderItem VALUES
(1001, 1, 101, 1,  '2023-03-10'),
(1002, 1, 102, 2,  '2023-03-10'),
(1003, 2, 104, 1,  '2023-05-22'),
(1004, 2, 106, 5,  '2023-05-22'),
(1005, 3, 101, 1,  '2023-08-15'),
(1006, 3, 110, 1,  '2023-08-15'),
(1007, 4, 108, 3,  '2023-11-02'),
(1008, 5, 103, 4,  '2024-01-20'),
(1009, 5, 102, 1,  '2024-01-20'),
(1010, 6, 105, 1,  '2024-02-14'),
(1011, 7, 107, 2,  '2024-04-08'),
(1012, 7, 106, 10, '2024-04-08'),
(1013, 7, 109, 3,  '2024-07-19'),
(1014, 2, 110, 1,  '2024-09-05'),
(1015, 3, 108, 2,  '2024-10-11');

-- Verify dataset
SELECT * FROM Customer;
SELECT * FROM Product;
SELECT * FROM OrderItem;

-- =============================================================================
-- PART A — WHOLE-TABLE AGGREGATES & COUNT VARIATIONS
-- =============================================================================

-- Task A1: Count the total number of customers, products, and orders in the database
-- (one query with three columns).
SELECT 
    (SELECT COUNT(*) FROM Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM Product) AS TotalProducts,
    (SELECT COUNT(*) FROM OrderItem) AS TotalOrders;

-- Task A2: Find the cheapest and most expensive products. Show MinPrice and MaxPrice.
SELECT 
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice
FROM Product;

-- Task A3: What is the average price of all products? Round to 2 decimal places.
SELECT 
    ROUND(AVG(Price), 2) AS AverageProductPrice
FROM Product;

-- Task A4: What is the total stock quantity across all products?
SELECT 
    SUM(StockQty) AS TotalStockQuantity
FROM Product;

-- Task A5: How many distinct cities do customers live in (ignoring NULL)?
SELECT 
    COUNT(DISTINCT City) AS DistinctCitiesCount
FROM Customer;

-- Task A6: How many distinct categories of products are there?
SELECT 
    COUNT(DISTINCT Category) AS DistinctCategoriesCount
FROM Product;

-- Task A7: How many customers have a recorded city? How many do not? (Two queries)
-- Query 1: With recorded city
SELECT COUNT(City) AS CustomersWithRecordedCity FROM Customer;

-- Query 2: Without recorded city (NULL)
SELECT COUNT(*) AS CustomersWithoutCity FROM Customer WHERE City IS NULL;

-- Task A8: Find the earliest and latest order date in the system.
SELECT 
    MIN(OrderDate) AS EarliestOrderDate,
    MAX(OrderDate) AS LatestOrderDate
FROM OrderItem;

-- Task A9: Compute the total revenue from all orders. Revenue per row = Quantity * Price; total = SUM.
SELECT 
    SUM(o.Quantity * p.Price) AS TotalRevenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID;

-- Task A10: Compute the average quantity per order (average of Quantity column in OrderItem). Round to 2 decimals.
SELECT 
    ROUND(AVG(Quantity), 2) AS AvgQuantityPerOrder
FROM OrderItem;


-- =============================================================================
-- PART B — GROUP BY, HAVING, AND AGGREGATES WITH JOINS
-- =============================================================================

-- Task B1: Number of customers in each city. Sort by count descending. (GROUP BY.)
SELECT 
    COALESCE(City, 'Unknown/NULL') AS City,
    COUNT(*) AS CustomerCount
FROM Customer
GROUP BY City
ORDER BY CustomerCount DESC;

-- Task B2: Number of products in each category. Sort by count descending.
SELECT 
    Category,
    COUNT(*) AS ProductCount
FROM Product
GROUP BY Category
ORDER BY ProductCount DESC;

-- Task B3: For each product category, find the average, minimum, and maximum price. 
-- Sort by average price descending.
SELECT 
    Category,
    ROUND(AVG(Price), 2) AS AvgPrice,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice
FROM Product
GROUP BY Category
ORDER BY AvgPrice DESC;

-- Task B4: Total stock quantity per category. Sort by total descending.
SELECT 
    Category,
    SUM(StockQty) AS TotalStock
FROM Product
GROUP BY Category
ORDER BY TotalStock DESC;

-- Task B5: Number of orders placed in each year. Show Year and NumOrders, sorted by year.
SELECT 
    YEAR(OrderDate) AS OrderYear,
    COUNT(*) AS NumOrders
FROM OrderItem
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear ASC;

-- Task B6: Number of orders placed each month of 2024. Show Month (1–12) and NumOrders, sorted by month.
SELECT 
    MONTH(OrderDate) AS OrderMonth,
    COUNT(*) AS NumOrders
FROM OrderItem
WHERE YEAR(OrderDate) = 2024
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth ASC;

-- Task B7: Find product categories where the average price is greater than 5,000. (GROUP BY + HAVING.)
SELECT 
    Category,
    ROUND(AVG(Price), 2) AS AvgPrice
FROM Product
GROUP BY Category
HAVING AVG(Price) > 5000;

-- Task B8: Find cities with more than 1 customer (exclude NULL city). (WHERE + GROUP BY + HAVING.)
SELECT 
    City,
    COUNT(*) AS CustomerCount
FROM Customer
WHERE City IS NOT NULL
GROUP BY City
HAVING COUNT(*) > 1;

-- Task B9: For each customer, count how many orders they have placed. 
-- Include customers with zero orders. (LEFT JOIN + COUNT.)
SELECT 
    c.CustID,
    c.CustName,
    COUNT(o.OrderID) AS TotalOrdersPlaced
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
GROUP BY c.CustID, c.CustName
ORDER BY TotalOrdersPlaced DESC;

-- Task B10: Total quantity sold for each product. Show ProdName and TotalQty, sorted by TotalQty descending.
-- Include products that have never been sold (TotalQty should be 0 or NULL). (LEFT JOIN.)
SELECT 
    p.ProdID,
    p.ProdName,
    COALESCE(SUM(o.Quantity), 0) AS TotalQuantitySold
FROM Product p
LEFT JOIN OrderItem o ON p.ProdID = o.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQuantitySold DESC;

-- Task B11: Total revenue (Quantity * Price) per product category. Sort by revenue descending.
SELECT 
    p.Category,
    SUM(o.Quantity * p.Price) AS TotalRevenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.Category
ORDER BY TotalRevenue DESC;

-- Task B12: For each customer, compute their total spend. Show CustName and TotalSpend, sorted descending.
-- Include customers with no orders. (LEFT JOIN.)
SELECT 
    c.CustID,
    c.CustName,
    COALESCE(SUM(o.Quantity * p.Price), 0.00) AS TotalSpend
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
LEFT JOIN Product p ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
ORDER BY TotalSpend DESC;

-- Task B13: List customers whose total spend exceeds 50,000. Show CustName and TotalSpend. (HAVING.)
SELECT 
    c.CustName,
    SUM(o.Quantity * p.Price) AS TotalSpend
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
HAVING SUM(o.Quantity * p.Price) > 50000;

-- Task B14: For each city, count the number of customers and total revenue generated by them.
-- Include only cities with more than 1 customer. (GROUP BY + HAVING.)
SELECT 
    c.City,
    COUNT(DISTINCT c.CustID) AS CustomerCount,
    SUM(o.Quantity * p.Price) AS TotalCityRevenue
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p ON o.ProdID = p.ProdID
WHERE c.City IS NOT NULL
GROUP BY c.City
HAVING COUNT(DISTINCT c.CustID) > 1
ORDER BY TotalCityRevenue DESC;

-- Task B15: Find the top 3 best-selling products by total quantity sold. (GROUP BY + ORDER BY + LIMIT.)
SELECT 
    p.ProdName,
    SUM(o.Quantity) AS TotalQtySold
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQtySold DESC
LIMIT 3;

-- Task B16: For each year, compute the total revenue. Show Year and Revenue, sorted by year.
SELECT 
    YEAR(o.OrderDate) AS RevenueYear,
    SUM(o.Quantity * p.Price) AS TotalRevenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY YEAR(o.OrderDate)
ORDER BY RevenueYear ASC;

-- Task B17: Find the average order value (revenue per order).
-- Group by OrderID first to get each order's value, then average those values.
SELECT 
    ROUND(AVG(OrderTotal), 2) AS AverageOrderValue
FROM (
    SELECT 
        o.OrderID,
        SUM(o.Quantity * p.Price) AS OrderTotal
    FROM OrderItem o
    JOIN Product p ON o.ProdID = p.ProdID
    GROUP BY o.OrderID
) AS OrderTotals;


-- =============================================================================
-- SECTION 11: GRADED ASSESSMENT PROBLEM — UNIVERSITY DATABASE
-- =============================================================================

CREATE DATABASE IF NOT EXISTS uni_lab;
USE uni_lab;

DROP TABLE IF EXISTS Enrollment, Course, Student;

CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FullName VARCHAR(60) NOT NULL,
    City VARCHAR(30),
    EnrollDate DATE
);

CREATE TABLE Course (
    CourseID VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(60) NOT NULL,
    Department VARCHAR(30),
    Credits INT,
    Fee DECIMAL(10,2)
);

CREATE TABLE Enrollment (
    EnrollID INT PRIMARY KEY,
    StudentID INT,
    CourseID VARCHAR(10),
    Marks INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Insert Students (Student 1009 has no enrollments; Student 1005 has NULL city)
INSERT INTO Student VALUES
(1001, 'Ahmad Raza',    'Lahore',    '2022-09-01'),
(1002, 'Sara Imran',    'Karachi',   '2022-09-01'),
(1003, 'Bilal Khan',    'Lahore',    '2023-09-01'),
(1004, 'Fatima Ali',    'Islamabad', '2022-09-01'),
(1005, 'Hira Yousaf',   NULL,        '2024-09-01'),
(1006, 'Zain Abbas',    'Karachi',   '2023-09-01'),
(1007, 'Mehwish Anwar', 'Lahore',    '2022-09-01'),
(1008, 'Talha Hussain', 'Islamabad', '2024-09-01'),
(1009, 'Areeba Yasin',  'Lahore',    '2023-09-01');

-- Insert Courses (Course BB301 has no enrollments)
INSERT INTO Course VALUES
('CS101','Intro to Programming', 'Computer Science', 3, 25000.00),
('CS201','Database Systems',     'Computer Science', 3, 28000.00),
('CS301','Operating Systems',    'Computer Science', 4, 30000.00),
('MT101','Calculus I',           'Mathematics',      3, 22000.00),
('EE201','Digital Logic',        'Electrical Engg',  3, 26000.00),
('BB301','Marketing Basics',     'Business',         3, 24000.00);

-- Insert Enrollments
INSERT INTO Enrollment VALUES
(1,  1001,'CS101', 78, '2022-09-15'),
(2,  1001,'CS201', 85, '2023-09-15'),
(3,  1001,'MT101', 90, '2022-09-15'),
(4,  1002,'CS101', 65, '2022-09-15'),
(5,  1002,'CS201', 72, '2023-09-15'),
(6,  1003,'CS101', 88, '2023-09-15'),
(7,  1003,'EE201', 80, '2023-09-15'),
(8,  1004,'MT101', 95, '2022-09-15'),
(9,  1004,'CS201', 70, '2023-09-15'),
(10, 1005,'CS101', 55, '2024-09-15'),
(11, 1006,'CS101', 82, '2023-09-15'),
(12, 1006,'CS301', 76, '2024-09-15'),
(13, 1007,'CS201', 91, '2023-09-15'),
(14, 1007,'CS301', 86, '2024-09-15'),
(15, 1008,'CS101', 60, '2024-09-15'),
(16, 1008,'MT101', 68, '2024-09-15');

-- -----------------------------------------------------------------------------
-- Assessment Questions (Q1 to Q12)
-- -----------------------------------------------------------------------------

-- Q1: How many students and how many courses are there? (Two values in one query.)
SELECT 
    (SELECT COUNT(*) FROM Student) AS TotalStudents,
    (SELECT COUNT(*) FROM Course) AS TotalCourses;

-- Q2: How many distinct cities do students come from (ignore NULL)?
SELECT 
    COUNT(DISTINCT City) AS DistinctCitiesCount
FROM Student;

-- Q3: Compute the average, minimum, and maximum Marks across all enrollments.
SELECT 
    ROUND(AVG(Marks), 2) AS AverageMarks,
    MIN(Marks) AS MinimumMarks,
    MAX(Marks) AS MaximumMarks
FROM Enrollment;

-- Q4: Number of students in each city. Sort by count descending. Include the NULL-city group at the end.
SELECT 
    COALESCE(City, 'Unknown/NULL') AS City,
    COUNT(*) AS StudentCount
FROM Student
GROUP BY City
ORDER BY (City IS NULL) ASC, StudentCount DESC;

-- Q5: Number of courses offered by each department, sorted by count descending.
SELECT 
    Department,
    COUNT(*) AS CourseCount
FROM Course
GROUP BY Department
ORDER BY CourseCount DESC;

-- Q6: For each course, show CourseName, the number of students enrolled, and the average marks.
-- Sort by average marks descending. (JOIN + GROUP BY.)
SELECT 
    c.CourseName,
    COUNT(e.EnrollID) AS EnrolledStudentsCount,
    ROUND(AVG(e.Marks), 2) AS AverageMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
ORDER BY AverageMarks DESC;

-- Q7: List courses with an average marks above 80. Show CourseName and AvgMarks. (HAVING.)
SELECT 
    c.CourseName,
    ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING AVG(e.Marks) > 80;

-- Q8: Total fee revenue per department, assuming each enrolled student paid the course fee.
-- Show Department and TotalRevenue, sorted descending. (3-table join + GROUP BY.)
SELECT 
    c.Department,
    SUM(c.Fee) AS TotalRevenue
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.Department
ORDER BY TotalRevenue DESC;

-- Q9: For each student, show how many courses they are enrolled in and their average marks.
-- Include students with no enrollments (count = 0, avg = NULL). (LEFT JOIN + GROUP BY.)
SELECT 
    s.StudentID,
    s.FullName,
    COUNT(e.EnrollID) AS EnrolledCoursesCount,
    ROUND(AVG(e.Marks), 2) AS AverageMarks
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName
ORDER BY EnrolledCoursesCount DESC;

-- Q10: Find students who scored above 85 in at least one course.
-- Show their FullName and the highest mark they have achieved. (GROUP BY + HAVING + MAX.)
SELECT 
    s.FullName,
    MAX(e.Marks) AS HighestMark
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName
HAVING MAX(e.Marks) > 85;

-- Q11: List departments where the average marks across all their courses is below 75.
-- Show Department and OverallAvgMarks. (Multi-step JOIN + GROUP BY + HAVING.)
SELECT 
    c.Department,
    ROUND(AVG(e.Marks), 2) AS OverallAvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.Department
HAVING AVG(e.Marks) < 75;

-- Q12: Find the top 3 students by total fee they have paid (sum of fees of their enrolled courses).
-- Show FullName and TotalFee. (JOIN + GROUP BY + ORDER BY + LIMIT.)
SELECT 
    s.FullName,
    SUM(c.Fee) AS TotalFeePaid
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c ON e.CourseID = c.CourseID
GROUP BY s.StudentID, s.FullName
ORDER BY TotalFeePaid DESC
LIMIT 3;

-- =============================================================================
-- End of LAB 12 Aggregate Functions Script
-- =============================================================================
