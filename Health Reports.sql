
/* SERVER AND INSTANCE STATUS */

DECLARE @DatabaseServerInformation  AS NVARCHAR(MAX);
DECLARE @Hostname                   AS VARCHAR(50);
DECLARE @Version                    AS VARCHAR(MAX);
DECLARE @Edition                    AS VARCHAR(50); 
DECLARE @IsClusteredInstance        AS VARCHAR(50); 
DECLARE @IsInstanceinSingleUserMode AS VARCHAR(50);

 SELECT @Hostname = CONVERT(VARCHAR(50), @@SERVERNAME)
      , @Version  = CONVERT(VARCHAR(MAX), @@VERSION)
      , @Edition  = CONVERT(VARCHAR(50), SERVERPROPERTY('edition'))
	  , @IsClusteredInstance = CASE SERVERPROPERTY('IsClustered') 
								 WHEN 1 THEN 'Clustered Instance'
								 WHEN 0 THEN 'Non Clustered instance'
								 ELSE 'null'
							   END
	  , @IsInstanceinSingleUserMode = CASE SERVERPROPERTY('IsSingleUser')
										 WHEN 1 THEN 'Single user'
										 WHEN 0 THEN 'Multi user'
										 ELSE 'null'
									   END;
									   
/*HTML Table with variables*/
    SET @DatabaseServerInformation = '<font face="Verdana" size="4">Server Info</font>  
									  <table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="90%" id="AutoNumber1" height="50">  
									  <tr>  
										  <td width="27%" height="22" bgcolor="#D3D3D3"><b><font face="Verdana" size="2" color="#FFFFFF">Host Name</font></b></td>  
										  <td width="39%" height="22" bgcolor="#D3D3D3"><b><font face="Verdana" size="2" color="#FFFFFF">SQL Server version</font></b></td>  
										  <td width="90%" height="22" bgcolor="#D3D3D3"><b><font face="Verdana" size="2" color="#FFFFFF">SQL Server edition</font></b></td> 
										  <td width="90%" height="22" bgcolor="#D3D3D3"><b><font face="Verdana" size="2" color="#FFFFFF">Failover Clustered Instance</font></b></td> 
										  <td width="90%" height="22" bgcolor="#D3D3D3"><b><font face="Verdana" size="2" color="#FFFFFF">Single User mode</font></b></td> 
									  </tr>  
 									  <tr>  
										<td width="27%" height="27"><font face="Verdana" size="2">' + @Hostname + '</font></td>  
										<td width="39%" height="27"><font face="Verdana" size="2">' + @Version + '</font></td>  
										<td width="90%" height="27"><font face="Verdana" size="2">' + @Edition + '</font></td>
										<td width="90%" height="27"><font face="Verdana" size="2">' + @IsClusteredInstance + '</font></td>
										<td width="90%" height="27"><font face="Verdana" size="2">' + @IsInstanceinSingleUserMode + '</font></td>
									  </tr>  
									</table>';

/** SERVER AND INSTANCE STATUS **/

