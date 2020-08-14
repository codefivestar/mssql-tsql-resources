----------------------------------------------------------------------------------------------------------
-- Create Date : 2019-10-28 03:50 PM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@outlook.com
-- Reference   : https://gallery.technet.microsoft.com/scriptcenter/List-all-SSRS-subscriptions-968ae4d5
--               https://dataqueen.unlimitedviz.com/2012/05/finding-report-subscription-errors/
-- Description : This Transact-SQL script list all existing subscriptions with the schedule data.
----------------------------------------------------------------------------------------------------------

USE [ReportServer];  -- You may change the database name.
GO

SELECT USR.UserName AS SubscriptionOwner
      ,SUB.ModifiedDate
      ,SUB.[Description]
      ,SUB.EventType
      ,SUB.DeliveryExtension
      ,SUB.LastStatus
      ,SUB.LastRunTime
      ,SCH.NextRunTime
      ,SCH.Name AS ScheduleName
      ,CAT.[Path] AS ReportPath
      ,CAT.[Description] AS ReportDescription
FROM dbo.Subscriptions AS SUB
     INNER JOIN dbo.Users AS USR
         ON SUB.OwnerID = USR.UserID
     INNER JOIN dbo.[Catalog] AS CAT
         ON SUB.Report_OID = CAT.ItemID
     INNER JOIN dbo.ReportSchedule AS RS
         ON SUB.Report_OID = RS.ReportID
            AND SUB.SubscriptionID = RS.SubscriptionID
     INNER JOIN dbo.Schedule AS SCH
         ON RS.ScheduleID = SCH.ScheduleID
ORDER BY USR.UserName
        ,CAT.[Path];

--

select
'SubnDesc' = s.Description,
'SubnOwner' = us.UserName,
'LastStatus' = s.LastStatus,
'LastRun' = s.LastRunTime,
'ReportPath' = c.Path,
'ReportModifiedBy' = uc.UserName,
'ScheduleId' = rs.ScheduleId,
'SubscriptionId' = s.SubscriptionID
from ReportServer.dbo.Subscriptions s
join ReportServer.dbo.Catalog c on c.ItemID = s.Report_OID
join ReportServer.dbo.ReportSchedule rs on rs.SubscriptionID = s.SubscriptionID
join ReportServer.dbo.Users uc on uc.UserID = c.ModifiedByID
join ReportServer.dbo.Users us on us.UserID = s.OwnerId;


-- With Jobs

SELECT  Schedule.ScheduleID AS JobName
       ,[Catalog].Name AS ReportName
       ,Subscriptions.Description AS Recipients
       ,[Catalog].Path AS ReportPath
       ,StartDate
       ,Schedule.LastRunTime
FROM    dbo.ReportSchedule
        INNER JOIN dbo.Schedule ON ReportSchedule.ScheduleID = Schedule.ScheduleID
        INNER JOIN dbo.Subscriptions ON ReportSchedule.SubscriptionID = Subscriptions.SubscriptionID
        INNER JOIN dbo.[Catalog] ON ReportSchedule.ReportID = [Catalog].ItemID
                                                         AND Subscriptions.Report_OID = [Catalog].ItemID