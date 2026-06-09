

/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"DriverKey":3,"OrderDetailKey":73896,"RouteKey":261874,"DriverExceptionKey":4,"DriverExceptionText":""}'
EXEC [DA_ConfirmPickupDelivery] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_GetPaid]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":3,"RouteKey":261874,"Latitude":10.2356854,"Longitude":25.365214875}',
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

		DECLARE		@DriverKey INT, @RouteKey INT -- , @RouteType VARCHAR(20)

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
				SELECT	@DriverKey = DriverKey,@RouteKey = RouteKey,@Latitude = Latitude, @Longitude = Longitude 
				FROM	OPENJSON(@JSONString, '$')
						WITH (
								DriverKey			INT				'$.DriverKey',
								RouteKey			INT				'$.RouteKey',
								Latitude			FLOAT	'$.Latitude',
								Longitude			FLOAT	'$.Longitude'
							)

				SET @DriverKey  = ISNULL(@DriverKey,0)
				SET @RouteKey  = ISNULL(@RouteKey,0)


				SET	@Status = 1
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				IF(@DriverKey = 0 OR @RouteKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DriverKey or Routekey cannot be 0 or NULL'
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

				UPDATE			RT
				SET				Status = 3
				FROM			Routes RT
				WHERE			RouteKey = @RouteKey

				DELETE FROM DA_ActiveDriverRoutes
				WHERE DriverKey = @DriverKey AND RouteKey = @RouteKey

				UPDATE		A
				SET			Complete = 1, CompleteDate = GETDATE()
				FROM		DA_AppDriverScreenDetails A
				WHERE		Routekey = @RouteKey

				SET				@IntError = 'Success'
				SET				@Reason = 'Success'
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
