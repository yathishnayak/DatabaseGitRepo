
create proc [dbo].[Get_MarketPriceGroup]
(
	@MarketLocationKey	int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SELECT PriceGroupingKey, PriceGrouping, MarketLocationKey
	FROM PriceGrouping
	WHERE MarketLocationKey = @MarketLocationKey and IsActive = 1 and IsDeleted = 0
	For JSON Path
END
