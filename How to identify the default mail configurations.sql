----------------------------------------------------------------------------------------------------------
--Autor          : Hidequel Puga
--Fecha          : 2018-05-22 02:03 p.m.
--Requerimiento  : Solicitud # 599
--Descripci�n    : How to identify the default mail configurations
----------------------------------------------------------------------------------------------------------

USE [msdb]
GO

    SELECT *
      FROM msdb.dbo.sysmail_profile p
INNER JOIN msdb.dbo.sysmail_principalprofile pp
	      ON pp.profile_id = p.profile_id
INNER JOIN msdb.dbo.sysmail_profileaccount pa
	      ON p.profile_id = pa.profile_id
INNER JOIN msdb.dbo.sysmail_account a
	      ON pa.account_id = a.account_id
INNER JOIN msdb.dbo.sysmail_server s
	      ON a.account_id = s.account_id;

    SELECT CONVERT(VARCHAR(50), @@SERVERNAME);

    SELECT SERVERPROPERTY('MachineName') AS [ServerName]
	       , SERVERPROPERTY('ServerName') AS [ServerInstanceName]
	       , SERVERPROPERTY('InstanceName') AS [Instance]
	       , SERVERPROPERTY('Edition') AS [Edition]
	       , SERVERPROPERTY('ProductVersion') AS [ProductVersion]
	       , LEFT(@@Version, Charindex('-', @@version) - 2) AS VersionName
