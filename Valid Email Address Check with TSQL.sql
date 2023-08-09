SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--=========================================================================================================
-- Autor          : Hidequel Puga
-- Fecha          : 2023-07-10
-- Descripción    : Check if email address is valid
-- Requerimiento  : #NoTkts #DBA #DBAWorks #DBARules
-- Modo de uso    : email1@example.com (valid)
--                  email1@example.com;email2@example.com (valid)
--                  email1@example.com;email2@example.com;erroremailexample.com (no valid)
--=========================================================================================================
ALTER FUNCTION [mail].[CheckIsValidEmail]
(
	@emails NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN

	DECLARE @email         NVARCHAR(255)
	      , @regex_pattern VARCHAR(100)
	      , @is_valid      BIT = 'True'

        SET @regex_pattern = '%[a-zA-Z0-9._-][@][A-Z0-9]%[.][A-Z0-9]%'

	WHILE CHARINDEX(';', @emails) > 0
		BEGIN
		
			SET @email  = LEFT(@emails, CHARINDEX(';', @emails) - 1);
			SET @emails = RIGHT(@emails, LEN(@emails) - CHARINDEX(';', @emails));

			IF (
						(@email LIKE @regex_pattern)         -- Esta condición utiliza un patrón de expresión regular para validar la dirección de correo electrónico
					AND @email NOT LIKE '%@%@%'              -- Esta condición verifica que no haya múltiples símbolos de arroba (@) en la dirección de correo electrónico
					AND CHARINDEX('.@', @email) = 0          -- Esta condición verifica que no haya un punto (.) seguido de un arroba (@) en la dirección de correo electrónico.
					AND CHARINDEX('..', @email) = 0          -- Esta condición verifica que no haya dos puntos (.) seguidos en la dirección de correo electrónico.
					AND CHARINDEX(',', @email) = 0           -- Esta condición verifica que no haya una coma (,) en la dirección de correo electrónico. 
					AND RIGHT(@email, 1) BETWEEN 'a' AND 'z' -- Esta condición verifica que la última letra de la dirección de correo electrónico esté entre 'a' y 'z'. 
					AND (@email NOT LIKE '% %')              -- Esta condición verifica que no haya espacios en blanco en la cadena de correo electrónico.
					AND (@email NOT LIKE ('%["(),:;<>\$]%')) -- Esta condición verifica que la dirección de correo electrónico no contenga caracteres especiales específicos.
					AND (SUBSTRING(@email, CHARINDEX('@', @email), LEN(@email)) NOT LIKE (('%[¡!#$&*+/=¿?^`{:};|\"<>~(,)]%'))) -- Esta condición verifica que el dominio de la dirección de correo electrónico no contenga caracteres especiales específicos.
					AND ((@email NOT LIKE '%[%') OR (@email NOT LIKE '%]%')) -- Esta condición verifica que la dirección de correo electrónico no contenga los caracteres '[' o ']'. 
			   ) 
				BEGIN
					SET @is_valid = @is_valid & 'True'
				END
			ELSE
				BEGIN
					SET @is_valid = @is_valid & 'False'
				END
		END

		-- Validar la última dirección de correo (sin punto y coma al final)
			IF (
						(@emails LIKE @regex_pattern)         -- Esta condición utiliza un patrón de expresión regular para validar la dirección de correo electrónico
					AND @emails NOT LIKE '%@%@%'              -- Esta condición verifica que no haya múltiples símbolos de arroba (@) en la dirección de correo electrónico
					AND CHARINDEX('.@', @emails) = 0          -- Esta condición verifica que no haya un punto (.) seguido de un arroba (@) en la dirección de correo electrónico.
					AND CHARINDEX('..', @emails) = 0          -- Esta condición verifica que no haya dos puntos (.) seguidos en la dirección de correo electrónico.
					AND CHARINDEX(',', @emails) = 0           -- Esta condición verifica que no haya una coma (,) en la dirección de correo electrónico. 
					AND RIGHT(@emails, 1) BETWEEN 'a' AND 'z' -- Esta condición verifica que la última letra de la dirección de correo electrónico esté entre 'a' y 'z'. 
					AND (@emails NOT LIKE '% %')              -- Esta condición verifica que no haya espacios en blanco en la cadena de correo electrónico.
					AND (@emails NOT LIKE ('%["(),:;<>\$]%')) -- Esta condición verifica que la dirección de correo electrónico no contenga caracteres especiales específicos.
					AND (SUBSTRING(@emails, CHARINDEX('@', @emails), LEN(@emails)) NOT LIKE (('%[¡!#$&*+/=¿?^`{:};|\"<>~(,)]%'))) -- Esta condición verifica que el dominio de la dirección de correo electrónico no contenga caracteres especiales específicos.
					AND ((@emails NOT LIKE '%[%') OR (@emails NOT LIKE '%]%')) -- Esta condición verifica que la dirección de correo electrónico no contenga los caracteres '[' o ']'. 
			   ) 
				BEGIN
					SET @is_valid = @is_valid & 'True'
				END
			ELSE
				BEGIN
					SET @is_valid = @is_valid & 'False'
				END

	RETURN @is_valid

END
GO
