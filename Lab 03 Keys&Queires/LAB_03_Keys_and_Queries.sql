-- =============================================================================
-- DATABASE SYSTEMS LAB 03: KEYS AND QUERIES
-- Reference: LAB_03_Manual.pdf (MySQL Lab Guide for Students)
-- Objectives:
-- 1. Understanding & implementing Database Keys (PK, FK, Unique, Composite,
--    Candidate, Alternate, Super, Natural, Surrogate)
-- 2. DDL Table Commands (CREATE, ALTER: ADD, MODIFY, CHANGE, DROP column/constraint)
-- 3. CRUD Operations (INSERT, SELECT, UPDATE, DELETE)
-- 4. Table Operations (TRUNCATE, DROP)
-- 5. University Lab Schema Implementation & Joins
-- =============================================================================

CREATE DATABASE IF NOT EXISTS university_keys_lab;
USE university_keys_lab;

-- Clean up existing tables in reverse dependency order
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS citizens;
DROP TABLE IF EXISTS demo_truncate_drop;

-- =============================================================================
-- SECTION 1: KEY CONCEPTS DEMONSTRATION TABLES
-- =============================================================================

-- Natural Key Example: Real-world unique attribute (CNIC)
CREATE TABLE citizens (
    cnic VARCHAR(15) PRIMARY KEY, -- Natural Key
    name VARCHAR(100) NOT NULL
);

INSERT INTO citizens VALUES 
('35201-1234567-1', 'Zahid Ali'),
('35201-7654321-2', 'Fatima Batool');

SELECT * FROM citizens;

-- =============================================================================
-- LAB TASK 1: CREATE THE UNIVERSITY TABLES WITH CONSTRAINTS
-- =============================================================================

-- 1. Departments Table
-- Primary Key: dept_id (Surrogate/Numeric Key)
-- Unique Key: dept_name
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) UNIQUE
);

-- 2. Students Table
-- Primary Key: student_id (Surrogate Key, AUTO_INCREMENT)
-- Candidate Keys: student_id, email (both uniquely identify a student)
-- Alternate Key: email (Candidate key not chosen as Primary Key)
-- Foreign Key: dept_id referencing departments(dept_id)
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 3. Courses Table
-- Primary Key: course_id
-- Foreign Key: dept_id referencing departments(dept_id)
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 4. Instructors Table
-- Primary Key: instructor_id
-- Unique Key: email
-- Foreign Key: dept_id referencing departments(dept_id)
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- 5. Enrollments Table
-- Composite Key: PRIMARY KEY (student_id, course_id)
-- Foreign Keys: student_id referencing students, course_id referencing courses
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

-- =============================================================================
-- LAB TASK 2: INSERT DATA AND QUERY USING SELECT
-- =============================================================================

-- Insert Departments
INSERT INTO departments VALUES 
(1, 'CS'),
(2, 'EE');

-- Insert Students
INSERT INTO students (name, email, age, dept_id) VALUES
('Ali', 'ali@gmail.com', 20, 1),
('Sara', 'sara@gmail.com', 21, 1),
('Ahmed', 'ahmed@gmail.com', 22, 2);

-- Insert Courses
INSERT INTO courses VALUES 
(101, 'Database', 1),
(102, 'AI', 1),
(201, 'Circuits', 2);

-- Insert Instructors
INSERT INTO instructors VALUES
(1, 'Dr. Kamran', 'kamran@uni.edu', 1),
(2, 'Dr. Zainab', 'zainab@uni.edu', 2);

-- Insert Enrollments (Composite Key instances)
INSERT INTO enrollments VALUES 
(1, 101, 'Fall 2025'),
(1, 102, 'Fall 2025'),
(2, 101, 'Fall 2025');

-- Query using SELECT
SELECT * FROM departments;
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM instructors;
SELECT * FROM enrollments;

-- =============================================================================
-- LAB TASK 3: UPDATE A STUDENT'S NAME
-- =============================================================================

UPDATE students
SET name = 'Ali Khan'
WHERE student_id = 1;

-- Verification of Update
SELECT student_id, name, email, dept_id FROM students WHERE student_id = 1;

-- =============================================================================
-- LAB TASK 4: DELETE A STUDENT RECORD
-- =============================================================================

-- Delete student with student_id = 2 (Sara)
-- Note: Cascading foreign key in enrollments handles related enrollment record
DELETE FROM students
WHERE student_id = 2;

-- Verification of Deletion
SELECT * FROM students;
SELECT * FROM enrollments;

-- =============================================================================
-- LAB TASK 5: TRY TRUNCATE AND DROP
-- =============================================================================

-- Demonstration table to demonstrate TRUNCATE and DROP safely
CREATE TABLE demo_truncate_drop (
    temp_id INT AUTO_INCREMENT PRIMARY KEY,
    temp_note VARCHAR(50)
);

INSERT INTO demo_truncate_drop (temp_note) VALUES 
('Sample Record 1'),
('Sample Record 2');

SELECT * FROM demo_truncate_drop;

-- TRUNCATE deletes all rows and resets AUTO_INCREMENT counter:
TRUNCATE TABLE demo_truncate_drop;
SELECT * FROM demo_truncate_drop; -- (Empty table)

-- DROP completely removes the table schema definition from the database:
DROP TABLE demo_truncate_drop;
-- SHOW TABLES; will confirm demo_truncate_drop is completely deleted.

-- =============================================================================
-- LAB TASK 6: ADD, MODIFY, RENAME, DROP COLUMNS USING ALTER TABLE
-- =============================================================================

-- 6.1 Add Column: phone
ALTER TABLE students
ADD phone VARCHAR(20);

-- 6.2 Modify Column: enforce age NOT NULL with default
UPDATE students SET age = 20 WHERE age IS NULL;
ALTER TABLE students
MODIFY age INT NOT NULL;

-- 6.3 Add a new column and rename it using CHANGE
ALTER TABLE students
ADD temp_col VARCHAR(50);

ALTER TABLE students
CHANGE temp_col student_address VARCHAR(100);

-- 6.4 Drop Column
ALTER TABLE students
DROP COLUMN student_address;

-- 6.5 Add Unique Constraint to existing column
ALTER TABLE students
ADD CONSTRAINT unique_phone UNIQUE (phone);

DESCRIBE students;

-- =============================================================================
-- LAB TASK 7: PRACTICE JOINS BETWEEN STUDENTS AND COURSES
-- =============================================================================

-- Re-insert a student to have rich join data
INSERT INTO students (student_id, name, email, age, dept_id, phone) VALUES 
(2, 'Sara Iqbal', 'sara.iqbal@gmail.com', 21, 1, '0301-4445566');

INSERT INTO enrollments VALUES 
(2, 101, 'Fall 2025'),
(2, 102, 'Fall 2025');

-- Query: Students and the courses they are enrolled in (via Enrollments junction table)
SELECT 
    s.student_id,
    s.name AS student_name,
    c.course_id,
    c.course_name,
    e.semester,
    d.dept_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON s.dept_id = d.dept_id
ORDER BY s.student_id, c.course_id;

-- =============================================================================
-- LAB TASK 8: EXPLORE KEYS THEORY & PRACTICAL DEMONSTRATION
-- =============================================================================
/*
  KEY TYPE DEFINITIONS & MAPPINGS IN THIS LAB:
  -----------------------------------------------------------------------------
  1. Super Key:
     Any column or combination of columns that uniquely identifies a row.
     Examples: {student_id}, {email}, {student_id, name}, {email, age}.

  2. Candidate Key:
     A minimal Super Key without any redundant attributes.
     In students table:
     - Candidate Key 1: student_id
     - Candidate Key 2: email

  3. Primary Key:
     The candidate key selected as the primary identifier.
     In students table: student_id.

  4. Alternate Key:
     Candidate keys that were NOT chosen as Primary Key.
     In students table: email.

  5. Composite Key:
     A primary key composed of two or more columns.
     In enrollments table: PRIMARY KEY (student_id, course_id).
     A student can take many courses, and a course has many students; together
     (student_id, course_id) uniquely identifies each enrollment.

  6. Foreign Key:
     A column referencing a Primary Key in another table to enforce referential integrity.
     Example: students(dept_id) REFERENCES departments(dept_id).

  7. Natural Key:
     A key composed of real-world identifiers (e.g. cnic in table citizens).

  8. Surrogate Key:
     An artificial numeric key generated by the DBMS (e.g. AUTO_INCREMENT student_id).
*/

-- Verification query demonstrating the Composite Key behavior
SELECT 
    student_id, 
    course_id, 
    COUNT(*) AS occurrence_count
FROM enrollments
GROUP BY student_id, course_id
HAVING COUNT(*) > 1; -- Returns 0 rows, confirming composite uniqueness

-- =============================================================================
-- End of LAB 03 Keys and Queries Script
-- =============================================================================
