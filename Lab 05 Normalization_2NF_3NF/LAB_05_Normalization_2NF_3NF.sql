-- =============================================================================
-- DATABASE SYSTEMS LAB 05: CONVERSION TO 2NF AND 3NF
-- Reference: LAB_04___LAB_05_Manual.pdf
-- Objectives:
-- 1. Identify and eliminate Partial Dependencies -> Second Normal Form (2NF).
-- 2. Identify and eliminate Transitive Dependencies -> Third Normal Form (3NF).
-- 3. Implement Bookstore 2NF and 3NF decomposed schemas with foreign keys.
-- 4. Execute verification and business reporting queries on 3NF tables.
-- 5. Complete Hospital Graded Assessment (Deliverables 3, 4, 5, 6).
-- =============================================================================

CREATE DATABASE IF NOT EXISTS normalization_2nf_3nf_lab;
USE normalization_2nf_3nf_lab;

-- =============================================================================
-- SECTION 1: BOOKSTORE LAB TASKS (TASKS 3, 4, 5, 6)
-- =============================================================================

/*
  -----------------------------------------------------------------------------
  Task 3 — Convert Bookstore 1NF to 2NF
  -----------------------------------------------------------------------------
  In OrderBook_1NF, the primary key is composite: (OrderID, BookID).
  
  Partial Dependencies Identified:
  1. OrderID -> OrderDate, CustID, CustName, CustEmail
     (These attributes depend only on OrderID, not on BookID).
  2. BookID -> BookTitle, Publisher, UnitPrice
     (These attributes depend only on BookID, not on OrderID).
  
  Full Dependency:
  - (OrderID, BookID) -> Qty
  
  Resolution for 2NF:
  Decompose into three tables so that every non-key attribute depends on
  the ENTIRE primary key of its table:
  1. Order_2NF (OrderID, OrderDate, CustID, CustName, CustEmail) [PK: OrderID]
  2. Book_2NF (BookID, BookTitle, Publisher, UnitPrice) [PK: BookID]
  3. OrderItem_2NF (OrderID, BookID, Qty) [PK: (OrderID, BookID)]
*/

DROP TABLE IF EXISTS Bookstore_OrderItem_2NF;
DROP TABLE IF EXISTS Bookstore_Order_2NF;
DROP TABLE IF EXISTS Bookstore_Book_2NF;

CREATE TABLE Bookstore_Book_2NF (
    BookID VARCHAR(10) PRIMARY KEY,
    BookTitle VARCHAR(60) NOT NULL,
    Publisher VARCHAR(40) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

CREATE TABLE Bookstore_Order_2NF (
    OrderID VARCHAR(10) PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustID VARCHAR(10) NOT NULL,
    CustName VARCHAR(50) NOT NULL,
    CustEmail VARCHAR(50) NOT NULL
);

CREATE TABLE Bookstore_OrderItem_2NF (
    OrderID VARCHAR(10) NOT NULL,
    BookID VARCHAR(10) NOT NULL,
    Qty INT NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    FOREIGN KEY (OrderID) REFERENCES Bookstore_Order_2NF(OrderID),
    FOREIGN KEY (BookID) REFERENCES Bookstore_Book_2NF(BookID)
);

/*
  -----------------------------------------------------------------------------
  Task 4 — Convert Bookstore 2NF to 3NF
  -----------------------------------------------------------------------------
  Rule: A table is in 3NF if it is in 2NF and has NO Transitive Dependencies
  (no non-prime attribute determines another non-prime attribute: X -> Y -> Z).

  Transitive Dependency in Bookstore_Order_2NF:
  - OrderID -> CustID, and CustID -> CustName, CustEmail.
  - Thus, CustName and CustEmail depend transitively on OrderID via CustID.

  Resolution for 3NF:
  Extract Customer information into its own dedicated relation:
  1. Customer (CustID PK, CustName, CustEmail)
  2. Bookstore_Order (OrderID PK, OrderDate, CustID FK)
  3. Bookstore_Book (BookID PK, BookTitle, Publisher, UnitPrice)
  4. Bookstore_OrderItem (OrderID FK, BookID FK, Qty, PK: (OrderID, BookID))
*/

DROP TABLE IF EXISTS Bookstore_OrderItem_3NF;
DROP TABLE IF EXISTS Bookstore_Order_3NF;
DROP TABLE IF EXISTS Bookstore_Customer_3NF;
DROP TABLE IF EXISTS Bookstore_Book_3NF;

-- 1. Customer Table (3NF)
CREATE TABLE Bookstore_Customer_3NF (
    CustID VARCHAR(10) PRIMARY KEY,
    CustName VARCHAR(50) NOT NULL,
    CustEmail VARCHAR(50) NOT NULL
);

-- 2. Book Table (3NF)
CREATE TABLE Bookstore_Book_3NF (
    BookID VARCHAR(10) PRIMARY KEY,
    BookTitle VARCHAR(60) NOT NULL,
    Publisher VARCHAR(40) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

-- 3. Order Table (3NF)
CREATE TABLE Bookstore_Order_3NF (
    OrderID VARCHAR(10) PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustID VARCHAR(10) NOT NULL,
    FOREIGN KEY (CustID) REFERENCES Bookstore_Customer_3NF(CustID)
);

-- 4. Order Item Table (3NF)
CREATE TABLE Bookstore_OrderItem_3NF (
    OrderID VARCHAR(10) NOT NULL,
    BookID VARCHAR(10) NOT NULL,
    Qty INT NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    FOREIGN KEY (OrderID) REFERENCES Bookstore_Order_3NF(OrderID),
    FOREIGN KEY (BookID) REFERENCES Bookstore_Book_3NF(BookID)
);

-- Populate 3NF Tables
INSERT INTO Bookstore_Customer_3NF VALUES
('C-11', 'Bilal', 'bilal@x.com'),
('C-12', 'Areeba', 'areeba@x.com');

INSERT INTO Bookstore_Book_3NF VALUES
('B-1', 'SQL Basics', 'Pearson', 1200.00),
('B-2', 'Python 101', 'OReilly', 1500.00),
('B-3', 'Networks', 'Pearson', 1800.00);

INSERT INTO Bookstore_Order_3NF VALUES
('O-501', '2026-04-02', 'C-11'),
('O-502', '2026-04-03', 'C-12'),
('O-503', '2026-04-05', 'C-11');

INSERT INTO Bookstore_OrderItem_3NF VALUES
('O-501', 'B-1', 1),
('O-501', 'B-2', 2),
('O-502', 'B-1', 3),
('O-503', 'B-3', 1),
('O-503', 'B-2', 1);

-- -----------------------------------------------------------------------------
-- Task 5 — Verification Queries
-- -----------------------------------------------------------------------------

-- Query 5.1: Recreate the original report (one row per book purchased)
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CustID,
    c.CustName,
    c.CustEmail,
    b.BookID,
    b.BookTitle,
    b.Publisher,
    b.UnitPrice,
    oi.Qty,
    (oi.Qty * b.UnitPrice) AS LineTotal
FROM Bookstore_Order_3NF o
JOIN Bookstore_Customer_3NF c ON o.CustID = c.CustID
JOIN Bookstore_OrderItem_3NF oi ON o.OrderID = oi.OrderID
JOIN Bookstore_Book_3NF b ON oi.BookID = b.BookID
ORDER BY o.OrderID, b.BookID;

-- Query 5.2: Total spend per customer
SELECT 
    c.CustID,
    c.CustName,
    c.CustEmail,
    COUNT(DISTINCT o.OrderID) AS TotalOrdersPlaced,
    SUM(oi.Qty * b.UnitPrice) AS TotalSpend
FROM Bookstore_Customer_3NF c
LEFT JOIN Bookstore_Order_3NF o ON c.CustID = o.CustID
LEFT JOIN Bookstore_OrderItem_3NF oi ON o.OrderID = oi.OrderID
LEFT JOIN Bookstore_Book_3NF b ON oi.BookID = b.BookID
GROUP BY c.CustID, c.CustName, c.CustEmail
ORDER BY TotalSpend DESC;

-- -----------------------------------------------------------------------------
-- Task 6 — Reflection (Anomalies Prevented)
-- -----------------------------------------------------------------------------
/*
  Task 6 Reflection:
  The 3NF schema guarantees that each real-world fact is stored in exactly one place.
  1. Insertion Anomaly is eliminated: We can now add new books (into Bookstore_Book_3NF)
     or new customers (into Bookstore_Customer_3NF) even before any purchase order is made.
  2. Update Anomaly is eliminated: Customer emails and names are stored in exactly one row
     in Bookstore_Customer_3NF. Modifying Bilal's email requires updating a single record,
     preventing data divergence across historical orders.
  3. Deletion Anomaly is eliminated: If an order or line item is cancelled and removed from
     Bookstore_Order_3NF or Bookstore_OrderItem_3NF, customer profiles and book catalog
     entries remain completely intact in their respective primary tables.
*/


-- =============================================================================
-- SECTION 2: GRADED ASSESSMENT PROBLEM — HOSPITAL PATIENT VISITS (2NF & 3NF)
-- =============================================================================

/*
  -----------------------------------------------------------------------------
  Assessment Deliverable 3: 2NF Schema with Justification
  -----------------------------------------------------------------------------
  In the hospital dataset:
  Functional Dependencies:
  - VisitID -> VisitDate, PatientID, DoctorID, Diagnosis, Fee
  - PatientID -> PatientName, PatientPhone
  - DoctorID -> DoctorName, Specialty, DeptName
  - DeptName -> DeptHead

  Since VisitID is the single candidate key for an entire consultation,
  there are technically no partial dependencies on a composite key in the visit table.
  However, the table heavily suffers from Transitive Dependencies:
  - VisitID -> PatientID AND PatientID -> (PatientName, PatientPhone)
  - VisitID -> DoctorID AND DoctorID -> (DoctorName, Specialty, DeptName)
  - DoctorID -> DeptName AND DeptName -> DeptHead

  To transition towards full normalization (2NF/3NF), we isolate entity tables
  representing Patient, Doctor, Department, and Visit.
*/

-- -----------------------------------------------------------------------------
-- Assessment Deliverable 4: 3NF Schema Fully Populated in MySQL
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS Hospital_Visit_3NF;
DROP TABLE IF EXISTS Hospital_Doctor_3NF;
DROP TABLE IF EXISTS Hospital_Department_3NF;
DROP TABLE IF EXISTS Hospital_Patient_3NF;

-- Table 1: Department (Eliminates transitive dependency DeptName -> DeptHead)
CREATE TABLE Hospital_Department_3NF (
    DeptName VARCHAR(50) PRIMARY KEY,
    DeptHead VARCHAR(50) NOT NULL
);

-- Table 2: Doctor (DoctorID determines DoctorName, Specialty, DeptName)
CREATE TABLE Hospital_Doctor_3NF (
    DoctorID VARCHAR(10) PRIMARY KEY,
    DoctorName VARCHAR(50) NOT NULL,
    Specialty VARCHAR(50) NOT NULL,
    DeptName VARCHAR(50) NOT NULL,
    FOREIGN KEY (DeptName) REFERENCES Hospital_Department_3NF(DeptName)
);

-- Table 3: Patient (PatientID determines PatientName, PatientPhone)
CREATE TABLE Hospital_Patient_3NF (
    PatientID VARCHAR(10) PRIMARY KEY,
    PatientName VARCHAR(50) NOT NULL,
    PatientPhone VARCHAR(20) NOT NULL
);

-- Table 4: Consultation Visit (Captures consultation events)
CREATE TABLE Hospital_Visit_3NF (
    VisitID VARCHAR(10) PRIMARY KEY,
    VisitDate DATE NOT NULL,
    PatientID VARCHAR(10) NOT NULL,
    DoctorID VARCHAR(10) NOT NULL,
    Diagnosis VARCHAR(100) NOT NULL,
    Fee DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Hospital_Patient_3NF(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Hospital_Doctor_3NF(DoctorID)
);

-- Populate Department Table
INSERT INTO Hospital_Department_3NF VALUES
('Heart Care', 'Dr. Tariq'),
('Skin Clinic', 'Dr. Asma');

-- Populate Doctor Table
INSERT INTO Hospital_Doctor_3NF VALUES
('D-30', 'Dr. Imran', 'Cardiology', 'Heart Care'),
('D-31', 'Dr. Asma', 'Dermatology', 'Skin Clinic');

-- Populate Patient Table
INSERT INTO Hospital_Patient_3NF VALUES
('P-201', 'Hassan', '0300-1112233'),
('P-202', 'Mehreen', '0301-4445566'),
('P-203', 'Junaid', '0302-7778899');

-- Populate Visit Table
INSERT INTO Hospital_Visit_3NF VALUES
('V-9001', '2026-04-10', 'P-201', 'D-30', 'Hypertension', 2500.00),
('V-9002', '2026-04-10', 'P-202', 'D-31', 'Eczema', 2000.00),
('V-9003', '2026-04-11', 'P-201', 'D-31', 'Allergy', 2000.00),
('V-9004', '2026-04-12', 'P-203', 'D-30', 'Arrhythmia', 3000.00);

-- -----------------------------------------------------------------------------
-- Assessment Deliverable 5: Recreate Table 8.1 by Joining 3NF Tables
-- -----------------------------------------------------------------------------
SELECT 
    v.VisitID,
    v.VisitDate,
    p.PatientID,
    p.PatientName,
    p.PatientPhone,
    d.DoctorID,
    d.DoctorName,
    d.Specialty,
    dept.DeptName,
    dept.DeptHead,
    v.Diagnosis,
    v.Fee AS `Fee (PKR)`
FROM Hospital_Visit_3NF v
JOIN Hospital_Patient_3NF p ON v.PatientID = p.PatientID
JOIN Hospital_Doctor_3NF d ON v.DoctorID = d.DoctorID
JOIN Hospital_Department_3NF dept ON d.DeptName = dept.DeptName
ORDER BY v.VisitID;

-- -----------------------------------------------------------------------------
-- Assessment Deliverable 6: Anomalies Eliminated by 3NF Design
-- -----------------------------------------------------------------------------
/*
  Anomalies Eliminated:
  1. Insertion Anomaly:
     We can now register a new doctor or a new department (e.g. Oncology headed by Dr. Rehan)
     before any patient books an appointment. In the flat design, doctor/department data
     could not exist without an associated VisitID.
  2. Update Anomaly:
     If a department head changes (e.g., Dr. Tariq leaves and is replaced), we only update
     a single row in Hospital_Department_3NF. In the unnormalized table, this required
     updating dozens of historical consultation visit records, risking inconsistency.
  3. Deletion Anomaly:
     If a patient visit is cancelled or deleted from Hospital_Visit_3NF, the patient's
     demographics (phone number) and the consulting doctor's professional records are
     preserved safely in their respective tables.
*/

-- =============================================================================
-- End of LAB 05 Conversion to 2NF and 3NF Script
-- =============================================================================
