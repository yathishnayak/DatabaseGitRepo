/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketLocationKey" : 3}'
	EXEC [Get_CostZones_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_CostZones_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@MarketKey		int

	SELECT 
		@MarketKey	= MarketKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketKey		INT			'$.MarketLocationKey'
	)

	SELECT ZoneKey,ZoneName,MarketKey as MarketLocationKey FROM cost_Zones WITH(NOLOCK)
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Successs'
END