USE [master]
GO

ALTER DATABASE SSISDB SET OFFLINE WITH
ROLLBACK IMMEDIATE
GO

--
ALTER DATABASE SSISDB MODIFY FILE ( NAME = data, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\SSISDB.mdf' );  
ALTER DATABASE SSISDB MODIFY FILE ( NAME = log, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\SSISDB.ldf' );  
--
--ALTER DATABASE SSISDB MODIFY FILE ( NAME = data, FILENAME = N'E:\Data Base\SQLSERVER\Data\SSISDB.mdf' );  
--ALTER DATABASE SSISDB MODIFY FILE ( NAME = log, FILENAME = N'F:\Data Base\SQLSERVER\Log\SSISDB.ldf' );  
--

USE [master]
GO

ALTER DATABASE SSISDB
SET ONLINE
GO

--

SELECT name, physical_name AS CurrentLocation, state_desc  
FROM sys.master_files  
WHERE database_id = DB_ID(N'SSISDB');  


--DOMAIN\servicesql

--Batch to move files
--move files\*.txt \ 