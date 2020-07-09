USE [msdb]
GO

DECLARE @jobstep_job_id AS UNIQUEIDENTIFIER;
    SET @jobstep_job_id = N'00000000-0000-0000-0000-000000000000'

EXEC msdb.dbo.sp_add_jobstep 
      @job_id               = @jobstep_job_id
	, @step_name            = N'Mail Success'
	, @step_id              = 2
	, @cmdexec_success_code = 0
	, @on_success_action    = 1
	, @on_fail_action       = 2
	, @retry_attempts       = 0
	, @retry_interval       = 0
	, @os_run_priority      = 0
	, @subsystem            = N'TSQL'
	, @command              = N'EXEC msdb.dbo.sp_send_dbmail @profile_name = ''PROFILE''
                                   , @recipients   = N''codefivestar@gmail.com''
						           , @subject      = N''Ejecución de Suscripción Correcta''
						           , @body         = N''Ejecución de Suscripción Correcta'';'
	, @database_name = N'master'
	, @flags = 0;


EXEC msdb.dbo.sp_add_jobstep 
      @job_id               = @jobstep_job_id
	, @step_name            = N'Mail Failure'
	, @step_id              = 3
	, @cmdexec_success_code = 0
	, @on_success_action    = 1
	, @on_fail_action       = 2
	, @retry_attempts       = 0
	, @retry_interval       = 0
	, @os_run_priority      = 0
	, @subsystem            = N'TSQL'
	, @command              = N'EXEC msdb.dbo.sp_send_dbmail @profile_name = ''PROFILE''
                                   , @recipients   = N''codefivestar@gmail.com''
						           , @importance   = ''High''
						           , @subject      = N''Fallo en la ejecución de suscripción''
						           , @body         = N''Fallo en la ejecución de suscripción'';'
	, @database_name        = N'master'
	, @flags                = 0;


EXEC msdb.dbo.sp_update_jobstep 
      @job_id             = @jobstep_job_id
	, @step_id            = 1
	, @on_success_action  = 4
	, @on_success_step_id = 2
	, @on_fail_action     = 4
	, @on_fail_step_id    = 3;
GO