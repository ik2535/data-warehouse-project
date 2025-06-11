/*
===============================================================================
DDL Script: Create Silver Healthcare Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema for cleaned and validated
    healthcare data, dropping existing tables if they already exist.
    Run this script to define the DDL structure of silver healthcare tables.
===============================================================================
*/

-- Silver Patient Information
IF OBJECT_ID('silver.ehr_patient_info', 'U') IS NOT NULL
    DROP TABLE silver.ehr_patient_info;
GO

CREATE TABLE silver.ehr_patient_info (
    patient_id          INT,
    patient_mrn         NVARCHAR(50),
    first_name          NVARCHAR(50),
    last_name           NVARCHAR(50),
    date_of_birth       DATE,
    gender              NVARCHAR(10),
    marital_status      NVARCHAR(20),
    registration_date   DATE,
    insurance_provider  NVARCHAR(100),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver Treatment Information
IF OBJECT_ID('silver.ehr_treatment_info', 'U') IS NOT NULL
    DROP TABLE silver.ehr_treatment_info;
GO

CREATE TABLE silver.ehr_treatment_info (
    treatment_id        INT,
    category_code       NVARCHAR(50),
    treatment_code      NVARCHAR(50),
    treatment_name      NVARCHAR(100),
    cost_estimate       DECIMAL(10,2),
    department          NVARCHAR(50),
    effective_date      DATE,
    discontinued_date   DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver Medical Records
IF OBJECT_ID('silver.ehr_medical_records', 'U') IS NOT NULL
    DROP TABLE silver.ehr_medical_records;
GO

CREATE TABLE silver.ehr_medical_records (
    record_id           NVARCHAR(50),
    treatment_code      NVARCHAR(50),
    patient_id          INT,
    admission_date      DATE,
    discharge_date      DATE,
    followup_date       DATE,
    total_cost          DECIMAL(10,2),
    duration_days       INT,
    outcome_score       INT,
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver Hospital Location Data
IF OBJECT_ID('silver.hms_location_data', 'U') IS NOT NULL
    DROP TABLE silver.hms_location_data;
GO

CREATE TABLE silver.hms_location_data (
    patient_mrn         NVARCHAR(50),
    region              NVARCHAR(50),
    city                NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver Patient Demographics
IF OBJECT_ID('silver.hms_patient_demographics', 'U') IS NOT NULL
    DROP TABLE silver.hms_patient_demographics;
GO

CREATE TABLE silver.hms_patient_demographics (
    patient_mrn         NVARCHAR(50),
    birth_date          DATE,
    gender_code         NVARCHAR(10),
    emergency_contact   NVARCHAR(100),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Silver Treatment Categories
IF OBJECT_ID('silver.hms_treatment_categories', 'U') IS NOT NULL
    DROP TABLE silver.hms_treatment_categories;
GO

CREATE TABLE silver.hms_treatment_categories (
    treatment_code      NVARCHAR(50),
    category            NVARCHAR(50),
    subcategory         NVARCHAR(50),
    requires_followup   NVARCHAR(10),
    dwh_create_date     DATETIME2 DEFAULT GETDATE(),
    dwh_update_date     DATETIME2 DEFAULT GETDATE()
);
GO

PRINT 'Silver healthcare tables created successfully!';
