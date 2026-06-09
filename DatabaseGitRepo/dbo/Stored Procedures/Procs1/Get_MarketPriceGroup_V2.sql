/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketLocationKey" : 3}'
	EXEC [Get_MarketPriceGroup_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_MarketPriceGroup_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString,'') = ''
		BEGIN
			SET @Status = 0
			SET @Reason = 'Parameters not found'
			RETURN
		END

	DECLARE 
		@MarketLocationKey	int

	SELECT 
		@MarketLocationKey	= MarketLocationKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketLocationKey		INT			'$.MarketLocationKey'
	)
	SELECT PriceGroupingKey, PriceGrouping, MarketLocationKey
	FROM PriceGrouping WITH (NOLOCK)
	WHERE MarketLocationKey = @MarketLocationKey and IsActive = 1 and IsDeleted = 0
	For JSON Path

	SET @Status = 1
	SET @Reason = 'Success'
END