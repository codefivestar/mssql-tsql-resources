----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- EMail           : codefivestqar@gmail.com
-- Date            : 2020-06-19
-- Description     : Script for replace character on transaction   
----------------------------------------------------------------------------------------------------------
----------------------------------------
-- Characters to replace with white space : 
----------------------------------------
--
--        / \ : * ? " < > |
--
----------------------------------------
-- Other :
----------------------------------------
--
--		# --> Ñ
--
----------------------------------------
-- More : https://www.w3schools.com/charsets/ref_html_ascii.asp#:~:text=ASCII%20is%20a%207%2Dbit,Z%2C%20and%20some%20special%20characters.
----------------------------------------

SELECT ColumnName 
	 , LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
	   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ColumnName, '/', ''), '\', ''), ':', ''), '*', ''), '?', ''), '"', ''), '<', ''), '>', ''), '|', ''), '#', 'Ñ'), ',',''), '.', ''))) AS TableName
  FROM [dbo].[TableName];