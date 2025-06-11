/*
===============================================================================
DDL Script: Create Bronze Healthcare Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema for healthcare data ingestion,
    dropping existing tables if they already exist.
    Run this script to define the DDL structure of bronze healthcare tables.
===============================================================================
*/

-- Patient Information from EHR System
IF OBJECT_ID('bronze.ehr_patient_info', 'U') IS NOT NULL
    DROP TABLE bronze.ehr_patient_info;
GO

CREATE TABLE bronze.ehr_patient_info (
    patient_id          INT,
    patient_mrn         NVARCHAR(50),
    first_name          NVARCHAR(50),
    last_name           NVARCHAR(50),
    date_of_birth       DATE,
    gender              NVARCHAR(10),
    marital_status      NVARCHAR(20),
    registration_date   DATE,
    insurance_provider  NVARCHAR(100)
);
GO

-- Treatment Information from EHR System  
IF OBJECT_ID('bronze.ehr_treatment_info', 'U') IS NOT NULL
    DROP TABLE bronze.ehr_treatment_info;
GO

CREATE TABLE bronze.ehr_treatment_info (
    treatment_id        INT,
    treatment_code      NVARCHAR(50),
    treatment_name      NVARCHAR(100),
    cost_estimate       DECIMAL(10,2),
    department          NVARCHAR(50),
    effective_date      DATE,
    discontinued_date   DATE
);
GO

-- Medical Records from EHR System
IF OBJECT_ID('bronze.ehr_medical_records', 'U') IS NOT NULL
    DROP TABLE bronze.ehr_medical_records;
GO

CREATE TABLE bronze.ehr_medical_records (
    record_id           NVARCHAR(50),
    treatment_code      NVARCHAR(50),
    patient_id          INT,
    admission_date      INT,
    discharge_date      INT,
    followup_date       INT,
    total_cost          DECIMAL(10,2),
    duration_days       INT,
    outcome_score       INT
);
GO

-- Hospital Location Data from HMS
IF OBJECT_ID('bronze.hms_location_data', 'U') IS NOT NULL
    DROP TABLE bronze.hms_location_data;
GO

CREATE TABLE bronze.hms_location_data (
    patient_mrn         NVARCHAR(50),
    region              NVARCHAR(50),
    city                NVARCHAR(50)
);
GO

-- Patient Demographics from HMS
IF OBJECT_ID('bronze.hms_patient_demographics', 'U') IS NOT NULL
    DROP TABLE bronze.hms_patient_demographics;
GO

CREATE TABLE bronze.hms_patient_demographics (
    patient_mrn         NVARCHAR(50),
    birth_date          DATE,
    gender_code         NVARCHAR(10),
    emergency_contact   NVARCHAR(100)
);
GO

-- Treatment Categories from HMS
IF OBJECT_ID('bronze.hms_treatment_categories', 'U') IS NOT NULL
    DROP TABLE bronze.hms_treatment_categories;
GO

CREATE TABLE bronze.hms_treatment_categories (
    treatment_code      NVARCHAR(50),
    category            NVARCHAR(50),
    subcategory         NVARCHAR(50),
    requires_followup   NVARCHAR(10)
);
GO

PRINT 'Bronze healthcare tables created successfully!';
