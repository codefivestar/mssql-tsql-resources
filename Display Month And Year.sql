SET LANGUAGE  'spanish';

DECLARE @table TABLE
(
      fechaDesde DATETIME
    , fechaHasta DATETIME
); 

INSERT @table 
VALUES('20151231', '20161231');
  WITH x AS 
     (
        SELECT   DATEADD( m , 1 ,fechaDesde ) as fecha  FROM @table
     UNION ALL
        SELECT  DATEADD( m , 1 ,fecha )
          FROM @table t 
    INNER JOIN x 
            ON DATEADD( m, 1, x.fecha) <= t.fechaHasta
      )

SELECT LEFT( CONVERT( VARCHAR, fecha , 112 ) , 6 ) as Periodo_Id 
     , DATEPART ( dd, DATEADD(dd,-(DAY(fecha)-1),fecha)) Num_Dia_Inicio
     , DATEADD(dd,-(DAY(fecha)-1),fecha) Fecha_Inicio
     , DATEPART ( mm , fecha ) Mes_Id
     , DATEPART ( yy , fecha ) Anio
     , DATEPART ( dd, DATEADD(dd,-(DAY(DATEADD(mm,1,fecha))),DATEADD(mm,1,fecha))) Num_Dia_Fin
     , DATEADD(dd,-(DAY(DATEADD(mm,1,fecha))),DATEADD(mm,1,fecha)) ultimoDia
     , datename(MONTH, fecha) mes
     , 'Q' + convert(varchar(10),  DATEPART(QUARTER, fecha)) Trimestre_Name
 FROM x OPTION(MAXRECURSION 0);