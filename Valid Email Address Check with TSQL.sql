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
    
	DECLARE @bit_email_val AS BIT;
	DECLARE @email_text    AS VARCHAR(100);

		SET @email_text    = LTRIM(RTRIM(ISNULL(@email, '')));
        SET @bit_email_val = CASE WHEN (@email_text = '') THEN 0
								  WHEN (@email_text LIKE '% %') THEN 0
								  WHEN (@email_text LIKE ('%["(),:;<>\]%')) THEN 0
								  WHEN (SUBSTRING(@email_text,CHARINDEX('@',@email_text),LEN(@email_text)) LIKE ('%[!#$%&*+/=?^`_{|]%')) THEN 0
								  WHEN ((LEFT(@email_text,1) LIKE ('[-_.+]') OR RIGHT(@email_text,1) LIKE ('[-_.+]'))) THEN 0                                                                                    
								  WHEN ((@email_text LIKE '%[%' OR @email_text LIKE '%]%')) THEN 0
								  WHEN (@email_text LIKE '%@%@%') THEN 0
								  WHEN (@email_text NOT LIKE '_%@_%._%') THEN 0
								  ELSE 1 
							  END;
					  
	RETURN @bit_email_val;
  
END 
GO

--
-- How to use 
--

SELECT email, dbo.ChkValidEmail(email) AS Validity 
  FROM dbo.sample_emails;

