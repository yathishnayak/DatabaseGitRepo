
CREATE PROCEDURE	[dbo].[DA_GetLanguageDetails]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"LanguageCode":"en"}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(100) = '',
	@IsLogout		BIT = 0 OUTPUT

)

AS
BEGIN
	SET @IsLogout = 0

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	--EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

	--IF(@ValidateUser = 0)
	--	BEGIN
	--		SET @Status = 0
	--		SET @IntError = @FBInternalError
	--		SET @Reason = @FBExternalError
	--		SET @IsLogout = 1
	--		RETURN
	--	END
	-- validate
	
	DECLARE @LogKey INT
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @DriverKey	INT ,@IsCompleted	BIT = 0
		DECLARE @GenError	VARCHAR(200) = 'Something Went Wrong, Contact System Administrator'
		--DECLARE @InternalError VARCHAR(1000)

		DECLARE @LanguageCode VARCHAR(10) = '', @LanguageName VARCHAR(50) = ''

		CREATE TABLE #ContainerDetails
		(
			Sl				INT,
			ContainerNo		VARCHAR(50),
			Updated			BIT
		)

		IF (ISNULL(@JSONString,'') = '')
			BEGIN
				SET	@Status = 0
				SET @IntError = 'JSON String Cannot be Blank'
			END
		--ELSE IF(ISNULL(@UserKey,0) = 0)
		--	BEGIN
		--		SET	@Status = 0
		--		SET @IntError = 'UserKey Cannot be Blank'
		--	END
		ELSE
			BEGIN				
				SELECT		@LanguageCode = LanguageCode
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									LanguageCode			VARCHAR(20)				'$.LanguageCode'
								 )

				SET @LanguageCode = ISNULL(@LanguageCode,0)
				SET @Status = 1

END

		IF(@LanguageCode = '' AND  @Status <> 0)
			BEGIN
				SET	@Status = 0
				SET @IntError = 'Language Code Cannot be Blank OR NULL'
			END
		ELSE IF (@LanguageCode NOT IN ('en','es') AND  @Status <> 0)
			BEGIN
				SET	@Status = 0
				SET @IntError = 'Check Language Code'
			END

		IF(@Status = 0)
			BEGIN
				SET @Reason = @GenError
			END
		ELSE
			BEGIN
				SET @LanguageName = (CASE @LanguageCode
				WHEN 'en' THEN 'English'
				WHEN 'es' THEN 'Spanish'
				END)
				
				DECLARE @JsonResult NVARCHAR(MAX)

				SET @JsonResult = (SELECT B.PhraseName + '$$$' +  A.PhraseName   AS ConvertedPhrase
				FROM		(SELECT		PD.LangPhraseDetailskey,PD.LanguageName,PD.LangPhraseKey
										,CASE WHEN ISNULL(PD.PhraseName,'') = '' THEN PD1.PhraseName ELSE PD.PhraseName END  PhraseName
							FROM		(SELECT * FROM DA_LanguagePhraseDetails WHERE LanguageName = @LanguageName)  PD
							LEFT JOIN	(SELECT * FROM DA_LanguagePhraseDetails WHERE LanguageName = 'English') PD1 ON  PD.LangPhraseKey = PD1.LangPhraseKey)  A
				INNER JOIN	DA_LanguagePhraseMaster B ON A.LangPhraseKey = B.LangPhraseKey
				WHERE		LanguageName = @LanguageName
				FOR JSON PATH , WITHOUT_ARRAY_WRAPPER )

				SELECT REPLACE(REPLACE(REPLACE(REPLACE(@JsonResult,'},{"ConvertedPhrase":',''),'$$$','":"'),'""','","'),'"ConvertedPhrase":','')

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
	SET		OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = @JsonResult
	WHERE	LogKey = @LogKey

END

