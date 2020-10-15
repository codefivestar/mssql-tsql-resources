USE CompliXpert;  
GO  

SELECT total_log_size_in_bytes
     , used_log_space_in_bytes    
     , (total_log_size_in_bytes - used_log_space_in_bytes)*1.0/1024/1024 AS [free log space in MB]  
FROM sys.dm_db_log_space_usage;  