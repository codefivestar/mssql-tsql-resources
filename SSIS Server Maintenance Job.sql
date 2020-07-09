--Aplica backup
USE [master];
GO

BACKUP DATABASE [SSISDB] TO  DISK = N'F:\Data Base\Backup_BD\SSISDB\SSISDB_backup_2019_03_28_081814_5278979.bak' WITH NOFORMAT
, NOINIT
, NAME = N'SSISDB-Full Database Backup'
, SKIP
, NOREWIND
, NOUNLOAD
,  STATS = 10;
GO

DECLARE @backupSetId AS INT;

SELECT @backupSetId = position 
  FROM [msdb]..[backupset] 
 WHERE [database_name] = N'SSISDB' 
   AND backup_set_id = (
						SELECT MAX(backup_set_id) 
                          FROM [msdb]..[backupset] 
						 WHERE [database_name] = N'SSISDB' 
						);

IF @backupSetId is null 
BEGIN 
	RAISERROR(N'Verify failed. Backup information for database ''SSISDB'' not found.', 16, 1) 
END

RESTORE VERIFYONLY FROM  DISK = N'F:\Data Base\Backup_BD\SSISDB\SSISDB_backup_2019_03_28_081814_5278979.bak' WITH  FILE = @backupSetId
, NOUNLOAD
, NOREWIND;

GO


--Aplica Shrink
USE [SSISDB]
GO
DBCC SHRINKDATABASE(N'SSISDB' )
GO

--Aplica periodo de retención
EXEC [SSISDB].[catalog].[configure_catalog] @property_name=N'RETENTION_WINDOW', @property_value=53
GO


--Aplica mantenimiento a SSISDB
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
		     );

	--SSIS Server Operation Records Maintenance
	IF DB_ID('SSISDB') IS NOT NULL AND ( @role IS NULL OR @role = 1 )
		EXEC [SSISDB].[internal].[cleanup_server_retention_window];

    --SSIS Server Max Version Per Project Maintenance
	IF DB_ID('SSISDB') IS NOT NULL AND ( @role IS NULL OR @role = 1 )
		EXEC [SSISDB].[internal].[cleanup_server_project_version];


--Leer archivo de transacciones
--SELECT * FROM fn_dblog(NULL, NULL) 

--Conteo de registros a borrar
DECLARE @retention_window_length AS INT;
DECLARE @temp_date               AS DATETIME;



	SELECT @retention_window_length = CONVERT(int,property_value)  
      FROM [catalog].[catalog_properties]
     WHERE property_name = 'RETENTION_WINDOW';

	 SET @temp_date = GETDATE() - @retention_window_length;

   SELECT COUNT(1) Qty
     FROM [internal].[operations] 
    WHERE [end_time] <= @temp_date;
