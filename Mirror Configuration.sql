----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Description : MS SQL Server Mirror Configuration with out Witness Instance.
-- Reference   : https://docs.microsoft.com/en-us/sql/database-engine/database-mirroring/database-mirroring-sql-server?view=sql-server-2017
----------------------------------------------------------------------------------------------------------

--Server Instance / Database:
--Principal --> TCP://SSInstance_1.DOMAIN:5022 
--Mirror    --> TCP://SSInstance_2.DOMAIN:5022
--Witness   --> No Configurado
--Database  --> D5S_test

--Paso # 1 : Aplicar en Instancia Principal

BACKUP DATABASE D5S_test TO DISK = '\\SharedFolder_temp\D5S_test.bak' WITH FORMAT;
BACKUP LOG D5S_test TO DISK      = '\\SharedFolder_temp\D5S_test.trn';

----------------------------------------------------------------------------------------------------

--Paso # 2 : Aplicar en Instancia Mirror

IF DB_ID('D5S_test') > 0 DROP DATABASE D5S_test;

RESTORE DATABASE D5S_test
FROM DISK = '\\SharedFolder_temp\D5S_test.bak' WITH NORECOVERY, 
MOVE 'D5S_test' TO 'E:\MSSQL\DATA\D5S_test.mdf', 
MOVE 'D5S_test_log' TO 'E:\MSSQL\DATA\D5S_test_log.ldf';

RESTORE LOG D5S_test FROM DISK = '\\SharedFolder_temp\D5S_test.trn' WITH NORECOVERY, FILE = 1;

----------------------------------------------------------------------------------------------------

--Paso # 3 : Aplicar en Instancia Mirror
ALTER DATABASE D5S_test SET PARTNER = 'TCP://SSInstance_1.DOMAIN:5022';

----------------------------------------------------------------------------------------------------

--Paso # 4 : Aplicar en Instancia Principal
ALTER DATABASE D5S_test SET PARTNER = 'TCP://SSInstance_2.DOMAIN:5022';

----------------------------------------------------------------------------------------------------

--Paso # 5 : Aplicar en Instancia Mirror (Si fuera necesario)

--Comando para Eliminar el Mirror entre base de datos.

-- ALTER DATABASE D5S_test SET PARTNER OFF  
-- RESTORE DATABASE D5S_test WITH RECOVERY; 
