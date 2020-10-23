USE [msdb];
GO

DECLARE @servername        VARCHAR(50);
DECLARE @run_date          INT;              --parametros de entrada
DECLARE @job_id            UNIQUEIDENTIFIER; --parametros de entrada
DECLARE @job_name          NVARCHAR(128);
DECLARE @step_name         NVARCHAR(128);
DECLARE @step_id           INT;
DECLARE @step_run_status   NVARCHAR(25);
DECLARE @step_run_date     INT; 
DECLARE @step_run_time     INT;
DECLARE @step_run_duration INT;
DECLARE @step_message      NVARCHAR(4000);
DECLARE @step_subsystem    NVARCHAR(40);
DECLARE @step_command      NVARCHAR(MAX);
DECLARE @ssis_pos_start    BIGINT;
DECLARE @ssis_pos_end      BIGINT;
DECLARE @ssis_server       NVARCHAR(128);
DECLARE @ssis_message      NVARCHAR(MAX);
DECLARE @html_header       NVARCHAR(MAX); 
DECLARE @html_table        NVARCHAR(MAX); 
DECLARE @html_footer       NVARCHAR(MAX); 
DECLARE @html_text         NVARCHAR(MAX);
DECLARE @subject           NVARCHAR(255);

	SET @job_id     = '[job_id]';
	SET @run_date   = CONVERT(INT, CONVERT(VARCHAR(10), GETDATE(), 112));

	SET @servername = @@SERVERNAME;

 SELECT @job_name = J.[name]
   FROM [msdb].[dbo].[sysjobs] AS J
  WHERE J.job_id = @job_id;

 SELECT @step_name    = H.step_name
      , @step_id      = H.step_id
	  , @step_run_status = CASE H.run_status
							 WHEN 0 THEN 'Failed'
							 WHEN 1 THEN 'Succeded'
							 WHEN 2 THEN 'Retry'
							 WHEN 3 THEN 'Cancelled'
							 WHEN 4 THEN 'In Progress'
						    END
      , @step_run_date = H.run_date   
      , @step_run_time = H.run_time   
      , @step_run_duration = H.run_duration
 	  , @step_message = H.[message]
   FROM [msdb].[dbo].[sysjobhistory] AS H
  WHERE H.instance_id IN (
                          SELECT MAX(instance_id)
						    FROM [msdb].[dbo].[sysjobhistory]
		                   WHERE job_id     = @job_id
						     AND run_date   = @run_date
			                 AND step_id    <> 0
						     AND run_status = 0
						  );

 SELECT @step_subsystem = S.subsystem
      , @step_command   = S.command
   FROM [msdb].[dbo].[sysjobsteps] AS S
  WHERE S.job_id  = @job_id
    AND S.step_id = @step_id;

	SET @html_header = '<!DOCTYPE html>' +
		                '<html>' +
							'<head>' +
							'<title>Reporte</title>' +
							'<style>' +
								'#reporte, h1 { font-family: "Lucida Sans Unicode", "Lucida Grande", sans-serif; font-size: 15px; border-collapse: collapse; width: 100%; }' +
								'#reporte td, #reporte th { border: 1px solid #ddd; padding: 8px; }' +
								'#reporte tr:nth-child(even) { background-color: #f2f2f2; }' +
								'#reporte tr:hover { background-color: #ddd; }' +
								'#reporte th { padding-top: 12px; padding-bottom: 12px; text-align: center; background-color: #ff0000; color: #000000; }' +
							'</style>' +
							'</head>' +
							'<body>';

	SET @html_footer = '</body></html>';

 IF(@step_subsystem = 'SSIS')
	BEGIN

		SET @ssis_pos_start = PATINDEX('%/SERVER %', @step_command) + 8;
		SET @ssis_pos_end   = CHARINDEX(' ', @step_command, @ssis_pos_start);
		SET @ssis_server    = SUBSTRING(@step_command, @ssis_pos_start, @ssis_pos_end - @ssis_pos_start);
		SET @ssis_pos_start = PATINDEX('%"\"%', @step_command) + 3;
		SET @ssis_pos_end   = PATINDEX('%\""%', @step_command);
		SET @step_command   = SUBSTRING(@step_command, @ssis_pos_start, @ssis_pos_end - @ssis_pos_start);
		SET @step_command   = RIGHT(@step_command, CHARINDEX('\', REVERSE(@step_command)) - 1);
		
     	SET @html_table = '<h1>Reporte de Ejecuci&oacute;n</h1>' +
							  '<table id="reporte">' +
								'<tr>' +
									'<th>Servidor</th>' +
									'<th>Tarea</th>' +
									'<th>Paso</th>' +
									'<th>Nombre</th>' +
									'<th>Tipo</th>' +
									'<th>Fecha / Hora</th>' +
									'<th>Duraci&oacute;n <br> ( Min )</th>' +
									'<th>Estatus</th>' +
									'<th>Mensaje</th>' +
								'</tr>' +
											CAST((
												SELECT td = @servername
														, ''
														, td = @job_name
														, ''
														, td = @step_id
														, ''
														, td = @step_name
														, ''
														, td = @step_subsystem
														, ''
														, td = [msdb].[dbo].[agent_datetime](@step_run_date, @step_run_time)
														, ''
														, td = ((@step_run_duration / 10000 * 3600 + (@step_run_duration / 100) % 100 * 60 + @step_run_duration % 100 + 31) / 60)
														, ''
														, td = @step_run_status
														, ''
														, td = @step_message
													FOR XML PATH('tr'), TYPE
												) AS NVARCHAR(MAX)
												) +
							  '</table>' +
							  '<br>' +
							  '<h1>Informaci&oacute;n SSIS</h1>' +
							  '<table id="reporte">' +
								'<tr>' +
									'<th>Paquete</th>' +
									'<th>Ruta Ejecuci&oacute;n</th>' +
									'<th>Evento</th>' +
									'<th>Fuente</th>' +
									'<th>Fecha / Hora</th>' +
									'<th>Mensaje</th>' +
								'</tr>' +
								CAST((
								      SELECT td = package_name
									       , ''
								           , td = execution_path
									       , ''
										   , td = event_name
									       , ''
										   , td = message_source_name
									       , ''
										   , td = message_time
									       , ''
										   , td = [message]
		                                FROM [SSISDB].[catalog].[event_messages] AS E
		                               WHERE E.[event_name] IN ('OnError') 
		                                 AND E.[operation_id] IN (
									                              SELECT operation_id
                                                                    FROM [SSISDB].[catalog].[event_messages]
                                                                   WHERE [package_name] = @step_command
		                                                             AND CONVERT(DATE, [message_time]) = CONVERT (date,convert(char(8), @run_date))
	                                                            GROUP BY operation_id
									                              )
                                    ORDER BY E.[event_message_id] DESC
									FOR XML PATH('tr'), TYPE
								      ) AS NVARCHAR(MAX)
									  ) + 
						      '</table>';



	END
 ELSE
	BEGIN
	
		SET @html_table = '<h1>Reporte de Ejecuci&oacute;n</h1>' +
		                  '<table id="reporte">' +
							'<tr>' +
								'<th>Servidor</th>' +
								'<th>Tarea</th>' +
								'<th>Paso</th>' +
								'<th>Nombre</th>' +
								'<th>Tipo</th>' +
								'<th>Fecha / Hora</th>' +
								'<th>Duraci&oacute;n <br> ( Min )</th>' +
								'<th>Estatus</th>' +
								'<th>Mensaje</th>' +
							'</tr>' +
										CAST((
											SELECT td = @servername
													, ''
													, td = @job_name
													, ''
													, td = @step_id
													, ''
													, td = @step_name
													, ''
													, td = @step_subsystem
													, ''
													, td = [msdb].[dbo].[agent_datetime](@step_run_date, @step_run_time)
													, ''
													, td = ((@step_run_duration / 10000 * 3600 + (@step_run_duration / 100) % 100 * 60 + @step_run_duration % 100 + 31) / 60)
													, ''
													, td = @step_run_status
													, ''
													, td = @step_message
												FOR XML PATH('tr'), TYPE
											) AS NVARCHAR(MAX)
											) +
						  '</table>';
	
	END

	SET @html_text = @html_header + @html_table + @html_footer;
	SET @subject   = 'Fallo en el job : ' + @job_name; 

	EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name = '[@profile_name]'
									 , @importance   = 'High'
									 , @body         = @html_text
									 , @body_format  = 'HTML'
									 , @recipients   = '[@recipients]'
									 , @subject      = @subject;