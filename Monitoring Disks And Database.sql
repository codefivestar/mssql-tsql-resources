/*Monitoreo de discos en [server-name]*/
IF object_id('tempdb..#drives') IS NOT NULL
	DROP TABLE #drives;

IF object_id('tempdb..#sizeDataBase') IS NOT NULL
	DROP TABLE #sizeDataBase;

SET NOCOUNT ON

DECLARE @hr        INT;
DECLARE @fso       INT;
DECLARE @FreeSpace INT;
DECLARE @drive     CHAR(1);
DECLARE @odrive    INT;
DECLARE @UsedSpace INT;
DECLARE @TotalSize VARCHAR(20);
DECLARE @Disk_1    VARCHAR(20);
DECLARE @MB        NUMERIC;

	SELECT CONVERT(VARCHAR(25), DB.NAME) AS dbName
		 , (
			SELECT COUNT(1)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid != 0
			) AS DataFiles
		 , (
			SELECT SUM((size * 8) / 1024)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid != 0
			) AS DataMB
		 , (
			SELECT COUNT(1)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid = 0
			) AS LogFiles
		 , (
			SELECT SUM((size * 8) / 1024)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid = 0
			) AS LogMB
		 , (
			SELECT SUM((size * 8) / 1024)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid != 0
			 ) 
		   + 
		   (
			SELECT SUM((size * 8) / 1024)
			  FROM sysaltfiles
			 WHERE DB_NAME(dbid) = DB.NAME
			   AND groupid = 0
			) AS TotalSizeMB
		  , CONVERT(SYSNAME, DatabasePropertyEx(NAME, 'Recovery')) AS RecoveryModel
		  , ISNULL((
				    SELECT TOP 1 CASE [TYPE]
						              WHEN 'D' THEN 'Full'
									  WHEN 'I' THEN 'Differential'
						              WHEN 'L' THEN 'Transaction log'
						         END 
						  + ' – ' + LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(), Backup_finish_date))) + ' days ago', 'NEVER')) 
						  + ' – ' + CONVERT(VARCHAR(20), backup_start_date, 103) 
						  + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) 
						  + ' – ' + CONVERT(VARCHAR(20), backup_finish_date, 103) 
						  + '' + CONVERT(VARCHAR(20), backup_finish_date, 108) 
						  + ' (' + CAST(DATEDIFF(second, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) 
						  + ' ' + 'seconds)'
				     FROM msdb.dbo.backupset BK
				    WHERE BK.database_name = DB.NAME
				 ORDER BY backup_set_id DESC
				    ), '') AS Lastbackup
	INTO #sizeDataBase
	FROM sysdatabases DB
ORDER BY 6 DESC;

SET @MB = 1048576;

CREATE TABLE #drives 
(
	drive CHAR(1) PRIMARY KEY
  , FreeSpace INT NULL
  , TotalSize INT NULL
  , UsedSpace INT NULL
  , Percent_Disk INT NULL
);

INSERT #drives (drive, FreeSpace)
  EXEC master.dbo.xp_fixeddrives;

EXEC @hr = sp_OACreate 'Scripting.FileSystemObject', @fso OUTPUT;

IF @hr <> 0
	EXEC sp_OAGetErrorInfo @fso;

DECLARE dcur CURSOR LOCAL FAST_FORWARD
FOR SELECT drive
      FROM #drives
  ORDER BY drive

OPEN dcur

FETCH NEXT
FROM dcur
INTO @drive

WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC @hr = sp_OAMethod @fso
							 , 'GetDrive'
							 , @odrive OUTPUT
							 , @drive;

		IF @hr <> 0
			EXEC sp_OAGetErrorInfo @fso

		EXEC @hr = sp_OAGetProperty @odrive
			, 'TotalSize'
			, @TotalSize OUTPUT

		IF @hr <> 0
			EXEC sp_OAGetErrorInfo @odrive

		UPDATE #drives
		   SET TotalSize = (@TotalSize / @MB) / 1024
		 WHERE drive = @drive;

		FETCH NEXT
		FROM dcur
		INTO @drive
	END

CLOSE dcur

DEALLOCATE dcur

EXEC @hr = sp_OADestroy @fso

IF @hr <> 0
	EXEC sp_OAGetErrorInfo @fso

	SELECT drive
		 , TotalSize AS 'Total(GB)'
		 , (TotalSize - (FreeSpace / 1024)) AS 'UsedSpace (BG)'
		 , (FreeSpace / 1024) AS 'Free(GB)'
		 , convert(CHAR(8), ((FreeSpace / TotalSize) * 100) / 1000, 108) + '%' AS 'Percent_Disk'
	  FROM #drives
  ORDER BY drive;

UPDATE #drives
   SET Percent_Disk = ((TotalSize - (FreeSpace / 1024)) * 100) / TotalSize
	 , UsedSpace    = (TotalSize - (FreeSpace / 1024));
GO

DECLARE @Size       INT;
DECLARE @tableHTML  NVARCHAR(MAX);
DECLARE @getdate AS NVARCHAR(MAX);

	SET @Size = 0;

	SELECT @Size = MIN(((FreeSpace / TotalSize) * 100) / 1000)
      FROM #drives;

DECLARE @tableHTML_2 NVARCHAR(MAX);
DECLARE @body NVARCHAR(MAX)

	IF (@Size >= 0 AND @Size < 25)
		BEGIN
			/*valida estatus EN LAS BASE DE DATOS*/
			SET @tableHTML_2 = N'<H4>Estatus de los Discos en [server-name]</H4>' 
			                 + N'<table border="1">' 
							 + N'<th bgcolor="#34823C"><font size="2"><font size="2">dbName</font></th><th bgcolor="#34823C"><font size="2">DataFiles</font></th>' 
							 + N'<th bgcolor="#34823C"><font size="2">Data MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">LogFiles</font></th>' 
							 + N'<th bgcolor="#34823C"><font size="2">Log MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">TotalSizeMB</font></th>' 
							 + N'<th bgcolor="#34823C"><font size="2"><font size="2">RecoveryModel</font></th>' 
							 + N'<th bgcolor="#34823C"><font size="2"><font size="2">Last backup</font></th>' 
							 + CAST((SELECT td = dbName
							              , ''
							              , td = DataFiles
							              , ''
							              , td = DataMB
							              , ''
							              , td = LogFiles
							              , ''
							              , td = LogMB
							              , ''
							              , td = TotalSizeMB
							              , ''
							              , td = RecoveryModel
							              , ''
							              , td = Lastbackup
							              , ''
						               FROM #sizeDataBAse
						                FOR XML PATH('tr')
							            , TYPE
						            ) AS NVARCHAR(MAX)) 
							 + N'</table>';
							 
			SET @body = '<html><body><H3>Base de Datos</H3>
		                 <tr>
		                 </tr>';
						 
			SET @tableHTML = N'<H4>Estatus de los Discos en [server-name]</H4>' 
			               + N'<table border="1">' 
						   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">DRIVE</font></th><th bgcolor="#79CA31"><font size="2">TOTAL</font></th>' 
						   + N'<th bgcolor="#79CA31"><font size="2">USED SPACE</font></th></font></th><th bgcolor="#79CA31"><font size="2"><font size="2">FREE SPACE</font></th>' 
						   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">PERCENT_FREE</font></th>' 
						   + CAST((
						           SELECT td = drive
							            , ''
							            , td = convert(CHAR(8), TotalSize, 108) + 'GB'
							            , ''
							            , td = convert(CHAR(8), (TotalSize - (FreeSpace / 1024))) + 'GB'
							            , ''
							            , td = convert(CHAR(8), (FreeSpace / 1024)) + 'GB'
							            , ''
							            , td = convert(CHAR(8), ((FreeSpace / TotalSize) * 100) / 1000, 108) + '%'
							            , ''
						             FROM #drives
						         ORDER BY drive
						              FOR XML PATH('tr')
							            , TYPE
						            ) AS NVARCHAR(MAX)) + N'</table>';
									
			SET @tableHTML = @tableHTML + @body + @tableHTML_2;
			
			/* Ejecuta envío de correo*/
			SET @getdate = 'ALERTA!!! Estatus de los Discos en [server-name] - Hay discos que cuenta con ' + cast(@Size AS CHAR(3)) + '% de disponibilidad al ' + convert(CHAR(10), getdate(), 101)

			EXEC msdb.dbo.sp_send_dbmail @profile_name = '[server-name]'
									   , @from_address = ''
									   , @importance   = 'High'
									   , @recipients   = ''
									   , @subject      = @getdate
									   , @body_format  = 'HTML'
									   , @body         = @tableHTML;
		END
ELSE IF (@Size >= 26 AND @Size < 50)
	BEGIN
		/*valida estatus EN LAS BASE DE DATOS*/
		SET @tableHTML_2 = N'<H4>Estatus de los Discos en [server-name]</H4>' 
		                 + N'<table border="1">' 
						 + N'<th bgcolor="#34823C"><font size="2"><font size="2">dbName</font></th><th bgcolor="#34823C"><font size="2">DataFiles</font></th>' 
						 + N'<th bgcolor="#34823C"><font size="2">Data MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">LogFiles</font></th>' 
						 + N'<th bgcolor="#34823C"><font size="2">Log MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">TotalSizeMB</font></th>' 
						 + N'<th bgcolor="#34823C"><font size="2"><font size="2">RecoveryModel</font></th>' 
						 + N'<th bgcolor="#34823C"><font size="2"><font size="2">Last backup</font></th>' 
						 + CAST((
								 SELECT td = dbName
									  , ''
									  , td = DataFiles
									  , ''
									  , td = DataMB
									  , ''
									  , td = LogFiles
									  , ''
									  , td = LogMB
									  , ''
									  , td = TotalSizeMB
									  , ''
									  , td = RecoveryModel
									  , ''
									  , td = Lastbackup
									  , ''
								   FROM #sizeDataBAse
									FOR XML PATH('tr')
									  , TYPE
								) AS NVARCHAR(MAX)) 
					     + N'</table>';
		SET @body = '<html><body><H3>Base de Datos</H3>
					<tr>
					</tr>';
					
		SET @tableHTML = N'<H4>Estatus de los Discos en [server-name]</H4>' 
		               + N'<table border="1">' 
					   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">DRIVE</font></th><th bgcolor="#79CA31"><font size="2">TOTAL</font></th>' 
					   + N'<th bgcolor="#79CA31"><font size="2">USED SPACE</font></th></font></th><th bgcolor="#79CA31"><font size="2"><font size="2">FREE SPACE</font></th>' 
					   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">PERCENT_FREE</font></th>' 
					   + CAST((
								SELECT td = drive
									 , ''
									 , td = convert(CHAR(8), TotalSize, 108) + 'GB'
									 , ''
									 , td = convert(CHAR(8), (TotalSize - (FreeSpace / 1024))) + 'GB'
									 , ''
									 , td = convert(CHAR(8), (FreeSpace / 1024)) + 'GB'
									 , ''
									 , td = convert(CHAR(8), ((FreeSpace / TotalSize) * 100) / 1000, 108) + '%'
									 , ''
								  FROM #drives
							  ORDER BY drive
								   FOR XML PATH('tr')
									 , TYPE
							   ) AS NVARCHAR(MAX)) + N'</table>';
							   
		SET @tableHTML = @tableHTML + @body + @tableHTML_2;
		
		/* Ejecuta envío de correo*/
		SET @getdate = 'Estatus de los Discos en [server-name] - Hay discos que cuenta con ' + cast(@Size AS CHAR(3)) + '% de disponibilidad al ' + convert(CHAR(10), getdate(), 101);

		EXEC msdb.dbo.sp_send_dbmail @profile_name = '[server-name]'
			                       , @from_address = ''
			                       , @recipients   = ''
			                       , @subject      = @getdate
			                       , @body_format  = 'HTML'
			                       , @body         = @tableHTML;
	END
ELSE IF (@Size >= 51 AND @Size < 75)
BEGIN
	/*valida estatus EN LAS BASE DE DATOS*/
	SET @tableHTML_2 = N'<H4>Estatus de los Discos en [server-name]</H4>' 
	                 + N'<table border="1">' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">dbName</font></th><th bgcolor="#34823C"><font size="2">DataFiles</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2">Data MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">LogFiles</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2">Log MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">TotalSizeMB</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">RecoveryModel</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">Last backup</font></th>' 
					 + CAST((
							 SELECT td = dbName
								  , ''
								  , td = DataFiles
								  , ''
								  , td = DataMB
								  , ''
								  , td = LogFiles
								  , ''
								  , td = LogMB
								  , ''
								  , td = TotalSizeMB
								  , ''
								  , td = RecoveryModel
								  , ''
								  , td = Lastbackup
								  , ''
							   FROM #sizeDataBAse
							    FOR XML PATH('tr')
								  , TYPE
							) AS NVARCHAR(MAX)) + N'</table>';
							
	SET @body = '<html><body><H3>Base de Datos</H3>
                 <tr>
                </tr>';
				
	SET @tableHTML = N'<H4>Estatus de los Discos en [server-name]</H4>' 
	               + N'<table border="1">' 
				   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">DRIVE</font></th><th bgcolor="#79CA31"><font size="2">TOTAL</font></th>' 
				   + N'<th bgcolor="#79CA31"><font size="2">USED SPACE</font></th></font></th><th bgcolor="#79CA31"><font size="2"><font size="2">FREE SPACE</font></th>' 
				   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">PERCENT_FREE</font></th>' 
				   + CAST((
				           SELECT td = drive
					            , ''
					            , td = convert(CHAR(8), TotalSize, 108) + 'GB'
					            , ''
					            , td = convert(CHAR(8), (TotalSize - (FreeSpace / 1024))) + 'GB'
					            , ''
					            , td = convert(CHAR(8), (FreeSpace / 1024)) + 'GB'
					            , ''
					            , td = convert(CHAR(8), ((FreeSpace / TotalSize) * 100) / 1000, 108) + '%'
					            , ''
				             FROM #drives
				         ORDER BY drive
				              FOR XML PATH('tr')
					            , TYPE
				          ) AS NVARCHAR(MAX)) + N'</table>';
						  
	SET @tableHTML = @tableHTML + @body + @tableHTML_2;
	
	/* Ejecuta envío de correo*/
	SET @getdate = 'Estatus de los Discos en [server-name] - Hay discos que cuenta con ' + cast(@Size AS CHAR(3)) + '% de disponibilidad al ' + convert(CHAR(10), getdate(), 101)

	EXEC msdb.dbo.sp_send_dbmail @profile_name = '[server-name]'
		                       , @from_address = ''
		                       , @recipients   = ''
		                       , @subject      = @getdate
		                       , @body_format  = 'HTML'
		                       , @body         = @tableHTML;
END
ELSE
BEGIN
	/*valida estatus EN LAS BASE DE DATOS*/
	SET @tableHTML_2 = N'<H4>Estatus de los Discos en [server-name]</H4>' 
	                 + N'<table border="1">' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">dbName</font></th><th bgcolor="#34823C"><font size="2">DataFiles</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2">Data MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">LogFiles</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2">Log MB</font></th></font></th><th bgcolor="#34823C"><font size="2"><font size="2">TotalSizeMB</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">RecoveryModel</font></th>' 
					 + N'<th bgcolor="#34823C"><font size="2"><font size="2">Last backup</font></th>' 
					 + CAST((
							SELECT td = dbName
								, ''
								, td = DataFiles
								, ''
								, td = DataMB
								, ''
								, td = LogFiles
								, ''
								, td = LogMB
								, ''
								, td = TotalSizeMB
								, ''
								, td = RecoveryModel
								, ''
								, td = Lastbackup
								, ''
							FROM #sizeDataBAse
							FOR XML PATH('tr')
								, TYPE
							) AS NVARCHAR(MAX)) + N'</table>';
	
	SET @body = '<html><body><H3>Base de Datos</H3>
                 <tr>
                 </tr>';
				 
	SET @tableHTML = N'<H4>Estatus de los Discos en [server-name]</H4>' 
				   + N'<table border="1">' 
				   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">DRIVE</font></th><th bgcolor="#79CA31"><font size="2">TOTAL</font></th>' 
				   + N'<th bgcolor="#79CA31"><font size="2">USED SPACE</font></th></font></th><th bgcolor="#79CA31"><font size="2"><font size="2">FREE SPACE</font></th>' 
				   + N'<th bgcolor="#79CA31"><font size="2"><font size="2">PERCENT_FREE</font></th>' 
				   + CAST((
							SELECT td = drive
								, ''
								, td = convert(CHAR(8), TotalSize, 108) + 'GB'
								, ''
								, td = convert(CHAR(8), (TotalSize - (FreeSpace / 1024))) + 'GB'
								, ''
								, td = convert(CHAR(8), (FreeSpace / 1024)) + 'GB'
								, ''
								, td = convert(CHAR(8), ((FreeSpace / TotalSize) * 100) / 1000, 108) + '%'
								, ''
							FROM #drives
						ORDER BY drive
							 FOR XML PATH('tr')
								, TYPE
							) AS NVARCHAR(MAX)) + N'</table>';
	
	SET @tableHTML = @tableHTML + @body + @tableHTML_2;
	
	/* Ejecuta envío de correo*/
	SET @getdate = 'Estatus de los Discos en [server-name] - Hay discos que cuenta con ' + cast(@Size AS CHAR(3)) + '% de disponibilidad al ' + convert(CHAR(10), getdate(), 101);

	EXEC msdb.dbo.sp_send_dbmail @profile_name = '[server-name]'
							   , @from_address = ''
							   , @recipients   = ''
							   , @subject      = @getdate
							   , @body_format  = 'HTML'
							   , @body         = @tableHTML;
							   
END