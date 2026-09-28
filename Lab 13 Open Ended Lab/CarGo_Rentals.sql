/* =====================================================================
   CarGo Rentals - Car Rental Management System
   DBMS Open-Ended Lab  |  Syeda Khadija Hassan  |  2024-SE-09
   Department of Software Engineering, University of Azad Jammu & Kashmir

   HOW TO RUN
   - MySQL 8.0.16+ or MariaDB 10.4+ (CHECK constraints must be enforced).
   - MySQL Workbench: File > Open SQL Script > click the lightning icon (Run All).
   - phpMyAdmin (XAMPP): Import tab > choose this file > Go.
   - The script drops and recreates the database, so it can be re-run safely.

   CONTENTS
     0. Create database
     1. TASK 1  - Tables, keys, constraints, sample data
     2. TASK 2  - Normalization check (rebuild the original flat record)
     3. TASK 3  - JOIN queries (4)
     4. TASK 4  - View
     5. TRIGGERS - vehicle availability rule (listed in the submission
                   requirements; the handout numbering skips "Task 5")
     6. TASK 6  - Stored procedures
     7. Testing - constraint, trigger and procedure demonstrations
     8. TASK 7  - Optimization analysis (EXPLAIN before / after)
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. CREATE DATABASE
   --------------------------------------------------------------------- */
DROP DATABASE IF EXISTS cargo_rentals;
CREATE DATABASE cargo_rentals
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cargo_rentals;


/* =====================================================================
   1. TASK 1 - DATABASE DESIGN AND IMPLEMENTATION
   Five tables:
     customers       - who rents
     vehicle_models  - make/model catalogue that owns the daily rate
     vehicles        - each physical car (plate number) of a model
     rentals         - one row per rental (the central transaction table)
     payments        - money received; one rental can have many payments
   Relationships:
     vehicle_models 1--M vehicles      customers 1--M rentals
     vehicles       1--M rentals       rentals   1--M payments
   ===================================================================== */

CREATE TABLE customers (
    customer_id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(80)   NOT NULL,
    phone         VARCHAR(12)   NOT NULL,
    cnic          VARCHAR(15)   NOT NULL,
    email         VARCHAR(100)  NULL,
    city          VARCHAR(50)   NOT NULL,
    registered_on DATE          NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_customers      PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_phone UNIQUE (phone),
    CONSTRAINT uq_customer_cnic  UNIQUE (cnic),
    CONSTRAINT uq_customer_email UNIQUE (email),
    CONSTRAINT chk_customer_phone CHECK (phone REGEXP '^03[0-9]{2}-[0-9]{7}$'),
    CONSTRAINT chk_customer_cnic  CHECK (cnic  REGEXP '^[0-9]{5}-[0-9]{7}-[0-9]$')
) ENGINE = InnoDB;

CREATE TABLE vehicle_models (
    model_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    make        VARCHAR(40)   NOT NULL,
    model_name  VARCHAR(40)   NOT NULL,
    seats       TINYINT UNSIGNED NOT NULL DEFAULT 5,
    daily_rate  DECIMAL(10,2) NOT NULL,          -- current price list (PKR/day)
    CONSTRAINT pk_vehicle_models PRIMARY KEY (model_id),
    CONSTRAINT uq_make_model     UNIQUE (make, model_name),
    CONSTRAINT chk_model_rate    CHECK (daily_rate > 0),
    CONSTRAINT chk_model_seats   CHECK (seats BETWEEN 2 AND 15)
) ENGINE = InnoDB;

CREATE TABLE vehicles (
    vehicle_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    vehicle_number VARCHAR(10)  NOT NULL,
    model_id       INT UNSIGNED NOT NULL,
    color          VARCHAR(20)  NOT NULL,
    model_year     SMALLINT     NOT NULL,
    status         VARCHAR(12)  NOT NULL DEFAULT 'Available',
    CONSTRAINT pk_vehicles       PRIMARY KEY (vehicle_id),
    CONSTRAINT uq_vehicle_number UNIQUE (vehicle_number),
    CONSTRAINT fk_vehicle_model  FOREIGN KEY (model_id)
        REFERENCES vehicle_models (model_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_vehicle_number CHECK (vehicle_number REGEXP '^[A-Z]{2,3}-[0-9]{3,4}$'),
    CONSTRAINT chk_vehicle_year   CHECK (model_year BETWEEN 2005 AND 2027),
    CONSTRAINT chk_vehicle_status CHECK (status IN ('Available','Rented','Maintenance'))
) ENGINE = InnoDB;

CREATE TABLE rentals (
    rental_id          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    customer_id        INT UNSIGNED  NOT NULL,
    vehicle_id         INT UNSIGNED  NOT NULL,
    rental_date        DATE          NOT NULL,
    due_date           DATE          NOT NULL,          -- agreed return date
    return_date        DATE          NULL,              -- NULL while still rented
    daily_rate_applied DECIMAL(10,2) NOT NULL,          -- rate frozen at booking time
    total_amount       DECIMAL(12,2) NOT NULL,          -- charge for the rental
    status             VARCHAR(10)   NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_rentals PRIMARY KEY (rental_id),
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rental_vehicle FOREIGN KEY (vehicle_id)
        REFERENCES vehicles (vehicle_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_rental_due     CHECK (due_date > rental_date),
    CONSTRAINT chk_rental_return  CHECK (return_date IS NULL OR return_date >= rental_date),
    CONSTRAINT chk_rental_rate    CHECK (daily_rate_applied > 0),
    CONSTRAINT chk_rental_total   CHECK (total_amount >= 0),
    CONSTRAINT chk_rental_status  CHECK (status IN ('Active','Returned')),
    CONSTRAINT chk_rental_state   CHECK (
        (status = 'Active'   AND return_date IS NULL) OR
        (status = 'Returned' AND return_date IS NOT NULL))
) ENGINE = InnoDB;

CREATE TABLE payments (
    payment_id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    rental_id    INT UNSIGNED  NOT NULL,
    amount       DECIMAL(12,2) NOT NULL,
    payment_date DATE          NOT NULL DEFAULT (CURRENT_DATE),
    method       VARCHAR(15)   NOT NULL DEFAULT 'Cash',
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id)
        REFERENCES rentals (rental_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT chk_payment_method CHECK (method IN ('Cash','Card','Bank Transfer','Mobile Wallet'))
) ENGINE = InnoDB;


/* ---------------------------------------------------------------------
   Sample data (PKR). Rental 1 is the record R001 given in the handout.
   Two customers (Imran, Mehwish) have never rented, so the LEFT JOIN
   queries have something to show. Five vehicles are currently rented,
   one is in maintenance and six are free.
   --------------------------------------------------------------------- */
INSERT INTO customers (customer_id, full_name, phone, cnic, email, city, registered_on) VALUES
(1,  'Ali Khan',        '0300-1234567', '37405-1234567-1', 'ali.khan@example.com',        'Islamabad',  '2026-05-12'),
(2,  'Ayesha Siddiqui', '0321-7654321', '35202-2345678-2', 'ayesha.siddiqui@example.com', 'Lahore',     '2026-05-20'),
(3,  'Bilal Ahmed',     '0333-4567890', '42101-3456789-3', 'bilal.ahmed@example.com',     'Karachi',    '2026-05-28'),
(4,  'Fatima Noor',     '0345-1122334', '37405-4567890-4', 'fatima.noor@example.com',     'Rawalpindi', '2026-06-15'),
(5,  'Hamza Sheikh',    '0312-9988776', '17301-5678901-5', 'hamza.sheikh@example.com',    'Peshawar',   '2026-06-30'),
(6,  'Sana Malik',      '0301-5566778', '35201-6789012-6', 'sana.malik@example.com',      'Lahore',     '2026-07-10'),
(7,  'Usman Tariq',     '0322-3344556', '61101-7890123-7', 'usman.tariq@example.com',     'Islamabad',  '2026-07-25'),
(8,  'Zainab Raza',     '0334-6677889', '37405-8901234-8', 'zainab.raza@example.com',     'Rawalpindi', '2026-08-05'),
(9,  'Imran Qureshi',   '0302-1239876', '36302-9012345-9', 'imran.qureshi@example.com',   'Multan',     '2026-08-18'),
(10, 'Mehwish Farooq',  '0343-2468135', '38403-0123456-0', 'mehwish.farooq@example.com',  'Faisalabad', '2026-09-02');

INSERT INTO vehicle_models (model_id, make, model_name, seats, daily_rate) VALUES
(1, 'Toyota',  'Corolla',  5,  5000.00),
(2, 'Honda',   'Civic',    5,  6500.00),
(3, 'Suzuki',  'Alto',     4,  3000.00),
(4, 'Suzuki',  'Cultus',   5,  3500.00),
(5, 'Toyota',  'Fortuner', 7, 12000.00),
(6, 'Hyundai', 'Tucson',   5,  9000.00),
(7, 'KIA',     'Sportage', 5,  8500.00),
(8, 'Toyota',  'Hiace',   12, 10000.00);

INSERT INTO vehicles (vehicle_id, vehicle_number, model_id, color, model_year, status) VALUES
(1,  'ABC-123',  1, 'White',  2022, 'Available'),
(2,  'LEA-4521', 1, 'Silver', 2023, 'Available'),
(3,  'ISB-786',  2, 'Black',  2021, 'Available'),
(4,  'RIW-2210', 2, 'Grey',   2023, 'Available'),
(5,  'LXZ-990',  3, 'White',  2022, 'Available'),
(6,  'MZG-808',  3, 'Blue',   2023, 'Available'),
(7,  'AGH-345',  4, 'Red',    2021, 'Available'),
(8,  'BNH-1122', 5, 'Black',  2023, 'Available'),
(9,  'KHI-5566', 6, 'White',  2024, 'Available'),
(10, 'SKD-909',  7, 'Grey',   2022, 'Available'),
(11, 'PSH-777',  8, 'White',  2020, 'Available'),
(12, 'LEB-3030', 2, 'White',  2022, 'Maintenance');

/* Rentals are inserted BEFORE the triggers exist (section 5), so the
   'Rented' status of the five active vehicles is set by hand below.
   From section 5 onward the triggers keep that status in sync. */
INSERT INTO rentals
 (rental_id, customer_id, vehicle_id, rental_date, due_date, return_date,
  daily_rate_applied, total_amount, status) VALUES
(1,  1, 1,  '2026-09-01', '2026-09-04', '2026-09-04',  5000.00,  15000.00, 'Returned'),
(2,  2, 3,  '2026-06-10', '2026-06-13', '2026-06-13',  6500.00,  19500.00, 'Returned'),
(3,  3, 8,  '2026-06-20', '2026-06-25', '2026-06-25', 12000.00,  60000.00, 'Returned'),
(4,  4, 5,  '2026-07-02', '2026-07-05', '2026-07-05',  3000.00,   9000.00, 'Returned'),
(5,  1, 2,  '2026-07-15', '2026-07-22', '2026-07-22',  5000.00,  35000.00, 'Returned'),
(6,  5, 9,  '2026-07-18', '2026-07-21', '2026-07-21',  9000.00,  27000.00, 'Returned'),
(7,  6, 7,  '2026-08-03', '2026-08-06', '2026-08-06',  3500.00,  10500.00, 'Returned'),
(8,  2, 4,  '2026-08-08', '2026-08-15', '2026-08-15',  6500.00,  45500.00, 'Returned'),
(9,  7, 11, '2026-08-12', '2026-08-14', '2026-08-14', 10000.00,  20000.00, 'Returned'),
(10, 3, 10, '2026-08-20', '2026-08-24', '2026-08-26',  8500.00,  51000.00, 'Returned'), -- returned 2 days late
(11, 8, 6,  '2026-08-25', '2026-08-28', '2026-08-28',  3000.00,   9000.00, 'Returned'),
(12, 4, 1,  '2026-09-06', '2026-09-10', '2026-09-10',  5000.00,  20000.00, 'Returned'),
(13, 5, 3,  '2026-09-15', '2026-09-22', NULL,          6500.00,  45500.00, 'Active'),
(14, 6, 8,  '2026-09-18', '2026-09-21', NULL,         12000.00,  36000.00, 'Active'),
(15, 7, 2,  '2026-09-19', '2026-09-26', NULL,          5000.00,  35000.00, 'Active'),
(16, 8, 9,  '2026-09-14', '2026-09-21', NULL,          9000.00,  63000.00, 'Active'),
(17, 2, 11, '2026-09-17', '2026-09-22', NULL,         10000.00,  50000.00, 'Active');

UPDATE vehicles SET status = 'Rented' WHERE vehicle_id IN (2, 3, 8, 9, 11);

INSERT INTO payments (rental_id, amount, payment_date, method) VALUES
(1,  15000.00, '2026-09-04', 'Cash'),
(2,  19500.00, '2026-06-10', 'Card'),
(3,  30000.00, '2026-06-20', 'Bank Transfer'),
(3,  30000.00, '2026-06-25', 'Cash'),
(4,   9000.00, '2026-07-05', 'Cash'),
(5,  35000.00, '2026-07-15', 'Bank Transfer'),
(6,  27000.00, '2026-07-18', 'Card'),
(7,  10500.00, '2026-08-06', 'Mobile Wallet'),
(8,  45500.00, '2026-08-08', 'Card'),
(9,  20000.00, '2026-08-14', 'Cash'),
(10, 34000.00, '2026-08-20', 'Bank Transfer'),
(10, 17000.00, '2026-08-26', 'Cash'),
(11,  9000.00, '2026-08-28', 'Cash'),
(12, 20000.00, '2026-09-10', 'Cash'),
(13, 20000.00, '2026-09-15', 'Card'),
(14, 12000.00, '2026-09-18', 'Bank Transfer'),
(15, 35000.00, '2026-09-19', 'Mobile Wallet'),
(16, 30000.00, '2026-09-14', 'Bank Transfer');
-- Rental 17 (Ayesha, Hiace) has no payment yet, on purpose: "Unpaid" case.

-- Quick row-count check of the sample data
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'vehicle_models', COUNT(*) FROM vehicle_models
UNION ALL SELECT 'vehicles',       COUNT(*) FROM vehicles
UNION ALL SELECT 'rentals',        COUNT(*) FROM rentals
UNION ALL SELECT 'payments',       COUNT(*) FROM payments;

-- Display the sample data table by table
SELECT * FROM customers;
SELECT * FROM vehicle_models;
SELECT * FROM vehicles ORDER BY vehicle_id;
SELECT * FROM rentals ORDER BY rental_id;
SELECT * FROM payments ORDER BY payment_id;


/* =====================================================================
   2. TASK 2 - NORMALIZATION CHECK
   The handout's flat record (R001) must be reproducible from the
   normalized tables. If this query returns exactly the original row,
   the decomposition lost no information (lossless join).
   The full 1NF -> 3NF analysis is in the report.
   ===================================================================== */
SELECT CONCAT('R', LPAD(r.rental_id, 3, '0'))      AS RentalID,
       c.full_name                                  AS CustomerName,
       c.phone                                      AS CustomerPhone,
       v.vehicle_number                             AS VehicleNumber,
       CONCAT(m.make, ' ', m.model_name)            AS VehicleModel,
       m.daily_rate                                 AS DailyRate,
       r.rental_date                                AS RentalDate,
       r.return_date                                AS ReturnDate,
       (SELECT SUM(p.amount) FROM payments p
         WHERE p.rental_id = r.rental_id)           AS PaymentAmount
FROM rentals r
JOIN customers      c ON c.customer_id = r.customer_id
JOIN vehicles       v ON v.vehicle_id  = r.vehicle_id
JOIN vehicle_models m ON m.model_id    = v.model_id
WHERE r.rental_id = 1;


/* =====================================================================
   3. TASK 3 - JOIN QUERIES
   ===================================================================== */

-- Query 1: every rental with customer, vehicle, model and dates (INNER JOIN).
-- return_date is NULL for vehicles that are still out.
SELECT c.full_name                       AS customer_name,
       v.vehicle_number,
       CONCAT(m.make, ' ', m.model_name) AS vehicle_model,
       r.rental_date,
       r.return_date
FROM rentals r
INNER JOIN customers      c ON c.customer_id = r.customer_id
INNER JOIN vehicles       v ON v.vehicle_id  = r.vehicle_id
INNER JOIN vehicle_models m ON m.model_id    = v.model_id
ORDER BY r.rental_date, r.rental_id;

-- Query 2: all customers and the vehicles they rented; customers who never
-- rented still appear, with NULLs (LEFT JOIN starting from customers).
SELECT c.customer_id,
       c.full_name,
       v.vehicle_number,
       CONCAT(m.make, ' ', m.model_name) AS vehicle_model,
       r.rental_date
FROM customers c
LEFT JOIN rentals        r ON r.customer_id = c.customer_id
LEFT JOIN vehicles       v ON v.vehicle_id  = r.vehicle_id
LEFT JOIN vehicle_models m ON m.model_id    = v.model_id
ORDER BY c.full_name, r.rental_date;

-- Query 3: all vehicles with their CURRENT rental (if any).
-- The 'Active' filter sits in the ON clause, not in WHERE: putting it in
-- WHERE would throw away every vehicle that is not rented right now.
SELECT v.vehicle_number,
       CONCAT(m.make, ' ', m.model_name) AS vehicle_model,
       v.status                          AS vehicle_status,
       c.full_name                       AS rented_by,
       r.rental_date,
       r.due_date
FROM vehicles v
INNER JOIN vehicle_models m ON m.model_id   = v.model_id
LEFT  JOIN rentals        r ON r.vehicle_id = v.vehicle_id AND r.status = 'Active'
LEFT  JOIN customers      c ON c.customer_id = r.customer_id
ORDER BY v.vehicle_number;

-- Query 4: number of rentals per customer, including zero.
-- COUNT(r.rental_id) counts real rentals only; COUNT(*) would report 1
-- for a customer with no rentals because the LEFT JOIN still makes a row.
SELECT c.customer_id,
       c.full_name,
       COUNT(r.rental_id) AS total_rentals
FROM customers c
LEFT JOIN rentals r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_rentals DESC, c.full_name;


/* =====================================================================
   4. TASK 4 - VIEW: consolidated rental report
   ===================================================================== */
CREATE OR REPLACE VIEW vw_rental_report AS
SELECT r.rental_id,
       c.customer_id,
       c.full_name                                   AS customer_name,
       c.phone                                       AS customer_phone,
       v.vehicle_number,
       CONCAT(m.make, ' ', m.model_name)             AS vehicle_model,
       r.rental_date,
       r.due_date,
       r.return_date,
       DATEDIFF(COALESCE(r.return_date, r.due_date), r.rental_date) AS rental_days,
       r.daily_rate_applied,
       r.total_amount,
       COALESCE(p.paid, 0)                           AS amount_paid,
       r.total_amount - COALESCE(p.paid, 0)          AS balance_due,
       CASE WHEN COALESCE(p.paid, 0) = 0              THEN 'Unpaid'
            WHEN COALESCE(p.paid, 0) < r.total_amount THEN 'Partial'
            ELSE 'Paid' END                          AS payment_status,
       r.status                                      AS rental_status
FROM rentals r
JOIN customers      c ON c.customer_id = r.customer_id
JOIN vehicles       v ON v.vehicle_id  = r.vehicle_id
JOIN vehicle_models m ON m.model_id    = v.model_id
LEFT JOIN (SELECT rental_id, SUM(amount) AS paid
           FROM payments GROUP BY rental_id) p ON p.rental_id = r.rental_id;

-- Using the view: full report, then only rentals that still owe money.
SELECT rental_id, customer_name, vehicle_number, vehicle_model,
       rental_date, return_date, total_amount, amount_paid,
       balance_due, payment_status, rental_status
FROM vw_rental_report
ORDER BY rental_id;

SELECT rental_id, customer_name, customer_phone, vehicle_number,
       total_amount, amount_paid, balance_due, payment_status
FROM vw_rental_report
WHERE balance_due > 0
ORDER BY balance_due DESC;


/* =====================================================================
   5. TRIGGERS - "a vehicle must not be available for another rental
      while it is already rented"
   Three triggers work together on the rentals table:
     trg_rentals_bi  BEFORE INSERT  -> rejects a booking if the vehicle is
                                       rented / in maintenance, or if the
                                       dates overlap another rental.
     trg_rentals_ai  AFTER  INSERT  -> marks the vehicle 'Rented'.
     trg_rentals_au  AFTER  UPDATE  -> marks it 'Available' when the rental
                                       goes from Active to Returned.
   ===================================================================== */
DELIMITER $$

CREATE TRIGGER trg_rentals_bi
BEFORE INSERT ON rentals
FOR EACH ROW
BEGIN
    DECLARE v_status  VARCHAR(12);
    DECLARE v_overlap INT DEFAULT 0;

    SELECT status INTO v_status
      FROM vehicles WHERE vehicle_id = NEW.vehicle_id;

    IF NEW.status = 'Active' AND v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vehicle is not available: it is already rented or under maintenance.';
    END IF;

    -- Date overlap with any other rental of the same vehicle
    -- (a car may be handed over the same day the previous rental ends).
    SELECT COUNT(*) INTO v_overlap
      FROM rentals r
     WHERE r.vehicle_id  = NEW.vehicle_id
       AND r.rental_date < COALESCE(NEW.return_date, NEW.due_date)
       AND NEW.rental_date < COALESCE(r.return_date, r.due_date);

    IF v_overlap > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vehicle is already booked for an overlapping period.';
    END IF;
END$$

CREATE TRIGGER trg_rentals_ai
AFTER INSERT ON rentals
FOR EACH ROW
BEGIN
    IF NEW.status = 'Active' THEN
        UPDATE vehicles SET status = 'Rented' WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END$$

CREATE TRIGGER trg_rentals_au
AFTER UPDATE ON rentals
FOR EACH ROW
BEGIN
    IF OLD.status = 'Active' AND NEW.status = 'Returned' THEN
        UPDATE vehicles SET status = 'Available' WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END$$

DELIMITER ;


/* =====================================================================
   6. TASK 6 - STORED PROCEDURES
   sp_register_rental  (required)  books a rental, calculates the charge
                                   = daily rate x days, records an optional
                                   advance payment. All-or-nothing
                                   (transaction + rollback on any error).
   sp_return_vehicle   (bonus)     closes a rental and recalculates the
                                   charge if the car came back late.
   ===================================================================== */
DELIMITER $$

CREATE PROCEDURE sp_register_rental (
    IN  p_customer_id    INT UNSIGNED,
    IN  p_vehicle_number VARCHAR(10),
    IN  p_rental_date    DATE,
    IN  p_days           INT,
    IN  p_advance        DECIMAL(12,2),
    IN  p_method         VARCHAR(15),
    OUT p_rental_id      INT UNSIGNED,
    OUT p_total          DECIMAL(12,2)
)
BEGIN
    DECLARE v_vehicle_id INT UNSIGNED;
    DECLARE v_model_id   INT UNSIGNED;
    DECLARE v_status     VARCHAR(12);
    DECLARE v_rate       DECIMAL(10,2);
    DECLARE v_customer   INT DEFAULT 0;

    -- Any error: undo everything and pass the original error to the caller.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET p_rental_date = COALESCE(p_rental_date, CURRENT_DATE);
    SET p_advance     = COALESCE(p_advance, 0);
    SET p_method      = COALESCE(p_method, 'Cash');

    IF p_days IS NULL OR p_days < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rental period must be at least 1 day.';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_customer FROM customers WHERE customer_id = p_customer_id;
    IF v_customer = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found.';
    END IF;

    -- Lock the vehicle row so two clerks cannot book the same car at once.
    SELECT vehicle_id, model_id, status
      INTO v_vehicle_id, v_model_id, v_status
      FROM vehicles
     WHERE vehicle_number = p_vehicle_number
       FOR UPDATE;

    IF v_vehicle_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle number not found.';
    END IF;
    IF v_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehicle is not available for rental.';
    END IF;

    SELECT daily_rate INTO v_rate FROM vehicle_models WHERE model_id = v_model_id;

    SET p_total = v_rate * p_days;

    IF p_advance < 0 OR p_advance > p_total THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Advance payment must be between 0 and the total charge.';
    END IF;

    INSERT INTO rentals
        (customer_id, vehicle_id, rental_date, due_date, daily_rate_applied, total_amount)
    VALUES
        (p_customer_id, v_vehicle_id, p_rental_date,
         DATE_ADD(p_rental_date, INTERVAL p_days DAY), v_rate, p_total);

    SET p_rental_id = LAST_INSERT_ID();

    IF p_advance > 0 THEN
        INSERT INTO payments (rental_id, amount, payment_date, method)
        VALUES (p_rental_id, p_advance, p_rental_date, p_method);
    END IF;

    COMMIT;
END$$

CREATE PROCEDURE sp_return_vehicle (
    IN  p_rental_id   INT UNSIGNED,
    IN  p_return_date DATE,
    OUT p_final_total DECIMAL(12,2)
)
BEGIN
    DECLARE v_status      VARCHAR(10);
    DECLARE v_rental_date DATE;
    DECLARE v_due_date    DATE;
    DECLARE v_rate        DECIMAL(10,2);
    DECLARE v_days        INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status, rental_date, due_date, daily_rate_applied
      INTO v_status, v_rental_date, v_due_date, v_rate
      FROM rentals
     WHERE rental_id = p_rental_id
       FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rental not found.';
    END IF;
    IF v_status = 'Returned' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This rental has already been returned.';
    END IF;
    IF p_return_date < v_rental_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Return date cannot be before the rental date.';
    END IF;

    -- Agreed period is always charged; extra days (late return) cost the same daily rate.
    SET v_days = GREATEST(DATEDIFF(v_due_date, v_rental_date),
                          DATEDIFF(p_return_date, v_rental_date));
    SET p_final_total = v_days * v_rate;

    UPDATE rentals
       SET return_date  = p_return_date,
           status       = 'Returned',
           total_amount = p_final_total
     WHERE rental_id = p_rental_id;      -- trigger trg_rentals_au frees the vehicle

    COMMIT;
END$$

DELIMITER ;


/* =====================================================================
   7. TESTING AND DEMONSTRATION
   sp_demo_expect_error is only a TEST HELPER: it runs a statement that is
   expected to fail, catches the error and logs the database's own message
   in demo_results, so the whole script keeps running.
   ===================================================================== */
DELIMITER $$
CREATE PROCEDURE sp_demo_expect_error (IN p_label VARCHAR(120), IN p_sql TEXT)
BEGIN
    DECLARE v_failed TINYINT DEFAULT 0;
    DECLARE v_msg    TEXT DEFAULT '';
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_msg = MESSAGE_TEXT;
        SET v_failed = 1;
    END;

    SET @demo_sql = p_sql;
    PREPARE demo_stmt FROM @demo_sql;
    EXECUTE demo_stmt;
    DEALLOCATE PREPARE demo_stmt;

    INSERT INTO demo_results (test_case, outcome, database_message)
    VALUES (p_label,
            IF(v_failed = 1, 'BLOCKED', 'ACCEPTED'),
            IF(v_failed = 1, v_msg, 'No error - statement executed'));
END$$
DELIMITER ;

CREATE TEMPORARY TABLE demo_results (
    test_case        VARCHAR(120),
    outcome          VARCHAR(10),
    database_message TEXT
);

-- 7a. CONSTRAINT tests (each one should be BLOCKED)
CALL sp_demo_expect_error('Customer with badly formatted phone (CHECK)',
  "INSERT INTO customers (full_name, phone, cnic, city) VALUES ('Test One', '12345', '11111-1111111-1', 'Lahore')");
CALL sp_demo_expect_error('Customer with a duplicate phone number (UNIQUE)',
  "INSERT INTO customers (full_name, phone, cnic, city) VALUES ('Test Two', '0300-1234567', '22222-2222222-2', 'Lahore')");
CALL sp_demo_expect_error('Customer without a name (NOT NULL)',
  "INSERT INTO customers (full_name, phone, cnic, city) VALUES (NULL, '0399-0000001', '33333-3333333-3', 'Lahore')");
CALL sp_demo_expect_error('Vehicle model with a negative daily rate (CHECK)',
  "INSERT INTO vehicle_models (make, model_name, daily_rate) VALUES ('Test', 'Car', -100)");
CALL sp_demo_expect_error('Payment for a rental that does not exist (FOREIGN KEY)',
  "INSERT INTO payments (rental_id, amount) VALUES (9999, 500)");
CALL sp_demo_expect_error('Rental that ends before it starts (CHECK)',
  "INSERT INTO rentals (customer_id, vehicle_id, rental_date, due_date, daily_rate_applied, total_amount, status) VALUES (1, 5, '2026-09-20', '2026-09-19', 3000, 0, 'Returned')");
SELECT * FROM demo_results;
DELETE FROM demo_results;

-- 7b. TRIGGER tests on the raw rentals table (each one should be BLOCKED)
CALL sp_demo_expect_error('Book ISB-786 which is currently rented',
  "INSERT INTO rentals (customer_id, vehicle_id, rental_date, due_date, daily_rate_applied, total_amount) VALUES (1, 3, '2026-09-20', '2026-09-23', 6500, 19500)");
CALL sp_demo_expect_error('Book LEB-3030 which is in maintenance',
  "INSERT INTO rentals (customer_id, vehicle_id, rental_date, due_date, daily_rate_applied, total_amount) VALUES (1, 12, '2026-09-20', '2026-09-23', 6500, 19500)");
CALL sp_demo_expect_error('Back-date a rental overlapping ABC-123 (1-4 Sep)',
  "INSERT INTO rentals (customer_id, vehicle_id, rental_date, due_date, return_date, daily_rate_applied, total_amount, status) VALUES (2, 1, '2026-09-02', '2026-09-05', '2026-09-05', 5000, 15000, 'Returned')");
SELECT * FROM demo_results;
DELETE FROM demo_results;

-- 7c. Vehicle life-cycle: procedure + triggers working together
-- Step 1: LXZ-990 (Suzuki Alto, 3000/day) is free.
SELECT vehicle_number, status FROM vehicles WHERE vehicle_number = 'LXZ-990';

-- Step 2: register a 4-day rental for Mehwish (customer 10) with 6000 advance.
CALL sp_register_rental(10, 'LXZ-990', '2026-09-14', 4, 6000.00, 'Mobile Wallet', @rid, @total);
SELECT @rid AS new_rental_id, @total AS total_charge;   -- 4 x 3000 = 12000

-- Step 3: trigger trg_rentals_ai has marked the vehicle 'Rented';
--         the view shows the new rental with 6000 still owing.
SELECT vehicle_number, status FROM vehicles WHERE vehicle_number = 'LXZ-990';
SELECT rental_id, customer_name, vehicle_number, rental_date, due_date,
       total_amount, amount_paid, balance_due, payment_status, rental_status
FROM vw_rental_report WHERE rental_id = @rid;

-- Step 4: the procedure and the triggers refuse invalid bookings.
CALL sp_demo_expect_error('Rent LXZ-990 again while it is rented',
  "CALL sp_register_rental(1, 'LXZ-990', '2026-09-20', 2, 0, 'Cash', @r2, @t2)");
CALL sp_demo_expect_error('Rental period of 0 days',
  "CALL sp_register_rental(1, 'ABC-123', '2026-09-20', 0, 0, 'Cash', @r2, @t2)");
CALL sp_demo_expect_error('Advance larger than total charge',
  "CALL sp_register_rental(1, 'ABC-123', '2026-09-20', 2, 99999, 'Cash', @r2, @t2)");
CALL sp_demo_expect_error('Unknown customer id',
  "CALL sp_register_rental(99, 'ABC-123', '2026-09-20', 2, 0, 'Cash', @r2, @t2)");
CALL sp_demo_expect_error('Unknown vehicle number',
  "CALL sp_register_rental(1, 'XXX-000', '2026-09-20', 2, 0, 'Cash', @r2, @t2)");
SELECT * FROM demo_results;
DELETE FROM demo_results;

-- Step 5: return it on 20 Sep (due 18 Sep -> 2 days late). Charge becomes
--         6 days x 3000 = 18000; trigger trg_rentals_au frees the vehicle.
CALL sp_return_vehicle(@rid, '2026-09-20', @final_total);
SELECT @final_total AS final_total_charge;
SELECT vehicle_number, status FROM vehicles WHERE vehicle_number = 'LXZ-990';
SELECT rental_id, customer_name, vehicle_number, rental_date, due_date, return_date,
       rental_days, total_amount, amount_paid, balance_due, payment_status, rental_status
FROM vw_rental_report WHERE rental_id = @rid;

-- Clean-up: remove the demonstration rental (and its payment) so the database
-- returns to its original sample state (17 rentals, 18 payments) after this script.
DELETE FROM payments WHERE rental_id = @rid;
DELETE FROM rentals  WHERE rental_id = @rid;
ALTER TABLE rentals  AUTO_INCREMENT = 18;
ALTER TABLE payments AUTO_INCREMENT = 19;

-- Clean up test helpers
DROP TEMPORARY TABLE demo_results;
DROP PROCEDURE sp_demo_expect_error;


/* =====================================================================
   8. TASK 7 - OPTIMIZATION ANALYSIS
   Problem: management's monthly activity report filters rentals with
   YEAR(rental_date) = ... AND MONTH(rental_date) = ... . Wrapping the
   column in a function makes the predicate non-SARGable, so MySQL cannot
   use an index on rental_date and must read every row. With 17 rows this
   is invisible; with years of history it is a full table scan per report.
   To show the effect honestly, a 100,000-row COPY of the rentals table is
   used (the real tables and triggers are not touched).
   ===================================================================== */

-- Build the test copy: same columns, no foreign keys, no triggers.
CREATE TABLE tmp_digits (d TINYINT NOT NULL PRIMARY KEY);
INSERT INTO tmp_digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

CREATE TABLE rentals_perf_test LIKE rentals;

INSERT INTO rentals_perf_test
    (customer_id, vehicle_id, rental_date, due_date, return_date,
     daily_rate_applied, total_amount, status)
SELECT 1 + (n MOD 8),
       1 + (n MOD 12),
       DATE_ADD('2025-01-01', INTERVAL (n MOD 730) DAY),
       DATE_ADD('2025-01-01', INTERVAL ((n MOD 730) + 3) DAY),
       DATE_ADD('2025-01-01', INTERVAL ((n MOD 730) + 3) DAY),
       5000.00, 15000.00, 'Returned'
FROM (SELECT a.d + 10*b.d + 100*c.d + 1000*e.d + 10000*f.d AS n
      FROM tmp_digits a, tmp_digits b, tmp_digits c, tmp_digits e, tmp_digits f) t;

SELECT COUNT(*) AS rows_in_test_table FROM rentals_perf_test;

-- BEFORE: function on the column, no index on rental_date -> full scan.
EXPLAIN SELECT vehicle_id, COUNT(*) AS rentals, SUM(total_amount) AS revenue
        FROM rentals_perf_test
        WHERE YEAR(rental_date) = 2026 AND MONTH(rental_date) = 8
        GROUP BY vehicle_id;

-- Adding the index alone does NOT help the YEAR()/MONTH() version:
CREATE INDEX idx_perf_rental_date ON rentals_perf_test (rental_date);
EXPLAIN SELECT vehicle_id, COUNT(*) AS rentals, SUM(total_amount) AS revenue
        FROM rentals_perf_test
        WHERE YEAR(rental_date) = 2026 AND MONTH(rental_date) = 8
        GROUP BY vehicle_id;

-- AFTER: same question as a plain date range -> index range scan.
EXPLAIN SELECT vehicle_id, COUNT(*) AS rentals, SUM(total_amount) AS revenue
        FROM rentals_perf_test
        WHERE rental_date >= '2026-08-01' AND rental_date < '2026-09-01'
        GROUP BY vehicle_id;

-- Both queries return the same answer:
SELECT vehicle_id, COUNT(*) AS rentals, SUM(total_amount) AS revenue
FROM rentals_perf_test
WHERE rental_date >= '2026-08-01' AND rental_date < '2026-09-01'
GROUP BY vehicle_id
ORDER BY vehicle_id;

-- Apply the improvement to the real database and remove the test objects.
CREATE INDEX idx_rentals_rental_date ON rentals (rental_date);

DROP TABLE rentals_perf_test;
DROP TABLE tmp_digits;

-- Final state check
SHOW INDEX FROM rentals;
