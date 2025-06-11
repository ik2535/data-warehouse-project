/*
===============================================================================
Healthcare Analytics Data Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs comprehensive data quality validation checks on the 
    gold layer healthcare views to ensure data integrity and accuracy 
    for clinical reporting and healthcare analytics.
===============================================================================
*/

-- Validate patient dimension completeness
SELECT 'Patient Dimension Completeness' AS check_name,
       COUNT(*) AS total_patients,
       SUM(CASE WHEN patient_key IS NULL THEN 1 ELSE 0 END) AS missing_patient_key,
       SUM(CASE WHEN medical_record_number IS NULL THEN 1 ELSE 0 END) AS missing_mrn,
       SUM(CASE WHEN first_name IS NULL OR first_name = '' THEN 1 ELSE 0 END) AS missing_first_name,
       SUM(CASE WHEN gender = 'Unknown' THEN 1 ELSE 0 END) AS unknown_gender
FROM gold.dim_patients;

-- Check for patient demographic data integrity
SELECT 'Patient Demographics Integrity' AS check_name,
       SUM(CASE WHEN birth_date > GETDATE() THEN 1 ELSE 0 END) AS future_birth_dates,
       SUM(CASE WHEN DATEDIFF(YEAR, birth_date, GETDATE()) > 120 THEN 1 ELSE 0 END) AS unrealistic_age,
       SUM(CASE WHEN registration_date < '2020-01-01' THEN 1 ELSE 0 END) AS old_registrations
FROM gold.dim_patients;

-- Validate treatment dimension completeness
SELECT 'Treatment Dimension Completeness' AS check_name,
       COUNT(*) AS total_treatments,
       SUM(CASE WHEN treatment_key IS NULL THEN 1 ELSE 0 END) AS missing_treatment_key,
       SUM(CASE WHEN treatment_code IS NULL THEN 1 ELSE 0 END) AS missing_treatment_code,
       SUM(CASE WHEN treatment_name IS NULL OR treatment_name = '' THEN 1 ELSE 0 END) AS missing_treatment_name,
       SUM(CASE WHEN estimated_cost <= 0 THEN 1 ELSE 0 END) AS invalid_costs
FROM gold.dim_treatments;

-- Check treatment category data integrity
SELECT 'Treatment Categories Integrity' AS check_name,
       COUNT(DISTINCT treatment_category) AS unique_categories,
       SUM(CASE WHEN treatment_category IS NULL THEN 1 ELSE 0 END) AS missing_categories,
       SUM(CASE WHEN requires_followup NOT IN ('Yes', 'No') THEN 1 ELSE 0 END) AS invalid_followup_flag
FROM gold.dim_treatments;

-- Validate fact table completeness and referential integrity
SELECT 'Medical Records Fact Completeness' AS check_name,
       COUNT(*) AS total_records,
       SUM(CASE WHEN patient_key IS NULL THEN 1 ELSE 0 END) AS missing_patient_key,
       SUM(CASE WHEN treatment_key IS NULL THEN 1 ELSE 0 END) AS missing_treatment_key,
       SUM(CASE WHEN record_id IS NULL THEN 1 ELSE 0 END) AS missing_record_id
FROM gold.fact_medical_records;

-- Check medical records business logic integrity
SELECT 'Medical Records Business Logic' AS check_name,
       SUM(CASE WHEN discharge_date < admission_date THEN 1 ELSE 0 END) AS invalid_date_sequence,
       SUM(CASE WHEN followup_date < discharge_date THEN 1 ELSE 0 END) AS invalid_followup_date,
       SUM(CASE WHEN length_of_stay < 0 THEN 1 ELSE 0 END) AS negative_stay_length,
       SUM(CASE WHEN total_cost <= 0 THEN 1 ELSE 0 END) AS invalid_costs,
       SUM(CASE WHEN outcome_score < 1 OR outcome_score > 10 THEN 1 ELSE 0 END) AS invalid_outcome_scores
FROM gold.fact_medical_records;

-- Validate outcome category logic
SELECT 'Outcome Category Validation' AS check_name,
       outcome_category,
       COUNT(*) AS record_count,
       MIN(outcome_score) AS min_score,
       MAX(outcome_score) AS max_score
FROM gold.fact_medical_records
WHERE outcome_category IS NOT NULL
GROUP BY outcome_category
ORDER BY outcome_category;

-- Check for orphaned records in fact table
SELECT 'Orphaned Records Check' AS check_name,
       SUM(CASE WHEN dp.patient_key IS NULL THEN 1 ELSE 0 END) AS orphaned_patients,
       SUM(CASE WHEN dt.treatment_key IS NULL THEN 1 ELSE 0 END) AS orphaned_treatments
FROM gold.fact_medical_records fmr
LEFT JOIN gold.dim_patients dp ON fmr.patient_key = dp.patient_key
LEFT JOIN gold.dim_treatments dt ON fmr.treatment_key = dt.treatment_key;

-- Healthcare Analytics Summary Report
SELECT 'Healthcare Analytics Summary' AS report_name,
       (SELECT COUNT(*) FROM gold.dim_patients) AS total_patients,
       (SELECT COUNT(*) FROM gold.dim_treatments) AS total_treatments,
       (SELECT COUNT(*) FROM gold.fact_medical_records) AS total_medical_records,
       (SELECT AVG(CAST(outcome_score AS FLOAT)) FROM gold.fact_medical_records) AS avg_outcome_score,
       (SELECT AVG(CAST(total_cost AS FLOAT)) FROM gold.fact_medical_records) AS avg_treatment_cost,
       (SELECT AVG(CAST(length_of_stay AS FLOAT)) FROM gold.fact_medical_records) AS avg_length_of_stay;

PRINT 'Healthcare gold layer data quality validation completed successfully!';
