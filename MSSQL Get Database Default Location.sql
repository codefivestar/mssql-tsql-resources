DECLARE @datadir NVARCHAR(4000)
	,@logdir NVARCHAR(4000)
	,@backupdir NVARCHAR(4000);

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	,N'Software\Microsoft\MSSQLServer\MSSQLServer'
	,N'DefaultData'
	,@datadir OUTPUT;

IF @datadir IS NULL
BEGIN
	EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
		,N'Software\Microsoft\MSSQLServer\Setup'
		,N'SQLDataRoot'
		,@datadir OUTPUT;
END

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	,N'Software\Microsoft\MSSQLServer\MSSQLServer'
	,N'DefaultLog'
	,@logdir OUTPUT;

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	,N'Software\Microsoft\MSSQLServer\MSSQLServer'
	,N'BackupDirectory'
	,@backupdir OUTPUT;

SELECT @datadir AS Data_directory
	,ISNULL(@logdir, @datadir) AS Log_directory
	,@backupdir AS Backup_directory;