-- =============================================================================
-- DATABASE SYSTEMS LAB 02: POINT OF SALE (POS) DATABASE SYSTEM
-- Task Requirements:
-- 1. Create database: Point_of_Sale
-- 2. Create roles: Admin, User/Customer, Salesman
-- 3. Create tables: Roles, Users, Categories, Products, Discounts, Orders, Order_Items
-- 4. Apply primary and foreign key constraints
-- 5. Insert at least 10 records in each table
-- 6. Generate simple business reporting using queries
-- =============================================================================

CREATE DATABASE IF NOT EXISTS Point_of_Sale;
USE Point_of_Sale;

-- Drop child tables before parent tables to maintain referential integrity
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Discounts;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;

-- =============================================================================
-- 1. TABLE DEFINITIONS WITH CONSTRAINTS
-- =============================================================================

-- Table 1: Roles (Stores system privilege levels: Admin, Salesman, Customer, etc.)
CREATE TABLE Roles (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- Table 2: Users (Stores system users, administrators, salesmen, and customers)
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    RoleID INT NOT NULL,
    City VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table 3: Categories (Product grouping)
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- Table 4: Products (Item catalog with pricing and stock)
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    CostPrice DECIMAL(10,2) NOT NULL CHECK (CostPrice >= 0),
    StockQuantity INT NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0),
    Barcode VARCHAR(50) UNIQUE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table 5: Discounts (Special offers and seasonal campaigns)
CREATE TABLE Discounts (
    DiscountID INT AUTO_INCREMENT PRIMARY KEY,
    OfferName VARCHAR(100) NOT NULL,
    DiscountPercent DECIMAL(5,2) NOT NULL CHECK (DiscountPercent BETWEEN 0 AND 100),
    MinPurchaseAmount DECIMAL(10,2) DEFAULT 0.00,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL
);

-- Table 6: Orders (Sales transactions)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    CustomerID INT NOT NULL,
    SalesmanID INT NOT NULL,
    DiscountID INT NULL,
    PaymentMethod VARCHAR(30) DEFAULT 'Cash',
    OrderStatus VARCHAR(20) DEFAULT 'Completed',
    FOREIGN KEY (CustomerID) REFERENCES Users(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (SalesmanID) REFERENCES Users(UserID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (DiscountID) REFERENCES Discounts(DiscountID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Table 7: Order_Items (Junction table with line items)
CREATE TABLE Order_Items (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    Subtotal DECIMAL(10,2) NOT NULL CHECK (Subtotal >= 0),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Optional: Create MySQL native database security roles
-- CREATE ROLE IF NOT EXISTS 'Admin', 'Salesman', 'Customer';
-- GRANT ALL PRIVILEGES ON Point_of_Sale.* TO 'Admin';
-- GRANT SELECT, INSERT, UPDATE ON Point_of_Sale.Orders TO 'Salesman';
-- GRANT SELECT, INSERT, UPDATE ON Point_of_Sale.Order_Items TO 'Salesman';
-- GRANT SELECT ON Point_of_Sale.Products TO 'Salesman';
-- GRANT SELECT ON Point_of_Sale.Products TO 'Customer';

-- =============================================================================
-- 2. DATA INSERTION (10 RECORDS PER TABLE)
-- =============================================================================

-- 10 Records for Roles
INSERT INTO Roles (RoleID, RoleName, Description) VALUES
(1, 'Admin', 'System administrator with full permissions'),
(2, 'Salesman', 'Floor sales representative processing orders'),
(3, 'Customer', 'End consumer placing orders'),
(4, 'Manager', 'Branch supervisor managing inventory and staff'),
(5, 'Cashier', 'Counter checkout operator'),
(6, 'Inventory Clerk', 'Warehouse and stock manager'),
(7, 'Accountant', 'Financial auditing and reporting personnel'),
(8, 'Procurement Officer', 'Vendor supplier liaison'),
(9, 'Support Specialist', 'Customer service representative'),
(10, 'Delivery Staff', 'Logistics and delivery coordinator');

-- 10 Records for Users
INSERT INTO Users (UserID, FullName, Email, Phone, RoleID, City) VALUES
(1, 'Bilal Tariq', 'admin.bilal@pos.com', '0300-1112233', 1, 'Lahore'),
(2, 'Hamza Rafiq', 'hamza.sales@pos.com', '0301-2223344', 2, 'Lahore'),
(3, 'Usman Shah', 'usman.sales@pos.com', '0302-3334455', 2, 'Karachi'),
(4, 'Ayesha Malik', 'ayesha.m@customer.com', '0303-4445566', 3, 'Lahore'),
(5, 'Zainab Bibi', 'zainab.b@customer.com', '0304-5556677', 3, 'Islamabad'),
(6, 'Fahad Mustafa', 'fahad.m@customer.com', '0305-6667788', 3, 'Karachi'),
(7, 'Mariam Noor', 'mariam.n@customer.com', '0306-7778899', 3, 'Lahore'),
(8, 'Saad Siddiqui', 'saad.mgr@pos.com', '0307-8889900', 4, 'Islamabad'),
(9, 'Nida Yasir', 'nida.c@customer.com', '0308-9990011', 3, 'Rawalpindi'),
(10, 'Omer Farooq', 'omer.sales@pos.com', '0309-0001122', 2, 'Lahore');

-- 10 Records for Categories
INSERT INTO Categories (CategoryID, CategoryName, Description) VALUES
(1, 'Beverages', 'Cold drinks, juices, coffee, and tea'),
(2, 'Bakery', 'Fresh bread, buns, biscuits, and pastries'),
(3, 'Dairy', 'Milk, yogurt, cheese, and butter'),
(4, 'Snacks', 'Crisps, nuts, chocolates, and confectionery'),
(5, 'Personal Care', 'Soaps, shampoos, lotions, and dental care'),
(6, 'Household', 'Detergents, cleaners, and dishwashing liquids'),
(7, 'Produce', 'Fresh fruits and seasonal vegetables'),
(8, 'Meat & Poultry', 'Fresh beef, chicken, mutton, and seafood'),
(9, 'Cereal & Grains', 'Rice, flour, oats, and pulses'),
(10, 'Frozen Foods', 'Ready-to-cook meals, nuggets, and ice cream');

-- 10 Records for Products
INSERT INTO Products (ProductID, ProductName, CategoryID, UnitPrice, CostPrice, StockQuantity, Barcode) VALUES
(1, 'Mineral Water 1.5L', 1, 90.00, 65.00, 200, 'BAR001001'),
(2, 'Brown Bread Large', 2, 160.00, 120.00, 80, 'BAR001002'),
(3, 'Full Cream Milk 1L', 3, 240.00, 195.00, 150, 'BAR001003'),
(4, 'Potato Chips 50g', 4, 70.00, 48.00, 300, 'BAR001004'),
(5, 'Herbal Shampoo 200ml', 5, 450.00, 320.00, 60, 'BAR001005'),
(6, 'Dishwash Liquid 500ml', 6, 280.00, 200.00, 95, 'BAR001006'),
(7, 'Farm Fresh Eggs 1 Dozen', 3, 310.00, 260.00, 110, 'BAR001007'),
(8, 'Basmati Rice 5kg', 9, 1850.00, 1500.00, 45, 'BAR001008'),
(9, 'Chicken Breast Fillet 1kg', 8, 890.00, 720.00, 40, 'BAR001009'),
(10, 'Frozen Chicken Nuggets 500g', 10, 650.00, 490.00, 75, 'BAR001010');

-- 10 Records for Discounts
INSERT INTO Discounts (DiscountID, OfferName, DiscountPercent, MinPurchaseAmount, StartDate, EndDate) VALUES
(1, 'No Discount', 0.00, 0.00, '2024-01-01', '2030-12-31'),
(2, 'New Year Mega Deal', 10.00, 1000.00, '2024-01-01', '2024-01-15'),
(3, 'Ramadan Special Offer', 15.00, 2000.00, '2024-03-10', '2024-04-10'),
(4, 'Eid Celebration Discount', 20.00, 3000.00, '2024-04-08', '2024-04-15'),
(5, 'Summer Weekend Clearance', 5.00, 500.00, '2024-06-01', '2024-08-31'),
(6, 'Independence Day Promo', 14.00, 1400.00, '2024-08-10', '2024-08-16'),
(7, 'Flash Friday Deal', 12.50, 1500.00, '2024-09-01', '2024-09-30'),
(8, 'Corporate Privilege Discount', 8.00, 5000.00, '2024-01-01', '2024-12-31'),
(9, 'Bakery Evening Flat Discount', 10.00, 300.00, '2024-01-01', '2024-12-31'),
(10, 'Loyalty VIP Pass', 18.00, 2500.00, '2024-01-01', '2024-12-31');

-- 10 Records for Orders
INSERT INTO Orders (OrderID, OrderDate, CustomerID, SalesmanID, DiscountID, PaymentMethod, OrderStatus) VALUES
(1, '2024-03-12 10:15:00', 4, 2, 3, 'Credit Card', 'Completed'),
(2, '2024-03-12 11:30:00', 5, 3, 1, 'Cash', 'Completed'),
(3, '2024-03-13 14:20:00', 6, 2, 1, 'Debit Card', 'Completed'),
(4, '2024-03-13 16:45:00', 7, 10, 3, 'Cash', 'Completed'),
(5, '2024-03-14 12:00:00', 4, 2, 1, 'Mobile Wallet', 'Completed'),
(6, '2024-03-14 17:15:00', 9, 3, 5, 'Cash', 'Completed'),
(7, '2024-03-15 09:40:00', 5, 10, 1, 'Credit Card', 'Completed'),
(8, '2024-03-15 13:10:00', 6, 2, 7, 'Cash', 'Completed'),
(9, '2024-03-16 15:50:00', 7, 3, 1, 'Mobile Wallet', 'Completed'),
(10, '2024-03-16 19:05:00', 4, 10, 8, 'Credit Card', 'Completed');

-- 10 Records for Order_Items
INSERT INTO Order_Items (OrderItemID, OrderID, ProductID, Quantity, UnitPrice, Subtotal) VALUES
(1, 1, 8, 2, 1850.00, 3700.00),
(2, 1, 3, 4, 240.00, 960.00),
(3, 2, 1, 6, 90.00, 540.00),
(4, 3, 9, 2, 890.00, 1780.00),
(5, 4, 10, 3, 650.00, 1950.00),
(6, 5, 2, 2, 160.00, 320.00),
(7, 6, 5, 1, 450.00, 450.00),
(8, 7, 4, 10, 70.00, 700.00),
(9, 8, 8, 1, 1850.00, 1850.00),
(10, 9, 7, 3, 310.00, 930.00);

-- =============================================================================
-- 3. SIMPLE BUSINESS REPORTING QUERIES
-- =============================================================================

-- Report 1: Product catalog with Category names and profit margin per unit
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.CostPrice,
    p.UnitPrice,
    (p.UnitPrice - p.CostPrice) AS UnitProfit,
    p.StockQuantity
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName;

-- Report 2: Order summaries showing Customer, Salesman, Discount, and Raw Line-Item Total
SELECT 
    o.OrderID,
    o.OrderDate,
    cust.FullName AS CustomerName,
    sales.FullName AS SalesmanName,
    d.OfferName AS DiscountApplied,
    d.DiscountPercent,
    SUM(oi.Subtotal) AS GrossTotal,
    ROUND(SUM(oi.Subtotal) * (1 - (d.DiscountPercent / 100)), 2) AS NetPayable,
    o.PaymentMethod
FROM Orders o
JOIN Users cust ON o.CustomerID = cust.UserID
JOIN Users sales ON o.SalesmanID = sales.UserID
LEFT JOIN Discounts d ON o.DiscountID = d.DiscountID
JOIN Order_Items oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.OrderDate, cust.FullName, sales.FullName, d.OfferName, d.DiscountPercent, o.PaymentMethod
ORDER BY o.OrderID;

-- Report 3: Sales performance per Salesman
SELECT 
    u.UserID AS SalesmanID,
    u.FullName AS SalesmanName,
    COUNT(DISTINCT o.OrderID) AS TotalOrdersProcessed,
    SUM(oi.Subtotal) AS TotalSalesRevenue
FROM Users u
JOIN Orders o ON u.UserID = o.SalesmanID
JOIN Order_Items oi ON o.OrderID = oi.OrderID
GROUP BY u.UserID, u.FullName
ORDER BY TotalSalesRevenue DESC;

-- Report 4: Current Inventory and Stock Valuation
SELECT 
    c.CategoryName,
    COUNT(p.ProductID) AS TotalProducts,
    SUM(p.StockQuantity) AS TotalUnitsInStock,
    SUM(p.StockQuantity * p.CostPrice) AS InventoryAssetValue
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName
ORDER BY InventoryAssetValue DESC;

-- Report 5: Low stock alert (Products with stock under 70 units)
SELECT 
    ProductID,
    ProductName,
    StockQuantity,
    UnitPrice
FROM Products
WHERE StockQuantity < 70
ORDER BY StockQuantity ASC;

-- =============================================================================
-- End of LAB 02 POS Database Script
-- =============================================================================
