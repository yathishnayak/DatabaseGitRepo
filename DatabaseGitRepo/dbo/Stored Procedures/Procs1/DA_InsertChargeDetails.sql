
/*
DECLARE @UserKey INT = 886, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"Appversion":"v1.0.6[UAT]","RouteKey":"584589","Latitude":13.3459275,"Longitude":74.7625297,"Notes":"","ChargeDetails":[{"ChargeDesc":"Tarp/Un-Tarp","ItemKey":143}]}'
EXEC [DA_InsertChargeDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_InsertChargeDetails]
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

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

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

		DECLARE @DriverKey	INT ,@IsCompleted	BIT = 0
		DECLARE @GenError	VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError VARCHAR(1000) = '', @NoofDays INT = 30
		DECLARE @IsUATServer BIT = 0

		CREATE TABLE #ChargeDetails
			(
				SL			INT,
				ChargeDesc	VARCHAR(50),
				ItemKey		INT,
				RouteKey	INT
			)
		
		DECLARE @RecordFound INT = 0, @RouteKey INT = 0, @Latitude FLOAT,@Longitude FLOAT	, @ChargeDetails NVARCHAR(MAX) = '' , @Notes VARCHAR(500)

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

				SELECT		@RouteKey = Routekey,@Latitude = Latitude, @Longitude = Longitude , @ChargeDetails = ChargeDetails, @Notes = Notes
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									RouteKey		INT				'$.RouteKey',
									Latitude		FLOAT			'$.Latitude',
									Longitude		FLOAT			'$.Longitude',
									Notes			VARCHAR(500)	'$.Notes',
									ChargeDetails	NVARCHAR(MAX)	'$.ChargeDetails' AS JSON
								 )
				
				INSERT INTO	#ChargeDetails (SL,ChargeDesc,ItemKey)
				SELECT		ROW_NUMBER() OVER(ORDER BY ItemKey) ,ChargeDesc,ItemKey
				FROM		OPENJSON(@ChargeDetails, '$')
							WITH (
									ChargeDesc	VARCHAR(50)		'$.ChargeDesc',
									ItemKey		INT				'$.ItemKey'
								 )
				
				SET @RecordFound = (SELECT COUNT(1) FROM #ChargeDetails)
				SET @Status = 1

				IF(@RecordFound) = 0 AND ISNULL(@Notes,'') = ''
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'No Record Found'
					END
				ELSE
					BEGIN
						IF(SELECT COUNT(1) FROM #ChargeDetails WHERE RouteKey = 0) > 0
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'RouteKey Cannot be 0 or Blank'
							END

						IF(SELECT COUNT(1) FROM #ChargeDetails WHERE ItemKey = 0) > 0
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Itemkey''s Cannot be 0 or Blank'
							END
					END
			END

		DECLARE  @JsonRes nvarchar(max), @i INT = 1 , @n INT = (SELECT COUNT(1) FROM #ChargeDetails)
				,@OrderDetailKey INT, @ContainerNo VARCHAR(20), @ItemKey INT, @UnitCost DECIMAL(18,2), @ChargeDesc VARCHAR(200)
				,@IsExists INT = 0

		IF(@Status = 0)
			BEGIN
				SET		@IntError =   (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				
				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

				SELECT @OrderDetailKey = OrderDetailKey FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey
				SELECT @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey


				SELECT		OE.Itemkey,I.Description , OE.RouteKey
				INTO		#ChargeDelete
				FROM		OrderExpense OE 
				LEFT JOIN	#ChargeDetails CD ON CD.ItemKey = OE.Itemkey
				LEFT JOIN	Item I On OE.Itemkey = I.ItemKey
				WHERE		OE.RouteKey = @RouteKey AND OE.Itemkey IN (22,81,139,136,310,265,170,143) 
							AND CD.ItemKey IS NULL AND ChargeSource = 'DriverApp'			

				IF(@IsDebug = 1)
					BEGIN
						SELECT * FROm #ChargeDelete
					END

				DELETE		OE
				FROM		#ChargeDelete CD
				INNER JOIN	OrderExpense OE ON CD.Itemkey = OE.Itemkey AND CD.RouteKey = OE.RouteKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text' , Description + ' Item Deleted for Container '
				FROM			#ChargeDelete


				WHILE(@i <= @n)
					BEGIN
						SELECT @ItemKey = ItemKey FROM #ChargeDetails WHERE SL = @i
						SET @IsExists = (SELECT COUNT(1) FROM OrderExpense WITH (NOLOCK) WHERE RouteKey = @RouteKey AND Itemkey = @ItemKey)
						PRINT '@Record No - ' + CAST(@i AS VARCHAR)

						

						IF(@IsExists = 0)
							BEGIN
								PRINT '@IsExists - ' + CAST(@i AS VARCHAR)
								
								SELECT @UnitCost =  UnitCost, @ChargeDesc = Description FROM Item WITH (NOLOCK) WHERE ItemKey = @ItemKey
								SELECT @ContainerNo
								INSERT INTO		OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
												BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, InternalNotes)
								SELECT			@ItemKey, @RouteKey, @UnitCost, 1,  @UnitCost, Getdate(),  1, 0, 
												1, 0, 0, 'DriverApp', @OrderDetailKey,'Reported by driver : ' + @Notes


								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text' , @ChargeDesc + ' Item Added for Container '
							END

						SET @i = @i + 1
					END
				
				UPDATE		RT
				SET			ChargeNotes = @Notes
				FROM		Routes RT
				WHERE		RouteKey = @RouteKey

				UPDATE		A
				SET			Charges = 1
				FROM		DA_AppDriverScreenDetails A
				WHERE		Routekey = @RouteKey

				SET @JsonRes = (SELECT @ContainerNo AS ContainerNo, @RouteKey AS Routekey FOR JSON PATH)
				SELECT @JsonRes

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
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = @JsonRes, IsLogout = @IsLogout
	WHERE LogKey = @LogKey

END

