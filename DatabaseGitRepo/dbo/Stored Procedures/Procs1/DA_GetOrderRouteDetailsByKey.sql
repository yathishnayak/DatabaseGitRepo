

/*
DECLARE @UserKey INT = 1726	, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @@IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSOnString = '[{"RouteKey": 886562}]'
EXEC DA_GetOrderRouteDetailsByKey @UserKey,@JSOnString,@Status OUTPUT, @@IntError OUTPUT, @Reason OUTPUT,@IsDebug
SELECT @Status,@@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_GetOrderRouteDetailsByKey]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"RouteKey": 490622}]',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT

)

AS
BEGIN
	SET @IsLogout = 0

	DECLARE @LogKey INT

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID, IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@FirebaseID,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

	IF(@IsDebug = 1)
		BEGIN
			SET @ValidateUser = 1
		END


	IF(@ValidateUser = 0)
		BEGIN
			SET @Status = 0
			SET @IntError = @FBInternalError
			SET @Reason = @FBExternalError
			SET @IsLogout = 1

			UPDATE DA_RequestResponseLogs
			SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout, UpdatedDate = GETDATE(), ReponseJSONString = NULL
			WHERE LogKey = @LogKey

			RETURN
		END
	-- validate
	
	

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @RouteKey		INT 
		DECLARE @GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError	VARCHAR(1000)
		DECLARE @IsUATServer BIT = 0, @Latitude FLOAT,@Longitude FLOAT



		IF(@@SERVERNAME = 'JCTDEV')
			BEGIN
				SET @IsUATServer = 1
			END

		IF (ISNULL(@JSONString,'') = '')
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'JSON String Cannot be Blank; '
			END
		ELSE IF(ISNULL(@UserKey,0) = 0)
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'UserKey Cannot be Blank'
			END
		ELSE
			BEGIN
				SELECT		@RouteKey = RouteKey,@Latitude = Latitude, @Longitude = Longitude
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									RouteKey		INT		'$.RouteKey',
									Latitude		FLOAT	'$.Latitude',
									Longitude		FLOAT	'$.Longitude'
								 )
				SET			@RouteKey = ISNULL(@RouteKey,0)
				SET			@Status = 1

				IF(@RouteKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'RouteKey Cannot be Null or 0'
					END
			END

		


		DECLARE @OrderDetailKey INT, @IsLinked BIT, @Leg1ChassisKey INT = 0, @Leg1ChassisNo VARCHAR(20) = ''
		SELECT @OrderDetailKey = OrderDetailKey FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey

		SELECT		*
		INTO		#Routes
		FROM		Routes WITH (NOLOCK)
		WHERE		RouteKey = @RouteKey OR OrderDetailKey = @OrderDetailKey


		-------------------INSERT RECORD IF RECORD IS MISSING IN DRIVERROUTEACCEPTANCE TABLE FOR PENDING RECORD--------------------------
		DECLARE @DriverKey INT = 0, @IsDriverAcceptanceRecordExists INT =0
		SET @DriverKey = (SELECT ISNULL(DriverKey,0) FROM #Routes WHERE RouteKey = @RouteKey )

		SET @IsDriverAcceptanceRecordExists = (SELECT COUNT(*) FROM DriverRouteAcceptance WHERE RouteKey = @RouteKey AND DriverKey = @DriverKey 
		and (Description = 'Pending' OR Description = 'accept') )

		IF(@IsDriverAcceptanceRecordExists = 0)
			BEGIN
				INSERT INTO DriverRouteAcceptance
							(RouteKey,Description,CreateDate,RejectReasonKey,RejectReasonDescr,CreateUserKey,DriverKey,ActionDate)
				SELECT		@RouteKey,'Pending',GETDATE(),0,'',@UserKey,@DriverKey,NULL
			END
		--------------------------------------------------------------------------------------------------------------------------


		SELECT @IsLinked = CASE WHEN ISNULL(LinkedContainer,'') = '' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END FROM #Routes  WHERE RouteKey = @RouteKey
		SELECT @Leg1ChassisKey = ChassisKey,@Leg1ChassisNo = ChassisNo FROM #Routes WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey
				AND ISNULL(LegNo,0) = 1

		--IF (ISNULL(@JSONString,'') = '')
		--	BEGIN
		--		SET	@Status = 0
		--		SET @InternalError = 'JSON String Cannot be Blank'
		--	END
		--ELSE IF(@RouteKey = 0)
		--	BEGIN
		--		SET	@Status = 0
		--		SET @InternalError = 'RouteKey Cannot be Null or 0'
		--	END


		IF(@Status = 0)
		BEGIN
			SET		@IntError = @InternalError
			SET		@Reason = @GenError
		END
		ELSE
		BEGIN
			
			INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
			SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

			CREATE TABLE  #ChargeData
			(
				ChargeDesc		VARCHAR(50),
				ItemKey			INT,
				OrderBy			INT
			)

			DECLARE		@LegType VARCHAR(10) = '', @LegID VARCHAR(50) = '', @ToLocation VARCHAR(20) = '', @FromLocation VARCHAR(20)
			SELECT		@LegType = ISNULL(RT.LegType,'') , @LegID = ISNULL(L.LegID,''), @ToLocation = L.ToLocation, @FromLocation = L.FromLocation
			FROM		#Routes RT WITH (NOLOCK) 
			INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
			WHERE		RouteKey = @RouteKey

			--DECLARE @WaitTImeKey INT = 0
			--IF(@FromLocation = 'Port')
			--	BEGIN
			--		SET @WaitTImeKey = 5
			--	END
			--ELSE
			--	BEGIN
			--		SET @WaitTImeKey = 162
			--	END

			INSERT INTO #ChargeData
			EXEC DA_GetChargeDataItems @FromLocation, @ToLocation

			CREATE TABLE  #DefaultDocType
			(
				DocType			VARCHAR(50),
				DefaultDocKey	INT,
				IsCompulsory	BIT
			)


			DECLARE @ChassisDefaultKey INT = 9, @ContainerDefaultKey INT = 9, @PickupDocsDefaultKey INT = 16,@DeliveryDocsDefaultKey INT = 15
			
			

			IF(@FromLocation = 'Shipper' )
				BEGIN
					SET @PickupDocsDefaultKey = 2
				END

			IF(@ToLocation IN ('Consignee','Customer') )
				BEGIN
					SET @DeliveryDocsDefaultKey = 2
				END

			INSERT INTO #DefaultDocType
			VALUES('Chassis',@ChassisDefaultKey,0),('Container',@ContainerDefaultKey,0),('PickupDocs',@PickupDocsDefaultKey,1),('DeliveryDocs',@DeliveryDocsDefaultKey,1)

			IF(@LegType = '')
				BEGIN		
					UPDATE	RT
					SET		LegType = CASE WHEN @LegID LIKE '%DROP%' THEN 'Drop' WHEN @LegID LIKE  '%LIVE%' THEN 'Live' ELSE '' END
					FROM	Routes RT
					WHERE	RouteKey = @RouteKey	
					
					IF(ISNULL(@ToLocation,'') IN ('Yard','Port'))
						BEGIN
							UPDATE	RT
							SET		LegType ='Drop' 
							FROM	Routes RT
							WHERE	RouteKey = @RouteKey
						END
				END

			DECLARE  @FileUploadURL	VARCHAR(200), @EditTime INT = 0
			SET @FileUploadURL = (SELECT ConfigValue1 FROM DA_ConfigValues WHERE ConfigKey = 1 )
			SET @EditTime = (SELECT ConfigValue1 FROM DA_ConfigValues WHERE ConfigKey = 2 )


			SELECT			DISTINCT L.FromLocation,L.ToLocation,OD.OrderDetailKey, ContainerNo, R.RouteKey, ISNULL(OD.SealNo,'')SealNo
							,CASE WHEN ISNULL(R.ChassisKey,0) = 0 THEN ISNULL(@Leg1ChassisKey,0) ELSE R.ChassisKey END AS ChassisKey
							,CASE WHEN ISNULL(R.ChassisNo,'') = '' THEN ISNULL(@Leg1ChassisNo,'') ElSE R.ChassisNo END AS ChassisNo
							,OD.ContainerSizeKey, CS.Description AS ContainerSize , ISNULL(IsDryRun,0)IsDryRun
							,OH.OrderDate, ISNULL(R.DriverKey,0)DriverKey , CAST(0 AS BIT) AS IsRejectable
							,R.ChargeNotes AS ChargeNotes , R.DriverInstructions   AS DriverNotes-- , ISNULL(NoWaitTIme,0) NoWaitTIme
							,AD.AddrName SourceAddrName,AD.Address1 SourceAdd1, AD.Address2 SourceAdd2, AD.City SourceCity, AD.State SourceState,AD.ZipCode SourceZip
							,AD1.AddrName DestAddrName,AD1.Address1 DestAdd1, AD1.Address2 DestAdd2, AD1.City DestCity, AD1.State DestState,AD1.ZipCode DestZip
							,ISNULL(R.ScheduledArrival,R.DeliveryDateTo)ScheduledArrival
							,ISNULL(ScheduledDeparture,'') AS  ScheduledDeparture
							,ISNULL(ScheduledPickupDate,'') AS  ScheduledPickupDate
							,ISNULL(R.ConfirmationNo,'') AS PickupConfirmationNo
							,ISNULL(DelConfirmationNo,'') AS DeliveryConfirmationNo
							, ISNULL(Oh.BrokerRefNo,'') AS CustomerNo
							,ISNULL(ActualArrival,'')ActualArrival, ISNULL(ActualDeparture,'')ActualDeparture 
							,CAST(CASE WHEN ISNULL(DRA1.Description,'') = 'Accept' THEN 1 ELSE 0 END  AS BIT) AS IsAccepted
							,CAST(CASE WHEN L.ToLocation = 'Yard' THEN 0 ELSE 1 END AS BIT) AS IsPickupDocsRequired 
							,CAST(CASE WHEN L.ToLocation = 'Yard' THEN 0 ELSE 1 END AS BIT) AS IsDeliveryDocsRequired
							,CAST(0 AS BIT) AS IsGetPaid
							,@FileUploadURL AS BaseFilePath,OT.OrderType
							--,ISNULL(R.PortWaitingTimeFrom,'')PortWaitingTimeFrom,ISNULL(R.PortWaitingTimeTo,'')PortWaitingTimeTo
							--,ISNULL(R.CustomerWaitingTimeFrom,'')CustomerWaitingTimeFrom,ISNULL(R.CustomerWaitingTimeTo,'')CustomerWaitingTimeTo
							,ISNULL(R.FromLocationWaitTimeFrom,'')FromLocationWaitTimeFrom,ISNULL(R.FromLocationWaitTimeTo,'')FromLocationWaitTimeTo
							,ISNULL(R.ToLocationWaitTimeFrom,'')ToLocationWaitTimeFrom,ISNULL(R.ToLocationWaitTimeTo,'')ToLocationWaitTimeTo							
							,ISNULL(R.LegType,'') LegType, R.Status AS RouteStatus, ASD.CompleteDate
							,CASE WHEN CC.ChassisCategory = 'JCT' OR (ISNULL(ChassisKey,0) <> 591 AND ISNULL(ChassisKey,0) > 0) THEN 'JCT' 
							WHEN CC.ChassisCategory IN ('Port','Customer') OR ISNULL(ChassisKey,0) = 591 THEN 'Other' ELSE '' END AS ChassisCategory
							,DRA1.AcceptanceKey
							,ISNULL(OD.BillOfLadding,OH.BillOfLading) AS MBLNo
							,ISNULL(CT.ContainerProperties,'') AS ContainerProperties
							, CAST(PickupNoWaitTIme AS BIT) AS PickupNoWaitTime, CAST(DeliveryNoWaitTime AS BIT) AS DeliveryNoWaitTime
				INTO		#Data
				FROM		OrderHeader OH WITH (NOLOCK)
				INNER JOIN	OrderDetail  OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
				INNER JOIN	OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
				LEFT JOIN	ContainerSize CS WITH (NOLOCK) ON OD.ContainerSizeKey = CS.ContainerSizeKey
				LEFT JOIN	#Routes  R WITH (NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
				LEFT JOIN	Leg L WITH (NOLOCK) ON R.LegKey = L.LegKey
				LEFT JOIN	Address AD WITH (NOLOCK) ON R.SourceAddrKey = AD.AddrKey
				LEFT JOIN	Address AD1 WITH (NOLOCK) ON R.DestinationAddrKey = AD1.AddrKey
				-- LEFT JOIN	DriverRouteAcceptance DRA WITH (NOLOCK) ON R.RouteKey = DRA.RouteKey AND R.DriverKey = DRA.DriverKey
				LEFT JOIN	(SELECT * FROM DriverRouteAcceptance  WITH (NOLOCK)  WHERE (Description = 'Pending' OR Description = 'accept'))  DRA1 ON R.RouteKey = DRA1.RouteKey AND R.DriverKey = DRA1.DriverKey
				LEFT JOIN	DA_AppDriverScreenDetails ASD WITH (NOLOCK) ON R.RouteKey = ASD.RouteKey
				LEFT JOIN	ChassisCategory CC ON R.ChassisCategoryKey = CC.ChassisCategoryKey
				LEFT JOIN	(SELECT		STRING_AGG(CT.TypeDescription, ',')  AS   ContainerProperties, OrderDetailKey
							FROM		ContainerTypesLink	CTL
							INNER JOIN	ContainerTypes CT ON CTL.ContainerTypeKey = CT.ContainerTypeKey
							GROUP BY	OrderDetailKey) CT ON OD.OrderDetailKey = CT.OrderDetailKey
 
				WHERE		R.RouteKey = @RouteKey   --  OD.OrderDetailKey = 49045
			
			IF(@IsDebug = 1)
				BEGIN
					SELECT * FROM #Data
				END


			SELECT	*
			INTO	#DA_ScreenDocumentTypeDropDownLink
			FROM	DA_ScreenDocumentTypeDropDownLink

			UPDATE #DA_ScreenDocumentTypeDropDownLink SET OrderBy = 0 WHERE ScreenName IN ('Container','Chassis') AND DocumentTypeKey = @ContainerDefaultKey
			UPDATE #DA_ScreenDocumentTypeDropDownLink SET OrderBy = 0 WHERE ScreenName IN ('PickupDocs') AND DocumentTypeKey = @PickupDocsDefaultKey
			UPDATE #DA_ScreenDocumentTypeDropDownLink SET OrderBy = 0 WHERE ScreenName IN ('DeliveryDocs') AND DocumentTypeKey = @DeliveryDocsDefaultKey


			SELECT		ROuteKey, ConfirmPickup,ConfirmEquipments,PickUpDocs,ConfirmDelivery,DeliveryDocs,PairContainer,Charges,Complete
			INTO		#DA_AppDriverScreenDetails
			FROM		DA_AppDriverScreenDetails
			WHERE		1 = 2

			IF((SELECT COUNT(*) FROM DA_AppDriverScreenDetails  WITH (NOLOCK) WHERE RouteKey = @RouteKey) = 0)
				BEGIN
					INSERT INTO	#DA_AppDriverScreenDetails
					SELECT	@RouteKey, 0 ConfirmPickup,0 ConfirmEquipments,0 PickUpDocs
							,0 ConfirmDelivery,0 DeliveryDocs,0 PairContainer,0 Charges	,0 Complete
				END
			ELSE
				BEGIN
					INSERT INTO	#DA_AppDriverScreenDetails
					SELECT	ROuteKey,ISNULL(ConfirmPickup,0)ConfirmPickup,ISNULL(ConfirmEquipments,0)ConfirmEquipments,ISNULL(PickUpDocs,0)PickUpDocs
							,ISNULL(ConfirmDelivery,0) ConfirmDelivery,ISNULL(DeliveryDocs,0)DeliveryDocs,ISNULL(PairContainer,0)PairContainer,ISNULL(Charges,0)Charges
							,ISNULL(Complete,0)Complete
					FROM	DA_AppDriverScreenDetails WITH (NOLOCK)
					WHERE	RouteKey = @RouteKey 
				END
			DECLARE @WaitTimeItemKey INT = 0
			SELECT TOP 1 @WaitTimeItemKey = Itemkey FROM OrderExpense
			WHERE RouteKey = @RouteKey AND Itemkey IN (162,5)

			DECLARE @JsonRes NVARCHAR(MAX)
			SET @JsonRes = (SELECT	*,							
							(SELECT RejectReasonKey,RejectReasonDescr,AllowEntry FROM RejectReasons  WITH (NOLOCK) 
							WHERE ReasonType = 'Reject' AND IsActive = 1
						    ORDER BY OrderBy FOR JSON PATH) AS RejectReasons
							,(SELECT ReasonCodeKey,   ReasonCode
							FROM DA_DriverReasonCodes FOR JSON PATH ) AS PortReasonCodes
								,(SELECT chassisKey,chassisNo FROM Chassis  WITH (NOLOCK)  FOR JSON PATH) AS ChassisDetails
								,(SELECT		DISTINCT ScreenName,DefaultDocKey,IsCompulsory,DT.Description AS DefaultDocDesc
												,DocTypes=  (SELECT	DT.DocumentTypeKey,Description DocType
															, ROW_NUMBER() OVER (Partition BY SD.ScreenName ORDER BY SD.OrderBy) AS OrderBy
												FROM		DocumenType DT  WITH (NOLOCK)  
												INNER JOIN	#DA_ScreenDocumentTypeDropDownLink SD ON DT.DocumentTypeKey = SD.DocumentTypeKey 
												WHERE		LinkTo = 'Order' AND SD.ScreenName = SD1.ScreenName
												FOR JSON PATH )
												, DocDetails = (SELECT CLD.DocumentKey, DT.Description DocType, REPLACE(DO.FilePath,'\','/')FilePath , DO.OriginalFileName AS DocFileName
												-- , DD.DocumentTypeDesc , CLD.RouteKey
												FROM			ContainerLegDocuments CLD WITH (NOLOCK)
												LEFT JOIN		DriverDocuments DD WITH (NOLOCK) ON CLD.DocumentKey = DD.DocumentKey
												LEFT JOIN		Document DO WITH (NOLOCK) ON DO.DocumentKey=CLD.DocumentKey
												LEFT JOIN		DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=DO.DocumentType
												WHERE			DD.DocumentTypeDesc = SD1.ScreenName AND CLD.RouteKey = @RouteKey
												FOR JSON PATH)	
									FROM		#DA_ScreenDocumentTypeDropDownLink SD1
									INNER JOIN	#DefaultDocType DDT ON SD1.ScreenName = DDT.DocType
									INNER JOIN	DocumenType DT ON DDT.DefaultDocKey = DT.DocumentTypeKey
									FOR JSON PATH) AS DocTypeDetails
								,(SELECT * FROM 
								(SELECT Pickup =	(SELECT  DriverExceptionKey , DriverException, AllowEntry 
																	FROM DriverExceptions 
																	WHERE ExceptionType = 'Pickup' AND IsActive = 1
																	ORDER BY OrderBy
																	FOR JSON PATH)   ,
										Delivery = (SELECT  DriverExceptionKey , DriverException , AllowEntry
																	FROM DriverExceptions 
																	WHERE ExceptionType = 'Delivery' AND IsActive = 1
																	ORDER BY OrderBy
																	FOR JSON PATH)) A   FOR JSON PATH) AS DriverExceptions	
								,(SELECT RouteKey,ISNULL(ConfirmPickup,0)ConfirmPickup,ISNULL(ConfirmEquipments,0)ConfirmEquipments,ISNULL(PickUpDocs,0)PickUpDocs
								,ISNULL(ConfirmDelivery,0) ConfirmDelivery,ISNULL(DeliveryDocs,0)DeliveryDocs,ISNULL(PairContainer,0)PairContainer,ISNULL(Charges,0)Charges
								,ISNULL(Complete,0)Complete
								FROM #DA_AppDriverScreenDetails ASD WITH (NOLOCK)
								WHERE ASD.RouteKey = D.Routekey
								 FOR JSON PATH) AS ScreensCompleted
								,(SELECT		DISTINCT CD.ChargeDesc , ISNULL(RT.Itemkey,CD.ItemKey) ItemKey
												, CAST(CASE WHEN ISNULL(ChargeSource,'') = 'DriverApp' OR MasterItemKey IS NULL THEN 1 ELSE 0 END  AS BIT) AS IsEnable
												, CAST(ISNULL(CAST(UnitCost AS DECIMAL(18,2)) * CAST(Qty AS DECIMAL(18,2)),0.00) AS DECIMAL(18,2)) AS ChargeAmt
												, CASE WHEN RT.RouteKey IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsRecordExists
												,OrderBy
									FROM		#ChargeData CD
									LEFT JOIN	(SELECT		A.RouteKey,OE.Itemkey, I.MasterItemKey, OE.UnitCost, OE.Qty, ChargeSource 
												FROM		#Routes A  WITH (NOLOCK)
												INNER JOIN	OrderExpense OE  WITH (NOLOCK) ON OE.RouteKey = A.Routekey
												INNER JOIN	Item I  WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
												INNER JOIN	Item M  WITH (NOLOCK) On I.MasterItemKey = M.ItemKey
												WHERE		A.RouteKey = D.RouteKey ) RT ON CASE WHEN ISNULL(@WaitTimeItemKey,0) > 0 AND CD.ItemKey = 0 THEN @WaitTimeItemKey ELSE CD.ItemKey END = RT.MasterItemKey
									ORDER BY OrderBy  FOR JSON PATH ) AS ChargeDetails
									,(SELECT RCD.ReasonCodeKey, RC.ReasonCode, ISNULL(ReasonCodeText,'')ReasonCodeText  
									FROM DA_DriverReasonCodeDetails RCD 
									INNER JOIN DA_DriverReasonCodes RC ON RCD.ReasonCodeKey = RC.ReasonCodeKey
									WHERE RCD.RouteKey = D.RouteKey FOR JSON PATH ) AS PortReasonEntryDetails
									,(SELECT		I.Description AS ChargeDesc,  OE.UnitCost, OE.Qty ,CAST((OE.UnitCost *  OE.Qty) AS DECIMAL(18,2))  ChargeAmount
										FROM		#Routes A  WITH (NOLOCK)
										INNER JOIN	OrderExpense OE  WITH (NOLOCK) ON OE.RouteKey = A.Routekey
										INNER JOIN	Item I  WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
										INNER JOIN	Item M  WITH (NOLOCK) On I.MasterItemKey = M.ItemKey
										WHERE		A.RouteKey = D.RouteKey  AND ChargeSource = 'DriverApp' FOR JSON PATH ) AS ChargeCompleteDetails
									-- ,(SELECT DocType,DefaultDocKey FROM #DefaultDocType FOR JSON PATH)  AS  DefaultDocType 
									--,(SELECT			DT.Description DocType, REPLACE(DO.FilePath,'\','/')FilePath , DO.OriginalFileName AS DocFileName
									--FROM			ContainerLegDocuments CLD WITH (NOLOCK)
									--LEFT JOIN		Document DO WITH (NOLOCK) ON DO.DocumentKey=CLD.DocumentKey
									--LEFT JOIN		DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=DO.DocumentType
									--WHERE			CLD.RouteKey = D.RouteKey
									---- WHERE			CLD.RouteKey = 357674
									--FOR JSON PATH	) DocDetails
									
									, (SELECT CAST(@IsLinked AS BIT) AS IsLinked, LinkedContainers =  
									(SELECT LinkedContainer AS LinkedContainerNo FROM #Routes OD WITH (NOLOCK) WHERE RouteKey = @RouteKey ORDER BY RouteKey DESC FOR JSON PATH )  FOR JSON PATH) AS PairContainerDetails
									, CAST(CASE WHEN RouteStatus IN (3,5) THEN 1 ELSE 0 END  AS BIT) AS IsCompleted
									,CAST(CASE WHEN CompleteDate IS NOT NULL AND   DATEDIFF(HOUR, CompleteDate, GETDATE()) <= @EditTime THEN 1 ELSE 0 END AS BIT) AS IsEditable
									FROM #Data D FOR JSON PATH )

			SELECT ISNULL(@JsonRes,'')

			IF(ISNULL(@JsonRes,'') = '')
				BEGIN
					SET		@IntError = 'No Record Found'
					SET		@Reason = @GenError
					SET		@Status = 0
				END
			ELSE
				BEGIN
					SET		@IntError = 'Success'
					SET		@Reason = 'Success'

				END

			DROP TABLE #DA_AppDriverScreenDetails
		END

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SET		@Status = 0
		SET		@IntError = 'Procedure Name : ' + ERROR_PROCEDURE() + '. Error Message : ' +  ERROR_MESSAGE()+ '. JSON String : ' + @JSONString
		SET		@Reason = 'Data Exception Error'
	END CATCH

	UPDATE DA_RequestResponseLogs
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = @JsonRes, IsLogout = @IsLogout
	WHERE LogKey = @LogKey

END

