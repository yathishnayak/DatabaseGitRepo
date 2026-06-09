
-- DROP PROCEDURE DA_WaitTimeUpdate
/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '	{"DriverKey":1680,"RouteKey":588781,"WaitTimeFrom":"2024-12-19T16:11:59","WaitTimeTo":"2024-12-19T16:11:59","Latitude":"13.3460012","Longitude":"74.7625663","RouteType":"Pickup","IsDryRun":"","IsLiveDrop":""}'
EXEC DA_Update_WaitTIme_DryRun_LiveDrop @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_Update_WaitTIme_DryRun_LiveDrop_BKP20250122]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '	{"DriverKey":1680,"RouteKey":588781,"WaitTimeFrom":"2024-12-19T16:11:59","WaitTimeTo":"2024-12-19T16:11:59","Latitude":"13.3460012","Longitude":"74.7625663","RouteType":"Pickup","IsDryRun":"","IsLiveDrop":""}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)

AS
BEGIN
	
	/*---------------------------------------DO NOT DELETE----------------------------------------------------------
		RouteType - Value will be 'Pickup' OR 'Delivery'
	*/


	DECLARE @LogKey INT
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY

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
				SET @RouteKey  = ISNULL(@RouteKey,0)
				SET @RouteType  = ISNULL(@RouteType,'')
				SET @IsDryRun  = ISNULL(@IsDryRun,0)
				SET @IsLiveDrop  = ISNULL(@IsLiveDrop,'')

				-- @OrderTypeKey : 1 - Import; 2 - Export

				SET @ActiveRoute = (SELECT RouteKey FROM DA_ActiveDriverRoutes WITH (NOLOCK) WHERE DriverKey = @DriverKey)
				SET @ActiveRoute = ISNULL(@ActiveRoute,0)

				SELECT		*
				INTO		#Routes
				FROM		Routes WITH (NOLOCK)
				WHERE		RouteKey IN (@RouteKey, @ActiveRoute)

				SELECT		@ContainerNo = ContainerNo,@OrderDetailkey = OD.OrderDetailKey , @LegID = L.LegID, @OrderTypeKey = OH.OrderTypeKey
							, @ToLocation = L.ToLocation, @FromLocation = L.FromLocation
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

				IF(@RouteType = 'Pickup' AND @FromLocationWaitTimeFrom IS NOT NULL and @FromLocationWaitTimeTo IS NOT NULL )
																	   
					BEGIN
						SET @IsWaitTimeUpdated = 1
					END
				ELSE IF (@RouteType = 'Delivery' AND @ToLocationWaitTimeFrom IS NOT NULL AND @ToLocationWaitTimeTo IS NOT NULL )
																	   
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
						IF(@IsDebug = 1)
							BEGIN
								SELECT @GenError AS GenError1, @ActiveRoute
							END

						SET	@ActiveContainer = (SELECT ContainerNo FROM #Routes RT
												INNER JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
												WHERE RT.RouteKey = @ActiveRoute)


						SET	@Status = 0
						SET @InternalError = 'Complete CONTAINER - '+ @ActiveContainer + ' route'
						SET @GenError = @InternalError
					END
				ELSE
					BEGIN
						IF(@IsDebug = 1)
							BEGIN
								SELECT @GenError AS GenError
							END
						IF(@DriverKey = 0 OR @RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'Check DriverKey Or RouteKey'
							END
						--SELECT @IsDebug
						IF(@IsDebug = 1)
							BEGIN
								SELECT @WaitTimeFrom, @WaitTimeTo
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

		IF(@IsDebug = 1)
			BEGIN
				SELECT '@Status' , @Status 
			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError


				IF(@IsDebug = 1)
					BEGIN
						SELECT 1,@IntError , @Reason 
					END
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
						SELECT 1,@WaitTimeFrom, @WaitTimeTo,@OrderTypeKey,@RouteType, @RouteKey
					END

				IF(@WaitTimeFrom <> '' AND @WaitTimeTo <> ''  AND @IsWaitTimeUpdated = 0  AND @NoWaitTime = 0 AND @IsUpdate = 0 )
					BEGIN
						IF (@RouteType = 'Pickup')
							BEGIN
								UPDATE		RT
								SET			FromLocationWaitTimeFrom = CAST(@WaitTimeFrom AS DATETIME), FromLocationWaitTimeTo = CAST(@WaitTimeTo AS DATETIME)
											,ActualDeparture = GETDATE(),ActualDepartureUpdateMethod = 'DriverApp',ActualDepartureUpdateDate = GETDATE()
											,ActualDepartureUpdateUser = @UserKey,[Status]=2, NoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

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
											,ActualArrival = GETDATE(),ActualArrivalUpdateMethod = 'DriverApp',ActualArrivalUpdateDate = GETDATE()
											,ActualArrivalUpdateUser = @UserKey, NoWaitTIme = @NoWaitTime
								FROM		Routes RT
								WHERE		RouteKey = @RouteKey

								--UPDATE		RT
								--SET			ActualArrival = GETDATE(),ActualArrivalUpdateMethod = 'DriverApp',ActualArrivalUpdateDate = GETDATE()
								--			,ActualArrivalUpdateUser = @UserKey
								--FROM		Routes RT
								--WHERE		RouteKey = @RouteKey
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
						ELSE IF((@FromLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Delivery' ) OR 
								(@ToLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Pickup'))
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
				
				IF(@RouteType = 'Pickup')
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
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET		@Status = 0
		SET		@IntError = 'Procedure Name : ' + ERROR_PROCEDURE() + '. Error Message : ' +  ERROR_MESSAGE()+ '. JSON String : ' + @JSONString
		SET		@Reason = 'Data Exception Error'
	END CATCH

	UPDATE DA_RequestResponseLogs
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = 'No Response for this Query'
	WHERE LogKey = @LogKey

END
