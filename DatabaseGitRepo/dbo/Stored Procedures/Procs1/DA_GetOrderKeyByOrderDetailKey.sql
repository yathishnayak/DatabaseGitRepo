/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '[{"OrderDetailKey": 1234}]'
EXEC [DA_GetOrderKeyByOrderDetailKey] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT
SELECT @Status,@IntError,@Reason
*/
CREATE PROCEDURE	[dbo].[DA_GetOrderKeyByOrderDetailKey]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"OrderDetailKey": 1234}]',
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
		DECLARE @OrderDetailKey		INT 
		DECLARE @GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		DECLARE @InternalError	VARCHAR(1000)
		DECLARE @IsUATServer BIT = 0

		IF(@@SERVERNAME = 'JCTDEV')
			BEGIN
				SET @IsUATServer = 1
			END

		IF(ISNULL(@JSONString,'') <> '')
			BEGIN
				SELECT		@OrderDetailKey = OrderDetailKey
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									OrderDetailKey		INT		'$.OrderDetailKey'
								 )

				SET			@OrderDetailKey = ISNULL(@OrderDetailKey,0)

				DECLARE @JsonRes nvarchar(max)
				SET @JsonRes = (
				SELECT		TOP 1 OrderKey, OrderDetailKey From OrderDetail 
							WHERE OrderDetailKey=@OrderDetailKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
				SELECT @JsonRes
				SET	@Status = 1
			END
		

		IF (ISNULL(@JSONString,'') = '')
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'JSON String Cannot be Blank'
			END
		ELSE IF(@OrderDetailKey = 0)
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'OrderDetailKey Cannot be Null or 0'
			END


		IF(@Status = 0)
			BEGIN
				SET		@IntError = @InternalError
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN
				SET		@IntError = 'Success'
				SET		@Reason = 'Success'
			END
	END TRY
	BEGIN CATCH
		SET		@Status = 0
		SET		@IntError = 'Procedure Name : ' + ERROR_PROCEDURE() + '. Error Message : ' +  ERROR_MESSAGE()+ '. JSON String : ' + @JSONString
		SET		@Reason = 'Data Exception Error'
	END CATCH

	UPDATE DA_RequestResponseLogs
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = @JsonRes, IsLogout = @IsLogout
	WHERE LogKey = @LogKey

END
