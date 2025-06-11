/*
===============================================================================
Healthcare ETL Procedure: Load Silver Layer
===============================================================================
Script Purpose:
    This stored procedure transforms and loads healthcare data from the bronze layer
    into the silver layer with data cleansing and validation.
===============================================================================
*/

IF OBJECT_ID('proc_load_silver_healthcare', 'P') IS NOT NULL
    DROP PROCEDURE proc_load_silver_healthcare;
GO

CREATE PROCEDURE proc_load_silver_healthcare
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @RowCount INT;
    
    BEGIN TRY
        PRINT 'Starting healthcare silver data loading process...';
        
        -- Clear existing silver data
        TRUNCATE TABLE silver.ehr_patient_info;
        TRUNCATE TABLE silver.ehr_treatment_info;
        TRUNCATE TABLE silver.ehr_medical_records;
        TRUNCATE TABLE silver.hms_location_data;
        TRUNCATE TABLE silver.hms_patient_demographics;
        TRUNCATE TABLE silver.hms_treatment_categories;
        
        PRINT 'Silver tables cleared successfully.';
        
        -- Load and clean patient information
        INSERT INTO silver.ehr_patient_info (
            patient_id, patient_mrn, first_name, last_name, date_of_birth,
            gender, marital_status, registration_date, insurance_provider
        )
        SELECT 
            patient_id,
            UPPER(LTRIM(RTRIM(patient_mrn))) AS patient_mrn,
            LTRIM(RTRIM(first_name)) AS first_name,
            LTRIM(RTRIM(last_name)) AS last_name,
            date_of_birth,
            CASE 
                WHEN LOWER(LTRIM(RTRIM(gender))) IN ('male', 'm') THEN 'Male'
                WHEN LOWER(LTRIM(RTRIM(gender))) IN ('female', 'f') THEN 'Female'
                ELSE 'Unknown'
            END AS gender,
            LTRIM(RTRIM(marital_status)) AS marital_status,
            registration_date,
            LTRIM(RTRIM(insurance_provider)) AS insurance_provider
        FROM bronze.ehr_patient_info
        WHERE patient_id IS NOT NULL
          AND patient_mrn IS NOT NULL
          AND first_name IS NOT NULL
          AND last_name IS NOT NULL;
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Processed ' + CAST(@RowCount AS VARCHAR(10)) + ' patient records.';
        
        -- Load and clean treatment information
        INSERT INTO silver.ehr_treatment_info (
            treatment_id, category_code, treatment_code, treatment_name,
            cost_estimate, department, effective_date, discontinued_date
        )
        SELECT 
            treatment_id,
            UPPER(LTRIM(RTRIM(treatment_code))) AS category_code,
            UPPER(LTRIM(RTRIM(treatment_code))) AS treatment_code,
            LTRIM(RTRIM(treatment_name)) AS treatment_name,
            cost_estimate,
            LTRIM(RTRIM(department)) AS department,
            effective_date,
            discontinued_date
        FROM bronze.ehr_treatment_info
        WHERE treatment_id IS NOT NULL
          AND treatment_code IS NOT NULL
          AND cost_estimate > 0;
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Processed ' + CAST(@RowCount AS VARCHAR(10)) + ' treatment records.';
        
        -- Load and clean medical records with date conversions
        INSERT INTO silver.ehr_medical_records (
            record_id, treatment_code, patient_id, admission_date,
            discharge_date, followup_date, total_cost, duration_days, outcome_score
        )
        SELECT 
            UPPER(LTRIM(RTRIM(record_id))) AS record_id,
            UPPER(LTRIM(RTRIM(treatment_code))) AS treatment_code,
            patient_id,
            -- Convert YYYYMMDD integer to DATE
            TRY_CAST(
                SUBSTRING(CAST(admission_date AS VARCHAR(8)), 1, 4) + '-' +
                SUBSTRING(CAST(admission_date AS VARCHAR(8)), 5, 2) + '-' +
                SUBSTRING(CAST(admission_date AS VARCHAR(8)), 7, 2) AS DATE
            ) AS admission_date,
            TRY_CAST(
                SUBSTRING(CAST(discharge_date AS VARCHAR(8)), 1, 4) + '-' +
                SUBSTRING(CAST(discharge_date AS VARCHAR(8)), 5, 2) + '-' +
                SUBSTRING(CAST(discharge_date AS VARCHAR(8)), 7, 2) AS DATE
            ) AS discharge_date,
            TRY_CAST(
                SUBSTRING(CAST(followup_date AS VARCHAR(8)), 1, 4) + '-' +
                SUBSTRING(CAST(followup_date AS VARCHAR(8)), 5, 2) + '-' +
                SUBSTRING(CAST(followup_date AS VARCHAR(8)), 7, 2) AS DATE
            ) AS followup_date,
            total_cost,
            duration_days,
            outcome_score
        FROM bronze.ehr_medical_records
        WHERE record_id IS NOT NULL
          AND treatment_code IS NOT NULL
          AND patient_id IS NOT NULL
          AND total_cost > 0
          AND outcome_score BETWEEN 1 AND 10;
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Processed ' + CAST(@RowCount AS VARCHAR(10)) + ' medical records.';
        
        -- Load location data
        INSERT INTO silver.hms_location_data (patient_mrn, region, city)
        SELECT 
            UPPER(LTRIM(RTRIM(patient_mrn))) AS patient_mrn,
            LTRIM(RTRIM(region)) AS region,
            LTRIM(RTRIM(city)) AS city
        FROM bronze.hms_location_data
        WHERE patient_mrn IS NOT NULL;
        
        -- Load patient demographics
        INSERT INTO silver.hms_patient_demographics (
            patient_mrn, birth_date, gender_code, emergency_contact
        )
        SELECT 
            UPPER(LTRIM(RTRIM(patient_mrn))) AS patient_mrn,
            birth_date,
            CASE 
                WHEN UPPER(LTRIM(RTRIM(gender_code))) = 'M' THEN 'Male'
                WHEN UPPER(LTRIM(RTRIM(gender_code))) = 'F' THEN 'Female'
                ELSE 'Unknown'
            END AS gender_code,
            LTRIM(RTRIM(emergency_contact)) AS emergency_contact
        FROM bronze.hms_patient_demographics
        WHERE patient_mrn IS NOT NULL;
        
        -- Load treatment categories
        INSERT INTO silver.hms_treatment_categories (
            treatment_code, category, subcategory, requires_followup
        )
        SELECT 
            UPPER(LTRIM(RTRIM(treatment_code))) AS treatment_code,
            LTRIM(RTRIM(category)) AS category,
            LTRIM(RTRIM(subcategory)) AS subcategory,
            CASE 
                WHEN LOWER(LTRIM(RTRIM(requires_followup))) IN ('yes', 'y', '1', 'true') THEN 'Yes'
                WHEN LOWER(LTRIM(RTRIM(requires_followup))) IN ('no', 'n', '0', 'false') THEN 'No'
                ELSE 'Unknown'
            END AS requires_followup
        FROM bronze.hms_treatment_categories
        WHERE treatment_code IS NOT NULL;
        
        PRINT 'Healthcare silver data loading completed successfully!';
        
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        PRINT 'Error occurred during healthcare silver data loading:';
        PRINT @ErrorMessage;
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

PRINT 'Healthcare silver data loading procedure created successfully!';
