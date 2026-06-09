

/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"DriverKey":802,"RouteKey":"527951","DocumentKey":358351,"Latitude":13.3459874,"Longitude":74.7625833}'
EXEC [DA_DeleteDocument] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_DeleteDocument]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":3,"RouteKey":261874,"DocumentKey":2,"Latitude":10.23558472,"Longitude":25.2548715555  }',
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

		DECLARE		@DriverKey INT, @RouteKey INT, @DocumentKey INT

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
				SELECT	@DriverKey = DriverKey, @RouteKey = RouteKey, @DocumentKey = DocumentKey
						,@Latitude = Latitude, @Longitude = Longitude
				FROM	OPENJSON(@JSONString, '$')
						WITH (
								DriverKey			INT				'$.DriverKey',
								RouteKey			INT				'$.RouteKey',
								DocumentKey			INT				'$.DocumentKey',
								Latitude			FLOAT			'$.Latitude',
								Longitude			FLOAT			'$.Longitude'
							)

				SET @DriverKey  = ISNULL(@DriverKey,0)
				SET @RouteKey  = ISNULL(@RouteKey,0)
				SET @DocumentKey  = ISNULL(@DocumentKey,0)

				SET	@Status = 1
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText

				

				IF(@DriverKey = 0 OR @DocumentKey = 0 OR @RouteKey = 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'DriverKey or DocumentKey or Routekey cannot be 0 or NULL'
					END
				ELSE IF (SELECT COUNT(*) FROM Document WHERE DocumentKey = @DocumentKey) = 0
					BEGIN
						SET	@Status = 0
						SET @InternalError = 'Document is already deleted or does not exist.'
						SET @GenError = @InternalError
					END

			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				-- SELECT	@DriverKey,@OrderDetailKey,@RouteKey,@DriverExceptionKey, @DriverExceptionText
				
				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()
				
				DELETE FROM DriverDocuments WHERE DocumentKey = @DocumentKey
				DELETE FROM OrderDetailDocuments WHERE DocumentKey = @DocumentKey
				DELETE FROM ContainerLegDocuments WHERE DocumentKey = @DocumentKey
				DELETE FROM Document WHERE DocumentKey = @DocumentKey


				SET		@IntError = 'Deleted Successfully'
				SET		@Reason = 'Deleted Successfully'
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
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = 'No Response for this Query', IsLogout = @LogKey
	WHERE LogKey = @LogKey

END
