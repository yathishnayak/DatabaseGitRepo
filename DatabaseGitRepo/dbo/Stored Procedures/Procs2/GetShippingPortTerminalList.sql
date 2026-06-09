CREATE PROCEDURE [dbo].[GetShippingPortTerminalList]  --GetShippingPortTerminalList 

AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				TerminalKey, TerminaID,PortKey,S.StatusKey,S.IsActive,S.IsDeleted,'' ShippingPortID,MarketLocation,PriceGrouping,
						[Address] = (SELECT '' as AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				ShippingPortTerminals  S
	--LEFT JOIN ShippingPort SP WITH (NOLOCK) ON SP.ShippingPortKey=S.PortKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=S.MarketLocationKey
	LEFT JOIN PriceGrouping PG WITH (NOLOCK) ON PG.PriceGroupingKey=S.PriceGroupingKey
	WHERE				ISNULL(S.IsActive,0) = 1 and ISNULL(S.IsDeleted,0) = 0
	ORDER BY			TerminaID
						FOR JSON PATH

END
