----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Date        : 2023-06-26
-- Description : Determine duration between two dates
----------------------------------------------------------------------------------------------------------

USE [master]
GO

  SELECT database_name      AS BaseDatos
       , backup_start_date  AS InicioBackup
	   , backup_finish_date AS FinBackup
       , (DATEDIFF(SECOND, backup_start_date, backup_finish_date) / 3600)        AS Horas
       , ((DATEDIFF(SECOND, backup_start_date, backup_finish_date) % 3600) / 60) AS Minutos
       , ((DATEDIFF(SECOND, backup_start_date, backup_finish_date) % 3600) % 60) AS Segundos
    FROM msdb.dbo.backupset 
   WHERE type          = 'D'
     AND database_name = 'nombre_base_datos'
ORDER BY backup_finish_date DESC

