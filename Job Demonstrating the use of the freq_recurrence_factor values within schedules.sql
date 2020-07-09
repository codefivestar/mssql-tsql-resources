-- run code to assign a bi-weekly schedule to one job

-- detach Weekly on Saturday Morning at 1 AM schedule
-- for Insert into JobRunLog table with a schedule job
exec msdb.dbo.sp_detach_schedule  
    @job_name = 'Insert into JobRunLog table with a schedule',  
    @schedule_name = 'Weekly on Saturday Morning at 1 AM' ;  
GO 



-- add a schedule to run bi-weekly on Saturday morning at 1 AM
-- and attach it to the Insert into JobRunLog table with a schedule job
declare @ReturnCode int
if exists (select name from msdb.dbo.sysschedules WHERE name = N'Bi-weekly on Saturday Morning at 1 AM')
delete from msdb.dbo.sysschedules where name=N'Bi-weekly on Saturday Morning at 1 AM'

exec @ReturnCode = msdb.dbo.sp_add_schedule  
        @schedule_name = N'Bi-weekly on Saturday Morning at 1 AM',
		@enabled=1, 
		@freq_type=8,               -- means job runs on a weekly basis
		@freq_interval=64,          -- means job runs on Saturday within a week
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=2,  -- means job runs every other freq_type
		@active_start_date=20170729, 
		@active_end_date=99991231, 
		@active_start_time=10000,   -- means job runs at 1 AM in day 
		@active_end_time=235959


exec @ReturnCode = msdb.dbo.sp_attach_schedule  
   @job_name = N'Insert into JobRunLog table with a schedule',  
   @schedule_name = N'Bi-weekly on Saturday Morning at 1 AM' 


-------------------------------------------------------------------------------------------------------------------------


-- jobs with a weekly schedule where job name is
-- Insert into JobRunLog table with a schedule

select
 sysjobs.name job_name
,sysjobs.enabled job_enabled
,sysschedules.name schedule_name
,sysschedules.freq_recurrence_factor
,case
	when freq_type = 8 then 'Weekly'
end frequency
,
replace
(
 CASE WHEN freq_interval&1 = 1 THEN 'Sunday, ' ELSE '' END
+CASE WHEN freq_interval&2 = 2 THEN 'Monday, ' ELSE '' END
+CASE WHEN freq_interval&4 = 4 THEN 'Tuesday, ' ELSE '' END
+CASE WHEN freq_interval&8 = 8 THEN 'Wednesday, ' ELSE '' END
+CASE WHEN freq_interval&16 = 16 THEN 'Thursday, ' ELSE '' END
+CASE WHEN freq_interval&32 = 32 THEN 'Friday, ' ELSE '' END
+CASE WHEN freq_interval&64 = 64 THEN 'Saturday, ' ELSE '' END
,', '
,''
) Days
,
case
	when freq_subday_type = 2 then ' every ' + cast(freq_subday_interval as varchar(7)) 
	+ ' seconds' + ' starting at '
	+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')	
	when freq_subday_type = 4 then ' every ' + cast(freq_subday_interval as varchar(7)) 
	+ ' minutes' + ' starting at '
	+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
	when freq_subday_type = 8 then ' every ' + cast(freq_subday_interval as varchar(7)) 
	+ ' hours'   + ' starting at '
	+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
	else ' starting at ' 
	+ stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
end time
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
inner join msdb.dbo.sysschedules on sysjobschedules.schedule_id = sysschedules.schedule_id
where freq_type = 8 and sysjobs.name = 'Insert into JobRunLog table with a schedule'


-------------------------------------------------------------------------------------------------------------------------


-- remove bi-weekly schedule and restore original 
-- schedule to the Insert into JobRunLog table with a schedule job

delete from msdb.dbo.sysjobschedules where schedule_id in
(
select schedule_id
from msdb.dbo.sysschedules
where name in ('Bi-weekly on Saturday Morning at 1 AM')
)


delete from msdb.dbo.sysschedules where schedule_id in
(
select schedule_id
from msdb.dbo.sysschedules
where name in ('Bi-weekly on Saturday Morning at 1 AM')
)



exec msdb.dbo.sp_attach_schedule  
    @job_name = 'Insert into JobRunLog table with a schedule',  
    @schedule_name = 'Weekly on Saturday Morning at 1 AM' ;  