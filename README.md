# Employee Activity Data Warehouse

This project is a SQL-based data warehouse solution that integrates multiple data sources (timesheets, training attendance, absences, and missing hours) into a unified star schema model for reporting employee activity.

## 📌 Overview

The goal of this project is to simulate a real-world ETL pipeline and data warehouse design by:
- integrating data from multiple heterogeneous sources
- cleaning and transforming raw data
- modeling the data using a star schema
- enabling reporting by day and by employee

## 🏗️ Architecture

The project follows a classic ETL flow:

**Source Data → Staging → Transformation → Data Warehouse (Dimensions + Fact)**

### Staging Tables
- `stg_employee`
- `stg_timesheet`
- `stg_absence`
- `stg_training_attendance`
- `stg_missing_hours`

### Dimension Tables
- `dim_employee` (SCD Type 2 simplified)
- `dim_date`
- `dim_activity_type`
- `dim_absence_type`
- `dim_training_session`

### Fact Table
- `fact_employee_activity`

Each row in the fact table represents:
> one employee + one day + one activity type

## ⚙️ ETL Process

The ETL process includes:
- importing data from CSV files into staging tables
- cleaning and standardizing data (TRIM, UPPER, date handling)
- calculating durations (e.g. training time from timestamps)
- expanding date intervals for absences
- loading dimension tables
- populating the fact table from multiple sources

## 📊 Example Reports

The model supports queries such as:

- Employee activity by day
- Monthly activity summary per employee
- Training session attendance and average duration
- Daily breakdown of worked / training / absence / missing hours

## 🧠 Key Concepts Used

- Star Schema design
- ETL pipeline (Extract, Transform, Load)
- Data integration from multiple sources
- Slowly Changing Dimension (SCD Type 2)
- SQL joins and aggregations
- Date handling and time calculations

## 🛠️ Technologies

- Oracle SQL
- SQL Developer
- CSV data sources

This project was built as part of a data/SQL learning module to simulate real-world data warehouse design and ETL processes.
