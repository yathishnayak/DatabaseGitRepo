
/*
DECLARE @UserKey INT = 418, @JSOnString NVARCHAR(MAX) = '[{"DriverKey": "971", "IsCompleted": 0}]', @Status BIT, @@IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1, @FirebaseID VARCHAR(100) = '', @IsLogout BIT
SET @JSOnString = '{"Appversion":"v1.0.8","DeviceID":{"System Name":"iOS","System Version":"18.3.1","Model":"iPhone","Localized Model":"iPhone","Machine":"iPhone15,5","UniqueID":"456d170b-37a9-4902-8c9c-c071297be957"},"DriverKey":"971","Latitude":"28.454959655259376","Longitude":"77.00097198360767","IsCompleted":0}'
SET @FirebaseID = 'cW9fsy8DM0zDmtwc8f-eXM:APA91bFjhlbC38PcyFn53DOgNsx9jsIdYo-j1ZRXsJqf5o-vQ0L6ACxbRTglnYSWZfMhVZtZ_YweA68zvsnnlBvtQxSObxZYDXAZ1bVsJLdDVYDF2DO6qQ8'
EXEC DA_GetOrderRouteDetails @UserKey,@JSOnString,@Status OUTPUT, @@IntError OUTPUT, @Reason OUTPUT,@IsDebug, @FirebaseID , @IsLogout OUTPUT
SELECT @Status,@@IntError,@Reason, @IsLogout
*/

CREATE PROCEDURE	[dbo].[DA_GetOrderRouteDetails]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"DriverKey": "971", "IsCompleted": 0}]',
	@Status			BIT	= 0 OUTPUT,
	@IntError		VARCHAR(1000) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT

)

AS
BEGIN
	SET @IsLogout = 0
	
	DECLARE @LogKey INT, @JsonRes nvarchar(max)

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
			SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout, UpdatedDate = GETDATE(), ReponseJSONString = @JsonRes
			WHERE LogKey = @LogKey

			RETURN
		END
	-- validate

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @DriverKey	INT ,@IsCompleted	BIT = 0
		DECLARE @GenError	VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError VARCHAR(1000), @NoofDays INT = 30
		DECLARE @IsUATServer BIT = 0

		IF(@@SERVERNAME = 'JCTDEV')
			BEGIN
				SET @NoofDays = 2000
				SET @JSONString = REPLACE(@JSONString,'"DriverKey": "1532"','"DriverKey": "657"')
				SET @JSONString = REPLACE(@JSONString,'"DriverKey": "1533"','"DriverKey": "1117"')
				SET @JSONString = REPLACE(@JSONString,'"DriverKey": "1535"','"DriverKey": "762"')
				SET @JSONString = REPLACE(@JSONString,'"DriverKey": "1547"','"DriverKey": "802"')
				SET @IsUATServer = 1
			END
		

		IF (ISNULL(@JSONString,'') = '')
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'JSON String Cannot be Blank'
			END
		ELSE IF(ISNULL(@UserKey,0) = 0)
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'UserKey Cannot be Blank'
			END
		ELSE
			BEGIN				
				SELECT		@DriverKey = DriverKey, @IsCompleted = IsCompleted
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									DriverKey	INT				'$.DriverKey',
									IsCompleted	INT				'$.IsCompleted'
								 )

				SET			@DriverKey = ISNULL(@DriverKey,0)
				SET			@IsCompleted = ISNULL(@IsCompleted,0)
							   				 			  		

				SET	@Status = 1

				IF(@DriverKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DriverKey Cannot be Null or 0'
					END
			END


		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				IF(@IsDebug = 1)
					BEGIN
						SELECT @IsCompleted,@DriverKey
					END

			

			--SELECT		DRC.*
			--INTO		#DriverRouteAcceptance
			--FROM		DriverRouteAcceptance DRC WITH (NOLOCK)
			--INNER JOIN	(SELECT  RouteKey, DriverKey, MAX(Acceptancekey)Acceptancekey FROM DriverRouteAcceptance  WITH (NOLOCK)
			--			GROUP BY RouteKey, DriverKey) DRC1 ON DRC.AcceptanceKey = DRC1.Acceptancekey

			SELECT		DRC.*
			INTO		#DriverRouteAcceptance
			FROM		DriverRouteAcceptance DRC WITH (NOLOCK)
			INNER JOIN	(SELECT  RouteKey,  MAX(Acceptancekey)Acceptancekey FROM DriverRouteAcceptance  WITH (NOLOCK)
						GROUP BY RouteKey) DRC1 ON DRC.AcceptanceKey = DRC1.Acceptancekey
		
			SELECT		OrderDetailKey, ContainerNo,ContainerSizeKey, OrderType, ContainerSize, RouteKey ,RouteStatus,OrderDate, FromLocation, ToLocation, DriverKey
						,SourceAddrName,SourceAdd1,SourceAdd2,SourceCity, SourceState, SourceZip
						,DestAddrName,DestAdd1,DestAdd2,DestCity,DestState,DestZip
						,ScheduledArrival,ScheduledDeparture,ScheduledPickupDate,ActualArrival,ActualDeparture
						, CASE WHEN OrderDesc = 'Reject' THEN RejectedDate  WHEN OrderStatus IN (1,2) THEN CompleteDate ELSE OrderByDate END AS AgingDate
						,ContainerProperties
						, CASE OrderStatus	WHEN 0 THEN 'Upcoming'
											WHEN 1 THEN 'Completed'
											WHEN 2 THEN 'Rejected' ELSE '' END AS OrderStatus
						,CASE WHEN OrderStatus = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsCompleted, IsAccepted,IsEditable
						,OrderProgress
			INTO		#Data
			FROM		(SELECT			OD.OrderDetailKey, ContainerNo,OD.ContainerSizeKey, CS.Description AS ContainerSize, R.RouteKey
						, CASE WHEN L.ToLocation = 'Yard' THEN ISNULL(ScheduledPickupDate,ScheduledDeparture)  WHEN L.FromLocation = 'Yard' THEN ISNULL(R.ScheduledArrival,R.DeliveryDateTo) ELSE ISNULL(ScheduledPickupDate,ScheduledDeparture) END OrderByDate
						,OH.OrderDate, L.FromLocation,L.ToLocation,R.DriverKey, ISNULL(ScheduledPickupDate,ScheduledDeparture) ScheduledPickupDate   , R.Status AS RouteStatus
						,AD.AddrName SourceAddrName,AD.Address1 SourceAdd1, AD.Address2 SourceAdd2, AD.City SourceCity, AD.State SourceState,AD.ZipCode SourceZip
						,AD1.AddrName DestAddrName,AD1.Address1 DestAdd1, AD1.Address2 DestAdd2, AD1.City DestCity, AD1.State DestState,AD1.ZipCode DestZip
						,ISNULL(R.ScheduledArrival,R.DeliveryDateTo) ScheduledArrival, DRC.Description OrderDesc, ISNULL(DRC.ActionDate,DRC.CreateDate) RejectedDate
						,  ScheduledDeparture
						,ActualArrival, ActualDeparture 
						,ISNULL(CT.ContainerProperties,'') AS ContainerProperties, ASD.CompleteDate
						, 
							--WHEN @IsUATServer = 0  
							--THEN (CASE WHEN ISNULL(DRC.Description,'') = 'Reject' THEN 2 ELSE 
							--		CASE WHEN isnull(R.IsAbandoned,0) = 0 THEN (CASE WHEN R.ActualArrival IS NOT NULL THEN 1 ELSE 0 END ) ELSE 1 END END)  
							--ELSE (CASE WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 1 ELSE 0 END) 
						--CASE WHEN ISNULL(DRC.Description,'') = 'Reject' THEN 2 ELSE 
						--			CASE WHEN isnull(R.IsAbandoned,0) = 0 THEN (CASE WHEN R.ActualArrival IS NOT NULL THEN 1 ELSE 0 END ) ELSE 1 END   
						CASE WHEN ISNULL(DRC.Description,'') = 'Reject' THEN 2 ELSE 
									CASE WHEN R.Status  IN (2,4) THEN 0 
									WHEN R.Status IN (3,5) THEN 1 END
						END AS OrderStatus  -- 0 - Upcoming, 1 - Completed, 2 - Rejected
						 
						,CAST(CASE WHEN DRC.Description = 'Accept' THEN 1 ELSE 0 END  AS BIT) AS IsAccepted
						,CASE WHEN ADR.RouteKey > 0 THEN 'InProgress' WHEN DRC.Description = 'Accept' AND ASD.Complete IS NULL THEN 'Accepted' ELSE '' END AS OrderProgress
						,OT.OrderType
						,CAST(CASE WHEN (ASD.CompleteDate IS NOT NULL AND   DATEDIFF(HOUR, ASD.CompleteDate, GETDATE()) <=24) OR ASD.CompleteDate IS NULL THEN 1 ELSE 0 END AS BIT) AS IsEditable
						FROM			OrderHeader OH WITH (NOLOCK)
						INNER JOIN		OrderDetail  OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
						INNER JOIN		OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey						
						LEFT JOIN		ContainerSize CS WITH (NOLOCK) ON OD.ContainerSizeKey = CS.ContainerSizeKey
						INNER JOIN		Routes  R WITH (NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
						-- LEFT JOIN		RouteStatus RS ON R.Status = RS.Status
						LEFT JOIN		Leg L WITH (NOLOCK) ON R.LegKey = L.LegKey
						LEFT JOIN		Address AD WITH (NOLOCK) ON R.SourceAddrKey = AD.AddrKey
						LEFT JOIn		Address AD1 WITH (NOLOCK) ON R.DestinationAddrKey = AD1.AddrKey 
						LEFT JOIN		(SELECT		STRING_AGG(CT.TypeDescription, ',')  AS   ContainerProperties, OrderDetailKey
										FROM		ContainerTypesLink	CTL
										INNER JOIN	ContainerTypes CT ON CTL.ContainerTypeKey = CT.ContainerTypeKey
										GROUP BY	OrderDetailKey) CT ON OD.OrderDetailKey = CT.OrderDetailKey
						LEFT JOIN		#DriverRouteAcceptance DRC  WITH (NOLOCK) ON R.RouteKey = DRC.RouteKey AND DRC.DriverKey = @DriverKey
						LEFT JOIN		DA_AppDriverScreenDetails ASD WITH (NOLOCK) ON R.RouteKey = ASD.RouteKey
						LEFT JOIN		DA_ActiveDriverRoutes ADR WITH (NOLOCK) ON R.RouteKey = ADR.RouteKey
						WHERE			(R.DriverKey = @DriverKey OR DRC.DriverKey = @DriverKey)
										AND CASE WHEN @UserKey = @UserKey THEN OH.CreateDate ELSE '2024-04-05' END >= '2024-04-05'
						)A --  OD.OrderDetailKey = 49045
			WHERE		(CASE WHEN @IsCompleted = 0 THEN A.RouteStatus ELSE 0 END IN (2,4) OR CASE WHEN @IsCompleted = 1 THEN A.RouteStatus ELSE 0 END IN (3,5) 
						OR 	ISNULL(OrderDesc,'') = 'Reject'	 )						
						AND CASE WHEN OrderStatus IN (1,2) THEN 1 ELSE OrderStatus END = @IsCompleted 
						
						-- AND CASE WHEN @UserKey = 886 THEN ContainerNo ELSE 'ECMU7220067' END   = 'ECMU7220067'
			ORDER BY	ScheduledPickupDate 


			IF(@IsDebug = 1)
				BEGIN
					SELECT * FROM (SELECT *, CASE
							WHEN CAST(AgingDate AS DATE) = CAST(GETDATE() AS DATE) OR OrderProgress = 'InProgress'  THEN 'Today'
							WHEN DATEPART(ISO_WEEK, AgingDate) = DATEPART(ISO_WEEK, GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) THEN 'This Week'
							WHEN MONTH(AgingDate) = MONTH(GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) THEN 'This Month'
							ELSE 'Older'
						END AS Aging
							FROM #Data) DA 
							WHERE Aging = 'Today'
							ORDER BY CASE WHEN  OrderProgress = 'InProgress' THEN 1 WHEN OrderProgress = 'Accepted' THEN 2 ELSE 3 END,AgingDate  
				END
			
			DECLARE @ActiveRouteKey INT = 0, @IsRouteExists INT = 0
			SELECT @ActiveRouteKey = RouteKey FROM DA_ActiveDriverRoutes WHERE DriverKey = @DriverKey
			SELECT @IsRouteExists = COUNT(*) from Routes WITH (NOLOCK) WHERE RouteKey = @ActiveRouteKey
			IF((SELECT ISNULL([Status],0) FROM Routes WITH (NOLOCK) WHERE RouteKey = @ActiveRouteKey) = 5 OR (@IsRouteExists = 0) )
				BEGIN
					DELETE FROM DA_ActiveDriverRoutes WHERE RouteKey = @ActiveRouteKey and DriverKey = @DriverKey
					UPDATE DA_AppDriverScreenDetails SET Complete = 1, CompleteDate = GETDATE() 
					WHERE RouteKey = @ActiveRouteKey and DriverKey = @DriverKey
					SET @ActiveRouteKey = 0
				END

			-- SELECT		SD.DriverKey, RT.DriverKey, RT.Status, SD.Complete , SD.CreatedDate , DATEDIFF(DAY, SD.CreatedDate,GETDATE()) 
			UPDATE		SD SET Complete = 1, CompleteDate = GETDATE()
			FROM		DA_AppDriverScreenDetails  SD
			INNER JOIN	Routes RT WITH(NOLOCK) ON SD.RouteKey = RT.RouteKey
			WHERE		Complete = 0 AND RT.Status = 5 AND DATEDIFF(DAY, SD.CreatedDate,GETDATE())  > 5

			SET @ActiveRouteKey = ISNULL(@ActiveRouteKey,0)

			SET @JsonRes =  (SELECT @ActiveRouteKey AS ActiveRouteKey, RouteDetails =  ((SELECT *, CASE
							WHEN RouteKey = @ActiveRouteKey THEN 'Active'
							WHEN (CAST(AgingDate AS DATE) = CAST(GETDATE() AS DATE) OR OrderProgress = 'InProgress' ) 
									AND @IsCompleted = 1 THEN 'Today'
							WHEN (CAST(AgingDate AS DATE) = CAST(GETDATE() AS DATE) OR OrderProgress = 'InProgress' ) 
									AND @IsCompleted = 0 THEN 'This Week'
							WHEN DATEPART(ISO_WEEK, AgingDate) = DATEPART(ISO_WEEK, GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) AND @IsCompleted = 1
									THEN 'This Week'
							WHEN DATEPART(ISO_WEEK, AgingDate) = DATEPART(ISO_WEEK, GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) AND @IsCompleted = 0
									THEN 'Older'
							WHEN MONTH(AgingDate) = MONTH(GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) AND @IsCompleted = 1
									THEN 'This Month'
							WHEN MONTH(AgingDate) = MONTH(GETDATE()) 
									AND YEAR(AgingDate) = YEAR(GETDATE()) AND @IsCompleted = 0
									THEN 'Older'
							ELSE 'Older'
						END AS Aging
							--, DocDetails = ( SELECT		D.DocumentKey,DocumentType,CreateDate,CreateUserKey,OriginalFileName,OriginalFileType,
							--FileSizeinMB,IsDeleted,DeletedDate,DeletedUserKey,REPLACE(FilePath,'\','/')FilePath, LD.RouteKey  
							--FROM		Document D  WITH (NOLOCK) 
							--INNER JOIN	ContainerLegDocuments  LD  WITH (NOLOCK) ON LD.DocumentKey = D.DocumentKey
							--WHERE DA.RouteKey = LD.RouteKey
							--FOR JSON PATH) 
							FROM #Data DA 
							ORDER BY CASE WHEN  OrderProgress = 'InProgress' THEN 1 WHEN OrderProgress = 'Accepted' THEN 2 ELSE 3 END,AgingDate   FOR JSON PATH))
							 -- FROM DA_ActiveDriverRoutes WHERE DriverKey = @DriverKey 						
							FOR JSON PATH)

				
			SELECT ISNULL(@JsonRes,'')

			IF(ISNULL(@JsonRes,'') = '')
				BEGIN
					SET		@IntError = 'No Records Found'
					SET		@Reason = 'No Records Found'
					SET		@Status = 0
				END
			ELSE
				BEGIN
					SET		@IntError = 'Success'
					SET		@Reason = 'Success'
				END
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
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout, UpdatedDate = GETDATE(), ReponseJSONString = @JsonRes
	WHERE LogKey = @LogKey

END

