-- https://dataedo.com/kb/query/sql-server/list-users-in-database

select name as username,
       create_date,
       modify_date,
       type_desc as type,
       authentication_type_desc as authentication_type
from sys.database_principals
where type not in ('A', 'G', 'R', 'X')
      and sid is not null
      and name != 'guest'
order by username;

--

DECLARE @TSQL          AS VARCHAR(1000);
DECLARE @TSQLoop       AS VARCHAR(1000);
DECLARE @TargetDbs     AS TABLE (DbName VARCHAR(128));
DECLARE @DbName        AS VARCHAR(128);
DECLARE @Temp_ListUser AS TABLE (  ServerName         NVARCHAR(50)
                                 , DatabaseName       NVARCHAR(128)
                                 , UserName           SYSNAME
                                 , CreateDate         DATETIME
                                 , ModifyDate         DATETIME
                                 , TypeDesc           NVARCHAR(60)
                                 , AuthenticationType NVARCHAR(60)
                                 );

	SET @TSQL = 'SELECT CONVERT(NVARCHAR(50), SERVERPROPERTY(''ServerName'')) AS ServerName
	                  , DB_NAME() AS DatabaseName
	                  , [name] AS UserName
			      , create_date AS CreateDate
				, modify_date AS ModifyDate
				, type_desc AS TypeDesc
				, authentication_type_desc AS AuthenticationType
			   FROM sys.database_principals
			  WHERE type NOT IN (''A'', ''G'', ''R'', ''X'')
			    AND sid IS NOT NULL
			    AND name != ''guest''
		     ORDER BY username';

	INSERT INTO @TargetDbs 
	     SELECT [name] 
	       FROM sys.databases;

	WHILE EXISTS (SELECT * FROM @TargetDbs)
		BEGIN

			SET @DbName  = (SELECT TOP 1 DbName FROM @TargetDbs);
			SET @TSQLoop = ('USE ' + @DBName + '; ') + @TSQL;

			--PRINT @TSQLoop;

			INSERT INTO @Temp_ListUser (ServerName, DatabaseName, UserName, CreateDate, ModifyDate, TypeDesc, AuthenticationType)
			       EXEC (@TSQLoop);

			DELETE FROM @TargetDBs 
			      WHERE DBName = @DBName;

		END

	SELECT * 
	  FROM @Temp_ListUser;