/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"FileName" : "ert", "CustKey" : ""}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [SELL_NAC_DRAYBASE_InsertFileProcessInfo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX) = '{
					  "FileName": "NACDrayBase_202605-04T09_04_59964Z.xlsx",
	"CustKey": 3464,
	"SheetData": [
		{
			"CustomerName": "Bollore Logistic (JCT)",
			"RateType": "NAC",
			"Market": "Long Beach",
			"Terminal": "LA/LB",
			"OrderType": "",
			"DrayageBase": 546,
			"FSF": 0.09,
			"City": "Perris",
			"State": "CA",
			"Zip": 0,
			"LocationName": "",
			"LocationNameintheSystem": "",
			"Consignee": "",
			"TruckType": "",
			"EffectiveDate": "11-05-2025",
			"EffectiveDateFrom": "Invoice Date",
			"ExpiryDate": ""
		}
	]
					}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [SELL_NAC_DRAYBASE_InsertFileProcessInfo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[SELL_NAC_DRAYBASE_InsertFileProcessInfo_V2]
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
		@JsonData			NVARCHAR(MAX)

	SELECT 
		@FileName	= FileName	,
		@CustKey	= CustKey	,
		@JsonData	= JsonData
	FROM OPENJSON(@JSONString)
	WITH
	(
		FileName		VARCHAR(100)		'$.FileName'	,
		CustKey			INT					'$.CustKey'		,
		JsonData		NVARCHAR(MAX)		'$.SheetData' AS JSON
	)

	SET			@Status = 1
	SET			@Reason = 'Record Saved Successfully'
	DECLARE		@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE		@FileProcessKey INT = 0

	If(ISNULL(@FileName,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '101'
		END
	--ELSE IF (isnull(@CustKey,0) = 0)
	--	BEGIN
	--		SET @Status = 0
	--		SET @Reason = @ErrorMessage + '102'
	--	END
	ELSE IF (@UserKey = 0)
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '103'
		END 

	IF(@Status = 1)
		BEGIN
			INSERT INTO		SELL_NAC_Draybase_FileProcessInfo
							(FileName,DateUploaded,CustKey, FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),@CustKey,0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY

		EXEC SELL_NAC_DRAYBASE_InsertFileProcessData 
		@FileProcessKey = @FileProcessKey,
		@JsonData       = @JsonData,
		@Status         = @Status OUTPUT,
		@Reason         = @Reason OUTPUT
		END

	SELECT @FileProcessKey AS FileProcessKey, @Status AS [Status], @Reason AS Reason FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END