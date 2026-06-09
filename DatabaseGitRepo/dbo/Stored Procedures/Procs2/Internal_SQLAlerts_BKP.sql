

CREATE PROCEDURE [dbo].[Internal_SQLAlerts_BKP]

AS

BEGIN
	DECLARE @SQL1 NVARCHAR(MAX),@SQL2 NVARCHAR(MAX), @SQLCOUNT NVARCHAR(MAX), @SQLCOLUMNS NVARCHAR(MAX)

	CREATE TABLE #DataCount
	(
		DataCount INT
	)

	SELECT		*
	INTO		#Tables
	FROM		Internal_DBAlert_TableNames

	DECLARE @i INT = 1 , @n INT = (SELECT COUNT(1) FROM #Tables), @Header VARCHAR(100), @ContainerList VARCHAR(100), @StopList VARCHAR(100), @SiteID VARCHAR(20)

	DECLARE @MailBodyFirst NVARCHAR(MAX), @MailBodyLast NVARCHAR(MAX), @MailBodyMiddle NVARCHAR(MAX) = '', @MailBodyHeader NVARCHAR(MAX)
			, @FinalBody NVARCHAR(MAX),  @TempMailBodyMiddle NVARCHAR(MAX), @HeaderText VARCHAR(2000), @QueryKey	INT, @ColumnNames VARCHAR(1000)
			,@AddlQuery NVARCHAR(MAX)

	DECLARE		@Message VARCHAR(100) = '' ,@Message1 VARCHAR(100) = 'All is Good', @Message2 VARCHAR(100) = 'Query Not Set'
	
	SELECT		*
	INTO		#DBQuiries
	FROM		Internal_DBAlert_Queries 

	-- SELECT COUNT(1) FROM #DBQuiries

	WHILE(SELECT COUNT(1) FROm #DBQuiries) > 0
		BEGIN
			
			SET @TempMailBodyMiddle = ''
			SET @i = 1
			SET @n  = (SELECT COUNT(1) FROM #Tables)

			SELECT		TOP 1 @QueryKey = QueryKey,@HeaderText = Header1, @ColumnNames = ColumnNames
			FROM		#DBQuiries	
			
			-- SELECT @QueryKey,@HeaderText,@ColumnNames

			SET @MailBodyHeader = '<tr><td colspan="2" style="font-size:18px;font-weight:bold;font-style:italic; padding-top:30px;">' + @HeaderText + '</td></tr>'

			WHILE (@i <= @n)
				BEGIN
					SELECT	@Header = TableName1,@ContainerList = TableName2,@StopList = TableName3, @SiteID = SiteID FROM #Tables WHERE TableKey = @i

					IF(@QueryKey = 1)
						BEGIN
							SET		@Message = CASE WHEN @SiteID IN ('Acer','Flexport','DHL','RObinson','CNB','KHNN','Melrose') THEN @Message1 ELSE @Message2 END
							SET		@SQL1 = ' FROM		Integration_JCB.dbo.TMS_IntegrationFileProcessInfo F
											LEFT JOIN	Integration_JCB.dbo.' + @Header + ' H on F.FileProcessKey = H.FileProcessKey
											WHERE		siteid = '''+ @SiteID +  ''' and DateReceived > getdate() - 30 and  IsProcessed = 0 and h.DataKey is null 
											AND ISNULL(IsReturnFile,0) = 0 '
							SET		@SQL2 = ' ORDER BY	DateReceived DESC'
						END
					ELSE IF (@QueryKey IN (2,3))
						BEGIN
							SET		@Message = CASE WHEN @SiteID IN ('Acer','Flexport','DHL','RObinson','CNB','KHNN','Melrose') THEN @Message1 ELSE @Message2 END

							IF(@SiteID = 'Robinson')
								BEGIN
									SET @AddlQuery = ' AND SL.facilityCode NOT IN (''SF'',''ST'',''RP'',''RT'')'
								END
							ELSE IF(@SiteID = 'DHL')
								BEGIN
									SET @AddlQuery = ' AND SL.facilityCode NOT IN (''RT'')'
								END

							SET		@SQL1 = 'FROM		Integration_JCB.dbo.' + @Header + ' H
											INNER JOIN	Integration_JCB.dbo.' + @ContainerList + ' CL on H.DataKey = CL.DataKey
											INNER JOIN	Integration_JCB.dbo.' + @StopList + ' SL on CL.ContainerKey = SL.ContainerKey
											INNER JOIN	JCBDB_Live.dbo.OrderHeader OH on H.TMS_OrderKey = OH.OrderKey
											INNER JOIN	JCBDB_Live.dbo.orderdetail OD on OH.OrderKey = OD.OrderKey and CL.TMSOrderDetailKey = OD.OrderDetailKey
											INNER JOIN	JCBDB_Live.dbo.Routes RT on RT.OrderDetailKey = Od.OrderDetailKey and SL.TMS_RouteKey = Rt.RouteKey
											WHERE		isnull(IsActualSent,0) = 0 and ' +  
														CASE @QueryKey WHEN   2 THEN 'Rt.ActualArrival'
														WHEN 3 THEN 'Rt.ActualDeparture' ELSE '' END
														+ ' is not null and RT.LastUpdateDate > getdate() - 30
														and	cl.equipmentNumber is not null '  + ISNULL(@AddlQuery,'')
							SET		@SQL2 = ' ORDER BY CL.equipmentNumber'
						END
					ELSE IF (@QueryKey  = 4)
						BEGIN	
							SET		@Message = CASE WHEN @SiteID IN ('Acer') THEN @Message1 ELSE @Message2 END

							SET		@AddlQuery = ''
							SET		@SQL1 = 'FROM		(SELECT * FROM InvoiceHeader) IH 
									LEFT JOIN	Integration_JCB.dbo.ACER_InvoiceHeader AIH ON IH.InvoiceKey = AIH.InvoiceKey
									LEFT JOIN	OrderHeader OH ON IH.OrderKey = OH.OrderKey 
									LEFT JOIN	OrderDetail OD ON OH.OrderKey = OD.OrderKey
									LEFT JOIN	Integration_JCB.dbo.ACER_ContainerList CL ON AIH.DataKey = CL.DataKey  AND AIH.ContainerNo = CL.equipmentNumber 
									WHERE		IH.CustKey = 3165    AND ISNULL(AIH.Is210Sent,0) = 0 AND CL.ContainerKey IS NOT NULL'  + ISNULL(@AddlQuery,'')
							SET		@SQL2 = ' IH.InvoiceDate '
						END

					SET		@SQLCOUNT = 'SELECT		COUNT(1) ' + @SQL1
					SET		@SQLCOLUMNS = @ColumnNames  + @SQL1 + @SQL2
		
					INSERT INTO #DataCount
					EXEC	(@SQLCOUNT)
					PRINT	(@SQLCOLUMNS) 
					
					DECLARE @DataCount INT = (SELECT * FROM #DataCount)

					IF @DataCount > 0
						BEGIN
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<tr><td style="border: 1px solid #ccc; width:10%;">' + @SiteID + '</td> <td   style="color:Red; font-weight:bold;border: 1px solid #ccc;"> There are Issues : Count(' + CAST(@DataCount AS VARCHAR) + ') -   <u><i>Refer Query Below</i> </u> </br>'
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<font size="2" style="color:Black; font-weight:Normal;"  >' + @SQLCOLUMNS + '</font></td></tr>'
						END
					ELSE
						BEGIN
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<tr><td  style="border: 1px solid #ccc; width:10%;">' + @SiteID + '</td><td   style="color:green; font-weight:bold; border: 1px solid #ccc;">' + @Message + '</td></tr>'
						END

					TRUNCATE TABLE #DataCount				


					SET		@i = @i + 1
				END
			SELECT @QueryKey
			DELETE FROM #DBQuiries WHERE QueryKey = @QueryKey

			SET @MailBodyMiddle = @MailBodyMiddle + @MailBodyHeader + @TempMailBodyMiddle

			-- SELECT COUNT(1) FROM #DBQuiries
		END

		SELECT		@MailBodyMiddle

	SET @MailBodyFirst = '<!DOCTYPE html>
					<html>
					<head>
						<meta charset="utf-8" />
						<title></title>
					</head>
					<body>
						<table cellpadding="8" cellspacing="0" border="0">
							'

	SET @MailBodyLast = '</table>
						</body>
						</html>'

	SET @FinalBody = @MailBodyFirst + @MailBodyMiddle + @MailBodyLast

	EXEC	msdb.dbo.sp_send_dbmail
			@profile_name = 'DB Admin Profile'
			--,@from_address = @fromEmail
			,@recipients = 'roshancrasto@trikaiser.com'
			,@copy_recipients = 'roshancrasto@trikaiser.com'
			,@subject = 'Test Mail'
			,@body = @FinalBody
			,@body_format = 'HTML'
			,@importance ='HIGH'

	DROP TABLE #Tables


END