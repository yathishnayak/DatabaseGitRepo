CREATE PROCEDURE [dbo].[Terminal_GetPriceGroups]
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

	SET @Status=1;
	SET @Reason='Success';
	--IF(ISNULL(@JsonString,'')='')
	--BEGIN
	--	SET @Status=0;
	--	SET @Reason='Parameter not found';
	--	RETURN;
	--END

	SELECT PriceGroupingKey,PriceGrouping,MarketLocationKey
	FROM PriceGrouping WHERE ISNULL(ISACTIVE,0)=1
	FOR JSON PATH
END
