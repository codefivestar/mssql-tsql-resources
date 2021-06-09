DECLARE @TSQL              AS VARCHAR(1000);
DECLARE @TSQLoop           AS VARCHAR(1000);
DECLARE @TargetDbs         AS TABLE (DbName VARCHAR(128));
DECLARE @DbName            AS VARCHAR(128);
DECLARE @Temp_OrphanedUser AS TABLE (  ServerName   NVARCHAR(50)
                                     , DatabaseName NVARCHAR(128)
									 , TypeDesc     NVARCHAR(60)
									 , [SID]        VARBINARY(85)
									 , UserName     SYSNAME
									 );

	SET @TSQL = 'SELECT CONVERT(NVARCHAR(50), SERVERPROPERTY(''ServerName'')) AS ServerName
	                  , DB_NAME()    AS DatabaseName
					  , dp.type_desc AS TypeDesc
					  , dp.SID       AS [SID]
					  , dp.name      AS UserName  
				   FROM sys.database_principals AS dp  
			  LEFT JOIN sys.server_principals AS sp  
					 ON dp.SID = sp.SID  
				  WHERE sp.SID IS NULL  
					AND dp.authentication_type_desc = ''INSTANCE''';

	INSERT INTO @TargetDbs 
	     SELECT [name] 
	       FROM sys.databases;

	WHILE EXISTS (SELECT * FROM @TargetDbs)
		BEGIN

			SET @DbName  = (SELECT TOP 1 DbName FROM @TargetDbs);
			SET @TSQLoop = ('USE ' + @DBName + '; ') + @TSQL;

			--PRINT @TSQLoop;

			INSERT INTO @Temp_OrphanedUser (ServerName, DatabaseName, TypeDesc, SID, UserName)
			       EXEC (@TSQLoop);

			DELETE FROM @TargetDBs 
			      WHERE DBName = @DBName;

		END

	SELECT * 
	  FROM @Temp_OrphanedUser;