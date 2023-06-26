----------------------------------------------------------------------------------------------------------
-- Author      : Hidequel Puga
-- Date        : 2023-06-26
-- Description : Determine duration between two dates
----------------------------------------------------------------------------------------------------------

DECLARE @fecha_inicio DATETIME;
DECLARE @fecha_final  DATETIME;
DECLARE @duracion     INT;
DECLARE @horas        INT
      , @minutos      INT
	  , @segundos     INT;

    SET @fecha_inicio = '2023-06-26 07:31:52.000';
    SET @fecha_final  = '2023-06-26 09:11:19.000';
    SET @duracion     = DATEDIFF(SECOND, @fecha_inicio, @fecha_final);
    SET @horas        = (@duracion / 3600);
    SET @minutos      = (@duracion % 3600) / 60;
    SET @segundos     = (@duracion % 3600) % 60;

 SELECT @horas    AS Horas
      , @minutos  AS Minutos
      , @segundos AS Segundos;