----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- Email           : codefivestar@gmail.com
-- Date            : [yyyy-mm-dd hh:mm AMPM]
-- Requirements    : Request # [000]
-- Description     : Quick Description of changes
-- Used Objects    : Tables >> table_name_1, table_name_2
-- Used For        :   SSRS >> [URL for .rdl]
-- Test            : EXECUTE [sp_name] <@parm_1>, <@parm_2>
----------------------------------------------------------------------------------------------------------
     SELECT deqs.last_execution_time AS [Time]
	      , dest.TEXT AS [Query]
	      , dest.*
       FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
      WHERE dest.dbid = DB_ID('msdb')
   ORDER BY deqs.last_execution_time DESC;
