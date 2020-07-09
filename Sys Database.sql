USE [master];
GO

SELECT @@SERVERNAME AS NombreServidor
     , [name]         AS NombreBaseDatos
  FROM master.dbo.sysdatabases


SELECT @@SERVERNAME AS NombreServidor
     , [name]       AS NombreBaseDatos
     , state_desc   AS Estado
  FROM sys.databases;  