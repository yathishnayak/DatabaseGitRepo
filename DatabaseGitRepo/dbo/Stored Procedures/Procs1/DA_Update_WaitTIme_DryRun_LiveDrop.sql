

/*
DECLARE @UserKey INT = 886, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 0, @FirebaseID VARCHAR(100) = '', @IsLogout BIT
SET @JSOnString = '{"Appversion":"v1.0.6[UAT]","DriverKey":1681,"RouteKey":"584856","WaitTimeFrom":"2025-03-27T08:16:50","WaitTimeTo":"2025-03-27T10:46:50","Latitude":"13.3460128","Longitude":"74.7625843","RouteType":"Pickup","IsDryRun":"false","IsLiveDrop":"","IsUpdate":"true","NoWaitTime":"false"}'
SET @FirebaseID = 'eLiPzulVSYGtoL5bVrtTjd:APA91bF0wTBcFjmQTePb6-rICKAP8EuObKVUMy4LQ_HpvhLqk1iF7VJEFv98KiCMdw14hqb_DocfIW-WW2kyiR4VPXJ0MbrTZkWjD6dpYExcV1NCRt_uJ38'
EXEC DA_Update_WaitTIme_DryRun_LiveDrop @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT,@IsDebug, @FirebaseID , @IsLogout OUTPUT
SELECT @Status,@IntError,@Reason, @IsLogout
*/

CREATE PROCEDURE	[dbo].[DA_Update_WaitTIme_DryRun_LiveDrop]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"Appversion":"v1.0.6[UAT]","DriverKey":1679,"RouteKey":"584562","WaitTimeFrom":"2025-02-27T08:01:39","WaitTimeTo":"2025-02-27T10:31:39","Latitude":"28.455003203783317","Longitude":"77.00108682546264","RouteType":"Delivery","IsDryRun":"false","IsLiveDrop":"","IsUpdate":"true","NoWaitTime":"false"}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(400) = '',
	@IsLogout		BIT = 0 OUTPUT
)

AS
BEGIN
	
	/*---------------------------------------DO NOT DELETE----------------------------------------------------------
		RouteType - Value will be 'Pickup' OR 'Delivery'
	*/
	SET @IsLogout = 0

	DECLARE @LogKey INT
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID,IsDebug,CreatedDate)
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

		DECLARE		@DriverKey INT, @RouteKey INT, @WaitTimeFrom	VARCHAR(20), @WaitTimeTo VARCHAR(20), @RouteType VARCHAR(20)
					,@IsDryRun BIT,@IsLiveDrop VARCHAR(20), @ContainerNo VARCHAR(50) = '', @OrderDetailkey INT = 0	, @LegID VARCHAR(50) = ''
					,@OrderTypeKey INT = 0,@FromLocationWaitTimeFrom DATETIME, @FromLocationWaitTimeTo DATETIME,@ToLocationWaitTimeFrom DATETIME
					,@ToLocationWaitTimeTo DATETIME , @ToLocation VARCHAR(20), @Comments VARCHAR(500) = '', @Itemkey INT = 0
					,@IsUpdateData BIT = 0, @FromLocation VARCHAR(20), @IsUpdate BIT, @NoWaitTime BIT

		DECLARE		@GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator; '
		DECLARE		@InternalError	VARCHAR(1000) = '', @Latitude FLOAT,@Longitude FLOAT, @ActiveRoute INT = 0	, @ActiveContainer VARCHAR(50) = ''
		SET			@Status = 1

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
				SELECT	@DriverKey = DriverKey, @RouteKey = RouteKey,@Latitude = Latitude, @Longitude = Longitude, @WaitTimeFrom = WaitTimeFrom
						,@WaitTimeTo = WaitTimeTo, @RouteType = RouteType
						, @IsDryRun = CASE WHEN IsDryRun = 'true' THEN 1 ELSE 0 END
						, @IsLiveDrop = IsLiveDrop, @IsUpdate = IsUpdate, @NoWaitTime = NoWaitTime

				FROM	OPENJSON(@JSONString, '$')
						WITH (
								DriverKey			INT				'$.DriverKey',
								RouteKey			INT				'$.RouteKey',
								Latitude			FLOAT			'$.Latitude',
								Longitude			FLOAT			'$.Longitude',
								WaitTimeFrom		VARCHAR(20)		'$.WaitTimeFrom',
								WaitTimeTo			VARCHAR(20)		'$.WaitTimeTo',
								RouteType			VARCHAR(20)		'$.RouteType',
								IsDryRun			VARCHAR(20)		'$.IsDryRun',
								IsLiveDrop			VARCHAR(20)		'$.IsLiveDrop',
								IsUpdate			BIT				'$.IsUpdate',
								NoWaitTime			BIT				'$.NoWaitTime'
							)

				SET @DriverKey  = ISNULL(@DriverKey,0)
				SET @RouteKey	= ISNULL(@RouteKey,0)
				SET @RouteType  = ISNULL(@RouteType,'')
				SET @IsDryRun	= ISNULL(@IsDryRun,0)
				SET @IsLiveDrop = ISNULL(@IsLiveDrop,'')

				-- @OrderTypeKey : 1 - Import; 2 - Export

				SET @ActiveRoute = (SELECT RouteKey FROM DA_ActiveDriverRoutes WITH (NOLOCK) WHERE DriverKey = @DriverKey)
				SET @ActiveRoute = ISNULL(@ActiveRoute,0)

				DECLARE @RouteStatus INT = 0

				SELECT		*
				INTO		#Routes
				FROM		Routes WITH (NOLOCK)
				WHERE		RouteKey IN (@RouteKey, @ActiveRoute)

				SELECT		@ContainerNo = ContainerNo,@OrderDetailkey = OD.OrderDetailKey , @LegID = L.LegID, @OrderTypeKey = OH.OrderTypeKey
							, @ToLocation = L.ToLocation, @FromLocation = L.FromLocation, @RouteStatus = RT.[Status]
				FROM		OrderDetail OD  WITH (NOLOCK)
				INNER JOIn	#Routes RT  WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	Leg L  WITH (NOLOCK) ON RT.LegKey = L.LegKey
				INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
				WHERE		RT.RouteKey = @RouteKey

				-- SELECT @DriverKey, @RouteKey

				DECLARE @IsWaitTimeUpdated BIT = 0
							

				SET	@Status = 1

				SELECT		@FromLocationWaitTimeFrom = FromLocationWaitTimeFrom,@FromLocationWaitTimeTo = FromLocationWaitTimeTo
							,@ToLocationWaitTimeFrom = ToLocationWaitTimeFrom, @ToLocationWaitTimeTo = ToLocationWaitTimeTo
				FROM		#Routes
				WHERE		RouteKey = @RouteKey

				IF(@RouteType = 'Pickup' AND @FromLocationWaitTimeFrom IS NOT NULL and @FromLocationWaitTimeTo IS NOT NULL 
					AND @FromLocationWaitTimeFrom <> @FromLocationWaitTimeTo )
					BEGIN
						SET @IsWaitTimeUpdated = 1
					END
				ELSE IF (@RouteType = 'Delivery' AND @ToLocationWaitTimeFrom IS NOT NULL AND @ToLocationWaitTimeTo IS NOT NULL 
					AND @ToLocationWaitTimeFrom <> @ToLocationWaitTimeTo)
					BEGIN
						SET @IsWaitTimeUpdated = 1
					END

				IF(@IsDebug = 1)
					BEGIN
						SELECT '@IsUpdate' , @IsUpdate 
						SELECT @FromLocationWaitTimeFrom, @FromLocationWaitTimeTo, @ToLocationWaitTimeFrom, @ToLocationWaitTimeTo
					END


				IF(@ActiveRoute > 0 AND @RouteKey <> @ActiveRoute AND @RouteType = 'Pickup')
					BEGIN
						SET	@ActiveContainer = (SELECT ContainerNo FROM #Routes RT
												INNER JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
												WHERE RT.RouteKey = @ActiveRoute)


						SET	@Status = 0
						SET @InternalError = 'Complete CONTAINER - '+ ISNULL(@ActiveContainer,'') + ' route'
						SET @GenError = @InternalError
					END
				ELSE IF(@RouteStatus = 5)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'This Route is already Completed'
						SET @GenError = @InternalError
					END
				ELSE
					BEGIN
						IF(@DriverKey = 0 OR @RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'Check DriverKey Or RouteKey'
							END
						

						IF(@RouteType = '' OR (@RouteType NOT IN ('Pickup','Delivery')))
							BEGIN
								SET @Status = 0
								SET @InternalError = @InternalError + '; Verify Routetype Value'
							END

						IF(@IsLiveDrop <> '' AND  (@IsLiveDrop NOT IN ('Live','Drop')))
							BEGIN
								SET @Status = 0
								SET @InternalError = @InternalError + '; Verify LiveDrop Value'
							END

						IF((ISNULL(@WaitTimeFrom,'') = '' OR ISNULL(@WaitTimeTo,'') = '') AND @IsUpdate = 0 AND @NoWaitTime = 0 AND @IsLiveDrop <> 'Drop')
							BEGIN
								SET @Status = 0
								SET @InternalError = @InternalError + '; WaitTimeFrom OR  WaitTimeTo Cannot be Null or Blank'
							END

						
						IF (@IsWaitTimeUpdated = 1  AND @WaitTimeFrom <> '' AND @WaitTimeTo <> '' AND @NoWaitTime = 0 )				 
							BEGIN
								SET @Status = 0
								SET @InternalError = @InternalError + '; Wait Time is already Updated'
							END

					END


				
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				DECLARE @OldLegType VARCHAR(20), @OldIsDryRun BIT = 0
				SELECT @OldLegType = LegType, @OldIsDryRun = ISNULL(IsDryRun,0)  FROM Routes RT WHERE RouteKey = @RouteKey  

				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

				IF(@IsLiveDrop <> '')
					BEGIN
						IF(@OldLegType <> @IsLiveDrop)
							BEGIN
								UPDATE	RT
								SET		LegType = @IsLiveDrop
								FROM	Routes RT 
								WHERE	RouteKey = @RouteKey

								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Leg Type updated to ' +  @IsLiveDrop +  + 'For Leg - ' + @LegID
							END
					END

				IF(@IsDryRun  = 1)
					BEGIN
						IF(ISNULL(@OldIsDryRun,0) <> @IsDryRun)
							BEGIN
								UPDATE	RT
								SET		IsDryRun = @IsDryRun, DryRunType = CASE WHEN @ToLocation = 'Port' THEN 1 ELSE 2 END
										, DryRunSource = 'DriverApp', DryRunSetUser = @UserKey,DryRunSetDate = GETDATE()
								FROM	Routes RT
								WHERE	RouteKey = @RouteKey

								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Is DryRun Updated '  + 'For Leg - ' + @LegID

								IF(@OrderTypeKey = 1)
									BEGIN
										IF(@ToLocation = 'Port')
											BEGIN
												SET @Itemkey = 11
												SET	@Comments = 'DryRun Import (Port) Item Added for Container'
												SET @IsUpdateData = 1
											END
										ELSE IF(@ToLocation IN ('Consignee','Customer','Depot','Shipper'))
											BEGIN
												SET @Itemkey = 164
												SET	@Comments = 'DryRun Import (Customer) Item Added for Container'
												SET @IsUpdateData = 1
											END									
									END

								IF(@OrderTypeKey = 2)
									BEGIN
										IF(@ToLocation = 'Port')
											BEGIN
												SET @Itemkey = 10
												SET	@Comments = 'DryRun Export (Port) Item Added for Container'
												SET @IsUpdateData = 1
											END
										ELSE IF(@ToLocation IN ('Consignee','Customer','Depot','Shipper'))
											BEGIN
												SET @Itemkey = 278
												SET	@Comments = 'DryRun Export (Customer) Item Added for Container'
												SET @IsUpdateData = 1
											END	
									END

									IF(@IsUpdateData = 1)
										BEGIN
											INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
																BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
											SELECT			I.ItemKey, @RouteKey, I.UnitCost, 1, I.UnitCost, Getdate(),  
															1, 0, 1, 0, 0, 'DriverApp', @OrderDetailKey, NULL
											FROM			Item I WITH (NOLOCK)
											INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
											WHERE			I.ItemKey = @Itemkey

											INSERT			INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
											SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text' 
															, @Comments
										END

									If(@RouteType = 'Pickup')
										BEGIN
											UPDATE	DA_AppDriverScreenDetails
											SET		ConfirmDelivery = 1, DeliveryDocs = 1,PairContainer = 1, ConfirmEquipments = 1
											WHERE	RouteKey = @RouteKey
										END

									If(@RouteType = 'Delivery')
										BEGIN
											UPDATE	DA_AppDriverScreenDetails
											SET		PairContainer = 1, ConfirmEquipments = 1
											WHERE	RouteKey = @RouteKey
										END
									

							END
					END

				DECLARE  @UnitCost DECIMAL(18,2) = 0, @ChargeDesc VARCHAR(50) = '', @WaitTimeinMinutes INT = 120

				IF(@IsDebug = 1)
					BEGIN
						SELECT 1,@WaitTimeFrom, @WaitTimeTo,@IsWaitTimeUpdated,@RouteType, @RouteKey, @NoWaitTime
					END
				
				DECLARE @CurrentDate DATETIME = GETDATE()

				IF(@WaitTimeFrom <> '' AND @WaitTimeTo <> ''  AND @IsWaitTimeUpdated = 0  AND @NoWaitTime = 0)
					BEGIN
						IF (@RouteType = 'Pickup')
							BEGIN
								UPDATE		RT
								SET			FromLocationWaitTimeFrom = CAST(@WaitTimeFrom AS DATETIME), FromLocationWaitTimeTo = CAST(@WaitTimeTo AS DATETIME)
											,ActualDeparture = @CurrentDate,ActualDepartureUpdateMethod = 'DriverApp',ActualDepartureUpdateDate = GETDATE()
											,ActualDepartureUpdateUser = @UserKey,[Status]=2, PickupNoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

								UPDATE		ODS SET ActualPickupDate = @CurrentDate
								FROM		OrderDetailStops ODS
								WHERE		FromRouteKey = @RouteKey

								insert into Routes_ActualLog(RouteKey, CreateDate, DateSource,  ActualDeparture, CreateUserKey)
								select @RouteKey, @CurrentDate, 'DriverApp', @CurrentDate, @UserKey

								--UPDATE		RT
								--SET			ActualDeparture = GETDATE(),ActualDepartureUpdateMethod = 'DriverApp',ActualDepartureUpdateDate = GETDATE()
								--			,ActualDepartureUpdateUser = @UserKey,[Status]=2
								--FROM		Routes RT
								--WHERE		RouteKey = @RouteKey
							END
						ELSE
							BEGIN
								UPDATE		RT
								SET			ToLocationWaitTimeFrom = @WaitTimeFrom, ToLocationWaitTimeTo = @WaitTimeTo
											,ActualArrival = @CurrentDate,ActualArrivalUpdateMethod = 'DriverApp',ActualArrivalUpdateDate = GETDATE()
											,ActualArrivalUpdateUser = @UserKey, DeliveryNoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

								UPDATE		ODS SET ActualDeliveryDate = @CurrentDate
								FROM		OrderDetailStops ODS
								WHERE		ToRouteKey = @RouteKey

								insert into Routes_ActualLog(RouteKey, CreateDate, DateSource,  ActualArrival, CreateUserKey)
								select @RouteKey, @CurrentDate, 'DriverApp', @CurrentDate, @UserKey
								--UPDATE		RT
								--SET			ActualArrival = GETDATE(),ActualArrivalUpdateMethod = 'DriverApp',ActualArrivalUpdateDate = GETDATE()
								--			,ActualArrivalUpdateUser = @UserKey
								--FROM		Routes RT
								--WHERE		RouteKey = @RouteKey
							END
					END	
				ELSE IF (@IsWaitTimeUpdated = 0 AND @NoWaitTime = 1)
					BEGIN
						IF (@RouteType = 'Pickup')
							BEGIN
								UPDATE		RT
								SET			ActualDeparture = @CurrentDate,ActualDepartureUpdateMethod = 'DriverApp',ActualDepartureUpdateDate = GETDATE()
											,ActualDepartureUpdateUser = @UserKey,[Status]=2,PickupNoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

								UPDATE		ODS SET ActualPickupDate = @CurrentDate
								FROM		OrderDetailStops ODS
								WHERE		FromRouteKey = @RouteKey

								insert into Routes_ActualLog(RouteKey, CreateDate, DateSource,  ActualDeparture, CreateUserKey)
								select @RouteKey, @CurrentDate, 'DriverApp', @CurrentDate, @UserKey

							END
						ELSE
							BEGIN
								UPDATE		RT
								SET			ActualArrival = @CurrentDate,ActualArrivalUpdateMethod = 'DriverApp',ActualArrivalUpdateDate = GETDATE()
											,ActualArrivalUpdateUser = @UserKey,DeliveryNoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

								UPDATE		ODS SET ActualDeliveryDate = @CurrentDate
								FROM		OrderDetailStops ODS
								WHERE		ToRouteKey = @RouteKey

								insert into Routes_ActualLog(RouteKey, CreateDate, DateSource,  ActualArrival, CreateUserKey)
								select @RouteKey, @CurrentDate, 'DriverApp', @CurrentDate, @UserKey
							END
					END
			

				IF(DATEDIFF(MINUTE, @WaitTimeFrom, @WaitTimeTo)) > @WaitTimeinMinutes
					BEGIN
						IF((@FromLocation = 'Port' AND @RouteType = 'Pickup' ) OR (@ToLocation = 'Port' AND @RouteType = 'Delivery'))
							BEGIN
								SELECT		@ItemKey = ItemKey, @UnitCost = UnitCost, @ChargeDesc  = Description
								FROM		Item WITH (NOLOCK)
								WHERE		ItemKey = 5

								INSERT INTO	OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
											BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey)
								SELECT		@ItemKey, @RouteKey, @UnitCost, 1,  @UnitCost, Getdate(),  1, 0, 
											1, 0, 0, 'DriverApp', @OrderDetailKey

								INSERT INTO	AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT		GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text' , @ChargeDesc + ' Item Added for Container '
							END
						ELSE IF((@FromLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Pickup' ) OR 
								(@ToLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Delivery'))
							BEGIN
								SELECT		@ItemKey = ItemKey, @UnitCost = UnitCost, @ChargeDesc  = Description
								FROM		Item WITH (NOLOCK)
								WHERE		ItemKey = 162

								INSERT INTO	OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
											BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey)
								SELECT		@ItemKey, @RouteKey, @UnitCost, 1,  @UnitCost, Getdate(),  1, 0, 
											1, 0, 0, 'DriverApp', @OrderDetailKey

								INSERT INTO	AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT		GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text' , @ChargeDesc + ' Item Added for Container '
							END
					END
				
				IF(@RouteType = 'Pickup' AND ISNULL(@ActiveRoute,0) = 0)
					BEGIN
						INSERT INTO DA_ActiveDriverRoutes
									(DriverKey,RouteKey,CreatedDate)
						SELECT		@DriverKey,@RouteKey,GETDATE()
					END
				
				IF(SELECT COUNT(*) FROM DA_AppDriverScreenDetails WHERE RouteKey = @RouteKey) = 0
					BEGIN
						INSERT INTO DA_AppDriverScreenDetails
									(DriverKey,UserKey,RouteKey,ConfirmPickup,ConfirmEquipments,PickUpDocs,ConfirmDelivery,DeliveryDocs,PairContainer
									,Charges,Complete,CreatedDate,UpdatedDate)
						SELECT		@DriverKey,@UserKey,@RouteKey,0,0,0,0,0,0,0,0,GETDATE(),GETDATE()
					END

				IF(@RouteType = 'Pickup')
					BEGIN
						UPDATE		A
						SET			ConfirmPickup = 1
						FROM		DA_AppDriverScreenDetails A
						WHERE		Routekey = @RouteKey
					END
				ELSE IF(@RouteType = 'Delivery')
					BEGIN
						UPDATE		A
						SET			ConfirmDelivery = 1
						FROM		DA_AppDriverScreenDetails A
						WHERE		Routekey = @RouteKey
					END

				SET		@IntError = 'Success'
				SET		@Reason = 'Success'
			END
	

	DECLARE @JsonRes NVARCHAR(MAX) = ''
	CREATE TABLE  #ChargeData
			(
				ChargeDesc		VARCHAR(50),
				ItemKey			INT,
				OrderBy			INT
			)

	INSERT INTO #ChargeData
	EXEC DA_GetChargeDataItems @FromLocation,  @ToLocation, @RouteType

	IF(@IsDebug = 1)
		BEGIN
			SELECT @FromLocation
			SELECT * FROM #ChargeData

			SELECT		OE.RouteKey,OE.Itemkey, I.MasterItemKey, OE.UnitCost, OE.Qty, ChargeSource 
									FROM		OrderExpense OE  WITH (NOLOCK) 
									INNER JOIN	Item I  WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
									INNER JOIN	Item M  WITH (NOLOCK) On I.MasterItemKey = M.ItemKey
									WHERE		OE.Routekey = @Routekey 
		END

	SET @JsonRes =	(SELECT		DISTINCT CD.ChargeDesc , ISNULL(RT.Itemkey,CD.ItemKey) ItemKey
									, CAST(CASE WHEN ISNULL(ChargeSource,'') = 'DriverApp' OR MasterItemKey IS NULL THEN 1 ELSE 0 END  AS BIT) AS IsEnable
									, CAST(ISNULL(CAST(UnitCost AS DECIMAL(18,2)) * CAST(Qty AS DECIMAL(18,2)),0.00) AS DECIMAL(18,2)) AS ChargeAmt
									, CASE WHEN RT.RouteKey IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsRecordExists
									,OrderBy
						FROM		#ChargeData CD
						LEFT JOIN	(SELECT		OE.RouteKey,OE.Itemkey, I.MasterItemKey, OE.UnitCost, OE.Qty, ChargeSource 
									FROM		OrderExpense OE  WITH (NOLOCK) 
									INNER JOIN	Item I  WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
									INNER JOIN	Item M  WITH (NOLOCK) On I.MasterItemKey = M.ItemKey
									WHERE		OE.Routekey = @Routekey ) RT ON CD.ItemKey = RT.MasterItemKey
						ORDER BY	OrderBy  FOR JSON PATH )

	SELECT ISNULL(@JsonRes,'') AS JsonResult
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
