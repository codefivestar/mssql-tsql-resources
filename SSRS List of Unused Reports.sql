USE ReportServer 
GO 
DECLARE @NotUsedDays INT 
 
SELECT @NotUsedDays = 30 
 
SELECT Name,Path,LastUsedDate,NotUsedsince=DATEDIFF(DD,LastUsedDate,GETDATE()) 
  FROM dbo.catalog C 
  JOIN ( 
          SELECT ReportID,LastUsedDate= MAX(timestart)  
            FROM dbo.executionlog 
           GROUP BY ReportID 
       ) E 
    ON C.ItemID = E.ReportID 
 WHERE DATEDIFF(DD,LastUsedDate,GETDATE()) >= @NotUsedDays 
 ORDER BY NotUsedsince ASC