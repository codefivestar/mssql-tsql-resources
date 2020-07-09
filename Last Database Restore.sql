----------------------------------------------------------------------------------------------------------
--File Name   : MSSQL – Last Database Restore.sql
--Create Date : 2018-08-21 08:24 A.M. 
--Author      : Hidequel Puga
--Mail        : bounty31k@outlook.com
--Reference   : https://social.msdn.microsoft.com/Forums/es-ES/71ec3240-e2c0-4f5f-953f-4be22a659609/existe-algun-query-para-encontrar-la-fecha-de-la-ultima-restauracion-de-una-base-de-datos?forum=sqlserveres
--Description : Last Database Restore
----------------------------------------------------------------------------------------------------------

SELECT bs.database_name AS TargetDatabase
	, bs.backup_start_date AS Operation_Date
	, cast(datediff(minute, bs.backup_start_date, bs.backup_finish_date) / 60 AS VARCHAR) + ' hours ' + cast(datediff(minute, bs.backup_start_date, bs.backup_finish_date) % 60 AS VARCHAR) + ' minutes ' + cast(datediff(second, bs.backup_start_date, bs.backup_finish_date) % 60 AS VARCHAR) + ' seconds' AS [Duration]
	, cast(bs.backup_size / 1024 / 1024 AS DECIMAL(22, 2)) AS [BackupSize(MB)]
	, 'BACKUP' AS Operation_Type
	, CASE bs.type
		WHEN 'D'
			THEN 'Database'
		WHEN 'L'
			THEN 'Log'
		WHEN 'I'
			THEN 'Differential'
		END AS BackupType
	, bs.user_name AS [User]
	, bmf.physical_device_name AS BackupFile
	, bs.server_name AS ServerOrigin
	, bs.recovery_model
	, bs.begins_log_chain
	, bs.is_copy_only
	, bms.software_name AS BackupSoftware
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediaset bms
	ON bs.media_set_id = bms.media_set_id
INNER JOIN msdb.dbo.backupmediafamily bmf
	ON bms.media_set_id = bmf.media_set_id
WHERE bs.database_name = db_name()
	AND bs.server_name = serverproperty('servername')

UNION ALL

SELECT rh.destination_database_name
	, rh.restore_date AS operation_date
	, 'Unknown' AS [Duration]
	, cast(bs.backup_size / 1024 / 1024 AS DECIMAL(22, 2)) AS [BackupSize(MB)]
	, 'RESTORE' AS Operation_Type
	, CASE rh.restore_type
		WHEN 'D'
			THEN 'Database'
		WHEN 'L'
			THEN 'Log'
		WHEN 'I'
			THEN 'Differential'
		END AS BackupType
	, rh.user_name AS [User]
	, bmf.physical_device_name AS BackupFile
	, bs.server_name AS ServerOrigin
	, bs.recovery_model
	, bs.begins_log_chain
	, bs.is_copy_only
	, bms.software_name AS BackupSoftware
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediaset bms
	ON bs.media_set_id = bms.media_set_id
INNER JOIN msdb.dbo.backupmediafamily bmf
	ON bms.media_set_id = bmf.media_set_id
INNER JOIN msdb.dbo.restorehistory rh
	ON bs.backup_set_id = rh.backup_set_id
WHERE rh.destination_database_name = db_name()
ORDER BY 2 DESC