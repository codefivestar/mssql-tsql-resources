-- list all jobs
select
 name
,enabled
,description
from msdb.dbo.sysjobs

-- list all schedules with selected attributes
select 
 name
,enabled
,freq_type
,freq_interval
,freq_subday_type
,freq_subday_interval
,freq_recurrence_factor  
from msdb.dbo.sysschedules

-- list all jobs with a schedule
select
 name
,enabled
,description
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
order by enabled desc


-- list all jobs without a schedule
select
 name
,enabled
,description
from msdb.dbo.sysjobs where job_id in
(
-- job_ids without a schedule
select job_id from msdb.dbo.sysjobs

except

select job_id from msdb.dbo.sysjobschedules
)


-- jobs that have a schedule with schedule identifiers
select
sysjobs.job_id
,sysjobs.name job_name
,sysjobs.enabled job_enabled
,sysschedules.name schedule_name
,sysschedules.schedule_id
,sysschedules.schedule_uid
,sysschedules.enabled schedule_enabled
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
inner join msdb.dbo.sysschedules on sysjobschedules.schedule_id = sysschedules.schedule_id
order by sysjobs.enabled desc
