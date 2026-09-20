-- =============================================================================
-- DATABASE SYSTEMS LAB 06: SQL FILTERS PART 01 — COMPARISON & LOGICAL OPERATORS
-- Reference: LAB_06___07_Manual.pdf (Section 3 & Section 6: Part A)
-- Objectives:
-- 1. Setup Employee Database Schema and load dataset
-- 2. Practice WHERE clause filtering with Comparison Operators (=, !=, <, >, <=, >=)
-- 3. Combine conditions with Logical Operators (AND, OR, NOT) & operator precedence
-- =============================================================================

CREATE DATABASE IF NOT EXISTS filters_lab;
USE filters_lab;

-- =============================================================================
-- SCHEMA SETUP & DATA POPULATION
-- =============================================================================

DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50) NOT NULL,
    Gender CHAR(1),
    Salary DECIMAL(10,2),
    HireDate DATE,
    City VARCHAR(30),
    JobTitle VARCHAR(40),
    DeptName VARCHAR(40)
);

INSERT INTO Employee VALUES
(101,'Ali Khan',      'M',120000.00,'2018-03-15','Lahore',    'Senior Engineer',  'Engineering'),
(102,'Sara Iqbal',    'F', 95000.00,'2019-06-01','Lahore',    'Software Engineer','Engineering'),
(103,'Hamza Raza',    'M', 85000.00,'2020-01-20','Karachi',   'Software Engineer','Engineering'),
(104,'Ayesha Noor',   'F',110000.00,'2017-11-10','Karachi',   'Marketing Lead',   'Marketing'),
(105,'Bilal Ahmed',   'M', 70000.00,'2021-04-05','Karachi',   'Marketing Exec',   'Marketing'),
(106,'Fatima Sheikh', 'F', 90000.00,'2019-09-12','Islamabad', 'Accountant',       'Finance'),
(107,'Usman Tariq',   'M', 78000.00,'2022-02-18','Islamabad', 'Accountant',       'Finance'),
(108,'Maira Javed',   'F',115000.00,'2016-07-22','Lahore',    'Research Lead',    'Research'),
(109,'Zain Abbas',    'M', 60000.00,'2023-01-09','Lahore',    'Research Analyst', 'Research'),
(110,'Nida Yousaf',   'F', 72000.00,'2022-08-30',NULL,        'Research Analyst', 'Research'),
(111,'Adeel Akhtar',  'M', 88000.00,'2020-05-14','Lahore',    'QA Engineer',      'Engineering'),
(112,'Sana Malik',    'F',102000.00,'2018-12-01','Karachi',   'Sales Manager',    'Sales'),
(113,'Talha Hussain', 'M', 65000.00,'2023-07-18','Islamabad', 'Sales Exec',        'Sales'),
(114,'Mehwish Anwar', 'F', 80000.00,'2021-10-25','Lahore',    'HR Officer',        'HR'),
(115,'Imran Shafi',   'M',125000.00,'2015-04-30',NULL,        'Director',         'Engineering');

-- Verify data
SELECT * FROM Employee;

-- =============================================================================
-- PART A — COMPARISON & LOGICAL OPERATORS
-- =============================================================================

-- Task A1: List EmpID, EmpName, and Salary of all employees who earn more than 90,000.
SELECT EmpID, EmpName, Salary
FROM Employee
WHERE Salary > 90000;

-- Task A2: Show all employees with salary less than or equal to 75,000. Display EmpName and Salary.
SELECT EmpName, Salary
FROM Employee
WHERE Salary <= 75000;

-- Task A3: Find every employee who works in Lahore and earns more than 90,000.
SELECT *
FROM Employee
WHERE City = 'Lahore' AND Salary > 90000;

-- Task A4: List employees in Karachi or Islamabad. Show EmpName and City.
SELECT EmpName, City
FROM Employee
WHERE City = 'Karachi' OR City = 'Islamabad';

-- Task A5: Find female employees who are not in the Engineering department.
SELECT *
FROM Employee
WHERE Gender = 'F' AND DeptName != 'Engineering';

-- Task A6: Show employees who are male and earn between 70,000 and 90,000 
-- (use AND and comparison operators only — no BETWEEN yet).
SELECT *
FROM Employee
WHERE Gender = 'M' AND Salary >= 70000 AND Salary <= 90000;

-- Task A7: List employees who are either Software Engineers or earn more than 100,000.
SELECT *
FROM Employee
WHERE JobTitle = 'Software Engineer' OR Salary > 100000;

-- Task A8: Find employees who are not in Marketing and not in Sales.
SELECT *
FROM Employee
WHERE DeptName != 'Marketing' AND DeptName != 'Sales';

-- =============================================================================
-- End of LAB 06 Filters Part 01 Script
-- =============================================================================
