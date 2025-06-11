# Healthcare Data Warehouse Project

This project builds a healthcare data warehouse using SQL Server with a three-layer medallion architecture (Bronze, Silver, Gold) to analyze patient data and treatment outcomes.

## Project Overview

The goal is to create a data warehouse that combines patient information from different healthcare systems (EHR and HMS) and provides clean, organized data for healthcare analytics and reporting.

## 🏗️ Data Architecture

The data architecture follows the Medallion Architecture with **Bronze**, **Silver**, and **Gold** layers:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DATA SOURCES  │    │  BRONZE LAYER   │    │  SILVER LAYER   │    │   GOLD LAYER    │
│                 │    │   (Raw Data)    │    │ (Cleaned Data)  │    │ (Analytics)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  EHR SYSTEM     │───▶│ bronze.ehr_*    │───▶│ silver.ehr_*    │───▶│ gold.dim_*      │
│ • Patient Info  │    │ (6 raw tables)  │    │ (cleaned data)  │    │ (2 dimensions)  │
│ • Treatments    │    │                 │    │                 │    │                 │
│ • Medical Records│    │                 │    │                 │    │ gold.fact_*     │
└─────────────────┘    │                 │    │                 │    │ (1 fact table)  │
                       │                 │    │                 │    │                 │
┌─────────────────┐    │                 │    │                 │    │                 │
│  HMS SYSTEM     │───▶│                 │    │                 │    │                 │
│ • Demographics  │    │                 │    │                 │    │                 │
│ • Locations     │    │                 │    │                 │    │                 │
│ • Categories    │    │                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

1. **Bronze Layer**: Stores raw healthcare data as-is from source systems. Data ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: Includes data cleansing, validation, and standardization processes to prepare healthcare data for analysis.
3. **Gold Layer**: Contains business-ready data modeled into a star schema for healthcare reporting and analytics.

## Data Sources

- **EHR System**: Patient info, treatments, medical records
- **HMS System**: Patient demographics, locations, treatment categories

## Project Structure

```
healthcare-data-warehouse/
├── datasets/               # Sample healthcare data files
├── scripts/               # SQL scripts for each layer
│   ├── bronze/           # Raw data tables
│   ├── silver/           # Cleaned data tables  
│   └── gold/             # Analytics views
├── tests/                # Data quality checks
└── docs/                 # Project documentation
```

## Getting Started

1. Set up SQL Server and create the database:
   ```sql
   scripts/init_database.sql
   ```

2. Create the bronze layer tables:
   ```sql
   scripts/bronze/ddl_bronze.sql
   ```

3. Create the silver layer tables:
   ```sql
   scripts/silver/ddl_silver.sql
   ```

4. Create the gold layer views:
   ```sql
   scripts/gold/ddl_gold.sql
   ```

5. Load sample data and run ETL procedures:
   ```sql
   scripts/silver/proc_load_silver.sql
   ```

## Sample Analytics

After loading data, you can run queries like:

```sql
-- Patient demographics by region
SELECT patient_region, gender, COUNT(*) as patient_count
FROM gold.dim_patients 
GROUP BY patient_region, gender;

-- Treatment outcomes analysis
SELECT treatment_category, AVG(outcome_score) as avg_outcome
FROM gold.fact_medical_records fmr
JOIN gold.dim_treatments dt ON fmr.treatment_key = dt.treatment_key
GROUP BY treatment_category;
```

## Data Quality

Run quality checks to validate your data:
- `tests/quality_checks_silver.sql` - Validates silver layer
- `tests/quality_checks_gold.sql` - Validates gold layer

## Technologies Used

- SQL Server
- T-SQL
- Healthcare data modeling
- ETL processes

---

This project demonstrates healthcare data warehousing concepts and can be used as a learning resource for SQL and data engineering.
