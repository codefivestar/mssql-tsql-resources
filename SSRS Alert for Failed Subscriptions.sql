USE ReportServer
GO

DECLARE @count INT

SELECT Cat.[Name]
	, Rep.[ScheduleId]
	, Own.UserName
	, ISNULL(REPLACE(Sub.[Description], 'send e-mail to ', ''), ' ') AS Recipients
	, Sub.[LastStatus]
	, Cat.[Path]
	, Sub.[LastRunTime]
INTO #tFailedSubs
FROM dbo.[Subscriptions] Sub WITH (NOLOCK)
INNER JOIN dbo.[Catalog] Cat WITH (NOLOCK)
	ON Sub.[Report_OID] = Cat.[ItemID]
INNER JOIN dbo.[ReportSchedule] Rep WITH (NOLOCK)
	ON (
			cat.[ItemID] = Rep.[ReportID]
			AND Sub.[SubscriptionID] = Rep.[SubscriptionID]
			)
INNER JOIN dbo.[Users] Own WITH (NOLOCK)
	ON Sub.[OwnerID] = Own.[UserID]
WHERE Sub.[LastStatus] NOT LIKE '%was written%' --File Share subscription
	AND Sub.[LastStatus] NOT LIKE '%pending%' --Subscription in progress. No result yet
	AND Sub.[LastStatus] NOT LIKE '%mail sent%' --Mail sent successfully.
	AND Sub.[LastStatus] NOT LIKE '%New Subscription%' --New Sub. Not been executed yet
	AND Sub.[LastStatus] NOT LIKE '%been saved%' --File Share subscription
	AND Sub.[LastStatus] NOT LIKE '% 0 errors.' --Data Driven subscription
	AND Sub.[LastStatus] NOT LIKE '%succeeded%' --Success! Used in cache refreshes
	AND Sub.[LastStatus] NOT LIKE '%successfully saved%' --File Share subscription
	AND Sub.[LastStatus] NOT LIKE '%New Cache%' --New cache refresh plan
	-- AND Sub.[LastRunTime] > GETDATE()-1

-- If any failed subscriptions found, proceed to build HTML & send mail.
SELECT @count = COUNT(*)
FROM #tFailedSubs

IF (@count > 0)
BEGIN
	DECLARE @EmailRecipient NVARCHAR(1000)
	DECLARE @SubjectText NVARCHAR(1000)
	DECLARE @ProfileName NVARCHAR(1000)
	DECLARE @tableHTML1 NVARCHAR(MAX)
	DECLARE @tableHTMLAll NVARCHAR(MAX)

	SET NOCOUNT ON

	SELECT @EmailRecipient = '';

	SET @SubjectText = 'Failed SSRS Subscriptions'

	--Set DB Mail profile to use
	SELECT TOP 1 @ProfileName = [Name]
	FROM msdb.dbo.sysmail_profile
	WHERE [Name] = ''

	SET @tableHTML1 = N'<H3 style="color:red; font-family:verdana">Failed SSRS Subscription details. Please resolve & re-run jobs</H3>' + N'<p align="left" style="font-family:verdana; font-size:8pt"></p>' + N'<table border="2" style="font-size:8pt; font-family:verdana; text-align:left">' + N'<tr style="color:black; font-weight:bold">' + N'<th>Report Name</th><th>SQL Agent Job ID</th><th>Owner Username</th><th>Distribution</th><th>Error Message</th><th>Report Location</th><th>Last Run Time</th></tr>' + CAST((
				SELECT td = t.[Name]
					, ''
					, td = t.[ScheduleId]
					, ''
					, td = t.[UserName]
					, ''
					, td = t.[Recipients]
					, ''
					, td = t.[LastStatus]
					, ''
					, td = t.[Path]
					, ''
					, td = t.[LastRunTime]
				FROM #tFailedSubs t
				FOR XML PATH('tr')
					, TYPE
				) AS NVARCHAR(MAX)) + N'</table>'
	SET @tableHTMLAll = ISNULL(@tableHTML1, '')

	IF @tableHTMLAll <> ''
	BEGIN
		--SELECT @tableHTMLAll
		EXEC msdb.dbo.sp_send_dbmail @profile_name = @ProfileName
			, @recipients = @EmailRecipient
			, @body = @tableHTMLAll
			, @body_format = 'HTML'
			, @subject = @SubjectText
	END

	SET NOCOUNT OFF

	DROP TABLE #tFailedSubs
END
