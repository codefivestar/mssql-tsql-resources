--  SELECT sys.databases.database_id
--       --, sys.databases.name AS DBName
--       , CONVERT(VARCHAR,SUM(size) * 8 / 1024) + ' MB' AS TotalDiskSpace
--    FROM sys.databases   
--    JOIN sys.master_files  
--      ON sys.databases.database_id = sys.master_files.database_id  
--GROUP BY sys.databases.database_id;

--exec sp_spaceused  

--

USE [master]
GO

SELECT @@SERVERNAME           AS [Server Name]
     , T1.[name]              AS [DB Name]
	 , ''                     AS [Db Apps]
     , T1.state_desc          AS [State]
	 , T1.recovery_model_desc AS [Recovery Model]
	 , T1.compatibility_level AS [Compatibility Level]
	 , T1.collation_name      AS [Collation Name]
	 , T2.[Total Disk Space]
  FROM sys.databases AS T1
  JOIN (
		SELECT sys.databases.database_id
		   --, sys.databases.name AS DBName
		     , CONVERT(VARCHAR,SUM(size) * 8 / 1024) + ' MB' AS [Total Disk Space]
		  FROM sys.databases   
		  JOIN sys.master_files  
		    ON sys.databases.database_id = sys.master_files.database_id  
	  GROUP BY sys.databases.database_id
        ) AS T2
	ON T1.database_id = T2.database_id
	;  