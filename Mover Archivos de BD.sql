USE [master]
GO

-- 1. Establecer nueva ubicación

ALTER DATABASE ALI_WRKBGDBA
    MODIFY FILE ( NAME = ALI_WRKBGDBA,   
                  FILENAME = 'F:\MSSQL\Data\ALI_WRKBGDBA.mdf');  --E:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\Data\ALI_WRKBGDBA_log.ldf
				                                                                               --C:\MSSQL\Data
GO

--ALTER DATABASE ALI_WRKBGDBA
--    MODIFY FILE ( NAME = ALI_WRKBGDBA_log,   
--                  FILENAME = 'F:\MSSQL\Data\ALI_WRKBGDBA_log.ldf');  --E:\MSSQL\MSSQL13.MSSQLSERVER\MSSQL\Data\ALI_WRKBGDBA_log.ldf
--				                                                                               --C:\MSSQL\Data
--GO
---------------------------------------------------------------------------------------------------

-- 2. Cerrar todas las conexiones
--    Utilizar el monitor de actividades

---------------------------------------------------------------------------------------------------

-- 3. Cambiar a Offline el estado de la base de datos

ALTER DATABASE ALI_WRKBGDBA SET OFFLINE;  
GO
---------------------------------------------------------------------------------------------------

-- 4. Mover físicamente los archivos
--    

---------------------------------------------------------------------------------------------------

-- 5. Regresar a Online el estado de la base de datos

ALTER DATABASE ALI_WRKBGDBA SET ONLINE;  
GO
---------------------------------------------------------------------------------------------------

-- 6. Verificar la ruta de los archivos 
SELECT name, physical_name AS NewLocation, state_desc AS OnlineStatus
  FROM sys.master_files  
 WHERE database_id = DB_ID(N'ALI_WRKBGDBA')  
GO


/*
	Ref : 
	Mover archivos   --> https://www.sqlshack.com/es/como-poder-mover-archivos-de-base-de-datos-sql-mdf-y-ldf-a-otra-ubicacion/
	Recuperar estado --> https://www.stellarinfo.com/blog/fix-sql-database-recovery-pending-state-issue/
 */