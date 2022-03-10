

-- find job steps that execute SSIS packages
use msdb
go

    select [job]=j.name, [step]=s.step_name, s.command 
      from dbo.sysjobsteps s
inner join dbo.sysjobs j
        on s.job_id = j.job_id
       and s.subsystem ='SSIS' 
go



-- find the SSIS package inside MSDB
use msdb
go

    select f.FolderName, [package]=p.name 
      from dbo.sysssispackagefolders f
inner join dbo.sysssispackages p
        on f.folderid = p.folderid;
go



-- find the SSIS packages used in SQL Server Jobs
use msdb
   select SQLInstance = @@ServerName
		, [job]=j.name
		, j.Enabled
		, [step]=s.step_name
		, SSIS_Package = case 
							  when charindex('/ISSERVER', s.command)=1 then substring(s.command, len('/ISSERVER "\"')+1, charindex('" /SERVER ', s.command)-len('/ISSERVER "\"')-3)
							  when charindex('/FILE', s.command)=1 then substring(s.command, len('/FILE "')+1, charindex('.dtsx', s.command)-len('/FILE "\"')+6)
							  when charindex('/SQL', s.command)=1 then substring(s.command, len('/SQL "\"')+1, charindex('" /SERVER ', s.command)-len('/SQL "\"')-3)
							  else s.command
						  end
		, StorageType = CASE 
					 when charindex('/ISSERVER', s.command) = 1 then 'SSIS Catalog'
					 when charindex('/FILE', s.command)=1 then 'File System'
					 when charindex('/SQL', s.command)=1 then 'MSDB'
					 else 'OTHER'
					end
		, [Server] = CASE 
					 when charindex('/ISSERVER', s.command) = 1 then replace(replace(substring(s.command, charindex('/SERVER ', s.command)+len('/SERVER ')+1, charindex(' /', s.command, charindex('/SERVER ', s.command)+len('/SERVER '))-charindex('/SERVER ', s.command)-len('/SERVER ')-1), '"\"',''), '\""', '')
					 when charindex('/FILE', s.command)=1 then substring(s.command, charindex('"\\', s.command)+3, CHARINDEX('\', s.command, charindex('"\\', s.command)+3)-charindex('"\\', s.command)-3)
					 when charindex('/SQL', s.command)=1 then replace(replace(substring(s.command, charindex('/SERVER ', s.command)+len('/SERVER ')+1, charindex(' /', s.command, charindex('/SERVER ', s.command)+len('/SERVER '))-charindex('/SERVER ', s.command)-len('/SERVER ')-1), '"\"',''), '\""', '')
					 else 'OTHER'
					END
    from dbo.sysjobsteps s
inner join dbo.sysjobs j
      on s.job_id = j.job_id
     and s.subsystem ='SSIS';
go


