----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Create Date : 2019-07-31 03:55 PM
-- Mail        : codefivestar@gmail.com
-- Description : Script to removes operation records from the database that are outside 
--               the retention window and maintains a maximum number of versions per project.
-- How to Use  : Run manually. 
---------------------------------------------------------------------------------------------------------


-- Change to msdb Database
USE [msdb];
GO

DECLARE @role INT;

	SET @role = (
					SELECT [role]
					  FROM [sys].[dm_hadr_availability_replica_states] hars
		        INNER JOIN [sys].[availability_databases_cluster] adc
			            ON hars.[group_id] = adc.[group_id]
		             WHERE hars.[is_local] = 1
			           AND adc.[database_name] = 'SSISDB'
		         )

IF ((DB_ID('SSISDB') IS NOT NULL) AND (@role IS NULL OR @role = 1))
	BEGIN
		-- SSIS Server Operation Records Maintenance
        EXEC [SSISDB].[internal].[cleanup_server_retention_window];

        -- SSIS Server Max Version Per Project Maintenance
		EXEC [SSISDB].[internal].[cleanup_server_project_version];

	END

-- Change to SSISDB Database
USE [SSISDB];
GO

DBCC SHRINKDATABASE (SSISDB, TRUNCATEONLY);  
--DBCC SHRINKDATABASE (SSISDB);  

-- Update retention days
UPDATE [SSISDB].[catalog].[catalog_properties]
   SET property_value = CONVERT(INT, property_value) - 2
 WHERE property_name = 'RETENTION_WINDOW';

-- Get retention days after update
SELECT * 
  FROM [SSISDB].[catalog].[catalog_properties]
 WHERE property_name = 'RETENTION_WINDOW';