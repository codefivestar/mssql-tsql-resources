----------------------------------------------------------------------------------------------------------
-- Create Date : 2019-10-08 03:13 PM
-- Author      : Hidequel Puga
-- Mail        : codefivestar@outlook.com
-- Reference   : https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/ole-automation-procedures-server-configuration-option?view=sql-server-2017
-- Description : Enable Ole Automation Procedures Server Configuration Option
----------------------------------------------------------------------------------------------------------

-- The following example shows how to view the current setting of OLE Automation procedures.
EXEC sp_configure 'Ole Automation Procedures';  
GO  

-- The following example shows how to enable OLE Automation procedures.
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Ole Automation Procedures', 1;  
GO  
RECONFIGURE;  
GO