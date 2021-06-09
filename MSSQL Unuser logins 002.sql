/**

The query below is a good starting point. It returns a list of logins that have no matching user in any attached database. 
Be aware there are many reasons a login might exist at the server level, but not have an explicitly created user in any user database. 
Before removing the logins shown by this code, you should validate that they are not needed. 
As an example, this code may list the service accounts used to run SQL Server services; removing them might be a bad idea.

It filters out server roles, since they cannot be added to databases as users. 
Similarly for certificate-mapped logins, since they can only be used for code signing.

Link : https://dba.stackexchange.com/questions/244015/logins-without-any-users/244017#244017

**/

DECLARE @cmd nvarchar(max);
SET @cmd = N'';
SELECT @cmd = @cmd + CASE WHEN @cmd = N'' THEN N'' ELSE N'
UNION ALL
' END + N'SELECT dp.sid
FROM ' + QUOTENAME(d.name) + N'.sys.database_principals dp
WHERE dp.sid IS NOT NULL
'
FROM sys.databases d
WHERE d.state_desc = N'ONLINE';

PRINT @cmd;

DROP TABLE IF EXISTS #database_sids;
CREATE TABLE #database_sids
(
    [sid] int NOT NULL
);
INSERT INTO #database_sids ([sid])
EXEC sys.sp_executesql @cmd;

SELECT sp.name
    , sp.type_desc
FROM sys.server_principals sp
WHERE NOT EXISTS (
    SELECT 1
    FROM #database_sids ds
    WHERE ds.sid = sp.sid
    )
    AND sp.[type_desc] NOT IN (
          N'SERVER_ROLE'
        , N'CERTIFICATE_MAPPED_LOGIN'
        )
ORDER BY sp.name;