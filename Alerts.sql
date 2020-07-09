USE [msdb]
GO

-- Crear operador
EXEC msdb.dbo.sp_add_operator @name=N'[bounty]', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'[bounty]@gmail.com', 
		@category_name=N'[Uncategorized]'
GO

-- Crear notificaciones
EXEC msdb.dbo.sp_add_alert @name = N'Severity 016'
	,@message_id = 0
	,@severity = 16
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 017'
	,@message_id = 0
	,@severity = 17
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 018'
	,@message_id = 0
	,@severity = 18
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 019'
	,@message_id = 0
	,@severity = 19
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 020'
	,@message_id = 0
	,@severity = 20
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 021'
	,@message_id = 0
	,@severity = 21
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 022'
	,@message_id = 0
	,@severity = 22
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 023'
	,@message_id = 0
	,@severity = 23
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 024'
	,@message_id = 0
	,@severity = 24
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Severity 025'
	,@message_id = 0
	,@severity = 25
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Mirror State Change'
	,@message_id = 0
	,@severity = 0
	,@enabled = 1
	,@delay_between_responses = 1200
	,@include_event_description_in = 1
	,@notification_message = N'La configuración Mirror de las BD ha dectectado cambios en las comunicaciónes entre servidores.'
	,@category_name = N'[Uncategorized]'
	,@wmi_namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER'
	,@wmi_query = N'Select * from Database_Mirroring_State_Change'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Mirror Unsent Log'
	,@message_id = 32042
	,@severity = 0
	,@enabled = 1
	,@delay_between_responses = 1200
	,@include_event_description_in = 1
	,@notification_message = N'Unsent Log mayor que 50 KB'
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Error Number 823'
	,@message_id = 823
	,@severity = 0
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Error Number 824'
	,@message_id = 824
	,@severity = 0
	,@enabled = 1
	,@delay_between_responses = 60
	,@include_event_description_in = 1
	,@category_name = N'[Uncategorized]'
	,@job_id = N'00000000-0000-0000-0000-000000000000';

EXEC msdb.dbo.sp_add_alert @name = N'Error Number 825'
	, @message_id = 825
	, @severity = 0
	, @enabled = 1
	, @delay_between_responses = 60
	, @include_event_description_in = 1
	, @category_name = N'[Uncategorized]'
	, @job_id = N'00000000-0000-0000-0000-000000000000';
	
GO	

-- Asignar operador a cada notificación
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 823', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 824', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error 825', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Mirror State Change', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Mirror Unsent Log', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 016', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 017', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 018', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 019', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 020', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 021', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 022', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 023', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 024', @operator_name=N'[bounty]', @notification_method = 1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 025', @operator_name=N'[bounty]', @notification_method = 1;

GO

