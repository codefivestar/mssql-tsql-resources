----------------------------------------------------------------------------------------------------------
--Create Date : 2018-12-18 03:53 P.M.
--Author      : Hidequel Puga
--Mail        : bounty31k@outlook.com
--Reference   : https://blog.sqlauthority.com/2010/01/17/sql-server-get-server-version-and-additional-info/
--Description : Get Server Version and Additional Info.
----------------------------------------------------------------------------------------------------------

--Opción # 1
SELECT @@VERSION VersionInfo
GO

--Opción # 2
EXEC xp_msver
GO