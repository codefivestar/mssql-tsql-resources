----------------------------------------------------------------------------------------------------------
-- General Data
----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- Email           : codefivestar@gmail.com
-- Date            : 2020-03-23 03:43 PM
-- Description     : How do I change the owner of a subscription in SQL Server Reporting Services
----------------------------------------------------------------------------------------------------------
-- Change History
----------------------------------------------------------------------------------------------------------
-- #               : []
-- Author          : []
-- Date            : [yyyy-mm-dd hh:mm AMPM]
-- Requirements    : []
-- Note            : []
----------------------------------------------------------------------------------------------------------

DECLARE @OldUserID UNIQUEIDENTIFIER;
DECLARE @NewUserID UNIQUEIDENTIFIER;

SELECT @OldUserID = UserID 
  FROM dbo.Users 
 WHERE UserName = '';

SELECT @NewUserID = UserID 
  FROM dbo.Users 
 WHERE UserName = '';

UPDATE dbo.Subscriptions 
    SET OwnerID = @NewUserID 
  WHERE OwnerID = @OldUserID