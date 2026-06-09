

CREATE PROCEDURE [dbo].[Internal_SQLAlerts]
(
	@IsDebug BIT = 1
)
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
			,@AddlQuery NVARCHAR(MAX), @IsQuerySet INT = 0 , @IsApplicable INT = 0, @FontColor VARCHAR(20) = '', @DefaultFontColor VARCHAR(20) = 'Green'

	DECLARE		@Message VARCHAR(100) = '' ,@Message1 VARCHAR(100) = 'All is Good', @Message2 VARCHAR(100) = 'Query Not Set'
				,@Message3 VARCHAR(100) = 'Not Applicable'
	
	SELECT		*
	INTO		#DBQuiries
	FROM		Internal_DBAlert_Queries
	WHERE		QueryKey IN (1,2,3,4,5)

	-- SELECT COUNT(1) FROM #DBQuiries

	WHILE(SELECT COUNT(1) FROm #DBQuiries) > 0
		BEGIN
			
			SET @TempMailBodyMiddle = ''
			SET @i = 1
			SET @n  = (SELECT COUNT(1) FROM #Tables)

			SELECT		TOP 1 @QueryKey = QueryKey,@HeaderText = Header1, @ColumnNames = ColumnNames
			FROM		#DBQuiries	
			ORDER BY	QueryKey 

			SET @MailBodyHeader = '<tr><td colspan="2" style="font-size:18px;font-weight:bold;font-style:italic; padding-top:30px;">' + @HeaderText + '</td></tr>'

			WHILE (@i <= @n)
				BEGIN
					SELECT	@Header = TableName1,@ContainerList = TableName2,@StopList = TableName3, @SiteID = SiteID FROM #Tables WHERE TableKey = @i

					IF(@QueryKey = 1)
						BEGIN
	
							SET		@IsQuerySet = CASE WHEN @SiteID IN ('Acer','Flexport','DHL','RObinson','CNB','KHNN','Melrose')  THEN 1 ELSE 0 END
							SET		@IsApplicable = 1
							
							SET		@Message = CASE WHEN @IsQuerySet = 1 THEN @Message1 ELSE @Message2 END							

							SET		@FontColor = CASE WHEN @IsQuerySet = 0 THEN 'Brown' ELSE @DefaultFontColor END
							SET		@FontColor = CASE WHEN @IsApplicable = 0 THEN 'Blue' ELSE @FontColor END

							IF(ISNULL(@IsQuerySet,0) = 1)
								BEGIN
									SET		@SQL1 = ' FROM		Integration_JCB.dbo.TMS_IntegrationFileProcessInfo F WITH (NOLOCK)
													LEFT JOIN	Integration_JCB.dbo.TMS_INTEGRATION_FILECONTENT FL ON F.FileProcessKey = FL.FileProcessKey
													LEFT JOIN	Integration_JCB.dbo.' + @Header + ' H WITH (NOLOCK) on F.FileProcessKey = H.FileProcessKey
													WHERE		siteid = '''+ @SiteID +  ''' and DateReceived > getdate() - 30 and  IsProcessed = 0 and h.DataKey is null 
													AND ISNULL(IsReturnFile,0) = 0  AND LEFT(JSONContent,19) <> ''{ "statusCode": 403''
													AND JSONContent IS NOT NULL AND ResponseType <> ''ERROR'''
									SET		@SQL2 = ' ORDER BY	DateReceived DESC'
								END
						END
					ELSE IF (@QueryKey IN (2)) -- 214  Process
						BEGIN
							SET		@IsQuerySet = CASE WHEN @SiteID IN ('DHL','Flexport','CNB','KHNN','RObinson','Century') THEN 1 ELSE 0 END
							SET		@IsApplicable = CASE WHEN @SiteID IN ('Melrose') THEN 0 ELSE 1 END

							SET		@Message = CASE WHEN @IsQuerySet = 1 THEN @Message1 ELSE @Message2 END
							SET		@Message = CASE WHEN @IsApplicable = 0 THEN @Message3 ELSE @Message END

							SET		@FontColor = CASE WHEN @IsQuerySet = 0 THEN 'Brown' ELSE @DefaultFontColor END
							SET		@FontColor = CASE WHEN @IsApplicable = 0 THEN 'Blue' ELSE @FontColor END

							-- SELECT CAST(@IsQuerySet  AS VARCHAR) + @SiteID

							IF(ISNULL(@IsQuerySet,0) = 1)
								BEGIN
									IF(@SiteID = 'DHL')
										BEGIN
											SET @AddlQuery = ' AND LocationType NOT IN (''RT'')'
										END
									ELSE IF(@SiteID = 'Flexport')
										BEGIN
											SET @AddlQuery = ' AND LocationType NOT IN (''RP'')'
										END
									ELSE IF(@SiteID = 'Century')
										BEGIN
											SET @AddlQuery = ' AND LocationType NOT IN (''RT'')'
										END
									ELSE IF(@SiteID IN ('CNB'))
										BEGIN
											SET @AddlQuery = ''
										END
									ELSE IF(@SiteID IN ('RObinson','KHNN','Melrose'))
										BEGIN
											SET @AddlQuery = ''
										END

									SET		@SQL1 = ' FROM	(SELECT			DISTINCT R.OrderKey,R.OrderDetailKey,CL.equipmentNumber AS ContainerNo,R.RouteKey,SL.stopNumber,R.LegKey,L.Description, RD.LocationType
																			,EmptySetDate,L.FromLocation,L.ToLocation
																			, isnull(isnull(R.PickupDateTo, R.PickupDateFrom),R.ActualDeparture) as SchedPickup
																			,isnull(isnull(R.DeliveryDateTo,R.DeliveryDateFrom),  R.ActualArrival) as SchedDelivery 
																			, R.ActualDeparture as ActualPickup				
																			,R.ActualArrival as ActualDelivery
																			,SL.ScheduledDateTime,Sl.ActualDateTime , R.LastUpdateDate, H.DataKey, ISNULL(R.IsDryRun ,0)IsDryRun
															FROM			(SELECT * FROM JCBDB_Live.dbo.Routes  WITH (NOLOCK) WHERE IsEmpty = 0) R
															INNER JOIn		Integration_JCB.dbo.' + @Header + ' DH WITH (NOLOCK) ON R.OrderKey = DH.TMS_OrderKey
															LEFT JOIN		JCBDB_Live.dbo.Leg L WITH (NOLOCK) ON R.LegKey = L.LegKey
															LEFT JOIN		JCBDB_Live.dbo.TKT_RouteDataNew RD WITH (NOLOCK) ON R.RouteKey = RD.RouteKey AND R.OrderKey = RD.OrderKey
															LEFT JOIN		(SELECT * FROM JCBDB_Live.dbo.TMS_Integration_Header  WITH (NOLOCK)
																			WHERE DataType IS NULL) H ON RD.OrderKey = H.TMS_OrderKey AND H.SiteID = ''' + @SiteID + '''
															LEFT JOIn		Integration_JCB.dbo.' + @ContainerList + ' CL WITH (NOLOCK) ON  H.DataKey = CL.DataKey
															LEFT JOIn		Integration_JCB.dbo.' + @StopList + ' SL WITH (NOLOCK) ON RD.LocationType =' + CASE WHEN @SiteID = 'KHNN' THEN 'SL.StopShortCode' ELSE 'SL.facilityCode' END + ' AND CL.ContainerKey = SL.ContainerKey
															)A
													WHERE	((LocationType IN (''ST'',''RT'') AND ActualDelivery IS NOT NULL AND ActualDateTime IS NULL) OR
															(LocationType IN (''ST'',''RT'') AND SchedDelivery IS NOT NULL AND ScheduledDateTime  IS NULL) OR
															(LocationType IN (''SF'',''RP'') AND ActualPickup IS NOT NULL AND ActualDateTime  IS NULL) OR
															(LocationType IN (''SF'',''RP'') AND SchedPickup IS NOT NULL AND ScheduledDateTime  IS NULL)OR
															(LocationType IN (''EP'') AND ActualPickup IS NOT NULL AND ActualDateTime  IS NULL) OR
															(LocationType IN (''ER'') AND EmptySetDate IS NOT NULL AND ActualDateTime  IS NULL))
															AND LastUpdateDate > getdate() - 30 AND stopNumber IS NOT NULL AND IsDryRun = 0 '  + ISNULL(@AddlQuery,'')
									SET		@SQL2 = ' Order By		OrderKey DESC'
								END
						END
					ELSE IF (@QueryKey  = 3) -- 210 Process
						BEGIN	

							SET		@IsQuerySet = CASE WHEN @SiteID IN ('Acer') THEN 1 ELSE 0 END
							SET		@IsApplicable = CASE WHEN @SiteID IN ('Melrose') THEN 0 ELSE 1 END

							SET		@Message = CASE WHEN @IsQuerySet = 1 THEN @Message1 ELSE @Message2 END
							SET		@Message = CASE WHEN @IsApplicable = 0 THEN @Message3 ELSE @Message END

							SET		@FontColor = CASE WHEN @IsQuerySet = 0 THEN 'Brown' ELSE @DefaultFontColor END
							SET		@FontColor = CASE WHEN @IsApplicable = 0 THEN 'Blue' ELSE @FontColor END

							IF(ISNULL(@IsQuerySet,0) = 1)
								BEGIN
									SET		@AddlQuery = ''
									SET		@SQL1 = 'FROM		(SELECT * FROM InvoiceHeader) IH 
													LEFT JOIN	Integration_JCB.dbo.ACER_InvoiceHeader AIH ON IH.InvoiceKey = AIH.InvoiceKey
													LEFT JOIN	OrderHeader OH ON IH.OrderKey = OH.OrderKey 
													LEFT JOIN	OrderDetail OD ON OH.OrderKey = OD.OrderKey
													LEFT JOIN	Integration_JCB.dbo.ACER_ContainerList CL ON AIH.DataKey = CL.DataKey  AND AIH.ContainerNo = CL.equipmentNumber 
													WHERE		IH.CustKey = 3165    AND ISNULL(AIH.Is210Sent,0) = 0 AND CL.ContainerKey IS NOT NULL'  + ISNULL(@AddlQuery,'')
									SET		@SQL2 = ' ORDER BY IH.InvoiceDate '
								END
						END
					ELSE IF (@QueryKey  = 4) -- POD Process
						BEGIN	

							SET		@IsQuerySet = CASE WHEN @SiteID IN ('DHL') THEN 1 ELSE 0 END
							SET		@IsApplicable = 1

							SET		@Message = CASE WHEN @IsQuerySet = 1 THEN @Message1 ELSE @Message2 END
							SET		@Message = CASE WHEN @IsApplicable = 0 THEN @Message3 ELSE @Message END

							SET		@FontColor = CASE WHEN @IsQuerySet = 0 THEN 'Brown' ELSE @DefaultFontColor END
							SET		@FontColor = CASE WHEN @IsApplicable = 0 THEN 'Blue' ELSE @FontColor END

							IF(ISNULL(@IsQuerySet,0) = 1)
								BEGIN
									SET		@AddlQuery = 'AND Shortcode = ''POD'''
									SET		@SQL1 = ' FROM		Integration_JCB.dbo.DHL_Header H
													INNER JOIN	Integration_JCB.dbo.TMS_IntegrationFileProcessInfo F on H.FileProcessKey = F.FileProcessKey
													INNER JOIN	Integration_JCB.dbo.DHL_ContainerList C on H.DataKey = C.DataKey
													INNER JOIN	Integration_JCB.dbo.DHL_StopList S on C.ContainerKey = S.ContainerKey
													INNER JOIN	JCBDB_LIVE.dbo.OrderDetail od ON H.TMS_OrderKey = OD.OrderKey
													INNER JOIN	JCBDB_LIVE.dbo.TMS_INTEGRATION_CONTAINER IC ON OD.OrderDetailKey = IC.TMS_OrderDetailKey
													INNER JOIN	JCBDB_LIVE.dbo.ContainerDocuments ODC ON od.OrderDetailKey = ODC.OrderDetailKey
													INNER JOIN	JCBDB_LIVE.dbo.Document D ON ODC.DocumentKey = D.DocumentKey
													INNER JOIN	JCBDB_LIVE.dbo.DocumenType DT ON D.DocumentType = DT.DocumentTypeKey
													WHERE		isnull(H.TMS_OrderKey,0) > 0 and ISNULL(TMS_RouteKey,0) > 0 
																and isnull(S.IsActualSent,0) = 1  and isnull(S.IsScheduleSent,0) = 1
																and isnull(S.IsDocSent,0) = 0 AND TMS_RouteKey = ODC.ROUTEKEY 
																and S.ActualDateTime > getdate() - 30'  + ISNULL(@AddlQuery,'')
									SET		@SQL2 = ' ORDER BY	H.DataKey desc '
								END
						END
					ELSE IF (@QueryKey  = 5) -- Multiple Containers on one Invoice
						BEGIN	

							SET		@IsQuerySet = CASE WHEN @SiteID IN ('ACER') THEN 1 ELSE 0 END
							SET		@IsApplicable = CASE WHEN @SiteID IN ('Flexport','DHL','Robinson','CNB','KHNN','Melrose') THEN 0 ELSE 1 END

							SET		@Message = CASE WHEN @IsQuerySet = 1 THEN @Message1 ELSE @Message2 END
							SET		@Message = CASE WHEN @IsApplicable = 0 THEN @Message3 ELSE @Message END

							SET		@FontColor = CASE WHEN @IsQuerySet = 0 THEN 'Brown' ELSE @DefaultFontColor END
							SET		@FontColor = CASE WHEN @IsApplicable = 0 THEN 'Blue' ELSE @FontColor END

							IF(ISNULL(@IsQuerySet,0) = 1)
								BEGIN
									SET		@AddlQuery = 'AND IH.InvoiceDate > ''2024-08-06 00:00:00.000''' 
									SET		@SQL1 = ' FROM		Integration_JCB.dbo.ACER_InvoiceHeader  IH
													INNER JOIN	Integration_JCB.dbo.ACER_Header H ON IH.DataKey = H.DataKey
													LEFT JOIN	Integration_JCB.dbo.ACER_ContainerList CL On H.DataKey = Cl.DataKey AND IH.ContainerNo = Cl.equipmentNumber
													LEFT JOIN	Integration_JCB.dbo.ACER_210DocData DD On H.Datakey = DD.DataKey  AND IH.InvoiceKey = DD.InvoiceKey 
													WHERE		Cl.ContainerKey IS NULL ' + ISNULL(@AddlQuery,'')
									SET		@SQL2 = ' ORDER By	IH.InvoiceKey DESC '
								END
						END
					
					SET		@SQLCOUNT = 'SELECT		COUNT(1) ' + @SQL1  
					SET		@SQLCOLUMNS = @ColumnNames  + @SQL1 + @SQL2
					
					IF(@IsQuerySet = 1)
						BEGIN
							INSERT INTO #DataCount
							EXEC		(@SQLCOUNT)							
						END

					
					
					DECLARE @DataCount INT = (SELECT * FROM #DataCount)
					-- PRINT	(@SQLCOLUMNS) 
					IF (@DataCount > 0 AND @IsQuerySet = 1)
						BEGIN
							PRINT	(@SQLCOLUMNS) 
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<tr><td style="border: 1px solid #ccc; width:10%;">' + @SiteID + '</td> <td   style="color:Red; font-weight:bold;border: 1px solid #ccc;"> There are Issues : Count(' + CAST(@DataCount AS VARCHAR) + ') -   <u><i>Refer Query Below</i> </u> </br>'
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<font size="2" style="color:Black; font-weight:Normal;"  >' + @SQLCOLUMNS + '</font></td></tr>'
						END
					ELSE
						BEGIN
							SET		@TempMailBodyMiddle = ISNULL(@TempMailBodyMiddle,'') + '<tr><td  style="border: 1px solid #ccc; width:10%;">' + @SiteID + '</td><td   style="color:'+ @FontColor + '; font-weight:bold; border: 1px solid #ccc;">' + @Message + '</td></tr>'
						END

					TRUNCATE TABLE #DataCount				


					SET		@i = @i + 1
				END
			SELECT @QueryKey
			DELETE FROM #DBQuiries WHERE QueryKey = @QueryKey

			SET @MailBodyMiddle = @MailBodyMiddle + @MailBodyHeader + @TempMailBodyMiddle

			

			-- SELECT COUNT(1) FROM #DBQuiries
		END

		If(@IsDebug = 1)
				BEGIN
					DECLARE @HTMl NVARCHAR(MAX), @Hours INT = 48
					EXEC Integration_JCB.dbo.Internal_SQLAlerts_IntegrationErrors @Hours, @HTML OUTPUT
					--SELECT @HTMl
					SET @HTMl = ' <br/> <br/> <div  style="font-size:18px;font-weight:bold;font-style:italic; padding-top:30px;"> Error Logs (Past '+ CAST(@Hours AS VARCHAR) + ' Hours) </div>' + @HTML  
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

	SET @MailBodyLast = '</table>' + ISNULL(@HTMl,'') + 
						'</body>
						</html>'

	SET @FinalBody = @MailBodyFirst + @MailBodyMiddle + @MailBodyLast

	DECLARE @CC VARCHAR(50) = 'roshancrasto@trikaiser.com'

	IF(@IsDebug = 0)
		BEGIN
			SET @CC = 'shiva@trikaiser.com'
		END

	EXEC	msdb.dbo.sp_send_dbmail
			@profile_name = 'DB Admin Profile'
			,@recipients = 'roshancrasto@trikaiser.com'
			,@copy_recipients = @CC
			,@subject = 'Integration SQL DB Alerts'
			,@body = @FinalBody
			,@body_format = 'HTML'
			,@importance ='HIGH'

	DROP TABLE #Tables
	DROP TABLE #DataCount
	DROP TABLE #DBQuiries


END