----------------------------------------------------------------------------------------------------------
-- Create Date : 2019-10-28 03:50 PM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@outlook.com
-- Reference   : https://www.virtualizationhowto.com/2013/03/how-to-find-ssrs-job-name-report-name-sql/
-- Description : This Transact-SQL script find the SSRS Job Name with the Report Name SQL.
----------------------------------------------------------------------------------------------------------

SELECT
c .Name AS ReportName
, rs . ScheduleID AS JOB_NAME
, s . [Description]
, s . LastStatus
, s . LastRunTime
FROM
ReportServer ..[Catalog] c
JOIN ReportServer .. Subscriptions s ON c. ItemID = s. Report_OID
JOIN ReportServer .. ReportSchedule rs ON c. ItemID = rs. ReportID
AND rs . SubscriptionID = s . SubscriptionID

 