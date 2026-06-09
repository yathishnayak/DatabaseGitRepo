

/*
DECLARE @UserKey INT = 886, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"DriverKey":1117,"OrderDetailKey":152529,"RouteKey":524727,"Latitude":13.3459902,"Longitude":74.7625873,"DriverExceptionKey":3,"DriverExceptionText":"No additional information"}'
EXEC [DA_DriverExceptionDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_DriverExceptionDetails]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":3,"OrderDetailKey":73896,"RouteKey":261874,"DriverExceptionKey":2,"DriverExceptionText":"Text"}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(1000) = '',
	@IsLogout		BIT = 0 OUTPUT
)

AS
BEGIN
	SET @IsLogout = 0

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

	DECLARE @LogKey INT

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
			SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout, UpdatedDate = GETDATE(), ReponseJSONString = NULL
			WHERE LogKey = @LogKey
			RETURN
		END
	-- validate
	


	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE		@DriverKey INT, @OrderDetailKey INT, @RouteKey INT, @DriverExceptionKey INT, @DriverExceptionText VARCHAR(1000)

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
				SELECT	@DriverKey = DriverKey,@OrderDetailKey = OrderDetailKey, @RouteKey = RouteKey, @DriverExceptionKey = DriverExceptionKey
						,@DriverExceptionText = DriverExceptionText,@Latitude = Latitude, @Longitude = Longitude
				FROM	OPENJSON(@JSONString, '$')
						WITH (
								DriverKey			INT				'$.DriverKey',
								OrderDetailKey		INT				'$.OrderDetailKey',
								RouteKey			INT				'$.RouteKey',
								DriverExceptionKey	INT				'$.DriverExceptionKey',
								DriverExceptionText	VARCHAR(1000)	'$.DriverExceptionText',
								Latitude			FLOAT			'$.Latitude',
								Longitude			FLOAT			'$.Longitude'
							)

				SET @DriverKey  = ISNULL(@DriverKey,0)
				SET @OrderDetailKey  = ISNULL(@OrderDetailKey,0)
				SET @RouteKey  = ISNULL(@RouteKey,0)
				SET @DriverExceptionKey  = ISNULL(@DriverExceptionKey,0)

				SET	@Status = 1
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				IF(SELECT COUNT(*) FROM DriverExceptionDetails WHERE RouteKey = @RouteKey) > 1
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'Exception Entry Found for this route'
						SET	@GenError = @InternalError
					END
				ELSE
					BEGIN
						IF(@DriverKey = 0 OR @OrderDetailKey = 0 OR @RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'DriverKey or OrderDetailkey or Routekey cannot be 0 or NULL'
							END

						IF(@DriverExceptionKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; DriverExceptionKey cannot be 0 or NULL'
							END

						IF(@DriverExceptionKey = 6 AND ISNULL(@DriverExceptionText,'') = '')
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; DriverExceptionText cannot Blank'
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

				INSERT INTO		DriverExceptionDetails
								(DriverKey,OrderDetailKey,RouteKey,DriverExceptionKey,DriverExceptionText,CreateDate)
				SELECT			@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey,@DriverExceptionText,GETDATE()

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
