/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Sell_GetConfigData_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Sell_GetConfigData_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN

	SELECT 
		ROW_NUMBER() OVER (ORDER BY MarketLocation, ZoneName, Terminal) AS RecordKey,
		*
	FROM
	(
		SELECT DISTINCT 
			ISNULL(SC.SellConfigKey,0) AS SellConfigKey, 
			ML.MarketLocationKey, 
			ML.MarketLocation, 
			T.PriceGroupingKey AS TerminalKey, 
			T.PriceGrouping AS Terminal,
			ZO.ZoneKey, 
			ZO.ZoneName,
			ISNULL(SC.IsPrePull,0) AS IsPrePull, 
			ISNULL(SC.PrePullValue,0) AS PrePullValue,
			ISNULL(SC.IsStopOff,0) AS IsStopOff, 
			ISNULL(SC.StopOffValue,0) AS StopOffValue,
			ISNULL(SC.HighestOff,0) AS HighestOff, 
			ISNULL(SC.DrayBaseValue,0) AS DrayBaseValue,
			TotalValue =
				CASE WHEN ISNULL(SC.IsPrePull,0) = 1 THEN ISNULL(SC.PrePullValue,0) ELSE 0 END +
				CASE WHEN ISNULL(SC.IsStopOff,0) = 1 THEN ISNULL(SC.StopOffValue,0) ELSE 0 END +
				ISNULL(SC.DrayBaseValue,0),
			SC.Effective_date AS EffectiveDateFrom, 
			SC.EffectiveFromKey, 
			CEF.EffectiveFrom, 
			YardType

		FROM MarketLocation ML WITH(NOLOCK) 
		INNER JOIN PriceGrouping T WITH(NOLOCK) 
			ON ML.MarketLocationKey = T.MarketLocationKey
		INNER JOIN cost_Zones ZO WITH(NOLOCK) 
			ON ML.MarketLocationKey = ZO.MarketKey
		LEFT JOIN COST_CostDataOutput CO WITH(NOLOCK) 
			ON CO.Market = ML.MarketLocation 
			AND CO.Zone = ZO.ZoneName 
			AND CO.Terminal = T.PriceGrouping
		LEFT JOIN Sell_Config SC WITH(NOLOCK) 
			ON ML.MarketLocationKey = SC.MarketKey 
			AND T.PriceGroupingKey = SC.TerminalKey 
			AND ZO.ZoneKey = SC.ZoneKey
		LEFT JOIN Cost_EffectiveFrom CEF WITH(NOLOCK) 
			ON SC.EffectiveFromKey = CEF.EffectiveKey
	) A
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END