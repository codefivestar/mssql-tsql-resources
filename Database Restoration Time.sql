----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Date        : 2021-07-09
-- Description : Shows database restoration time after backup
----------------------------------------------------------------------------------------------------------

	SELECT SERVERPROPERTY('MachineName')            AS DestSrvName
	     , restorehistory.destination_database_name AS DestDBName
		 , restorehistory.restore_date              AS RestoreDate
		 , restorehistory.restore_type              AS RestoreType
		 , backupset.user_name                      AS UserName
		 , backupset.server_name                    AS OrigSvrName
		 , backupset.database_name                  AS OrigDBName
		 , backupset.backup_finish_date             AS BackupFinishDate
		 , DATEDIFF (MI, backupset.backup_finish_date, restorehistory.restore_date) AS [TimeElapsed (Mi)] 
	  FROM [msdb].[dbo].[restorehistory]
INNER JOIN [msdb].[dbo].[BackupSet] 
        ON restorehistory.backup_set_id = backupset.backup_set_id
     WHERE restorehistory.destination_database_name = 'EPOWER2'