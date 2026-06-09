CREATE PROCEDURE Get_CostZones
@MarketKey	INT=0
AS
BEGIN
	SELECT ZoneKey,ZoneName,MarketKey FROM cost_Zones
	FOR JSON PATH;
END