USE [CFSDB]
GO

IF EXISTS (
			SELECT * 
              FROM [sys].[objects] 
             WHERE [type] = 'P'
               AND [name] = 'MSSQLGenerateHealthReport'
			)
BEGIN
	DROP PROCEDURE [dbo].[MSSQLGenerateHealthReport]
END
GO

CREATE PROCEDURE [dbo].[MSSQLGenerateHealthReport]
(
	  @profile_name NVARCHAR(128)
	, @recipients   VARCHAR(MAX)
	, @format       VARCHAR(10) -- grid or mail
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @subject       AS NVARCHAR(255)
      , @header        AS NVARCHAR(MAX)
      , @body_html     AS NVARCHAR(MAX)
      , @body_format   AS VARCHAR(10)
      , @footer        AS NVARCHAR(MAX)
	  , @health_report AS NVARCHAR(MAX);
	
	--SET @profile_name = '';
	--SET @recipients   = 'codefivestar@gmail.com';
	SET @body_format  = 'HTML';
	SET @subject      = 'Health Report for ' + CONVERT(VARCHAR(50), @@SERVERNAME);
	SET @header       = N'<!DOCTYPE html><html><head><style>#report{font-family: Verdana, Geneva, sans-serif;font-size: 12px;border-collapse: collapse;width: 90%}#report td, #report th{border: 1px solid #ddd;padding: 4px}#report th{padding-top: 12px;padding-bottom: 12px;text-align: left;background-color: #5E81AC;color: white}.warning{color: red;font-weight: bold}p{font-family: Verdana, Geneva, sans-serif;font-size: 13px}h3{font-family: Verdana, Geneva, sans-serif}</style></head><body>';
    SET @footer       = N'<br><footer><p>Gesti&oacute;n Base de Datos</p><p>Departamento de Tecnolog&iacute;a</p></footer></body></html>';
	
--------------------------------------------------------------------------------------------------------------
-- ** SERVER INFORMATION **                                                                                 --
--------------------------------------------------------------------------------------------------------------

	IF OBJECT_ID(N'tempdb..#Temp_ServerInformation') IS NOT NULL
		DROP TABLE #Temp_ServerInformation;

	CREATE TABLE #Temp_ServerInformation
	(
	   servername  VARCHAR(50)
	 , [version]   VARCHAR(1000)
	 , edition     VARCHAR(50)
	 , servicepack VARCHAR(50)
	 , collation   VARCHAR(50)
	 , is_clustered_instance           VARCHAR(50)
	 , is_instance_in_single_user_mode VARCHAR(50)
	);

	INSERT INTO #Temp_ServerInformation(servername, [version], edition, servicepack, collation, is_clustered_instance, is_instance_in_single_user_mode)
		 SELECT CONVERT(VARCHAR(50), @@SERVERNAME)
			  , CONVERT(VARCHAR(500), @@VERSION)
			  , CONVERT(VARCHAR(50), SERVERPROPERTY('edition'))
			  , CONVERT(VARCHAR(50), SERVERPROPERTY('productlevel'))  
			  , CONVERT(VARCHAR(50), SERVERPROPERTY('collation')) 
			  , CASE SERVERPROPERTY('IsClustered') 
				   WHEN 1 THEN 'Clustered Instance'
				   WHEN 0 THEN 'Non Clustered Instance'
				   ELSE ''
				 END
			  , CASE SERVERPROPERTY('IsSingleUser')
				   WHEN 1 THEN 'Single User'
				   WHEN 0 THEN 'Multi User'
				   ELSE ''
				 END;

			SET @health_report = N'<h3>MSSQL Server Version</h3>
									<table id="report">
									<tr>
										<th>Host Name</th>
										<th>SQL Server Version</th>
										<th>SQL Server Edition</th>
										<th>Service Pack</th>
										<th>Collation</th>
										<th>Failover Clustered Instance</th>
										<th>Single User Mode</th>
									</tr>';

		 SELECT @health_report = @health_report 
								+ '<tr><td>' + t.servername + '</td>'
								+ '<td>' + t.[version] + '</td>'
								+ '<td>' + t.edition + '</td>'
								+ '<td>' + t.servicepack + '</td>'
								+ '<td>' + t.collation + '</td>'
								+ '<td>' + t.is_clustered_instance + '</td>'
								+ '<td>' + t.is_instance_in_single_user_mode + '</td></tr>'
		   FROM #Temp_ServerInformation AS t;								  

	        SET @health_report = @health_report + '</table>';

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- ** INSTANCE INFORMATION **                                                                               --
--------------------------------------------------------------------------------------------------------------

	IF OBJECT_ID(N'tempdb..#Temp_InstanceInformation') IS NOT NULL
		DROP TABLE #Temp_InstanceInformation;

	CREATE TABLE #Temp_InstanceInformation
	(
	   start_time DATETIME
	 , uptime     INT
	);

	INSERT INTO #Temp_InstanceInformation(start_time, uptime)
		 SELECT sqlserver_start_time
			  , CONVERT(VARCHAR(20), DATEDIFF(DD, sqlserver_start_time, GETDATE())) AS uptime
		   FROM sys.dm_os_sys_info; 

			SET @health_report = @health_report 
								 + N'<h3>MSSQL Server Instance</h3>
									 <table id="report">
									 <tr>
										 <th>Start Time</th>
										 <th>Up Time (Days)</th>
									 </tr>';

		 SELECT @health_report = @health_report 
								 + '<tr><td>' + FORMAT(t.start_time, 'yyyy-MM-dd hh:mm tt') + '</td>'
								 + '<td>' + convert(nvarchar, t.uptime) + '</td></tr>'
		   FROM #Temp_InstanceInformation AS t;								  

			SET @health_report = @health_report + '</table>';

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- ** DISK STATS **                                                                                         --
--------------------------------------------------------------------------------------------------------------


	DECLARE @result  AS INT
		  , @objfso  AS INT
		  , @drv     AS INT 
		  , @cdrive  AS VARCHAR(13) 
		  , @size    AS VARCHAR(50) 
		  , @free    AS VARCHAR(50)
		  , @label   AS varchar(10);


	IF OBJECT_ID(N'tempdb..#DriveSpace_temp') IS NOT NULL
		DROP TABLE #DriveSpace_temp;

	IF OBJECT_ID(N'tempdb..#DriveInfo_temp') IS NOT NULL
		DROP TABLE #DriveInfo_temp;

	CREATE TABLE #DriveSpace_temp (
		  DriveLetter CHAR(1) NOT NULL
		, FreeSpace   VARCHAR(10) NOT NULL
	);

	CREATE TABLE #DriveInfo_temp (
		  DriveLetter CHAR(1)
		, TotalSpace  BIGINT
		, FreeSpace   BIGINT
		, [Label]     VARCHAR(10)
	);

	INSERT INTO #DriveSpace_temp 
		   EXEC [master].[dbo].xp_fixeddrives;

	-- Iterate through drive letters.
	DECLARE curDriveLetters CURSOR FOR SELECT DriveLetter FROM #DriveSpace_temp;
	DECLARE @DriveLetter CHAR(1) OPEN curDriveLetters

	FETCH NEXT FROM curDriveLetters 
	INTO @DriveLetter
	WHILE (@@fetch_status <> -1)
		BEGIN

			IF (@@fetch_status <> -2)
				BEGIN

					SET @cDrive = 'GetDrive("' + @DriveLetter + '")'; 

					EXEC @Result = sp_OACreate 'Scripting.FileSystemObject', @objfso OUTPUT; 

					IF @Result = 0 
						EXEC @Result = sp_OAMethod @objfso, @cdrive, @drv OUTPUT; 

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'TotalSize', @size OUTPUT;

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'FreeSpace', @free OUTPUT;

					IF @Result = 0 
						EXEC @Result = sp_OAGetProperty @drv,'VolumeName', @label OUTPUT;

					IF @Result <> 0 
						EXEC sp_OADestroy @Drv; 
						EXEC sp_OADestroy @objfso; 

						SET @Size = (CONVERT(BIGINT, @Size) / 1048576);
						SET @Free = (CONVERT(BIGINT, @Free) / 1048576);

						INSERT INTO #DriveInfo_temp
							 VALUES (@driveletter, @size, @free, @label);

				END
			FETCH NEXT FROM curDriveLetters 
			INTO @DriveLetter

		END

	CLOSE curDriveLetters
	DEALLOCATE curDriveLetters

	         SET @health_report = @health_report
										+ N'<h3>Disk Stats </h3>  
											<table id="report">  
												<tr>  
												  <th>Drive Letter</th>  
												  <th>Label</th>  
												  <th>Total Space (MB)</th> 
												  <th>Used Space (MB)</th> 
												  <th>Free Space (MB)</th> 
												  <th>Percentage Free (%)</th> 
												</tr>';

		  SELECT @health_report = @health_report 
								+ CASE WHEN (((CONVERT(NUMERIC(9,2), t.FreeSpace) / CONVERT(NUMERIC(9,2), t.TotalSpace)) * 100) < 40) THEN '<tr class="warning">'
									   ELSE '<tr>'
								   END
								+ '<td>' + t.DriveLetter + '</td>'
								+ '<td>' + CASE WHEN (t.DriveLetter = 'C') THEN 'OS'
												ELSE t.[Label]
											END + '</td>'
								+ '<td>' + FORMAT(t.TotalSpace, '###,###,##0.00') + '</td>'
								+ '<td>' + FORMAT((t.TotalSpace - t.FreeSpace), '###,###,##0.00') + '</td>'
								+ '<td>' + FORMAT(t.FreeSpace, '###,###,##0.00') + '</td>'
								+ '<td>' + FORMAT(((CONVERT(NUMERIC(9,2), t.FreeSpace) / CONVERT(NUMERIC(9,2), t.TotalSpace)) * 100), '###,###,##0.00') + '</td>'
								+ '</tr>'
			FROM #DriveInfo_temp AS t
		ORDER BY [DriveLetter] ASC;

	DROP TABLE #DriveSpace_temp;
	DROP TABLE #DriveInfo_temp;

	SET @health_report = @health_report + '</table>';

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- ** DATABASE INFORMATION **                                                                               --
--------------------------------------------------------------------------------------------------------------


	IF OBJECT_ID(N'tempdb..#Temp_DatabaseInformation') IS NOT NULL
		DROP TABLE #Temp_DatabaseInformation;

	CREATE TABLE #Temp_DatabaseInformation
	(
	   database_id           INT
	 , [name]                NVARCHAR(50)
	 , compatibility_level_desc NVARCHAR(50)
	 , recovery_model_desc   NVARCHAR(50)
	 , datafiles             NVARCHAR(50)
	 , datafiles_size        NVARCHAR(50)
	 , logfiles              NVARCHAR(50)
	 , logfiles_size         NVARCHAR(50)
	 , database_size         NVARCHAR(50)
	 );

	 INSERT INTO #Temp_DatabaseInformation (database_id, [name], compatibility_level_desc, recovery_model_desc, datafiles, datafiles_size, logfiles, logfiles_size , database_size)
		  SELECT a.database_id
			   , a.[name]
			   , CASE a.[compatibility_level]
					WHEN 80 THEN 'SQL Server 2000 (80)'
					WHEN 90 THEN 'SQL Server 2005 (90)'
					WHEN 100 THEN 'SQL Server 2008 (100)'
					WHEN 110 THEN 'SQL Server 2012 (110)'
					WHEN 120 THEN 'SQL Server 2014 (120)'
					WHEN 130 THEN 'SQL Server 2016 (130)'
					WHEN 140 THEN 'SQL Server 2017 (140)'
					WHEN 150 THEN 'SQL Server 2019 (150)'
				  END AS compatibility_level_desc
			   , a.recovery_model_desc
			   , c.files AS datafiles
			   , FORMAT(c.size, '###,###,##0.00') as datafiles_size
			   , d.files AS logfiles
			   , FORMAT(d.size, '###,###,##0.00') as logfiles_size
			   , FORMAT((c.size + d.size), '###,###,##0.00') AS database_size
			FROM sys.databases AS a 
	  INNER JOIN (
				   SELECT database_id, type, type_desc, count(1) AS files, sum((size*8)/1024.00) AS size
					 FROM sys.master_files AS DbFiles
					WHERE type = 0
				 GROUP BY database_id, type, type_desc
					) AS c 
			  ON a.database_id = c.database_id
	  INNER JOIN (
				   SELECT database_id, type, type_desc, count(1) AS files, sum((size*8)/1024.00) AS size
					 FROM sys.master_files AS DbFiles
					WHERE type = 1
				 GROUP BY database_id, type, type_desc
					) AS d 
			  ON a.database_id = d.database_id
		GROUP BY a.database_id
			   , a.[name]
			   , a.compatibility_level
			   , a.recovery_model_desc
			   , c.files
			   , c.size
			   , d.files
			   , d.size;

	 SET @health_report = @health_report 
	                    + N'<h3>Database</h3>
							<table id="report">
								<tr>
									<th>Name</th>
									<th>Compatibility Level</th>
									<th>Recovery Model</th>
									<th>Data Files</th>
									<th>Data Files Size (MB)</th>
									<th>Log Files</th>
									<th>Log Files (MB)</th>
									<th>Database Size (MB)</th>
								</tr>';

	 SELECT @health_report = @health_report 
							+ '<tr><td>' + t.[name] + '</td>'
							+ '<td>' + t.compatibility_level_desc + '</td>'
							+ '<td>' + t.recovery_model_desc + '</td>'
							+ '<td>' + t.datafiles + '</td>'
							+ '<td>' + t.datafiles_size + '</td>'
							+ '<td>' + t.logfiles + '</td>'
							+ '<td>' + t.logfiles_size + '</td>'
							+ '<td>' + t.database_size + '</td></tr>'
       FROM #Temp_DatabaseInformation AS t
   ORDER BY t.database_id;

	SET @health_report = @health_report + '</table>';


--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- ** BACKUP INFORMATION **                                                                                 --
--------------------------------------------------------------------------------------------------------------


	IF OBJECT_ID(N'tempdb..#Temp_BackupInformation') IS NOT NULL
		DROP TABLE #Temp_BackupInformation;

	CREATE TABLE #Temp_BackupInformation 
	(     database_id        INT
		, [database_name]    NVARCHAR(50)
		, backup_type        NVARCHAR(50)
		, backup_finish_date NVARCHAR(20)
		, backup_size        NVARCHAR(50)
		, elapsed_time_last_backup NVARCHAR(50)
		, duration           NVARCHAR(50)
		, rownum             INT
	);

	INSERT INTO #Temp_BackupInformation(database_id, [database_name], backup_type, backup_finish_date, backup_size, elapsed_time_last_backup, duration, rownum)
		  SELECT db.database_id AS database_id
		       , db.[name]      AS [database_name]
			   ,  CASE bs.[type]
					WHEN 'D' THEN 'Full backup'
					WHEN 'I' THEN 'Differential backup'
					WHEN 'L' THEN 'Log backup'
					ELSE '-'
				  END AS backup_type
			   , ISNULL(FORMAT(bs.backup_finish_date, N'yyyy-MM-dd hh:mm tt'), 'Never') AS backup_finish_date
			   , ISNULL(FORMAT(CONVERT(NUMERIC(10,2), bs.compressed_backup_size / 1024 / 1024), '###,###,##0.00'), '-') AS backup_size
			   , CASE 
					WHEN (ABS(DATEDIFF(DAY, GETDATE(), bs.backup_finish_date)) = 0) THEN LTRIM(ISNULL(STR(ABS(DATEDIFF(HOUR, GETDATE(), bs.backup_finish_date))) + ' hours ago', '-'))
					ELSE LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(), bs.backup_finish_date))) + ' days ago', '-'))
				  END AS elapsed_time_last_backup
			   , LTRIM(ISNULL(STR(ABS(DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date))) + ' seconds', '-')) AS duration
			   , ROW_NUMBER() OVER (PARTITION BY db.[name] ORDER BY MAX(bs.backup_finish_date) DESC) AS rownum
	        FROM [master].[sys].[databases] AS db
 LEFT OUTER JOIN [msdb].[dbo].[backupset] AS bs
			  ON DB_ID(bs.[database_name]) = db.database_id
			  AND bs.type = 'D'
			 AND bs.server_name = SERVERPROPERTY('ServerName')
		   WHERE db.[name] <> 'tempdb'
		GROUP BY db.database_id
		       , db.[name]
			   ,  bs.[type]
			   , bs.compressed_backup_size
			   , bs.backup_start_date, bs.backup_finish_date
		  --HAVING MAX(bs.backup_finish_date) <= DATEADD(dd, -7, GETDATE()) 
		  --    OR MAX(bs.backup_finish_date) IS NULL

			 SET @health_report = @health_report 
								+ N'<h3>Database Backup</h3>
									<table id="report">
									<tr>
										<th>Name</th>
										<th>Last Full Backup</th>
										<th>Elapsed Time Last Backup</th>
										<th>Duration</th>
										<th>Backup Size (MB)</th>
									</tr>';

			SELECT @health_report = @health_report
			                      + '<tr><td>' + t.[database_name] + '</td>'
								  + '<td>' + t.backup_finish_date + '</td>'
								  + '<td>' + t.elapsed_time_last_backup + '</td>'
								  + '<td>' + t.duration + '</td>'
	                              + '<td>' + t.backup_size + '</td></tr>'
		      FROM #Temp_BackupInformation AS t
			 WHERE t.rownum = 1
		  ORDER BY t.database_id;

		  SET @health_report = @health_report + '</table>' + '<br><p>**Exclude tempdb </p>';


--------------------------------------------------------------------------------------------------------------

SET @body_html = @header + @health_report + @footer;

IF(@format = 'grid')
	BEGIN
	    SELECT @body_html AS Report;
	END
ELSE IF (@format = 'mail')
	BEGIN

		EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name = @profile_name
										 , @recipients   = @recipients
										 , @body         = @body_html
										 , @body_format  = @body_format
										 , @subject      = @subject;

	END
ELSE
	BEGIN
			SELECT 'not specified' AS Report;
	END





END
GO

EXEC [dbo].[MSSQLGenerateHealthReport] @profile_name = N'CFS'
                                     , @recipients   = N'codefivestar@gmail.com'
									 , @format       = N'grid'
GO