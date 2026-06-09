
/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"RouteKey":570426,"AcceptanceKey":1301,"Latitude":13.3459935,"Longitude":74.7625717,"ReasonKey":12,"AcceptReject":"reject","ReasonText":"HOS"}'
--SET @JSONString = '{"RouteKey":527951,"Latitude":13.3459828,"Longitude":74.7625784,"ReasonKey":4,"AcceptReject":"reject","ReasonText":"Over Assignments","AcceptanceKey":641}'
EXEC [DA_DriverRouteAcceptance] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_DriverRouteAcceptance]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"RouteKey":177966, "ReasonKey":0, "AcceptReject":"reject", "ReasonText":"terminated"}]',
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

		DECLARE @RouteKey		INT,
				@ReasonKey		SMALLINT,
				@AcceptReject	VARCHAR(50),
				@ReasonText		VARCHAR(50)

		DECLARE @GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator; '
		DECLARE @InternalError	VARCHAR(1000) = '', @Latitude FLOAT,@Longitude FLOAT	, @AcceptanceKey INT = 0, @Desc VARCHAR(20) = ''
				, @IsRecordExists INT = 0	


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
				SELECT		@RouteKey		= RouteKey,
							@ReasonKey		= ReasonKey,	
							@AcceptReject	= AcceptReject,
							@ReasonText		= ReasonText,@Latitude = Latitude, @Longitude = Longitude,@AcceptanceKey = AcceptanceKey						
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									RouteKey		INT				'$.RouteKey',
									ReasonKey		SMALLINT		'$.ReasonKey',
									AcceptReject	VARCHAR(50)		'$.AcceptReject',
									ReasonText		VARCHAR(50)		'$.ReasonText',
									Latitude		FLOAT			'$.Latitude',
									Longitude		FLOAT			'$.Longitude',
									AcceptanceKey	INT				'$.AcceptanceKey'
								 )

				SET			@RouteKey   = ISNULL(@RouteKey,0)
				SET			@ReasonKey  = ISNULL(@ReasonKey, 0)
				SET			@ReasonText = ISNULL(@ReasonText, '')
				SET			@Status = 1

				DECLARE		@DriverKey INT
				SET			@DriverKey=(SELECT DriverKey FROM dbo.[routes] WHERE RouteKey=@RouteKey)			

				SELECT @Desc = Description FROM DriverRouteAcceptance WITH (NOLOCK) WHERE AcceptanceKey = @AcceptanceKey AND Description <> 'Pending'

				IF(ISNULL(@AcceptanceKey,0) = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'AcceptanceKey Cannot be 0'
					END
				ELSE IF(ISNULL(@Desc,'') <> '')
					BEGIN
						SET	@Status = 0
						SET @InternalError = CASE WHEN @Desc = 'Accept' THEN 'This Route is already Accepted' ELSE 'This Route is Already Rejected' END
						SET @GenError = @InternalError
					END
				ELSE 
					BEGIN
						IF(@RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'RouteKey Cannot be Null or 0; '
							END
						ELSE IF(SELECT COUNT(*) FROm Routes WHERE RouteKey = @RouteKey) = 0
							BEGIN
								SET	@Status = 0
								SET @InternalError = 'RouteKey not found in database'
							END

						IF(@AcceptReject = 'Reject' and @ReasonKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; ReasonKey Cannot be Null or 0 When Rejected; '
								SET @GenError = 'Kindly select a Reason'
							END
						IF(@AcceptReject = 'Reject' and @ReasonKey = 5 and @ReasonText = '')
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; ReasonText Cannot be Blank for Rejected reason as "Other"; '
								SET @GenError = 'Reason Text Cannot be Blank'
							END
					END
			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

				IF (@AcceptReject='Reject')
					BEGIN
						UPDATE		dbo.[routes]
						SET			DriverKey= NULL
						WHERE		RouteKey= @RouteKey

						UPDATE		dbo.[Routes]
						SET			[Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' AND IsActive=1 )
						WHERE		RouteKey= @RouteKey
					END

				--INSERT INTO		DriverRouteAcceptance (RouteKey,[Description], RejectReasonKey, RejectReasonDescr,CreateUserKey, DriverKey)
				--SELECT			@RouteKey,@AcceptReject, @ReasonKey, @ReasonText,@UserKey, @DriverKey

				UPDATE			DriverRouteAcceptance
				SET				[Description] = @AcceptReject,  ActionDate = GETDATE(), RejectReasonKey = @ReasonKey, RejectReasonDescr = @ReasonText
								, CreateUserKey = @UserKey
				WHERE			AcceptanceKey = @AcceptanceKey

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
