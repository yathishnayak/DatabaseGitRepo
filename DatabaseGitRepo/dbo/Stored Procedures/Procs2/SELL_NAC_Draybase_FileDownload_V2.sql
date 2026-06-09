/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"FileProcessKey" : 1}'
	EXEC [SELL_NAC_Draybase_FileDownload_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[SELL_NAC_Draybase_FileDownload_V2] -- SELL_NAC_Draybase_FileDownload 1
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
	@FileProcessKey		int = 0

	SELECT 
	@FileProcessKey		= FileProcessKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		FileProcessKey		int			'$.FileProcessKey'
	)

	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, 
			City, State, Zip, LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom
	from SELL_NAC_Draybase_FinalDataOutput
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END