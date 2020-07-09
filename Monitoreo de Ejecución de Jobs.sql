DECLARE @xml  NVARCHAR(MAX);
DECLARE @html NVARCHAR(MAX);
         
    SET @xml = CAST((     
                     SELECT distinct TABLA1.job_name AS 'td'
					      , ''
						  , convert(char(8), TABLA1.run_datetime, 112) AS 'td'
						  , ''
						  , TABLA1.run_status AS 'td'
						  , ''
						  , convert(char(8), TABLA1.NextRunDateTime, 112) AS 'td'
                       FROM (select job_name
					              , run_datetime
								  , CASE run_status
									    WHEN 0 THEN 'Failed'
										WHEN 1 THEN 'Succeeded'
										WHEN 2 THEN 'Retry'
										WHEN 3 THEN 'Canceled'
										WHEN 4 THEN 'Running' -- In Progress
									 END AS run_status
								  , CASE NextRunDate
										WHEN 0 THEN NULL
										ELSE CAST(CAST(NextRunDate AS CHAR(8))
												 + ' ' 
												 + STUFF(STUFF(RIGHT('000000' + CAST(NextRunTime AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':')AS DATETIME)
										  END AS NextRunDateTime
      

							   from (
									 select job_name
									      , run_datetime
										  , SUBSTRING(run_duration, 1, 2) + ':' + SUBSTRING(run_duration, 3, 2) + ':' + SUBSTRING(run_duration, 5, 2) AS run_duration
										  , run_status
										  , NextRunTime
										  , NextRunDate
                                       from (
        select DISTINCT
            j.name as job_name, 
            run_datetime = CONVERT(DATETIME, RTRIM(h.run_date)) +  
                (h.run_time * 9 + h.run_time % 10000 * 6 + h.run_time % 100 * 10) / 216e4,
            run_duration = RIGHT('000000' + CONVERT(varchar(6), h.run_duration), 6), 
            sJOBH.run_status, sJOBH.run_time, sJOBH.[message], sJOBSCH.NextRunTime, sJOBSCH.NextRunDate
        from msdb..sysjobhistory h
        
            LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM [msdb].[dbo].[sysjobschedules]
                GROUP BY [job_id]
            ) AS [sJOBSCH]
        ON h.job_id = [sJOBSCH].[job_id]        
        
        inner join msdb..sysjobs j
        on h.job_id = j.job_id
        
          LEFT JOIN (
                SELECT 
                    [job_id]
                    , [run_date]
                    , [run_time]
                    , [run_status]
                    , [run_duration]
                    , [message]
                    , ROW_NUMBER() OVER (
                                            PARTITION BY [job_id] 
                                            ORDER BY [run_date] DESC, [run_time] DESC
                      ) AS RowNumber
                FROM [msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [J].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1
    ) t
) t) AS TABLA1
where CONVERT (CHAR (8), run_datetime, 112) = CONVERT (CHAR (8), GETDATE()-1, 112)
------order by  run_datetime desc

      
      
FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

/*--- body*/
SET @html ='<html><body>Ejecuciones Diarias de JOBS<br><br>
<table border = 1> 
<tr bgcolor=6699CC>
<th> job_name </th> <th> run_datetime </th><th> run_status </th><th>  NextRunDateTime</th> </tr>'    
 
SET @html = @html + @xml +'</table></body></html>'


EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'MYPROFILE', -- replace with your SQL Database Mail Profile 
@body = @html,
@body_format ='HTML',
@recipients = 'bounty31k@outlook.com', -- replace with your email address
@subject = 'Estatus de ejecuciones de JOB';
