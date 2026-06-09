/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketLocationKey" : 3}'
	EXEC [SELL_GetDrayBaseTariff_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
-- SELL_GetDrayBaseTariff @MarketKey = 2, @TerminalKey = 6, @zonekey = 3 , @City = 'BurBank'
CREATE PROCEDURE [dbo].[SELL_GetDrayBaseTariff_V2] -- SELL_GetDrayBaseTariff @MarketKey = 2, @TerminalKey = 6, @zonekey = 10, @City = 'BurBank'
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	set Nocount on
	Set FmtOnly off

	IF ISNULL(@JSONString, '') = ''
				BEGIN
					SET		@Status = 0
					SET		@Reason = 'Parameters not found'
					RETURN
				END	

	DECLARE 
		@MarketKey		int = 0,
		@TerminalKey	int = 0,
		@ZoneKey		int = 0,
		@City			varchar(50) = ''

	SELECT 
		@MarketKey		=		MarketKey	,
		@TerminalKey	=		TerminalKey	,
		@ZoneKey		=		ZoneKey		,
		@City			=		City	
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketKey		INT				'$.MarketLocationKey',	
		TerminalKey		INT				'$.TerminalKey',
		ZoneKey			INT				'$.ZoneKey',	
		City			VARCHAR(50)		'$.City'
	)

	DECLARE @BasePercentSMB	numeric(18,2) = 0,
			@BasePercentENT	numeric(18,2) = 0,
			@SMB_FSF		numeric(18,2) = 33,
			@ENT_FSF		numeric(18,2) = 35,
			@SpotCount		int = 0

	select @BasePercentSMB = BasePercent from CustomerSegments WITH(NOLOCK) where CustomerSegment = 'SMB'
	select @BasePercentENT = BasePercent from CustomerSegments WITH(NOLOCK) where CustomerSegment = 'ENT'
	
	select @SpotCount = count(1) from Sell_DrayBaseSpotTariff WITH(NOLOCK)

	if(isnull(@SpotCount,0) = 0)
	Begin
		Select *,
			SMB_FSFValue = convert(numeric(18,2),round(SMB_DrayBaseRate *  SMB_FSFPercent,2)),
			SMB_Total = convert(numeric(18,2),round(SMB_DrayBaseRate * (1+ SMB_FSFPercent),2)),
			SMB_NetRevenue =  convert(numeric(18,2),round((SMB_DrayBaseRate * (1+ SMB_FSFPercent)),2)) - DrayBase_Cost,
			ENT_FSFValue = convert(numeric(18,2),round(ENT_DrayBaseRate *  ENT_FSFPercent,2)),
			ENT_Total = convert(numeric(18,2),round(ENT_DrayBaseRate * (1+ ENT_FSFPercent),2)),
			ENT_NetRevenue =  convert(numeric(18,2),round((ENT_DrayBaseRate * (1+ ENT_FSFPercent)),2)) - DrayBase_Cost
		INTO #TempData
		From (
			Select * from (
				select ROW_NUMBER() over(partition by MarketLocationKey, TerminalKey, ZoneKey, City  
							Order by MarketLocationKey, TerminalKey, ZoneKey, City, TotalCost Desc ) as HighestAll,
					ROW_NUMBER() over(partition by MarketLocationKey, TerminalKey, ZoneKey, City , YardPortType
							Order by MarketLocationKey, TerminalKey, ZoneKey, City,YardPortType, TotalCost Desc ) as HighestYardPort,
						* ,
					SMB_DrayBaseRate = convert(numeric(18,2), round(case when  isnull(A.DrayBaseValue ,0) = 0 then 0 
						else A.DrayBaseValue + (A.DrayBaseValue * (@BasePercentSMB/100)) end,2)),
					SMB_Margin = convert(numeric(18,2),(@BasePercentSMB/100)),
					SMB_FSFPercent = convert(numeric(18,2),Case when isnull(A.FSF,0) = 0 then (@SMB_FSF/100) else A.FSF/100 end),
					ENT_DrayBaseRate = convert(numeric(18,2),round(case when  isnull(A.DrayBaseValue ,0) = 0 then 0 
						else A.DrayBaseValue + (A.DrayBaseValue * (@BasePercentENT/100)) end,2)),
					ENT_Margin = convert(numeric(18,2),(@BasePercentENT/100)),
					ENT_FSFPercent = convert(numeric(18,2),Case when isnull(A.FSF,0) = 0 then (@ENT_FSF/100) else A.FSF/100 end),
					NAC_DrayBaseRate = case when  isnull(A.TotalCost ,0) = 0 then 0 else A.TotalCost   end,
					NAC_Margin = 0,
					NAC_FSFPercent = convert(numeric(18,2),Case when isnull(A.FSF,0) = 0 then 0.35 else A.FSF/100 end)
				
				from (
					select   ML.MarketLocation as Market, ML.MarketLocationKey,
						T.PriceGrouping as Terminal, T.PriceGroupingKey as TerminalKey,
						Z.ZoneName as Zone,  Z.ZoneKey,
						CO.City, CO.State, CO.ZipCode, 
						isnull(SC.DrayBaseValue,co.Cost + isnull(CO.FSFCost,0)) as DrayBase_Cost,
						FSF = case when isnull(CO.FSF,0) = 0 then 0 else Co.fsf/100 end, 
						CO.FSFCost, CO.YardPortType,
						isnull(SC.HighestOff,'ALL') as HighestOff, 
						ROW_NUMBER() Over (partition by  ML.MarketLocation, T.PriceGrouping, Z.ZoneName, CO.City, CO.State, CO.ZipCode Order by  cost desc) as RecordRank,
						--PP.PrepullCost, PP.Prepulllocation,
						--SO.StopOffCost, SO.StopOfflocation,
						TotalCost = CO.cost +  isnull(CO.FSFCost,0) , --+
							--case when isnull(SC.IsPrePull,0) = 0 then 0 else  isnull(sc.PrePullValue, PP.PrepullCost) end + 
							--case when isnull(SC.IsStopOff,0) = 0 then 0 else  isnull(sc.StopOffValue, SO.StopOffCost) end ,
						isnull(SC.IsPrePull,0) as IsPrePull, CASE WHEN ISNULL(sc.IsPrePull,0) = 0 THEN 0 ELSE isnull(SC.PrePullValue,0) END as PrePullValue, 
						isnull(SC.IsStopOff,0) as IsStopOff, CASE WHEN ISNULL(sc.IsStopOff,0) = 0 THEN 0 ELSE isnull(SC.StopOffValue,0) END as StopOffValue,
						isnull(SC.DrayBaseValue,co.Cost + isnull(CO.FSFCost,0)) as DrayBaseValue, Co.DriverType
				
					from  COST_CostDataOutput CO WITH(NOLOCK)
					inner join MarketLocation ML WITH(NOLOCK) on CO.Market = ML.MarketLocation
					inner join PriceGrouping T WITH(NOLOCK) on T.MarketLocationKey = ML.MarketLocationKey AND co.Terminal = t.PriceGrouping
					inner join cost_Zones Z WITH(NOLOCK) on ML.MarketLocationKey = Z.MarketKey AND co.Zone = z.ZoneName
					left join Sell_Config SC WITH(NOLOCK) on ML.MarketLocationKey = SC.MarketKey and T.PriceGroupingKey = SC.TerminalKey and Z.ZoneKey = SC.ZoneKey
						--and SC.HighestOff = LTRIM(RTRIM(CO.YardPortType))
					--Left join COST_CostDataOutput CO on CO.Market = ML.MarketLocation and CO.Terminal = T.PriceGrouping and Co.Zone = Z.ZoneName
					--Left join COST_CostDataOutput_PrePull PP on CO.Market = PP.Market and CO.Terminal = PP.Terminal 
					--			and CO.Zone = PP.Zone and CO.City = PP.City and CO.State = PP.State
					--LEft join COST_CostDataOutput_StopOff SO On CO.Market = SO.Market and CO.Terminal = SO.Terminal 
					--			and CO.Zone = SO.Zone and CO.City = SO.City and CO.State = SO.State
					where	(ML.MarketLocationKey = @MarketKey OR isnull(@MarketKey,0) = 0) AND
							(T.PriceGroupingKey = @TerminalKey OR isnull(@TerminalKey,0) = 0 ) AND
							(Z.ZoneKey = @ZoneKey OR isnull(@ZoneKey,0) = 0 ) AND
							(CO.City = @City OR isnull(@City,'') = '')
				) A
			) AA
			--WHERE YardPortType = Case when HighestOff = 'ALL' then YardPortType else HighestOff end AND
			--	 HighestAll = case when HighestOff = 'ALL' then 1 else HighestAll end AND
			--	 HighestYardPort = Case when HighestOff = 'ALL' then HighestYardPort else 1 end
		) B

		select @BasePercentSMB as SMB_Margin,
			@BasePercentENT as ENT_Margin,
			@SMB_FSF as SMB_FSF,
			@ENT_FSF  as ENT_FSF,
			SpotTariff = (Select  * from #TempData Order by Market, Terminal, Zone, City, State, ZipCode For Json Path)
	For Json Path
	End
	else
	Begin
		Select St.MarketKey as MarketLocationKey, TerminalKey, City, State, ZipCode, St.ZoneKey, DrayBaseValue, DrayBaseValue as DrayBase_Cost,
			SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal as SMB_Total, SMB_NetRevenue, 
			ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal as ENT_Total, ENT_NetRevenue ,
			ML.MarketLocation as Market,  PG.PriceGrouping as Terminal, Z.Zonename as Zone, St.TruckType as HighestOff
		into #TempData1
		from Sell_DrayBaseSpotTariff ST WITH(NOLOCK)
		inner join MarketLocation ML WITH(NOLOCK) on St.MarketKey = ML.MarketLocationKey
		inner join PriceGrouping PG WITH(NOLOCK) on St.TerminalKey = PG.PriceGroupingKey
		inner join cost_Zones Z WITH(NOLOCK) on ST.ZoneKey = Z.ZoneKey

		--select * from #TempData1
		Select top 1 @BasePercentSMB = SMB_Margin ,
				@BasePercentENT = ENT_Margin,
				@SMB_FSF = SMB_FSF,
				@ENT_FSF = ENT_FSF 
		from #TempData1
		select @BasePercentSMB as SMB_Margin,
			@BasePercentENT as ENT_Margin,
			@SMB_FSF as SMB_FSF,
			@ENT_FSF  as ENT_FSF,
			SpotTariff = (Select * from #TempData1 Order by Market, Terminal, Zone, City, State, ZipCode For Json Path)
	For Json Path
	End
	--select * from #TempData
	SET @Status = 1
	SET @Reason = 'Success'
End