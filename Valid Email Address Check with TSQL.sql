----------------------------------------------------------------------------------------------------------
-- General Data
----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Date        : 2020-08-21
-- Requirement : --
-- Description : Check email address
----------------------------------------------------------------------------------------------------------

CREATE FUNCTION [dbo].[ChkValidEmail]
(
	@email VARCHAR(100)
) 
RETURNS BIT
AS
BEGIN 
    
	DECLARE @bitEmailVal AS BIT;
	DECLARE @EmailText   AS VARCHAR(100);

		SET @EmailText = LTRIM(RTRIM(ISNULL(@email, '')))

  SET @bitEmailVal = CASE WHEN @EmailText = '' THEN 0
                          WHEN @EmailText LIKE '% %' THEN 0
                          WHEN @EmailText LIKE ('%["(),:;<>\]%') THEN 0
                          WHEN SUBSTRING(@EmailText,CHARINDEX('@',@EmailText),LEN(@EmailText)) LIKE ('%[!#$%&*+/=?^`_{|]%') THEN 0
                          WHEN (LEFT(@EmailText,1) LIKE ('[-_.+]') OR RIGHT(@EmailText,1) LIKE ('[-_.+]')) THEN 0                                                                                    
                          WHEN (@EmailText LIKE '%[%' OR @EmailText LIKE '%]%') THEN 0
                          WHEN @EmailText LIKE '%@%@%' THEN 0
                          WHEN @EmailText NOT LIKE '_%@_%._%' THEN 0
                          ELSE 1 
                      END;
					  
  RETURN @bitEmailVal;
  
END 
GO

--
-- How to use 
--

SELECT email, dbo.ChkValidEmail(email) AS Validity 
  FROM dbo.sample_emails;

