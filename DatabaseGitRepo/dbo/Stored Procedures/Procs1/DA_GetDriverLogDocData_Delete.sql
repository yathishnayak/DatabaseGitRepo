
/*
DECLARE @UserKey INT = 418, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"DateFrom":"2025-02-19","DateTo":"2025-02-26","DriverKey":1681}'
EXEC [DA_GetDriverLogDocData_Delete] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT,  @Reason OUTPUT,@IsDebug
SELECT @Status,@IntError,@Reason, @IsDebug
*/

CREATE PROCEDURE	[dbo].[DA_GetDriverLogDocData_Delete]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"RouteKey":185450,"Latitude":"13.346142","Longitude":"74.762551","ChargeDetails":[{"ChargeDesc":"Tri-Axle PU","ItemKey":0},{"ChargeDesc":"Chassis Split","ItemKey":139}]}',
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

	-- SET @IsDebug = 1 

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000), @JsonRes NVARCHAR(MAX)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

	IF(@IsDebug = 1)
		BEGIN
			SET @ValidateUser = 1
		END

	DECLARE @LogKey INT
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID,IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@FirebaseID,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY

	IF(@ValidateUser = 0)
		BEGIN
			SET @Status = 0
			SET @IntError = @FBInternalError
			SET @Reason = @FBExternalError
			SET @IsLogout = 1

			UPDATE DA_RequestResponseLogs
			SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout,  UpdatedDate = GETDATE(), ReponseJSONString = NULL
			WHERE LogKey = @LogKey

			RETURN
		END
	-- validate	
	

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @DriverKey	INT ,@DateFrom	VARCHAR(50) ,@DateTo	VARCHAR(50) 
		DECLARE @GenError	VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError VARCHAR(1000) = '', @NoofDays INT = 30
		DECLARE @IsUATServer BIT = 0


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
				SELECT		@DriverKey = DriverKey, @DateFrom = DateFrom, @DateTo = DateTo
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									DriverKey	INT				'$.DriverKey',
									DateFrom	VARCHAR(50)		'$.DateFrom',
									DateTo		VARCHAR(50)		'$.DateTo'
								 )

				SET			@DriverKey = ISNULL(@DriverKey,0)
				
				-- SET @DateTO = @DateTO + 1

				SET	@Status = 1

				-- SET @DriverKey = 1681

				IF(@DriverKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DriverKey Cannot be Null or 0'
					END
				ELSE IF((@DateFrom IS NULL OR @DateFrom = '') OR (@DateTo IS NULL OR @DateTO = '')  )
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DateFrom OR DateTo Cannot be Null'
					END
				ELSE IF (TRY_CAST(@DateFrom AS DATETIME) IS NULL OR TRY_CAST(@DateTo AS DATETIME) IS NULL)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DateFrom OR DateTo format in InValid'
					END
			END

		CREATE TABLE #TempDates (DateValue DATETIME);

		WITH DateCTE AS (
			SELECT CAST(@DateFrom AS DATETIME) AS DateValue
			UNION ALL
			SELECT CAST(DATEADD(DAY, 1, DateValue) AS DATETIME)
			FROM DateCTE
			WHERE DateValue < CAST(@DateTo AS DATETIME)
		)
		INSERT INTO #TempDates (DateValue)
		SELECT DateValue FROM DateCTE OPTION (MAXRECURSION 0);
		
		IF(@IsDebug = 1)
			BEGIN
				SELECT @DateFrom,@DateTo,@DriverKey
				SELECT * FROM #TempDates
			END

		IF(@Status = 0)
			BEGIN
				SET			@IntError =   (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET			@Reason = @GenError
			END
		ELSE
			BEGIN

				IF(@IsDebug = 1)
					BEGIN
						SELECT 'Dates', CAST(CONVERT(VARCHAR,@DateFrom,101) AS DATETIME), CAST(CONVERT(VARCHAR,@DateTo,101) AS DATETIME)
					END
				
				IF OBJECT_ID('tempdb..#Routes') IS NOT NULL  
					DROP TABLE #Routes;

				IF OBJECT_ID('tempdb..#OrderExpense') IS NOT NULL  
					DROP TABLE #OrderExpense;				
				
				SELECT		RouteKey,ActualArrival,ActualDeparture,FromLocationWaitTimeFrom,FromLocationWaitTimeTo,ToLocationWaitTimeFrom,ToLocationWaitTimeTo
							,ChassisKey,ChassisNo,IsDryRun,IsEmpty,OrderDetailKey,SourceAddrKey,DestinationAddrKey,LegKey,DriverKey
				INTO		#Routes
				FROM		(SELECT * FROM Routes WITH (NOLOCK)  WHERE OrderDetailkey = 216052) RT 
				WHERE		(ActualArrival >= CAST(CONVERT(VARCHAR,@DateFrom,101) AS DATETIME)  AND 
							ActualArrival <= CAST(CONVERT(VARCHAR,@DateTo,101) AS DATETIME) + 1) OR
							ActualDeparture >= CAST(CONVERT(VARCHAR,@DateFrom,101) AS DATETIME)  AND 
							ActualDeparture <= CAST(CONVERT(VARCHAR,@DateTo,101) AS DATETIME) + 1
							
				IF(@IsDebug = 1)
					BEGIN
						SELECT @DateFrom,@DateTo
						SELECT * FROM #Routes
					END

				--SELECT * 
				--FROM (
				--	SELECT		Itemkey, OE.RouteKey
				--	FROM		OrderExpense OE
				--	INNER JOIN	#Routes RT ON OE.RouteKey = RT.RouteKey
				--) AS SourceTable
				--PIVOT (
				--	SUM(SalesAmount) FOR Itemkey IN ([2021], [2022])
				--) AS PivotTable;

				SELECT		RT.RouteKey, Itemkey
				INTO		#OrderExpense
				FROM		OrderExpense OE
				INNER JOIN	#Routes RT ON OE.RouteKey = RT.RouteKey
				WHERE		OE.Itemkey IN (136,232)

				SET @JsonRes = (
				SELECT		ISNULL(DriverID,'') AS CarrierCode, ISNULL(D.FirstName,'') + ' ' + ISNULL(D.LastName,'') AS FirstLastName, ISNULL(DOTNumber,'') AS DOTNo, ISNULL(MCNumber,'') AS MCNo
							, CONVERT(VARCHAR,TD.DateValue,101) AS LogDate
							, RouteDetails =	
							(SELECT		RT.RouteKey, ContainerNo as ContainerNo
										, L.FromLocation + CHAR(10) + ADF.City + CHAR(10) +  ADF.ZipCode AS ShipFrom 
										,  CONVERT(VARCHAR(10), ActualDeparture, 120) + CHAR(10) + CONVERT(VARCHAR(8), ActualDeparture, 108) AS ShipFromDate
										, CAST(CONVERT(VARCHAR(8), FromLocationWaitTimeFrom, 108) AS VARCHAR) + ' - ' 
										+  CAST(CONVERT(VARCHAR(8), FromLocationWaitTimeTo, 108) AS VARCHAR) + CHAR(10) + 
										'Total ' + CAST(DATEDIFF(MINUTE, FromLocationWaitTimeFrom, FromLocationWaitTimeTo) / 60 AS VARCHAR) + ':' +
										CAST(DATEDIFF(MINUTE, FromLocationWaitTimeFrom, FromLocationWaitTimeTo) % 60 AS VARCHAR) 
										AS ShipFromWaitTime
										, ISNULL(L.ToLocation,'') + CHAR(10) +  ADT.City + CHAR(10) + ADT.ZipCode AS ShipTo
										,  CONVERT(VARCHAR(10), ActualArrival, 120) + CHAR(10) + CONVERT(VARCHAR(8), ActualArrival, 108) AS ShipToDate
										, CAST(CONVERT(VARCHAR(8), ToLocationWaitTimeFrom, 108) AS VARCHAR) + ' - ' 
										+  CAST(CONVERT(VARCHAR(8), ToLocationWaitTimeTo, 108) AS VARCHAR)  + CHAR(10) + 
										'Total ' + CAST(DATEDIFF(MINUTE, ToLocationWaitTimeFrom, ToLocationWaitTimeTo) / 60 AS VARCHAR) + ':' +
										CAST(DATEDIFF(MINUTE, ToLocationWaitTimeFrom, ToLocationWaitTimeTo) % 60 AS VARCHAR) 
										AS ShipToWaitTime
										, CASE WHEN RT.ChassisKey In (591) THEN RT.ChassisNo ELSE CH.chassisNo END AS ChassisNo
										, CASE WHEN OE1.RouteKey = 0 THEN 'N' ELSE 'Y' END AS OW
										, CASE WHEN ISNULL(RT.IsDryRun,0) = 1 THEN 'Y' ELSE 'N' END AS DRY
										, CASE WHEN ISNULL(RT.IsEmpty,0) = 0 THEN 'L' ELSE 'E' END AS LE
										, CASE WHEN OE2.RouteKey = 0 THEN 'N' ELSE 'Y' END AS Gen
										, ISNULL(OE.Charges,'')Charges , ISNULL(OE.ChargeNotes,'')ChargeNotes
							FROM		#Routes  RT WITH (NOLOCK)
							INNER JOIN	OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
							INNER JOIN	Address ADF WITH (NOLOCK) ON RT.SourceAddrKey = ADF.AddrKey
							INNER JOIN	Address ADT WITH (NOLOCK) ON RT.DestinationAddrKey = ADT.AddrKey
							INNER JOIN	Leg L WITH (NOLOCK) On RT.LegKey = L.LegKey
							INNER JOIN	Chassis CH WITH (NOLOCK) ON CH.chassisKey = RT.ChassisKey
							LEFT JOIN	#OrderExpense OE1 ON RT.RouteKey = OE1.RouteKey AND Itemkey = 136
							LEFT JOIN	#OrderExpense OE2 ON RT.RouteKey = OE2.RouteKey AND OE2.Itemkey = 232
							LEFT JOIN	(SELECt		Routekey, STRING_AGG(ISNULL(ItemID,''), ', ') AS Charges 
													, STRING_AGG(ISNULL(InternalNotes,''), ', ') AS ChargeNotes
										FROM		OrderExpense  OE WITH (NOLOCK)
										INNER JOIN	Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
										GROUP BY	RouteKey ) OE ON RT.RouteKey = OE.RouteKey
							WHERE		RT.DriverKey = DriverKey  AND FromLocationWaitTimeFrom IS NOT NULL
										AND (CONVERT(VARCHAR,TD.DateValue,101) = CONVERT(VARCHAR,RT.ActualArrival,101)
										OR CONVERT(VARCHAR,TD.DateValue,101) = CONVERT(VARCHAR,RT.ActualDeparture,101))
										FOR JSON PATH )
				FROM		Driver D WITH (NOLOCK)
				INNER JOIN	#TempDates TD ON 1 = 1
				WHERE		DriverKey = @DriverKey
				FOR JSON PATH)

				SET	@Status = 1
				SET	@IntError =   'Success'
				SET	@Reason = 'Sucess'

				SELECT @JsonRes AS JsonRes
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


	IF OBJECT_ID('tempdb..#Routes') IS NOT NULL  
		DROP TABLE #Routes;

	IF OBJECT_ID('tempdb..#OrderExpense') IS NOT NULL  
		DROP TABLE #OrderExpense;

END

