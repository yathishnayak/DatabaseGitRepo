/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"FileProcessKey" : 33}'
	EXEC [SELL_NAC_Accessorial_FileDownload_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[SELL_NAC_Accessorial_FileDownload_V2]
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
		@FileProcessKey		INT = 0

	SELECT 
		@FileProcessKey  = FileProcessKey
	FROM OPENJSON(@JSONString)
	WITH(
		FileProcessKey INT '$.FileProcessKey'
	)

	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, LineItem, 
			City, State, Zip, LocationName, IsLocationExists, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, ContainerSize, 
			EffectiveDate, EffectiveDateFrom
	from SELL_NAC_Accessorial_FinalDataOutput WITH (NOLOCK)
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END