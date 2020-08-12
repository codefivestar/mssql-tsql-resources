USE [master];
GO

SELECT @@SERVERNAME AS NombreServidor
     , [name]         AS NombreBaseDatos
  FROM master.dbo.sysdatabases


SELECT @@SERVERNAME        AS ServerName
     , [name]              AS DBName
     , state_desc          AS [State]
	 , recovery_model_desc AS RecoveryModel
	 , compatibility_level AS CompatibilityLevel
	 , collation_name      AS [CollationName]
  FROM sys.databases;   