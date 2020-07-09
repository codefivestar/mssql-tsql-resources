----------------------------------------------------------------------------------------------------------
-- File Name   : MSSQL – Set Read Only and Single User.sql
-- Create Date : 2019-06-19 11:30 AM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@outlook.com
-- Reference   : https://docs.microsoft.com/en-us/sql/relational-databases/databases/set-a-database-to-single-user-mode?view=sql-server-2017
-- Tag         : SINGLE_USER MULTI_USER READ_ONLY READ_WRITE
----------------------------------------------------------------------------------------------------------

USE [master];
GO

ALTER DATABASE [database_name]
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [database_name]
SET READ_ONLY;
GO

ALTER DATABASE [database_name]
SET MULTI_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE [database_name]
SET READ_WRITE;
GO