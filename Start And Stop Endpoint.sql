
--Step # 1 : On Principal Server
SELECT * FROM sys.endpoints WHERE TYPE = 4;

ALTER ENDPOINT [endpoint_name] STATE = STOPPED
ALTER ENDPOINT [endpoint_name] STATE = STARTED

--Step # 2 : On Mirror Server
SELECT * FROM sys.endpoints WHERE TYPE = 4;

ALTER ENDPOINT endpoint_Baliado STATE = STOPPED
ALTER ENDPOINT endpoint_Baliado STATE = STARTED

--Step # 3 : On Principal Server
ALTER DATABASE [database_name] SET PARTNER RESUME;