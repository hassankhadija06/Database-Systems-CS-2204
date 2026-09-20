-- =============================================================================
-- DATABASE SYSTEMS LAB 04: NORMALIZATION — OVERVIEW AND 1NF
-- Reference: LAB_04___LAB_05_Manual.pdf
-- Objectives:
-- 1. Understand normalization principles, redundancy, and anomalies.
-- 2. Identify Functional Dependencies (FDs) and Candidate Keys.
-- 3. Eliminate repeating groups and multi-valued attributes to achieve 1NF.
-- 4. Implement Bookstore Scenario (Task 1 & Task 2 in MySQL).
-- 5. Implement Hospital Assessment Scenario (Deliverable 1 & Deliverable 2 in MySQL).
-- =============================================================================

CREATE DATABASE IF NOT EXISTS normalization_lab;
USE normalization_lab;

-- =============================================================================
-- PART 1: CONCEPTUAL OVERVIEW & WORKED CLASS EXAMPLE
-- =============================================================================
/*
  1. What is Normalization?
     Normalization is the disciplined process of decomposing a flat/unnormalized
     table into structured relations to eliminate data redundancy and prevent
     insertion, update, and deletion anomalies.

  2. The Three Serious Anomalies of Unnormalized Data:
     - Insertion Anomaly: Cannot record new information without unrelated data
       (e.g., cannot add a new course or doctor until a student/patient registers).
     - Update Anomaly: Updating a single fact requires changing multiple rows.
       If one row is missed, data becomes inconsistent.
     - Deletion Anomaly: Deleting one fact unintentionally wipes out another fact
       (e.g., deleting a student cancels the only record of an instructor's office).

  3. First Normal Form (1NF) Rules:
     - Every cell must hold a single, atomic (indivisible) value.
     - No repeating groups or comma-separated/multi-valued lists.
     - Each row must be uniquely identified by a primary key (often composite in 1NF).
*/

-- Class Example 1NF Table:
DROP TABLE IF EXISTS Registration_1NF;
CREATE TABLE Registration_1NF (
    StuID VARCHAR(10),
    StuName VARCHAR(50),
    StuCity VARCHAR(30),
    CourseCode VARCHAR(10),
    CourseTitle VARCHAR(50),
    Credits INT,
    InstID VARCHAR(10),
    InstName VARCHAR(50),
    InstOffice VARCHAR(10),
    PRIMARY KEY (StuID, CourseCode)
);

INSERT INTO Registration_1NF VALUES
('S101','Ali','Lahore','CS-201','DB',3,'I-01','Ahmed','R-12'),
('S101','Ali','Lahore','CS-305','OS',3,'I-02','Bilal','R-18'),
('S102','Sara','Karachi','CS-201','DB',3,'I-01','Ahmed','R-12'),
('S102','Sara','Karachi','CS-410','AI',4,'I-03','Sana','R-22');

SELECT * FROM Registration_1NF;

-- =============================================================================
-- PART 2: BOOKSTORE LAB TASKS (SECTION 7)
-- =============================================================================

/*
  -----------------------------------------------------------------------------
  Task 1 — Identify FDs and Anomalies (Bookstore Scenario)
  -----------------------------------------------------------------------------
  Raw Data given in Table 7.1:
  - Orders: O-501, O-502, O-503
  - Multi-valued books: SQL Basics (B-1), Python 101 (B-2), Networks (B-3)

  Functional Dependencies (FDs) identified:
  1. OrderID -> OrderDate, CustID
  2. CustID -> CustName, CustEmail
  3. BookID -> BookTitle, Publisher, UnitPrice
  4. (OrderID, BookID) -> Qty

  Candidate Key for the 1NF table:
  - (OrderID, BookID) uniquely identifies each row.

  Anomalies in Unnormalized Flat Design:
  1. Insertion Anomaly: We cannot add a newly published book (e.g. B-4 'Cloud Computing')
     into the bookstore catalog until a customer places an order for it.
  2. Update Anomaly: If customer Bilal changes his email address, we must update
     every single row across multiple orders and order lines. If one row is missed,
     conflicting emails exist for the same customer.
  3. Deletion Anomaly: If order O-502 is cancelled and deleted, we risk losing the
     only sales record that customer Areeba exists if she has no other orders.
*/

-- -----------------------------------------------------------------------------
-- Task 2 — Convert Bookstore Data to 1NF (Table OrderBook_1NF)
-- -----------------------------------------------------------------------------
-- In 1NF, all multi-valued cells (lists of books, publishers, prices, and quantities)
-- are flattened into atomic rows with composite primary key (OrderID, BookID).

DROP TABLE IF EXISTS OrderBook_1NF;

CREATE TABLE OrderBook_1NF (
    OrderID VARCHAR(10) NOT NULL,
    OrderDate DATE NOT NULL,
    CustID VARCHAR(10) NOT NULL,
    CustName VARCHAR(50) NOT NULL,
    CustEmail VARCHAR(50) NOT NULL,
    BookID VARCHAR(10) NOT NULL,
    BookTitle VARCHAR(60) NOT NULL,
    Publisher VARCHAR(40) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Qty INT NOT NULL,
    PRIMARY KEY (OrderID, BookID)
);

-- Insert all atomic rows corresponding to Table 7.1
INSERT INTO OrderBook_1NF VALUES
('O-501', '2026-04-02', 'C-11', 'Bilal', 'bilal@x.com', 'B-1', 'SQL Basics', 'Pearson', 1200.00, 1),
('O-501', '2026-04-02', 'C-11', 'Bilal', 'bilal@x.com', 'B-2', 'Python 101', 'OReilly', 1500.00, 2),
('O-502', '2026-04-03', 'C-12', 'Areeba', 'areeba@x.com', 'B-1', 'SQL Basics', 'Pearson', 1200.00, 3),
('O-503', '2026-04-05', 'C-11', 'Bilal', 'bilal@x.com', 'B-3', 'Networks', 'Pearson', 1800.00, 1),
('O-503', '2026-04-05', 'C-11', 'Bilal', 'bilal@x.com', 'B-2', 'Python 101', 'OReilly', 1500.00, 1);

-- Verify 1NF Table
SELECT * FROM OrderBook_1NF;

-- =============================================================================
-- PART 3: GRADED ASSESSMENT PROBLEM — HOSPITAL PATIENT VISITS (1NF)
-- =============================================================================

/*
  -----------------------------------------------------------------------------
  Assessment Deliverable 1: Functional Dependencies & Candidate Keys
  -----------------------------------------------------------------------------
  Data Attributes:
  - VisitID, VisitDate, PatientID, PatientName, PatientPhone,
    DoctorID, DoctorName, Specialty, DeptName, DeptHead,
    Diagnosis, Fee

  Functional Dependencies:
  1. VisitID -> VisitDate, PatientID, DoctorID, Diagnosis, Fee
  2. PatientID -> PatientName, PatientPhone
  3. DoctorID -> DoctorName, Specialty, DeptName
  4. DeptName -> DeptHead

  Candidate Key:
  - Primary Candidate Key: VisitID (Every consultation visit has a unique VisitID).
*/

-- -----------------------------------------------------------------------------
-- Assessment Deliverable 2: 1NF Table Implementation in MySQL
-- -----------------------------------------------------------------------------
-- Unnormalized representation flattened into atomic fields:

DROP TABLE IF EXISTS Hospital_1NF;

CREATE TABLE Hospital_1NF (
    VisitID VARCHAR(10) PRIMARY KEY,
    VisitDate DATE NOT NULL,
    PatientID VARCHAR(10) NOT NULL,
    PatientName VARCHAR(50) NOT NULL,
    PatientPhone VARCHAR(20) NOT NULL,
    DoctorID VARCHAR(10) NOT NULL,
    DoctorName VARCHAR(50) NOT NULL,
    Specialty VARCHAR(50) NOT NULL,
    DeptName VARCHAR(50) NOT NULL,
    DeptHead VARCHAR(50) NOT NULL,
    Diagnosis VARCHAR(100) NOT NULL,
    Fee DECIMAL(10,2) NOT NULL
);

INSERT INTO Hospital_1NF VALUES
('V-9001', '2026-04-10', 'P-201', 'Hassan',  '0300-1112233', 'D-30', 'Dr. Imran', 'Cardiology',  'Heart Care',  'Dr. Tariq', 'Hypertension', 2500.00),
('V-9002', '2026-04-10', 'P-202', 'Mehreen', '0301-4445566', 'D-31', 'Dr. Asma',  'Dermatology', 'Skin Clinic', 'Dr. Asma',  'Eczema',       2000.00),
('V-9003', '2026-04-11', 'P-201', 'Hassan',  '0300-1112233', 'D-31', 'Dr. Asma',  'Dermatology', 'Skin Clinic', 'Dr. Asma',  'Allergy',      2000.00),
('V-9004', '2026-04-12', 'P-203', 'Junaid',  '0302-7778899', 'D-30', 'Dr. Imran', 'Cardiology',  'Heart Care',  'Dr. Tariq', 'Arrhythmia',   3000.00);

-- Query the 1NF representation
SELECT * FROM Hospital_1NF;

-- Observations at 1NF:
-- Notice that Patient Hassan's phone and name repeat across V-9001 and V-9003.
-- Doctor details and department head repeat across multiple visits.
-- This redundancy will be eliminated in 2NF and 3NF during LAB 05.

-- =============================================================================
-- End of LAB 04 Normalization Overview and 1NF Script
-- =============================================================================
