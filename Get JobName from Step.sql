----------------------------------------------------------------------------------------------------------
-- Create Date : 2020-01-24 12:15 PM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@gmail.com
-- Reference   : https://social.msdn.microsoft.com/Forums/sqlserver/en-US/0eb9c96c-fc06-4ae6-8b30-4e486d62f573/how-to-retrieve-current-step-name-of-currently-running-job?forum=transactsql
-- Description : How to retrieve current step name of currently running job
----------------------------------------------------------------------------------------------------------

    SELECT DISTINCT j.name AS JobName
		 , CASE 
				WHEN ja.last_executed_step_id IS NULL THEN js.step_name
				ELSE js2.step_name
			END AS StepName
		 , ja.start_execution_date AS StartDateTime
		 , 'Running' AS RunStatus
		 , (
			SELECT RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate()) / 3600), 2)      + ':' + 
			       RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate()) % 3600 / 60), 2) + ':' + 
				   RIGHT('0' + CONVERT(VARCHAR(2), DATEDIFF(second, start_execution_date, GetDate()) % 60), 2)
			) AS Duration
		 , '' AS Message
	  FROM [msdb].[dbo].sysjobactivity ja
	  JOIN [msdb].[dbo].sysjobs j ON ja.job_id = j.job_id
 LEFT JOIN [msdb].[dbo].sysjobsteps js ON j.job_id = js.job_id
	   AND CASE 
				WHEN ja.last_executed_step_id IS NULL THEN j.start_step_id
				ELSE ja.last_executed_step_id
			END = js.step_id
 LEFT JOIN msdb.dbo.sysjobsteps js2 
        ON js.job_id             = js2.job_id
	   AND js.on_success_step_id = js2.step_id
     WHERE ja.session_id = (
							SELECT TOP 1 session_id
							  FROM msdb.dbo.syssessions
		                  ORDER BY agent_start_date DESC
		                    )
	   AND start_execution_date IS NOT NULL
	   AND stop_execution_date  IS NULL;
