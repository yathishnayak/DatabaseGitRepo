CREATE PROCEDURE	[dbo].[DA_InsertReasonCodes]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":1117,"RouteKey":524727,"Latitude":13.3459902,"Longitude":74.7625873,"ReasonCodeKey":3,"ReasonCodeText":"No additional information","RouteType":"Pickup"}',
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

		DECLARE		@DriverKey INT, @RouteKey INT, @ReasonCodeKey INT, @ReasonCodeText VARCHAR(1000), @RouteType  VARCHAR(50)

		DECLARE		@GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator; '
		DECLARE		@InternalError	VARCHAR(1000) = '', @Latitude FLOAT,@Longitude FLOAT		
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
				SELECT	@DriverKey = DriverKey,@RouteKey = RouteKey, @ReasonCodeKey = ReasonCodeKey
						,@ReasonCodeText = ReasonCodeText,@Latitude = Latitude, @Longitude = Longitude, @RouteType = RouteType
				FROM	OPENJSON(@JSONString, '$')
						WITH (
								DriverKey			INT				'$.DriverKey',
								RouteKey			INT				'$.RouteKey',
								ReasonCodeKey		INT				'$.ReasonCodeKey',
								ReasonCodeText		VARCHAR(1000)	'$.ReasonCodeText',
								RouteType			VARCHAR(500)	'$.RouteType',
								Latitude			FLOAT			'$.Latitude',
								Longitude			FLOAT			'$.Longitude'
							)

				SET @DriverKey  = ISNULL(@DriverKey,0)
				SET @RouteType  = ISNULL(@RouteType,0)
				SET @RouteKey  = ISNULL(@RouteKey,0)
				SET @ReasonCodeKey  = ISNULL(@ReasonCodeKey,0)

				SET	@Status = 1
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				IF(SELECT COUNT(*) FROM DA_DriverReasonCodeDetails WHERE RouteKey = @RouteKey) > 0
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'Reason Code Entry Found for this route'
						SET	@GenError = @InternalError
					END
				ELSE
					BEGIN
						IF(@DriverKey = 0 OR @RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'DriverKey or Routekey cannot be 0 or NULL'
							END

						IF(@ReasonCodeKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; ReasonCode Key cannot be 0 or NULL'
							END

						IF(@ReasonCodeKey = 2 AND ISNULL(@ReasonCodeText,'') = '')
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; ReasonCodeText cannot Blank'
								SET @GenError = @InternalError
							END
					END
			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = @InternalError
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

				INSERT INTO		DA_DriverReasonCodeDetails
								(DriverKey,RouteKey,ReasonCodeKey,ReasonCodeText,CreatedDate)
				SELECT			@DriverKey,@RouteKey,@ReasonCodeKey,@ReasonCodeText,GETDATE()

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
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = 'No Response for this Query', IsLogout = @IsLogout
	WHERE LogKey = @LogKey

END
