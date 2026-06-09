
/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @@IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSOnString = '{"RouteKey":"527808","Latitude":28.455044724585278,"Longitude":77.00100277726649,"IsNoLinkedContainer":false,"ContainerDetails":[{"ContainerNo":"CAAU6878652"}]}'
EXEC DA_PairContainer @UserKey,@JSOnString,@Status OUTPUT, @@IntError OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status,@@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_PairContainer]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"RouteKey":185450,"Latitude":"13.346142","Longitude":"74.762551","ContainerDetails":[{"ContainerNo":"3PLI2406387"},{"ContainerNo":"ACEI2406420"},{"ContainerNo":"ZFSR6282623"}]}',
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
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID,IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@FirebaseID,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY
	
	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT
	
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

		DECLARE @DriverKey	INT ,@IsCompleted	BIT = 0
		DECLARE @GenError	VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError VARCHAR(1000)

		DECLARE @RouteKey INT = 0, @Latitude FLOAT,@Longitude FLOAT	, @ContainerDetails NVARCHAR(MAX) = '' , @IsNoLinkedContainer BIT = 0 

		CREATE TABLE #ContainerDetails
		(
			Sl				INT,
			ContainerNo		VARCHAR(50),
			Updated			BIT
		)

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
				SELECT		@RouteKey = Routekey,@Latitude = Latitude, @Longitude = Longitude, @IsNoLinkedContainer = IsNoLinkedContainer , @ContainerDetails = ContainerDetails
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									RouteKey			INT				'$.RouteKey',
									Latitude			FLOAT	'$.Latitude',
									Longitude			FLOAT	'$.Longitude',
									IsNoLinkedContainer	BIT				'$.IsNoLinkedContainer',
									ContainerDetails	NVARCHAR(MAX)	'$.ContainerDetails' AS JSON
								 )

				SET @RouteKey = ISNULL(@Routekey,0)
				SET @IsNoLinkedContainer = ISNULL(@IsNoLinkedContainer,0)
				
				INSERT INTO	#ContainerDetails (SL,ContainerNo,Updated)
				SELECT		ROW_NUMBER() OVER(ORDER BY ContainerNo) ,ContainerNo,0
				FROM		OPENJSON(@ContainerDetails, '$')
							WITH (
									ContainerNo	VARCHAR(50)		'$.ContainerNo'
								 )

				IF(@IsDebug = 1)
					BEGIN
						SELECT * FROM #ContainerDetails
					END
				
				SET			@Status = 1

				IF(@RouteKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'RouteKey Cannot be Null or 0'
					END

				IF((SELECT COUNT(*) FROM #ContainerDetails) > 1)
					BEGIN
						SET	@Status = 0
						SET @InternalError = ISNULL(@InternalError,'') +  '; Only one container at a time can be Linked'
					END

				IF((SELECT COUNT(*) FROM #ContainerDetails WHERE ISNULL(ContainerNo,'') = '') > 0 AND @IsNoLinkedContainer = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = ISNULL(@InternalError,'') +  '; Container No Cannot be Blank'
						SET @GenError = @InternalError
					END
			END
		

		DECLARE		@JsonResult NVARCHAR(MAX), @OrderDetailKey INT = 0, @ContainerNo VARCHAR(50) = '', @IsContainerLinked INT = 0
					, @IsContainerExists INT = 0
		DECLARE		@i INT = 1 , @n INT = (SELECT COUNT(*) FROM #ContainerDetails )
		DECLARE		@LinkedOrderDetailKey INT =0, @LinkedContainerNo VARCHAR(50) = '', @Message VARCHAR(2000) = '', @IsSameContainer BIT = 0
					,@IsOtherContainerLinked BIT = 0
		SET			@OrderDetailKey = (SELECT OrderDetailKey FROM Routes  WITH (NOLOCK) WHERE RouteKey = @RouteKey )
		SELECT		@ContainerNo = (SELECT ContainerNo from ORderDetail  WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey )

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = (SELECT dbo.DA_ReplaceStartSemicolon (@GenError)) 
			END
		ELSE IF(@IsNoLinkedContainer = 0)
			BEGIN
				

				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()
				-- SELECT * FROM #ContainerDetails
				WHILE (@i <= @n)
					BEGIN
						
						SELECT		@LinkedContainerNo = ContainerNo FROM #ContainerDetails WHERE Sl = @i
						SELECT		@IsContainerExists = COUNT(*) FROm OrderDetail WITH (NOLOCK) WHERE ContainerNo = @LinkedContainerNo
						SELECT		@LinkedOrderDetailKey = OrderDetailKey FROm OrderDetail  WITH (NOLOCK) WHERE ContainerNo = @LinkedContainerNo
						SELECT		@IsContainerLinked = COUNT(*) FROm OrderDetail  WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey
									AND ISNULL(IsLinked,0) = 0 AND ISNULL(LinkedContainerNo,'') = ''
						SELECT		@IsOtherContainerLinked = COUNT(*) FROm OrderDetail  WITH (NOLOCK) WHERE ContainerNo = @LinkedContainerNo 
									AND ISNULL(IsLinked,0) = 0 AND ISNULL(LinkedContainerNo,'') = ''
		
						-- SELECT		@ContainerNo, @OrderDetailKey, @LinkedContainerNo, @LinkedOrderDetailKey, @IsContainerLinked
						SET			@IsSameContainer = CASE WHEN @ContainerNo = @LinkedContainerNo THEN 1 ELSE 0 END

						IF(@IsDebug = 1)
							BEGIN
								SELECT @IsContainerLinked,@IsSameContainer, @LinkedContainerNo, @ContainerNo
							END
		 
						IF((ISNULL(@IsOtherContainerLinked,0) = 1 OR ISNULL(@IsContainerExists,0) = 0) AND @IsSameContainer = 0)
							BEGIN
								SET  @Message = @Message + '; Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 								
								UPDATE #ContainerDetails SET Updated = 1 WHERE Sl = @i

								UPDATE	OrderDetail
								SET		IsLinked = 1, LinkedContainerNo = @ContainerNo, LinkedOrderDetailKey = @OrderDetailKey
								WHERE	ContainerNo = @LinkedContainerNo	
								
								UPDATE	OrderDetail
								SET		IsLinked = 1, LinkedContainerNo = @LinkedContainerNo, LinkedOrderDetailKey = @LinkedOrderDetailKey
										,MarkedNoEmptyAvailable = NULL,MarkedNoEmptyAvailableBY = NULL
								WHERE	ContainerNo = @ContainerNo

								update R
								set LinkedContainer = @LinkedContainerNo,
									--containerNoSource = 'DriverApp',
									LinkedContainerSource = 'DriverApp',
									LinkedBy = @UserKey,
									LinkedDate = GETDATE()	
								from Routes R	
								WHERE RouteKey = @RouteKey
								--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
								--where od.OrderDetailKey = @OrderDetailKey

								INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT		GETDATE(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, 'DriverApp', 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 
							END
						ELSE IF(@IsSameContainer = 1)
							BEGIN
								SET @Status = 0
								SET  @Message = @Message + '; You cannot link the container to itself' 
							END
						ELSE IF ISNULL(@IsOtherContainerLinked,0) > 0
							BEGIN
								SET @Status = 0
								SET  @Message = @Message + '; Container ' + @ContainerNo + ' is Already Linked a Container'
							END
						--ELSE IF ISNULL(@IsContainerLinked,0) <> 1
						--	BEGIN
						--		SET @Status = 0
						--		SET  @Message = @Message + '; Container ' + @LinkedContainerNo + ' is Already Linked a Container'
						--	END
						

						SET			@i = @i + 1
					END
				
				UPDATE		A
				SET			PairContainer = 1
				FROM		DA_AppDriverScreenDetails A
				WHERE		Routekey = @RouteKey

				SET		@JsonResult =  ( SELECT * FROM #ContainerDetails FOR JSON PATH )
				
				SELECT	@JsonResult

				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@Message))
				SET		@Reason = CASE WHEN @IsNoLinkedContainer = 0 THEN 'Success' ELSE @IntError END
			END
		ELSE
			BEGIN
				
				IF(@IsDebug = 1)
					BEGIN
						SELECT @OrderDetailkey, @UserKey
					END
				
				UPDATE	OrderDetail
				SET		IsLinked = 0, LinkedContainerNo = NULL, LinkedOrderDetailKey = NULL
				WHERE	OrderDetailkey = @OrderDetailkey

				EXEC OrderDetail_NoEmptytoLink @OrderDetailkey, @UserKey

				UPDATE		RT
				SET			NoEmptyAvailableMarked = 1,
							NoEmptyAvailableMarkedBY=@UserKey,
							NoEmptyAvailableMarkedDate=GETDATE(),
							NoEmptyMarkedSource = 'DriverApp'
				FROM		Routes RT
				WHERE		Routekey = @RouteKey

				UPDATE		A
				SET			PairContainer = 1
				FROM		DA_AppDriverScreenDetails A
				WHERE		Routekey = @RouteKey

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

	UPDATE	DA_RequestResponseLogs
	SET		OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = @JsonResult, IsLogout = @IsLogout
	WHERE	LogKey = @LogKey

END

