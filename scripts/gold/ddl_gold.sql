/*
===============================================================================
DDL Script: Create Gold Healthcare Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the healthcare data warehouse. 
    The Gold layer represents the final dimension and fact tables optimized for
    healthcare reporting and clinical analytics.

    Each view performs transformations and combines data from the Silver layer 
    to produce clean, enriched, and analysis-ready healthcare datasets.

Usage:
    - These views can be queried directly for healthcare analytics and clinical reporting.
===============================================================================
*/

-- =============================================================================
-- Create Healthcare Dimension: gold.dim_patients
-- =============================================================================
IF OBJECT_ID('gold.dim_patients', 'V') IS NOT NULL
    DROP VIEW gold.dim_patients;
GO

CREATE VIEW gold.dim_patients AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pi.patient_id) AS patient_key, -- Surrogate key
    pi.patient_id                              AS patient_id,
    pi.patient_mrn                             AS medical_record_number,
    pi.first_name                              AS first_name,
    pi.last_name                               AS last_name,
    ld.region                                  AS patient_region,
    ld.city                                    AS patient_city,
    pi.marital_status                          AS marital_status,
    CASE 
        WHEN pi.gender != 'Unknown' THEN pi.gender -- EHR is primary source for gender
        ELSE COALESCE(pd.gender_code, 'Unknown')    -- Fallback to HMS data
    END                                        AS gender,
    pd.birth_date                              AS birth_date,
    pi.registration_date                       AS registration_date,
    pi.insurance_provider                      AS insurance_provider,
    pd.emergency_contact                       AS emergency_contact
FROM silver.ehr_patient_info pi
LEFT JOIN silver.hms_patient_demographics pd
    ON pi.patient_mrn = pd.patient_mrn
LEFT JOIN silver.hms_location_data ld
    ON pi.patient_mrn = ld.patient_mrn;
GO

-- =============================================================================
-- Create Healthcare Dimension: gold.dim_treatments
-- =============================================================================
IF OBJECT_ID('gold.dim_treatments', 'V') IS NOT NULL
    DROP VIEW gold.dim_treatments;
GO

CREATE VIEW gold.dim_treatments AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ti.effective_date, ti.treatment_code) AS treatment_key, -- Surrogate key
    ti.treatment_id                            AS treatment_id,
    ti.treatment_code                          AS treatment_code,
    ti.treatment_name                          AS treatment_name,
    ti.category_code                           AS category_code,
    tc.category                                AS treatment_category,
    tc.subcategory                             AS treatment_subcategory,
    tc.requires_followup                       AS requires_followup,
    ti.cost_estimate                           AS estimated_cost,
    ti.department                              AS department,
    ti.effective_date                          AS effective_date
FROM silver.ehr_treatment_info ti
LEFT JOIN silver.hms_treatment_categories tc
    ON ti.category_code = tc.treatment_code
WHERE ti.discontinued_date IS NULL; -- Filter out discontinued treatments
GO

-- =============================================================================
-- Create Healthcare Fact Table: gold.fact_medical_records
-- =============================================================================
IF OBJECT_ID('gold.fact_medical_records', 'V') IS NOT NULL
    DROP VIEW gold.fact_medical_records;
GO

CREATE VIEW gold.fact_medical_records AS
SELECT
    mr.record_id                               AS record_id,
    tr.treatment_key                           AS treatment_key,
    pt.patient_key                             AS patient_key,
    mr.admission_date                          AS admission_date,
    mr.discharge_date                          AS discharge_date,
    mr.followup_date                           AS followup_date,
    mr.total_cost                              AS total_cost,
    mr.duration_days                           AS length_of_stay,
    mr.outcome_score                           AS outcome_score,
    CASE 
        WHEN mr.outcome_score >= 8 THEN 'Excellent'
        WHEN mr.outcome_score >= 6 THEN 'Good'
        WHEN mr.outcome_score >= 4 THEN 'Fair'
        ELSE 'Poor'
    END                                        AS outcome_category
FROM silver.ehr_medical_records mr
LEFT JOIN gold.dim_treatments tr
    ON mr.treatment_code = tr.treatment_code
LEFT JOIN gold.dim_patients pt
    ON mr.patient_id = pt.patient_id;
GO

PRINT 'Gold healthcare views created successfully!';
