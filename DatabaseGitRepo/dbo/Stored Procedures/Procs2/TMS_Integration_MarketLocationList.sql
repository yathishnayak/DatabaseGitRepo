

CREATE Proc [dbo].[TMS_Integration_MarketLocationList]
AS
SELECT			MarketLocationKey, MarketLocation
FROM			MarketLocation WITH (NOLOCK)
ORDER BY		MarketLocation
FOR JSON PATH

