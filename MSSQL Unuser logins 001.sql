/**

However, following query help you to get logins that are not mapped to any user in the database and not assigned to server role, 
you may comment (--) the last predicate (and (r.name = 'public' or r.name is null )) in the where clause to list all logins with their role names that are not mapped with any database user,
and pick FixCommand column value (T-SQL) for selected logins from result.

Link : https://dba.stackexchange.com/questions/250844/how-to-find-unused-logins-in-sql-server#
**/

DECLARE @TSQL      VARCHAR(1000);
DECLARE @TSQLoop   VARCHAR(1000);
DECLARE @DBName    VARCHAR(128);
DECLARE @TargetDBs TABLE (DBName VARCHAR(128));
DECLARE @Temp      TABLE ([sid] VARBINARY(85), [name] NVARCHAR (100));

	SET @TSQL = 'SELECT sid
					  , name
				   FROM sys.database_principals AS dp
				  WHERE type IN (''S'', ''U'', ''G'') 
					AND sid IS NOT NULL 
					AND (dp.name NOT IN (''dbo'', ''guest'') 
					AND dp.name NOT LIKE ''##%'')';

	INSERT INTO @TargetDBs 
	SELECT [name] 
	  FROM sys.databases;

	WHILE EXISTS (SELECT * FROM @TargetDBs)
		BEGIN

			SET @DBName  = (SELECT TOP 1 DBName FROM @TargetDBs);
			SET @TSQLoop = ('USE ' + @DBName + '; ') + @TSQL;

			INSERT INTO @Temp ([sid], [name])
			       EXEC (@TSQLoop);

			DELETE FROM @TargetDBs 
			      WHERE DBName = @DBName;

		END

	SELECT sp.name      AS LoginName
		 , r.name       AS RoleName
		 , sp.sid       AS [SID]
		 , sp.type_desc AS TypeDesc
		 , 'DROP LOGIN [' + sp.name + ']' AS FixCommand
	  FROM sys.server_principals AS sp
 LEFT JOIN @Temp AS dp
		ON sp.sid = dp.sid
 LEFT JOIN sys.server_role_members rm
		ON sp.principal_id = rm.member_principal_id
 LEFT JOIN sys.server_principals r
		ON rm.role_principal_id = r.principal_id
	 WHERE sp.type IN ('S', 'U', 'G')
	   AND (
			NOT sp.name = 'sa'
			AND sp.name NOT LIKE '##%'
			AND sp.name NOT LIKE 'NT %'
			)
	   AND dp.name IS NULL
	   AND (
			r.name = 'public'
			OR r.name IS NULL
			)
GO