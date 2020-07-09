----------------------------------------------------------------------------------------------------------
-- Create Date : 2020-01-23 09:48 AM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@gmail.com
-- Reference   : https://blog.sqlauthority.com/2015/07/13/sql-server-how-to-change-server-name/
-- Description : How to Change Server Name
----------------------------------------------------------------------------------------------------------

-- Server Detail
SELECT HOST_NAME() AS 'host_name()'
     , @@servername AS 'ServerName\InstanceName'
     , SERVERPROPERTY('servername') AS 'ServerName'
     , SERVERPROPERTY('machinename') AS 'Windows_Name'
     , SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'NetBIOS_Name'
     , SERVERPROPERTY('instanceName') AS 'InstanceName'
     , SERVERPROPERTY('IsClustered') AS 'IsClustered';

-- Step # 1 : Execute below to drop the current server name
EXEC sp_DROPSERVER 'oldservername'

-- Step # 2 : Execute below to add a new server name. Make sure local is specified.
EXEC sp_ADDSERVER 'newservername', 'local'

-- Step # 3 : Restart SQL Services.
-- Step # 4 : Verify the new name using:
SELECT @@SERVERNAME;
SELECT * 
  FROM sys.servers WHERE server_id = 0;

