DECLARE @email_recipients      NVARCHAR(1000);
DECLARE @email_copy_recipients NVARCHAR(1000);
DECLARE @email_subject         NVARCHAR(1000);
DECLARE @email_profile         NVARCHAR(1000);
DECLARE @html_table            NVARCHAR(MAX);
DECLARE @html_all              NVARCHAR(MAX);
DECLARE @email_from            NVARCHAR(MAX);

	SET @email_recipients      = '';
	SET @email_copy_recipients = '';
	SET @email_from            = '';
	SET @email_subject         = ''; 
	SET @email_profile         = '';
    SET @html_table            = N'<!DOCTYPE html>
									<html>
										<head>
											<style>
												body {
													font-family : Verdana, Geneva, sans-serif;
												}

												#notification {
													font-size: 13px;
													border-collapse: collapse;
													width: 500px;
												}

												#notification td, #notification th {
													border: 1px solid #ddd;
													padding: 4px;
												}

												#notification th {
													padding-top: 12px;
													padding-bottom: 12px;
													text-align: left;
													background-color: #FF0000;
													color: white;
												}

												p {
													font-size: 13px;
												}
											</style>
										</head>
										<body>'
									+ N'<h3></h3>' 
									+ N'<p></p>' 
									+ N'<table id="notification">' 
									+ N'<tr>' 
									+ N'<th></th>
										<th></th>
										<th></th>
										</tr>' 
									+ CAST((
											SELECT td = t.FECHA_CORTE
													, ''
													, td = t.NUM_CONTRATO
													, ''
													, td = COUNT(1)
												FROM AT_INVER_VALOR_lIBROS_temp t
											GROUP BY t.FECHA_CORTE, t.NUM_CONTRATO
												HAVING COUNT(1) > 1
													FOR XML PATH('tr')
													, TYPE
											) AS NVARCHAR(MAX)) 
									+ N'</table>
										<br>
										<br>
										<footer>
											<p></p>
											<p></p>
										</footer>
									</body>
								</html>';

	SET @html_all = ISNULL(@html_table, '');

	IF (@html_all <> '')
		BEGIN
					
			EXEC [msdb].[dbo].[sp_send_dbmail] @profile_name    = @email_profile
											 , @from_address    = @email_from
											 , @importance      = 'High'
											 , @recipients      = @email_recipients
											 , @copy_recipients = @email_copy_recipients
											 , @subject         = @email_subject
											 , @body_format     = 'HTML'
											 , @body            = @html_all;
													 
		END