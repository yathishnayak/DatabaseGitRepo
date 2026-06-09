/*
DECLARE @UserKey		INT=512,
		@JsonString		VARCHAR(MAX)='{"MarketLocationKey":3}',
		@IsDebug		BIT = 1,
		@Status			BIT	= 0 ,
		@Reason			NVARCHAR(1000) = '' 
		EXEC PriceGrouping_GetByLocation @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
*/
CREATE PROCEDURE [dbo].[PriceGrouping_GetByLocation]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	--** Main Object **--
	DECLARE @MarketLocationKey INT =	0

	SELECT @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			MarketLocationKey				INT				'$.MarketLocationKey'
		)
	
	SET @Reason='Success'
	SET @Status=1
	SELECT PriceGroupingKey, PriceGrouping
	FROM PriceGrouping WITH (NOLOCK)
	WHERE (@MarketLocationKey=0 OR ISNULL(MarketLocationKey,2)=@MarketLocationKey)
	FOR JSON PATH
END