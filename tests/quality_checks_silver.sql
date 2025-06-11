/*
===============================================================================
Healthcare Data Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    This script performs data quality validation checks on the silver layer
    healthcare tables to ensure data integrity and completeness.
===============================================================================
*/

-- Check for duplicate patients
SELECT 'Duplicate Patient Check' AS check_name,
       COUNT(*) AS duplicate_count
FROM (
    SELECT patient_id, COUNT(*) as cnt
    FROM silver.ehr_patient_info
    GROUP BY patient_id
    HAVING COUNT(*) > 1
) duplicates;

-- Check for missing required patient fields
SELECT 'Missing Patient Data Check' AS check_name,
       SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS missing_patient_id,
       SUM(CASE WHEN patient_mrn IS NULL OR patient_mrn = '' THEN 1 ELSE 0 END) AS missing_mrn,
       SUM(CASE WHEN first_name IS NULL OR first_name = '' THEN 1 ELSE 0 END) AS missing_first_name,
       SUM(CASE WHEN last_name IS NULL OR last_name = '' THEN 1 ELSE 0 END) AS missing_last_name
FROM silver.ehr_patient_info;

-- Check for duplicate treatments
SELECT 'Duplicate Treatment Check' AS check_name,
       COUNT(*) AS duplicate_count
FROM (
    SELECT treatment_code, COUNT(*) as cnt
    FROM silver.ehr_treatment_info
    GROUP BY treatment_code
    HAVING COUNT(*) > 1
) duplicates;

-- Check for missing treatment information
SELECT 'Missing Treatment Data Check' AS check_name,
       SUM(CASE WHEN treatment_code IS NULL OR treatment_code = '' THEN 1 ELSE 0 END) AS missing_treatment_code,
       SUM(CASE WHEN treatment_name IS NULL OR treatment_name = '' THEN 1 ELSE 0 END) AS missing_treatment_name,
       SUM(CASE WHEN cost_estimate IS NULL OR cost_estimate <= 0 THEN 1 ELSE 0 END) AS invalid_cost
FROM silver.ehr_treatment_info;

-- Check for invalid date sequences in medical records
SELECT 'Invalid Date Sequence Check' AS check_name,
       COUNT(*) AS invalid_dates
FROM silver.ehr_medical_records
WHERE discharge_date < admission_date
   OR followup_date < discharge_date;

-- Check for negative costs or durations
SELECT 'Invalid Medical Values Check' AS check_name,
       SUM(CASE WHEN total_cost <= 0 THEN 1 ELSE 0 END) AS negative_costs,
       SUM(CASE WHEN duration_days < 0 THEN 1 ELSE 0 END) AS negative_duration,
       SUM(CASE WHEN outcome_score < 1 OR outcome_score > 10 THEN 1 ELSE 0 END) AS invalid_outcome_score
FROM silver.ehr_medical_records;

-- Data Completeness Summary
SELECT 'Healthcare Data Completeness' AS summary_name,
       (SELECT COUNT(*) FROM silver.ehr_patient_info) AS total_patients,
       (SELECT COUNT(*) FROM silver.ehr_treatment_info) AS total_treatments,
       (SELECT COUNT(*) FROM silver.ehr_medical_records) AS total_medical_records,
       (SELECT COUNT(*) FROM silver.hms_location_data) AS total_locations,
       (SELECT COUNT(*) FROM silver.hms_patient_demographics) AS total_demographics;

PRINT 'Healthcare silver layer data quality checks completed!';
