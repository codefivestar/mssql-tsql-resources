SELECT T1.*
  FROM [msdb].[dbo].[sysjobs_view] AS T1
  JOIN [msdb].[dbo].[sysjobactivity] AS T2
    ON T1.job_id = T2.job_id
  JOIN [msdb].[dbo].[syssessions] AS T3
    ON T3.session_id = T2.session_id
  JOIN (
        SELECT MAX(agent_start_date) as max_agent_start_date
		  FROM [msdb].[dbo].[syssessions]
         ) AS T4
    ON T4.max_agent_start_date = T3.agent_start_date
  WHERE T2.run_requested_date IS NOT NULL
    AND T2.stop_execution_date IS NULL;

SELECT * 
  FROM [msdb].[dbo].[sysjobactivity] AS T2
WHERE T2.job_id = '60DE4639-E491-4FD4-A9D9-2C3E67AC887C';

SELECT * FROM [msdb].[dbo].[syssessions];