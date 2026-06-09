/*
Declare @UserKey int, @JSONString nvarchar(max),@Status	bit =0,@Reason	varchar(1000)=''
set @JSONString = '{"MarketKey":0,"Group":null}'
Exec SELL_GetAccessorialTariff @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
Select @Status, @Reason
*/

CREATE PROC [dbo].[SELL_GetAccessorialTariff] -- SELL_GetAccessorialTariff
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= false output,
	@Reason			varchar(1000) = '' output
)
as 
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	declare @MarketKey		int = 0,
			@Group			varchar(20) = ''
	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End


	Select @MarketKey = MarketKey, @Group = Groupstr
	from OpenJSON(@JsonString, '$')
	WITH (
		MarketKey			int			'$.MarketLocationKey',
		Groupstr			varchar(20)	'$.Group'	
	)

	select distinct WarehouseSizeMap into #TempContsize from ContainerSize WITH(NOLOCK) where WarehouseSizeMap is not null

	select Top 50  
		ML.MarketLocationKey, 
		CO.Market, CO.LineItem, isnull(CO.YardPort,'') as  YardPort, 
		isnull(Z.ZoneKey,0) as ZoneKey, isnull(CO.Zone,'') as Zone, '' as [Group], --CO.[Group], 
		CO.UnitCost, CO.Per, isnull(Sa.SellAccRateKey,0) as SellAccRateKey,
		isnull(SA.SMB_Margin,0) as SMB_Margin, 
		isnull(SA.SMB_Rate,0) as SMB_Rate,
		isnull(SMB_BvsNB,'') as SMB_BvsNB, 
		isnull(SMB_FreeTime,0) as SMB_FreeTime, 
		isnull(SMB_Min,0) as  SMB_Min,
		isnull(SMB_Max,0) as SMB_Max, 
		isnull(SMB_NetRevenue,0) as SMB_NetRevenue,
		isnull(SMB_Date,'') as SMB_Date, 
		isnull(SMB_UserKey,0) as SMB_UserKey, 
		isnull(SMBU.UserName,'') as SMB_UserName,
		isnull(SA.ENT_Margin,0) as ENT_Margin, 
		isnull(SA.ENT_Rate,0) as ENT_Rate,
		isnull(ENT_BvsNB, '') as ENT_BvsNB,
		isnull(ENT_FreeTime,0) as ENT_FreeTime,
		isnull(ENT_Min, 0) as ENT_Min,
		isnull(ENT_Max, 0) as ENT_Max,
		isnull(ENT_NetRevenue, 0) as ENT_NetRevenue,
		isnull(ENT_Date, '') as ENT_Date,
		isnull(ENT_UserKey, 0) as ENT_UserKey,
		isnull(ENTU.UserName,'') as ENT_UserName,
		isnull(SA.NAC_Margin,0) as NAC_Margin, isnull(SA.NAC_Rate,0) as NAC_Rate,
		isnull(NAC_BvsNB, '') as NAC_BvsNB,
		isnull(NAC_FreeTime,0) as  NAC_FreeTime,
		isnull(NAC_Min, 0) as NAC_Min,
		isnull(NAC_Max, 0) as NAC_Max,
		isnull(NAC_NetRevenue,0) as NAC_NetRevenue,
		isnull(NAC_Date, '') as NAC_Date,
		isnull(NAC_UserKey, 0) as NAC_UserKey,
		isnull(NACU.UserName,'') as NAC_UserName,
		isnull(CS.WarehouseSizeMap,'') as ContainerSize
	from (select Market,Lineitem, YardPort, Zone, EffectiveDate, OutputDataKey,
		ROW_NUMBER() over (partition by Market,Lineitem, YardPort, [Zone] Order by convert(DateTime, EffectiveDate) Desc )   as Row_num
		from COSTACC_FinalDataOutput WITH(NOLOCK) ) T
	inner join COSTACC_FinalDataOutput CO WITH(NOLOCK) on T.OutputDataKey = CO.OutputDataKey
	inner join MarketLocation ML WITH(NOLOCK) on Co.Market = ML.MarketLocation
	Left join cost_Zones Z WITH(NOLOCK) on Co.Zone = Z.ZoneName
	inner join Item M WITH(NOLOCK) on CO.LineItem = M.Description and M.itemkey = M.MasterItemKey
	LEft join #TempContsize CS on 1= Case when M.Description = 'Transload' then 1 else 0 end
	Left join Sell_AccessorialRates SA WITH(NOLOCK) on ML.MarketLocationKey = SA.MarketKey and 
			SA.ZoneKey = ISNULL(Z.ZoneKey,0) and SA.YardPort = ISNULL(CO.YardPort,'') AND
			sa.LineItem = co.LineItem
	LEFT  JOIN [User] SMBU WITH(NOLOCK) ON SA.SMB_UserKey = SMBU.UserKey
	LEFT  JOIN [User] ENTU WITH(NOLOCK) ON SA.ENT_UserKey = ENTU.UserKey
	LEFT  JOIN [User] NACU WITH(NOLOCK) ON SA.NAC_UserKey = NACU.UserKey
	--Left join Sell_ShowAccessorial SSA on LTRIM(RTRIM(REPLACE(REPLACE(CO.LineItem,CHAR(10),''),CHAR(13),'')))  = LTRIM(RTRIM(REPLACE(REPLACE(SSA.LineItem,CHAR(10),''),CHAR(13),''))) 
	where row_num = 1 and  --isnull(SSA.ShowinSellDB,1) = 1 and
		(isnull(@MarketKey,0) = 0 OR ML.MarketLocationKey = @MarketKey) AND
		(isnull(@Group,'') = '' OR CO.[Group] = @Group)
	order by CO.LineItem
	for JSON PATH--, INCLUDE_NULL_VALUES

	set @Status = 1
	set @Reason = 'SUCCESS'
END