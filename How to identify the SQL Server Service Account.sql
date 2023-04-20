----------------------------------------------------------------------------------------------------------
-- Date        : 2023-04-20
-- Author      : Hidequel Puga, <codefivestar@gmail.com>
-- Description : How to identify the sql server service account in t-sql
-- Ref         : https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-server-services-transact-sql?view=azuresqldb-current
----------------------------------------------------------------------------------------------------------

SELECT SERVERPROPERTY('MachineName') AS ComputerName
     , SERVERPROPERTY('ServerName')  AS InstanceName
     , dss.servicename               AS ServiceName
	 , dss.service_account           AS ServiceAccount
	 , dss.startup_type_desc         AS StartupTypeDesc
	 , dss.status_desc               AS StatusDesc
	 --*
  FROM sys.dm_server_services AS dss