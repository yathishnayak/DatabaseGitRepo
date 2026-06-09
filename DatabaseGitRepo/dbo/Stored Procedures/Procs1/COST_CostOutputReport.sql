
CREATE PROCEDURE [dbo].[COST_CostOutputReport] --  COST_CostOutputReport 0,0,0,0,''
(
	@MarketKey			INT = 0,
	@CityKey			INT = 0,
	@TerminalKey		INT = 0,
	@DriverTypeKey		INT = 0,
	@Zone				VARCHAR(100)='',
	@YardPort			VARCHAR(100)='',
	@SearchText			VARCHAR(200) = ''

)
AS

BEGIN
	
	-- SELECT * FROM PriceGrouping WHERE PriceGrouping = 'ADDISON'

	DECLARE			@Market VARCHAR(100), @City VARCHAR(100), @Terminal VARCHAR(100), @DriverType VARCHAR(100) 

	SET				@Market = (SELECT MarketLocation FROm MarketLocation WHERE MarketLocationKey = @MarketKey )		
	SET				@City = (SELECT City FROm LocationData WHERE CityKey = @CityKey )	
	SET				@Terminal = (SELECT PriceGrouping FROm PriceGrouping WHERE PriceGroupingKey = @TerminalKey )
	SET				@DriverType = (SELECT TruckType FROm TruckType WHERE TruckTypeKey = @DriverTypeKey )	




	
	SELECT			market, Terminal,  City, State, ZipCode, Zone, DriverType, Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom
					,STUFF((SELECT ', ' + SS.yardPortType 
							FROM COST_CostDataOutput SS
							WHERE CD.market = SS.market  AND CD.Terminal = SS.Terminal  AND  CD.City = SS.City  AND  CD.State = SS.State  AND ISNULL(CD.ZipCode,'') = ISNULL(SS.ZipCode,'')  AND  CD.Zone = SS.Zone AND CD.DriverType= SS.DriverType
							AND CD.Cost = SS.Cost AND CD.FSFCost = SS.FSFCost AND CD.FSF = SS.FSF
							AND CD.Draybase = SS.Draybase AND CD.EffectiveDate = SS.EffectiveDate AND CD.EffectiveDateFrom = ss.EffectiveDateFrom
							-- AND  Cost = 140 AND FSFCost = 0.25 AND FSF = 175   AND City = 'Amana' AND CostOutputDataKey Not in (1247 ,1244, 1250)
							FOR XML PATH('')), 1, 1, '') YardPortType
	INTO			#TMP
	FROM			COST_CostDataOutput CD
	-- WHERE			Cost = 140 AND FSFCost = 0.25 AND FSF = 175   AND City = 'Amana'  
	GROUP BY		market, Terminal,  City, State, ZipCode, Zone, DriverType, Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom


	-- SELECT * FROM #TMP

	SELECT			market, YardPortType,  City, State, ZipCode, Zone, DriverType, Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom
					,STUFF((SELECT ', ' + SS.Terminal 
							FROM #TMP SS
							WHERE CD.market = SS.market AND  CD.City = SS.City  AND  CD.State = SS.State  AND ISNULL(CD.ZipCode,'') = ISNULL(SS.ZipCode,'')  AND  CD.Zone = SS.Zone AND CD.DriverType= SS.DriverType
							AND CD.Cost = SS.Cost AND CD.FSFCost = SS.FSFCost AND CD.FSF = SS.FSF
							AND CD.Draybase = SS.Draybase AND CD.EffectiveDate = SS.EffectiveDate AND CD.EffectiveDateFrom = ss.EffectiveDateFrom AND CD.YardPortType = ss.YardPortType
							-- AND  Cost = 140 AND FSFCost = 0.25 AND FSF = 175   AND City = 'Amana'  
							FOR XML PATH('')), 1, 1, '') Terminal
	INTO			#FINALDATA
	FROM			#TMP CD
	-- WHERE			Cost = 140 AND FSFCost = 0.25 AND FSF = 175   AND City = 'Amana'  
	GROUP BY		market, YardPortType,  City, State, ZipCode, Zone, DriverType, Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom


	-- SELECT * FROM #FINALDATA

	SELECT			Market, Terminal,City, State, ZipCode, Zone,  DriverType, YardPortType,
					Cost, FSF, DrayBase ,CONVERT(VARCHAR,EffectiveDate,110) EffectiveDate , EffectiveDateFrom, FSFCost
	FROM			#FINALDATA
	WHERE			(Market = @Market OR '' = ISNULL(@Market,'') )
					AND (City = @City OR '' = ISNULL(@City,'') )
					AND (Terminal = @Terminal OR '' = ISNULL(@Terminal,'')) 
					AND (DriverType = @DriverType OR '' = ISNULL(@DriverType,'') )
					AND (Zone =@Zone OR ''=ISNULL(@Zone,''))
					AND (YardPortType =@YardPort OR ''=ISNULL(@YardPort,''))
					AND Cost > 0 -- AND FSFCost > 0
	ORDER BY		Market, City, State, ZipCode, Zone,  DriverType, Terminal, EffectiveDate, EffectiveDateFrom
END

