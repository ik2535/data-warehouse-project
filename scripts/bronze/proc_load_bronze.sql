/*
===============================================================================
Healthcare ETL Procedure: Load Bronze Layer
===============================================================================
Script Purpose:
    This stored procedure loads healthcare data from CSV files into the bronze layer
    tables. It handles data ingestion from EHR and HMS source systems.
===============================================================================
*/

IF OBJECT_ID('proc_load_bronze_healthcare', 'P') IS NOT NULL
    DROP PROCEDURE proc_load_bronze_healthcare;
GO

CREATE PROCEDURE proc_load_bronze_healthcare
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        PRINT 'Starting healthcare bronze data loading process...';
        
        -- Clear existing bronze data
        TRUNCATE TABLE bronze.ehr_patient_info;
        TRUNCATE TABLE bronze.ehr_treatment_info;
        TRUNCATE TABLE bronze.ehr_medical_records;
        TRUNCATE TABLE bronze.hms_location_data;
        TRUNCATE TABLE bronze.hms_patient_demographics;
        TRUNCATE TABLE bronze.hms_treatment_categories;
        
        PRINT 'Bronze tables cleared successfully.';
        
        -- Note: In a real implementation, you would use BULK INSERT or other methods
        -- to load data from CSV files. For this demo, we show the structure.
        
        /*
        Example BULK INSERT commands:
        
        BULK INSERT bronze.ehr_patient_info
        FROM 'C:\Data\source_ehr\patient_info.csv'
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            FORMAT = 'CSV'
        );
        
        -- Repeat for all other tables...
        */
        
        PRINT 'Healthcare bronze data loading completed successfully!';
        
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
               
        PRINT 'Error occurred during healthcare bronze data loading:';
        PRINT @ErrorMessage;
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

PRINT 'Healthcare bronze data loading procedure created successfully!';
