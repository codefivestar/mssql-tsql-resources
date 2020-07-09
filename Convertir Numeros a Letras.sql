CREATE FUNCTION [dbo].[Convertir_Numeros_A_Letras]
(
	@Numero DECIMAL(18, 2)
)
RETURNS VARCHAR(180)
AS
BEGIN

	DECLARE @ImpLetra   VARCHAR(180);
	DECLARE @lnEntero   BIGINT
		  , @lcRetorno  VARCHAR(512)
		  , @lnTerna    BIGINT
		  , @lcMiles    VARCHAR(512)
		  , @lcCadena   VARCHAR(512)
		  , @lnUnidades BIGINT
		  , @lnDecenas  BIGINT
		  , @lnCentenas BIGINT
		  , @lnFraccion BIGINT;

	SELECT @lnEntero   = CAST(@Numero AS BIGINT)
		 , @lnFraccion = (@Numero - @lnEntero) * 100
		 , @lcRetorno  = ''
		 , @lnTerna    = 1;

	WHILE @lnEntero > 0
		BEGIN 
		
			SELECT @lcCadena   = '';
			SELECT @lnUnidades = @lnEntero % 10;
			SELECT @lnEntero   = CAST(@lnEntero / 10 AS BIGINT);
			SELECT @lnDecenas  = @lnEntero % 10;
			SELECT @lnEntero   = CAST(@lnEntero / 10 AS BIGINT);
			SELECT @lnCentenas = @lnEntero % 10;
			SELECT @lnEntero   = CAST(@lnEntero / 10 AS BIGINT);

			-- Unidades
			SELECT @lcCadena = CASE WHEN @lnUnidades = 1 THEN 'UN ' + @lcCadena
									WHEN @lnUnidades = 2 THEN 'DOS ' + @lcCadena
									WHEN @lnUnidades = 3 THEN 'TRES ' + @lcCadena
									WHEN @lnUnidades = 4 THEN 'CUATRO ' + @lcCadena
									WHEN @lnUnidades = 5 THEN 'CINCO ' + @lcCadena
									WHEN @lnUnidades = 6 THEN 'SEIS ' + @lcCadena
									WHEN @lnUnidades = 7 THEN 'SIETE ' + @lcCadena
									WHEN @lnUnidades = 8 THEN 'OCHO ' + @lcCadena
									WHEN @lnUnidades = 9 THEN 'NUEVE ' + @lcCadena
									ELSE @lcCadena
								END;

			-- Decenas
			SELECT @lcCadena = CASE WHEN @lnDecenas = 1 THEN 
															CASE @lnUnidades WHEN 0 THEN 'DIEZ '
																			 WHEN 1 THEN 'ONCE '
																			 WHEN 2 THEN 'DOCE '
																			 WHEN 3 THEN 'TRECE '
																			 WHEN 4 THEN 'CATORCE '
																			 WHEN 5 THEN 'QUINCE '
																			 WHEN 6 THEN 'DIECISEIS '
																			 WHEN 7 THEN 'DIECISIETE '
																			 WHEN 8 THEN 'DIECIOCHO '
																			 WHEN 9 THEN 'DIECINUEVE '
															 END
									WHEN @lnDecenas = 2 THEN 
															CASE @lnUnidades WHEN 0 THEN 'VEINTE '
																			 ELSE 'VEINTI' + @lcCadena
															 END
									WHEN @lnDecenas = 3 THEN 
															CASE @lnUnidades WHEN 0 THEN 'TREINTA '
																			 ELSE 'TREINTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 4 THEN 
															CASE @lnUnidades WHEN 0 THEN 'CUARENTA '
																			 ELSE 'CUARENTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 5 THEN 
															CASE @lnUnidades WHEN 0 THEN 'CINCUENTA '
																			 ELSE 'CINCUENTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 6 THEN
															CASE @lnUnidades WHEN 0 THEN 'SESENTA '
																			 ELSE 'SESENTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 7 THEN
															CASE @lnUnidades WHEN 0 THEN 'SETENTA '
																			 ELSE 'SETENTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 8 THEN
															CASE @lnUnidades WHEN 0 THEN 'OCHENTA '
																			 ELSE 'OCHENTA Y ' + @lcCadena
															 END
									WHEN @lnDecenas = 9 THEN
															CASE @lnUnidades WHEN 0 THEN 'NOVENTA '
																			 ELSE 'NOVENTA Y ' + @lcCadena
															 END
									ELSE @lcCadena
								END;

			-- Centenas
			SELECT @lcCadena = CASE 
			                        WHEN @lnCentenas = 1 AND @lnUnidades = 0 AND @lnDecenas = 0 THEN 'CIEN ' + @lcCadena
						            WHEN @lnCentenas = 1 AND NOT(@lnUnidades = 0 AND @lnDecenas = 0) THEN 'CIENTO ' + @lcCadena
									WHEN @lnCentenas = 2 THEN 'DOSCIENTOS ' + @lcCadena
									WHEN @lnCentenas = 3 THEN 'TRESCIENTOS ' + @lcCadena
									WHEN @lnCentenas = 4 THEN 'CUATROCIENTOS ' + @lcCadena
									WHEN @lnCentenas = 5 THEN 'QUINIENTOS ' + @lcCadena
									WHEN @lnCentenas = 6 THEN 'SEISCIENTOS ' + @lcCadena
									WHEN @lnCentenas = 7 THEN 'SETECIENTOS ' + @lcCadena
									WHEN @lnCentenas = 8 THEN 'OCHOCIENTOS ' + @lcCadena
									WHEN @lnCentenas = 9 THEN 'NOVECIENTOS ' + @lcCadena
									ELSE @lcCadena
								END;

			-- Analiza terna
			SELECT @lcCadena = CASE 
			                        WHEN @lnTerna = 1 THEN @lcCadena
									WHEN @lnTerna = 2 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) THEN @lcCadena + 'MIL '
									WHEN @lnTerna = 3 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) AND	@lnUnidades = 1 AND @lnDecenas = 0 AND @lnCentenas = 0 THEN @lcCadena + 'MILLON '
									WHEN @lnTerna = 3 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) AND NOT (@lnUnidades = 1 AND @lnDecenas = 0 AND @lnCentenas = 0) THEN @lcCadena + 'MILLONES '
									WHEN @lnTerna = 4 AND (@lnUnidades + @lnDecenas + @lnCentenas <> 0) THEN @lcCadena + 'MIL MILLONES DE '
									ELSE ''
								END

			-- Arma el retorno
			SELECT @lcRetorno = @lcCadena + @lcRetorno;
			SELECT @lnTerna   = @lnTerna + 1;
			
		END

	IF @lnTerna = 1
		SELECT @lcRetorno = 'CERO';
		   SET @lcRetorno = REPLACE(@lcRetorno, 'UN  MIL', 'MIL');
		   SET @lcRetorno = REPLACE(@lcRetorno, 'UNA', 'UNO');

	DECLARE @sFraccion VARCHAR(15);
		SET @sFraccion = '00' + LTRIM(CAST(@lnFraccion AS VARCHAR));

	SELECT @ImpLetra = RTRIM(@lcRetorno) + ' DOLARES CON ' + SUBSTRING(@sFraccion, LEN(@sFraccion) - 1, 2) + '/100';

	IF(SUBSTRING(@ImpLetra,CHARINDEX('M',@ImpLetra,1),14) = 'MILLON DOLARES')
		BEGIN
			SELECT @ImpLetra = REPLACE(@ImpLetra,'MILLON DOLARES', 'MILLON DE DOLARES')
		END
	ELSE IF (SUBSTRING(@ImpLetra,CHARINDEX('M',@ImpLetra,1),16) = 'MILLONES DOLARES')
		BEGIN
			SELECT @ImpLetra = REPLACE(@ImpLetra,'MILLONES DOLARES', 'MILLONES DE DOLARES')
		END

	RETURN @ImpLetra;
	
END;
