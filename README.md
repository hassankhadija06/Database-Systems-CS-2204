# Database Systems Labs

A complete collection of hands-on MySQL laboratory exercises covering core Database Systems concepts. Each lab builds practical skills through schema design, constraints, normalization, filtering, joins, scalar functions, and aggregate queries.

## Lab Overview

| Lab | Topic | Folder |
|-----|-------|--------|
| Lab 01 | Installation of XAMPP |
| Lab 02 | Point of Sale (POS) Database System | [Lab02_POS_Database](Lab02_POS_Database/) |
| Lab 03 | Keys and Queries (University Schema) | [Lab03_Keys_and_Queries](Lab03_Keys_and_Queries/) |
| Lab 04 | Normalization – Overview & 1NF | [Lab04_Normalization_1NF](Lab04_Normalization_1NF/) |
| Lab 05 | Normalization – 2NF & 3NF | [Lab05_Normalization_2NF_3NF](Lab05_Normalization_2NF_3NF/) |
| Lab 06 | SQL Filters Part 01 – Comparison & Logical Operators | [Lab06_Filters_Part01](Lab06_Filters_Part01/) |
| Lab 07 | SQL Filters Part 02 – BETWEEN, IN, LIKE, IS NULL, Sorting | [Lab07_Filters_Part02](Lab07_Filters_Part02/) |
| Lab 08 | SQL Joins Part 01 – INNER, LEFT, RIGHT Joins | [Lab08_Joins_Part01](Lab08_Joins_Part01/) |
| Lab 09 | SQL Joins Part 02 – Self Joins, Multi-table Joins | [Lab09_Joins_Part02](Lab09_Joins_Part02/) |
| Lab 10 | Scalar Functions Part 01 – String Functions | [Lab10_Scalar_Functions_Part01](Lab10_Scalar_Functions_Part01/) |
| Lab 11 | Scalar Functions Part 02 – Numeric & Date/Time Functions | [Lab11_Scalar_Functions_Part02](Lab11_Scalar_Functions_Part02/) |
| Lab 12 | Aggregate Functions – GROUP BY, HAVING | [Lab12_Aggregate_Functions](Lab12_Aggregate_Functions/) |

## Prerequisites

- **MySQL** 8.0+ or **MariaDB** 10.5+ (or any compatible MySQL client)
- MySQL Workbench, DBeaver, VS Code with SQL extension, or command-line `mysql` client
- Basic familiarity with SQL syntax

## How to Run Any Lab

1. Open a MySQL client and connect to your server.
2. Navigate to the desired lab folder.
3. Execute the `.sql` file:

   **Command line:**
   ```bash
   mysql -u your_username -p < LabXX_Folder/LAB_XX_Script.sql
   ```

   **Inside MySQL client:**
   ```sql
   SOURCE /path/to/LabXX_Folder/LAB_XX_Script.sql;
   ```

4. Most scripts create their own database (e.g., `Point_of_Sale`, `joins_lab`, etc.). Switch to it with `USE database_name;` if needed.
5. Run the verification / reporting queries included at the end of each script to confirm correctness.

## Repository Structure

```
Database-Systems-Labs/
├── README.md                          ← Main repository README
├── Lab02_POS_Database/
│   ├── LAB_02_POS_Database.sql
│   └── README.md
├── Lab03_Keys_and_Queries/
│   ├── LAB_03_Keys_and_Queries.sql
│   └── README.md
├── Lab04_Normalization_1NF/
│   ├── LAB_04_Normalization_Overview_1NF.sql
│   └── README.md
├── Lab05_Normalization_2NF_3NF/
│   ├── LAB_05_Normalization_2NF_3NF.sql
│   └── README.md
├── Lab06_Filters_Part01/
│   ├── LAB_06_Filters_Part01.sql
│   └── README.md
├── Lab07_Filters_Part02/
│   ├── LAB_07_Filters_Part02.sql
│   └── README.md
├── Lab08_Joins_Part01/
│   ├── LAB_08_Joins_Part01.sql
│   └── README.md
├── Lab09_Joins_Part02/
│   ├── LAB_09_Joins_Part02.sql
│   └── README.md
├── Lab10_Scalar_Functions_Part01/
│   ├── LAB_10_Scalar_Functions_Part01.sql
│   └── README.md
├── Lab11_Scalar_Functions_Part02/
│   ├── LAB_11_Scalar_Functions_Part02.sql
│   └── README.md
└── Lab12_Aggregate_Functions/
    ├── LAB_12_Aggregate_Functions.sql
    └── README.md
```

Each lab folder contains:
- The complete SQL script
- A focused README explaining what the lab covers, how to execute it, and how to verify results

## Recommended Learning Order

1. Lab 02 → Lab 03 (schema design & keys)
2. Lab 04 → Lab 05 (normalization)
3. Lab 06 → Lab 07 (filtering & sorting)
4. Lab 08 → Lab 09 (joins)
5. Lab 10 → Lab 11 (scalar functions)
6. Lab 12 (aggregates)

## Notes

- All scripts are self-contained: they drop existing tables (if any) and recreate them, then insert sample data and run practice queries.
- Scripts use `CREATE DATABASE IF NOT EXISTS` so they are safe to re-run.
- Some labs reuse databases (e.g., Lab 07 continues from Lab 06’s `filters_lab`). Follow the recommended order or re-run the prerequisite lab first.

## License

These materials are intended for educational use. Feel free to fork, modify, and use them for learning or teaching.
