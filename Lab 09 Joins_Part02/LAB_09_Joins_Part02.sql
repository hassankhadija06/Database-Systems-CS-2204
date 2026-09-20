-- =============================================================================
-- DATABASE SYSTEMS LAB 09: SQL JOINS PART 02 — SELF JOINS, MULTI-TABLE JOINS & ASSESSMENT
-- Reference: LAB_08___09_Manual.pdf (Section 12: Part B & Section 13: Assessment Problem)
-- Objectives:
-- 1. Self Joins on hierarchical structures (Employee to Manager)
-- 2. Multi-table Joins (3-table, 4-table relationships)
-- 3. Complex join logic with filtering and aggregation
-- 4. Graded Assessment Problem (Library Database: Q1 - Q10)
-- =============================================================================

USE joins_lab;

-- =============================================================================
-- PART B — SELF JOINS, MULTI-TABLE JOINS, AND COMBINED CHALLENGES
-- =============================================================================

-- Task B1: For each employee, show their name and their manager's name. 
-- Top-level managers should still appear with NULL Manager. (SELF JOIN)
SELECT 
    e.EmpName AS EmployeeName,
    m.EmpName AS ManagerName
FROM Employee e
LEFT JOIN Employee m ON e.ManagerID = m.EmpID;

-- Task B2: List employees who earn more than their direct manager. 
-- Show employee name, employee salary, manager name, manager salary.
SELECT 
    e.EmpName AS EmployeeName,
    e.Salary AS EmployeeSalary,
    m.EmpName AS ManagerName,
    m.Salary AS ManagerSalary
FROM Employee e
INNER JOIN Employee m ON e.ManagerID = m.EmpID
WHERE e.Salary > m.Salary;

-- Task B3: List employees whose manager works in a different department. 
-- Show EmpName, ManagerName, and both department names.
SELECT 
    e.EmpName AS EmployeeName,
    ed.DeptName AS EmployeeDept,
    m.EmpName AS ManagerName,
    md.DeptName AS ManagerDept
FROM Employee e
INNER JOIN Employee m ON e.ManagerID = m.EmpID
INNER JOIN Department ed ON e.DeptID = ed.DeptID
INNER JOIN Department md ON m.DeptID = md.DeptID
WHERE e.DeptID != m.DeptID;

-- Task B4: Show every employee with the project name they work on and weekly hours.
-- (3-table join: Employee -> Assignment -> Project)
SELECT 
    e.EmpName, 
    p.ProjectName, 
    a.HoursPerWeek
FROM Employee e
INNER JOIN Assignment a ON e.EmpID = a.EmpID
INNER JOIN Project p ON a.ProjectID = p.ProjectID;

-- Task B5: List every assignment with employee name, project name, and the project's department name. (4-table join)
SELECT 
    e.EmpName, 
    p.ProjectName, 
    d.DeptName AS ProjectDepartment, 
    a.HoursPerWeek
FROM Assignment a
INNER JOIN Employee e ON a.EmpID = e.EmpID
INNER JOIN Project p ON a.ProjectID = p.ProjectID
INNER JOIN Department d ON p.DeptID = d.DeptID;

-- Task B6: List the names and weekly hours of employees working on the Mobile App project.
SELECT 
    e.EmpName, 
    a.HoursPerWeek
FROM Employee e
INNER JOIN Assignment a ON e.EmpID = a.EmpID
INNER JOIN Project p ON a.ProjectID = p.ProjectID
WHERE p.ProjectName = 'Mobile App';

-- Task B7: List every employee in Lahore together with the projects they are assigned to (project name and hours). 
-- Include Lahore employees with no assignments.
SELECT 
    e.EmpName, 
    e.City, 
    p.ProjectName, 
    a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
LEFT JOIN Project p ON a.ProjectID = p.ProjectID
WHERE e.City = 'Lahore';

-- Task B8: List the names of employees who work on a project run by a department different from their own.
SELECT 
    e.EmpName, 
    e.DeptID AS EmployeeDeptID, 
    p.ProjectName, 
    p.DeptID AS ProjectDeptID
FROM Employee e
INNER JOIN Assignment a ON e.EmpID = a.EmpID
INNER JOIN Project p ON a.ProjectID = p.ProjectID
WHERE e.DeptID != p.DeptID;

-- Task B9: For each department, list the names of projects that started in 2024. 
-- Include departments that have no such projects. (Condition placed in ON clause to preserve unmatched depts)
SELECT 
    d.DeptName, 
    p.ProjectName, 
    p.StartDate
FROM Department d
LEFT JOIN Project p ON d.DeptID = p.DeptID AND YEAR(p.StartDate) = 2024;

-- Task B10: List every employee with the total hours they work per week across all their projects. 
-- Include employees with zero hours. (LEFT JOIN + SUM + GROUP BY)
SELECT 
    e.EmpID, 
    e.EmpName, 
    COALESCE(SUM(a.HoursPerWeek), 0) AS TotalHoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
GROUP BY e.EmpID, e.EmpName
ORDER BY TotalHoursPerWeek DESC;


-- =============================================================================
-- SECTION 13: GRADED ASSESSMENT PROBLEM — LIBRARY DATABASE
-- =============================================================================

CREATE DATABASE IF NOT EXISTS library_lab;
USE library_lab;

DROP TABLE IF EXISTS Loan, Book, Member, Author;

CREATE TABLE Author (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(60) NOT NULL,
    Country VARCHAR(30)
);

CREATE TABLE Book (
    BookID INT PRIMARY KEY,
    Title VARCHAR(80) NOT NULL,
    Genre VARCHAR(30),
    Price DECIMAL(8,2),
    AuthorID INT,
    PublishedYear INT,
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

CREATE TABLE Member (
    MemberID INT PRIMARY KEY,
    MemberName VARCHAR(60) NOT NULL,
    City VARCHAR(30),
    JoinDate DATE
);

CREATE TABLE Loan (
    LoanID INT PRIMARY KEY,
    MemberID INT,
    BookID INT,
    LoanDate DATE,
    ReturnDate DATE, -- NULL = not yet returned
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

-- Insert Authors
INSERT INTO Author VALUES
(1,'Jane Austen',      'UK'),
(2,'Chinua Achebe',    'Nigeria'),
(3,'Haruki Murakami',  'Japan'),
(4,'Bapsi Sidhwa',     'Pakistan'),
(5,'Mohsin Hamid',     'Pakistan'),
(6,'Anonymous Writer', NULL); -- no books

-- Insert Books
INSERT INTO Book VALUES
(101,'Pride and Prejudice',        'Fiction', 850.00,  1,    1813),
(102,'Emma',                       'Fiction', 900.00,  1,    1815),
(103,'Things Fall Apart',          'Fiction', 1100.00, 2,    1958),
(104,'Norwegian Wood',             'Fiction', 1500.00, 3,    1987),
(105,'Kafka on the Shore',         'Fiction', 1700.00, 3,    2002),
(106,'Ice-Candy-Man',              'Fiction', 1200.00, 4,    1988),
(107,'The Reluctant Fundamentalist','Fiction',1300.00, 5,    2007),
(108,'Exit West',                  'Fiction', 1450.00, 5,    2017),
(109,'Mystery Title',              'Mystery', 950.00,  NULL, 2020); -- no author

-- Insert Members
INSERT INTO Member VALUES
(201,'Ahmad Raza',   'Lahore',    '2023-01-15'),
(202,'Sara Imran',   'Karachi',   '2023-03-20'),
(203,'Bilal Khan',   'Lahore',    '2024-02-10'),
(204,'Fatima Ali',   'Islamabad', '2022-09-05'),
(205,'Hira Yousaf',  NULL,        '2024-05-01'); -- no loans yet

-- Insert Loans
INSERT INTO Loan VALUES
(1, 201, 101, '2024-03-01', '2024-03-15'),
(2, 201, 104, '2024-04-10', NULL),
(3, 202, 103, '2024-02-20', '2024-03-05'),
(4, 202, 107, '2024-05-01', NULL),
(5, 203, 105, '2024-04-25', '2024-05-15'),
(6, 204, 102, '2024-01-10', '2024-01-30'),
(7, 204, 108, '2024-06-01', NULL);

-- -----------------------------------------------------------------------------
-- Assessment Questions (Q1 to Q10)
-- -----------------------------------------------------------------------------

-- Q1: Show every book with its author's name and country. (INNER JOIN)
SELECT 
    b.BookID, 
    b.Title, 
    a.AuthorName, 
    a.Country
FROM Book b
INNER JOIN Author a ON b.AuthorID = a.AuthorID;

-- Q2: Show every author with their books. Authors with no books must still appear once with NULL Title. (LEFT JOIN)
SELECT 
    a.AuthorID, 
    a.AuthorName, 
    b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID;

-- Q3: List members who have never borrowed any book. (LEFT JOIN + IS NULL)
SELECT 
    m.MemberID, 
    m.MemberName, 
    m.City
FROM Member m
LEFT JOIN Loan l ON m.MemberID = l.MemberID
WHERE l.LoanID IS NULL;

-- Q4: List every loan with the member's name, book title, and author's name. (3-table join)
SELECT 
    l.LoanID, 
    m.MemberName, 
    b.Title AS BookTitle, 
    a.AuthorName
FROM Loan l
INNER JOIN Member m ON l.MemberID = m.MemberID
INNER JOIN Book b ON l.BookID = b.BookID
INNER JOIN Author a ON b.AuthorID = a.AuthorID;

-- Q5: List currently borrowed books (ReturnDate IS NULL) along with the borrower's name and city.
SELECT 
    b.Title, 
    m.MemberName, 
    m.City, 
    l.LoanDate
FROM Loan l
INNER JOIN Book b ON l.BookID = b.BookID
INNER JOIN Member m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL;

-- Q6: List Pakistani authors and the titles of their books. Include Pakistani authors with no books. (LEFT JOIN + WHERE on author country)
SELECT 
    a.AuthorName, 
    b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
WHERE a.Country = 'Pakistan';

-- Q7: List every book together with the names of all members who have borrowed it. Include books that have never been borrowed. (LEFT JOIN chain)
SELECT 
    b.Title, 
    m.MemberName, 
    l.LoanDate
FROM Book b
LEFT JOIN Loan l ON b.BookID = l.BookID
LEFT JOIN Member m ON l.MemberID = m.MemberID;

-- Q8: Find authors whose books have never been borrowed. (Multi-step: Author -> Book -> Loan)
SELECT 
    a.AuthorID, 
    a.AuthorName
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
LEFT JOIN Loan l ON b.BookID = l.BookID
GROUP BY a.AuthorID, a.AuthorName
HAVING COUNT(l.LoanID) = 0;

-- Q9: Produce a FULL OUTER JOIN of Author and Book using UNION — every author and every book, matched where possible.
SELECT 
    a.AuthorName, 
    b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID

UNION

SELECT 
    a.AuthorName, 
    b.Title
FROM Author a
RIGHT JOIN Book b ON a.AuthorID = b.AuthorID;

-- Q10: List members who have borrowed books written by Pakistani authors. Show member name, book title, and author name. (4-way join with filter)
SELECT 
    m.MemberName, 
    b.Title, 
    a.AuthorName
FROM Member m
INNER JOIN Loan l ON m.MemberID = l.MemberID
INNER JOIN Book b ON l.BookID = b.BookID
INNER JOIN Author a ON b.AuthorID = a.AuthorID
WHERE a.Country = 'Pakistan';

-- =============================================================================
-- End of LAB 09 Joins Part 02 Script
-- =============================================================================
