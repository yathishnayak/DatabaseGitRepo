/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"FileName": "NACBobtailTemplate.xlsx",
    "CustKey": "0",
    "SheetData": "[{\"CustomerID\":\"\",\"CustomerName\":\"Century (Amazon) (JCT)\",\"RateType\":\"NAC\",\"Market\":\"Chic\",\"LineItemName\":\"Bobtail\",\"BobtailRate\":0,\"BobtailFormat\":\"\",\"City\":\"CA\",\"State\":\"AS\",\"Zip\":1,\"LocationName\":\"\",\"LocationNameintheSystem\":\"\",\"EffectiveDate\":\"05-11-2025\",\"EffectiveDateFrom\":\"\",\"ExpiryDate\":\"\"}]"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [SELL_NAC_BOBTAIL_InsertFileProcessInfo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[SELL_NAC_BOBTAIL_InsertFileProcessInfo_V2] -- [SELL_NAC_BOBTAIL_InsertFileProcessInfo] 'ert','',''
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
	
		DECLARE 
			@FileName			VARCHAR(100),
			@CustKey			INT,
			@JSOnData			NVARCHAR(MAX)

		SELECT 
			@FileName	= FileName,
			@CustKey	= CustKey,
			@JSOnData	= JSOnData
		FROM OPENJSON(@JSONString)
		WITH
		(
			FileName		VARCHAR(100)		'$.FileName',
			CustKey			INT					'$.CustKey',
			JSOnData		NVARCHAR(MAX)		'$.SheetData' AS JSON
		)

	SET		@Status = 1
	SET			@Reason = 'Record Saved Successfully' 
	DECLARE			@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE		@FileProcessKey INT = 0

	If(ISNULL(@FileName,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '101'
		END
	ELSE IF (@UserKey = 0)
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '103'
		END

	IF(@Status = 1)
		BEGIN
			INSERT INTO		SELL_NAC_BOBTAIL_FileProcessInfo
							(FileName,DateUploaded,CustKey, FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),@CustKey,0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY
		EXEC SELL_NAC_BOBTAIL_InsertFileProcessData 
		@FileProcessKey = @FileProcessKey,
		@JsonData       = @JsonData,		
		@status			= @Status OUTPUT,		
		@Reason			= @Reason OUTPUT	
		END

	SELECT @Status AS Status, @Reason AS Reason, @FileProcessKey AS FileProcessKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END