
/*
	DECLARE @JsonInput	nvarchar(2000) = '', @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(100) = '' 
	SET @JsonInput = '{"MarketKey":3,"TerminalKey":3,"ZipCode":"92880","DriverTypeKey":1,"isPrePull":true,"PrePullLocationKey":5,"isYardShuttle":true,"YardShuttleLocationKeys":"105,210","isStopOff":true,"StopOffLocationKey":5,"AccessorialsLineItems":"Hazmat Surcharge,Dry Run- Export","UserKey":512}'
	--SET @JsonInput = ''
	EXEC Cost_OutputByQuestion @JsonInput, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/

CREATE proc [dbo].[Cost_OutputByQuestion]
(
	@JsonInput		nvarchar(2000) = '',
	@JsonOutput		nvarchar(max) ='' OUTPUT,
	@Status			bit = 0 output,
	@Reason			varchar(500) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JsonInput,'') = '')
	Begin
		set @Status = 0
		set @Reason = 'Input Parameters not received'
		return
	End
	SEt @Status = 1
	Declare
		@MarketKey						int,
		@TerminalKey					int,
		@ZipCode						varchar(20),
		@DriverTypeKey					int,
		@isPrePull						bit,
		@PrePullLocationKey				int,
		@isYardShuttle					bit,
		@YardShuttleLocationKeys		varchar(50),
		@isStopOff						bit,
		@StopOffLocationKey				int,
		@AccessorialsLineItems			nvarchar(max),
		@UserKey						int,
		@AddedAccessorialsTotalCost		decimal(18,3),
		@City							varchar(50),
		@State							varchar(10),
		@PrePullLocation				varchar(50),
		@StopOffLocation				varchar(50),
		@YardShuttleLocation			varchar(50),
		@DriverType						varchar(50),
		@DrayBaseValue					Decimal(18,2),
		@YardShuttleCost				Decimal(18,2),
		@Terminal						varchar(50),
		@Market							varchar(50),
		@YardPortType					varchar(10),
		@PrePullYardPortType			varchar(10),
		@ShuttleYardPortType			varchar(10),
		@StopOffYardPortType			varchar(10)
	
	--select * from COSTACC_FinalDataOutput
	select 
		@MarketKey					=MarketKey	,			
		@TerminalKey				=TerminalKey,				
		@ZipCode					=ZipCode	,				
		@DriverTypeKey				=DriverTypeKey	,		
		@isPrePull					=isPrePull,				
		@PrePullLocationKey			=PrePullLocationKey,		
		@isYardShuttle				=isYardShuttle,			
		@YardShuttleLocationKeys	=YardShuttleLocationKeys,	
		@isStopOff					=isStopOff	,			
		@StopOffLocationKey			=StopOffLocationKey,		
		@AccessorialsLineItems		=AccessorialsLineItems,		
		@UserKey					=UserKey					
	from OpenJson(@JsonInput, '$')
	WITH (
		MarketKey					int				'$.MarketKey',
		TerminalKey					int				'$.TerminalKey',
		ZipCode						varchar(20)		'$.ZipCode',
		DriverTypeKey				int				'$.DriverTypeKey',
		isPrePull					bit				'$.isPrePull',
		PrePullLocationKey			int				'$.PrePullLocationKey',
		isYardShuttle				bit				'$.isYardShuttle',
		YardShuttleLocationKeys		varchar(50)		'$.YardShuttleLocationKeys',
		isStopOff					bit				'$.isStopOff',
		StopOffLocationKey			int				'$.StopOffLocationKey',
		AccessorialsLineItems		nvarchar(max)	'$.AccessorialsKeys' as json,
		UserKey						int				'$.UserKey'
	)
	
	

	select @City = City, @State = State from LocationData where ZipCode =  @ZipCode
	
	select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey
	Select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	Select @DriverType = TruckType from TruckType where TruckTypeKey = @DriverTypeKey

	Declare @RecCount int = 0
	select @RecCount = count(1) from COST_CostDataOutput where City = @city and State = @State and 
		Market = @Market and Terminal = @Terminal and DriverType = @DriverType

	if(@RecCount = 0)
	Begin
		Set @Status = 0
		set @Reason = 'Records not found in Cost Database for the combination of City:' + @City + ', State:' + @State + ', Market:' + @Market
			+ ', Terminal:' + @Terminal + ', DriverType:' + @DriverType
	End
	SElect @PrePullYardPortType = Case when isnull(@isPrePull,0) = 1 then  (Select YardType from Yard where YardId = @PrePullLocationKey) else 'NA' end
	print '@PrePullYardPortType'
	print @PrePullYardPortType

	Select @YardPortType = Case when isnull(@isPrePull,0) = 0 then 'IE' else @PrePullYardPortType end
	print '@YardPortType'
	print @YardPortType

	select top 1 @DrayBaseValue = Cost + fsf  
		from COST_CostDataOutput 
		where city = @city and State = @State and DriverType =@DriverType 
			and Terminal = @Terminal and Market = @Market and YardPortType = @YardPortType
		order by convert(datetime, (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)) desc
	print '@DrayBaseValue'
	print @DrayBaseValue
	--select @DrayBaseValue
	select * into #YardShuttleKeys from dbo.Fn_SplitParam(@YardShuttleLocationKeys)
	--select * into #AccesorialItemKeys from dbo.Fn_SplitParam(@AccessorialsLineItems)
	
	--select @AccessorialsLineItems
	select value into #AccesorialItemKeys from  OpenJSON(@AccessorialsLineItems,'$')


	--select * from #YardShuttleKeys
	create table #YardKeys
	(
		YardID		int, 
		YardType	varchar(10)
	)

	if((Select count(1) from #YardShuttleKeys) > 0)
	Begin
		Insert into #YardKeys
		select Distinct Yardid , YardType
		from #YardShuttleKeys A
		inner join (
			select YardID, 'From ' + ShortName  as ShuttleName, 100 + YardId as ShuttleCode, YardType
			from yard 
			where IsActive = 1 and IsShuttleLocation = 1
			union all
			select YardID, 'To ' + ShortName  as ShuttleName, 200 + YardId as ShuttleCode, YardType
			from yard 
			where IsActive = 1 and IsShuttleLocation = 1
		) Y on A.Value = Y.ShuttleCode
		
	End
	--select * from #YardKeys
	--select * from #AccesorialItemKeys
	-- Setup Defaults where not selected
	--SEt Pre-Pull Location
	if(isnull(@isPrePull,0) = 0)
	Begin
		if(@MarketKey = 2)
		begin
			select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			--select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'Reyes'
		End
		else IF(@MarketKey = 3)
		Begin
			select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			--select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'JCT-Fontana'
		End
		else
		Begin
			select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			--select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'Reyes'
		End
	End
	print '-----------------------'
	print '@PrePullLocationKey'
	print @PrePullLocationKey

	--SEt the StopOff Location
	if(isnull(@isStopOff,0) = 0)
	Begin
		if(@MarketKey = 2)
		begin
			select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
		End
		else IF(@MarketKey = 3)
		Begin
			select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
		End
		else
		Begin
			select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
		End
	End

	print '------------------'
	print '@StopOffLocationKey'
	print @StopOffLocationKey

	--SEt the Yard Shuttle Location
	if(isnull(@isYardShuttle,0) = 0 OR (select count(1) from #YardShuttleKeys) = 0)
	Begin
		insert into #YardKeys
		select  YardId , YardType from Yard where ShortName = 'Reyes'
	End

	SELECT A.*
		into #Prepull
		FROM COST_CostDataOutput_PrePull A
		inner join Yard Y on  A.Prepulllocation = Y.ShortName
		where Y.YardId = @PrePullLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

	SELECT A.*
		into #StopOff
		FROM COST_CostDataOutput_StopOff A
		inner join Yard Y on A.StopOfflocation =  Y.ShortName
		where Y.YardId = @StopOffLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal


	SELECT Top 1 A.*
		into #YardShuttleFrom
		FROM COST_CostDataOutput_YardShuttle A
		inner join Yard Y on   Y.ShortName like '%' + A.YardFrom + '%'
		inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
		where A.City = @city and A.State = @State

	SELECT top 1 A.*
		into #YardShuttleTo
		FROM COST_CostDataOutput_YardShuttle A
		inner join Yard Y on Y.ShortName like '%' + A.YardTo + '%'
		inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
		where A.City = @city and A.State = @State

	select 'PrePull', * from #Prepull
	select 'StopOff', * from #StopOff
	Select 'Yard Shuttle From', * from #YardShuttleFrom
	Select 'Yard Shuttle To', * from #YardShuttleTo

	select @YardShuttleCost =  convert(decimal(18,3),isnull((select YardCost from #YardShuttleFrom),0)) --+ isnull((select YardCost from #YardShuttleTo),0) )
	--Select '@YardShuttleCost', @YardShuttleCost

	--///*********** ACCESSORIAL COST CALCULATION **************************
	--select B.LineItem, B.Per, b.UnitCost , convert(decimal(18,3),b.UnitCost) as TotalCost
	--into #Accessorials
	--from #AccesorialItemKeys A
	--inner join COSTACC_FinalDataOutput B on A.Value = B.LineItem
	--inner join MarketLocation M on B.Market = M.MarketLocation and M.MarketLocationKey = @MarketKey
	--select  '@AccessorialsLineItems', @AccessorialsLineItems
	declare @combinedString varchar(max)
	select @combinedString = COALESCE(@combinedString + ', ', '') + value from #AccesorialItemKeys
	--select '@combinedString', @combinedString

	select RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	into #AccRercs
	from COSTACC_FinalDataOutput where 1=0

	insert into #AccRercs 
	( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent)
	exec CostACC_CalcAccessorialCost @MarketKey = @marketKey,
			@AccessorialsLineItems = @combinedString,
			@Terminal = @Terminal,
			@YardPort = @YardPortType,
			@TruckType = @DriverType

	alter table #AccRercs add TotalCost Decimal(18,3) 
	update #AccRercs set TotalCost = convert(decimal(18,3),UnitCost) 
	--select * from #AccRercs
	select @AddedAccessorialsTotalCost = sum(totalCost)  from #AccRercs
	--///*********** ACCESSORIAL COST CALCULATION **************************

	Create Table #Summary
	(
		HeaderText			varchar(100),
		LineItem1			varchar(100),
		LineItem1_Value		decimal(18,3),
		LineItem2			varchar(100),
		LineItem2_Value		decimal(18,3),
		LineItem3			varchar(100),
		LineItem3_Value		decimal(18,3),
		LineItem4			varchar(100),
		LineItem4_Value		decimal(18,3),
		LineItem5			varchar(100),
		LineItem5_Value		decimal(18,3),
		Total_text			varchar(100),
		Total_value			decimal(18,3)
	)

	insert into #Summary (LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
				LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText )
	select		'Pre-Pull', 0 , 
				'Yard Shuttle', 0, 
				'Stop Off', 0, 
				'Dray base',0,
				'Accessorial Item Cost',0, 
				'$$ TOTAL COST', 0, 
				'SELECTED FROM QUESTIONS'

	update #Summary set LineItem1_Value = Case when isnull(@isPrePull,0)=1 then (select top 1 PrePullCost from #Prepull) else 0 end
	update #Summary set LineItem2_Value = Case when isnull(@isYardShuttle,0)=1 then @YardShuttleCost else 0 end 
	update #Summary set LineItem3_Value = Case when isnull(@isStopOff,0)=1 then (select top 1 StopOffCost from #StopOff) else 0 end 
	update #Summary set LineItem4_Value = @DrayBaseValue 
	update #Summary set LineItem5_Value = @AddedAccessorialsTotalCost

	update #Summary set Total_value = LineItem1_Value + LineItem2_Value + LineItem3_Value + LineItem4_Value + LineItem5_Value

	SElect PriceGroupingKey, PriceGrouping, MarketLocationKey , Case when PriceGroupingKey = @TerminalKey then 0 else 1 end as SortOrder
	into #Terminal from PriceGrouping 
	where MarketLocationKey = @MarketKey


	Create table #LegTypeValues
	(
		LegType		varchar(50),
		LegCost		decimal(18,3)
	)

	insert into #LegTypeValues values
	('PrePull', (select top 1 PrePullCost from #Prepull)),
	('Shuttle', @YardShuttleCost),
	('Dray Base', @DrayBaseValue / 2 ),
	('Stop-Off', (select top 1 StopOffCost from #StopOff))

	select LegGroupKey, LegTypeHeaderText ,LegGroupID
	into #LegGroups
	from Cost_LegGroups Order by LegGroupKey
	
	Select LegGroupKey, LegName, LegOrderBy, LegTypeName
	into #LegTypeList
	from Cost_LegGroups LG
	inner join Cost_LegTypes LT on LG.LegTypesCombined like '%' + LT.LegTypeID + ',' + '%'
	order by LegGroupKey, LegOrderBy

	--select * from #Terminal
	--SELECT * FROM #Summary
	--select * from #LegTypeList
	--select * from #LegGroups

	Select @JsonOutput = (
		select PriceGroupingKey, PriceGrouping, MarketLocationKey,
			TruckTypes=(select TruckTypeKey, TruckType,
					LegHeadings = (Select LegGroupKey, LegTypeHeaderText ,LegGroupID,
									LegList = (Select LegGroupKey, LegName, LegOrderBy, isnull(LV.LegCost,-1) as LegCost
												from #LegTypeList LL
												Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
												Where LL.LegGroupKey = LG.LegGroupKey
												For JSON Path
												),
									LegGroupTotalCost = (Select sum( isnull(LV.LegCost,-1))
												from #LegTypeList LL
												Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
												Where LL.LegGroupKey = LG.LegGroupKey)
								from #LegGroups LG
								Order by LegGroupKey
								For JSON PAth),
					AddedAccessorials = (select LineItem, Per, UnitCost , TotalCost
										from #AccRercs
										For JSON Path),
					AddedAccessorialsTotalCost = @AddedAccessorialsTotalCost
					from TruckType
					for JSON Path),
			Summary = (Select LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
						LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText 
						from #Summary
						For JSON PATH),
			LineItemDetails =  (
				select 'Accessorial Item Details' as Heading, 
						B.LineItem, B.Per, b.UnitCost , 
						convert(decimal(18,3),b.UnitCost) as TotalCost
				from #AccRercs B
				for JSON PATH
			)
		from #Terminal
		--where PriceGroupingKey = @TerminalKey
		order by SortOrder, PriceGrouping
		For JSON PATH
		)

	If @Status = 1
	Begin
		Set @Reason = 'SUCCESS'
	End

	drop table #AccRercs
	drop table #LegTypeValues
	drop table #YardKeys
	Drop table #AccesorialItemKeys
	DROP TABLE #Summary
	drop table #LegGroups
	drop table #Terminal
	drop table #LegTypeList
END
