
--Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys ='84:', @MarketKey = 2, @city ='Ontario',@State='CA',@Location='Volvo Car USA LLC',@CustKey=2423,@OrderDetailKey=151687,@ContainerNo='MSNU7431144', @IsDebug = 1
--Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey  @MarketKey = 3, @city ='Joliet',@State='IL',@Location='Expeditors Distribution - cherry',@CustKey=3106,@OrderDetailKey=128634,@ContainerNo='ACLU9719083', @IsDebug = 1
--Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey  @MarketKey = 2, @city ='Carson',@State='CA',@Location='Whse#4.',@CustKey=3106,@OrderDetailKey=124480,@ContainerNo='AMFU8893346', @IsDebug = 1
--AUTO_SELL_CalcAccessorialValueByOrderDetailKey  @MarketKey = 2, @city ='Phoenix',@State='AZ',@Location='ACD',@CustKey=1765,@OrderDetailKey=87632,@ContainerNo='TCNU2584969'
--AUTO_SELL_CalcAccessorialValueByOrderDetailKey  @MarketKey = 2, @city ='Perris',@State='CA',@Location='DELL PRODUCTS LP',@CustKey=3170,@InvoiceKey=68738,@ContainerNo='MSDU6189083'
--AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys = '84:18:103:116:24', @MarketKey = 2, @City = 'Fontana', @State = 'CA', @Location = 'FNG WAREHOUSE', @CustKey = 3141, @containerNo = 'MSDU4444050', @IsDebug = 1
CREATE PRoc [dbo].[AUTO_SELL_CalcAccessorialValueByOrderDetailKey_Base20251015]  -- 1765 // 3281
(
	@ItemKeys				varchar(500), -- Colon separated itemkeys
	@MarketKey				int = 0,
	@OrderDetailKey			int = 0,
	@ContainerNo			varchar(50) = '',
	@Terminal				varchar(50) = '',
	@Location				varchar(100) = '',
	@city					varchar(100) = '',
	@State					varchar(20) = '',
	@TruckType				varchar(50) = '',
	@CustKey				int = 0,
	@IsGeneralNAC			Bit = 1, -- When 1, then Ignore custKey and use General Data in NAC
	@IsDebug				bit = 0
)
As
BEGIN
	Declare  
		@AddedAccessorialsTotalCost		decimal(18,2),
		@Market				varchar(50),
		@CustomerSegment		varchar(10),
		@IsSpotOn			bit = 0,
		@CustName			varchar(200)

	select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
				@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end,
				@custname = C.CustName
		from Customer C
		inner join CustomerSegments CS WITH (NOLOCK) on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT WITH (NOLOCK) on C.RateTypeKey = CRT.RateTypeKey
		where CustKey = @CustKey
		

	select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	--select '@Market', @Market

	Select * into #ItemsToProcess from Fn_SplitParamCol(@ItemKeys)

	--select * from #ItemsToProcess

	if(Select count(1) from #ItemsToProcess ) = 0
	Begin
		return
	End

	create table #ItemsACC_CalcAccessorial
	(
		ItemKey				int,
		IDescription		varchar(100),
		MItemKey			int,
		MDescription		varchar(100),
		CostGroup			varchar(50)
	)

	if(@IsDebug = 1)
	Begin
		select 'Accessorial', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, 
			@Location as Location, @ContainerNo as ContainerNo, @TruckType as TruckType , @OrderDetailKey as OrderDetailKey
	End


	insert into #ItemsACC_CalcAccessorial (ItemKey, IDescription, MItemKey, MDescription, CostGroup)
	select OE.Value, I.[Description],  M.itemkey , M.[Description] , DD.DriverNonDriverCostDesc
	from #ItemsToProcess OE
	inner join Item I WITH (NOLOCK) on OE.Value = I.ItemKey
	inner join Item M WITH (NOLOCK) on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	Left join DriverNonDriverCostItems DD WITH (NOLOCK) on M.CostGrp = DD.DriverNonDriverCostKey
	

	if(@IsDebug = 1)
	Begin
		select' #Items',* from #ItemsACC_CalcAccessorial
	end

	IF OBJECT_ID('tempdb..#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

	IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END
	Select ROW_NUMBER() over (partition by Lineitem order by convert(datetime, EffectiveDate) Desc,  City Desc, State DESC, 
		Terminal DESC, Marketkey Desc, CustName Desc,LocationName Desc, outputdataKey Desc) Rownum,
		OutputDataKey, RecordSL, B.MarketKey, B.Terminal, B.City, B.State, B.Zip, B.LocationName,
		B.ContainerSize, B.ContainerSizeKey, B.CustKey, B.CustName, B.EffectiveDate, B.EffectiveDateFrom, B.IsLocationExists,
		A.ItemKey, b.LineItem, B.MarketLocation, B.Segment, B.SegmentKey, b.TerminalKey,
		Rate, BvsNB, FreeTime, MinCnt, MaxCnt, CostGroup, 
		FileName, DateUploaded, U.UserName as  UploadedBy
	into #TempAccessorial
	from #ItemsACC_CalcAccessorial A
	inner join SELL_NAC_Accessorial_FinalDataOutput B WITH (NOLOCK) on A.MDescription = B.LineItem
	inner join SELL_NAC_Accessorial_FileProcessInfo F WITH (NOLOCK) on B.FileProcessKey = F.FileProcessKey
			inner join [user] U WITH (NOLOCK) on F.UserKey = U.UserKey
	where (B.CustName = @CustName OR B.CustName is null )  and MarketKey = isnull(@MarketKey,0) and 
		( State = isnull(@State,'') OR State is null) and 
		( City = isnull(@city,'') OR City is null) and
		( LocationName = isnull(@Location,'') OR LocationName is null)
		and B.EffectiveDate <= convert(Date, getdate())
	Order by convert(Datetime, B.EffectiveDate) Desc, OutputDataKey Desc

	if(@IsDebug = 1)
	Begin
		select '#TempAccessorial',* from #TempAccessorial order by Lineitem, Rownum
	end

	Select *
	into #Accessorials
	from #TempAccessorial A 
	where Rownum = 1

	print @city

	if(@IsDebug = 1)
	Begin
		select '#Accessorials', * from #Accessorials
	End

	select  RecordSL, LineItem, MarketLocation as Market, Terminal,itemKey, --TruckType, YardPort, [Zone], [Group], 
		Rate, BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, CostGroup,
		(isYardPort + isTerminal + isMArket + isTruckType + isZone+  isLocation +isCity + isState) as TotMatch,
		isYardPort , isTerminal , isMArket , isTruckType , isZone ,  isLocation, isCity, isState,
		FileName, DateUploaded, UploadedBy, @CustomerSegment as CustSegment
			into #InterRecord
			from (
			select *, 
				isYardPort = 0, -- Case when YardPort = @yardPort then 1 else 0 end , 
				isTerminal = Case when Terminal = @Terminal then 1 else 0 end ,
				isMArket = Case when MarketLocation = @Market then 1 else 0 end,
				isTruckType = 0, -- Case when TruckType = @TruckType then 1 else 0 end,
				isZone = 0, -- Case when Zone = @zone then 1 else 0 end,
				isLocation = Case when LocationName = @Location then 1 else 0 end,
				isState = Case when State = @State then 1 else 0 end,
				isCity = Case when City = @city then 1 else 0 end
				from #Accessorials
				WHERE (Terminal = @Terminal OR isnull(Terminal,'') = '') AND
					(MarketLocation = @Market OR isnull(MarketLocation,'') = '') 

				) A
	if(@IsDebug = 1)
	Begin
		select '#InterRecord',* from #InterRecord
	end

	
		
		if((select count(1) from #InterRecord) = 0)
		Begin

			if(@CustomerSegment = 'SMB')
			BEgin
				insert into #InterRecord 
				( RecordSL, LineItem, Market, Terminal, ItemKey, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, 
					isYardPort,isTerminal,isMArket,isTruckType, isZone, isLocation,isState,isCity,
					EffectiveDate, EffectiveDateFrom, CostGroup, FileName, DateUploaded, UploadedBy,CustSegment)
				select SellAccRateKey, AR.LineItem, ML.MarketLocation, '', I.ItemKey, AR.SMB_Rate, AR.SMB_BvsNB,
					AR.SMB_FreeTime, AR.SMB_Min, AR.SMB_Max, 
					0,0,1, 0,0,0,1,1,
					SMB_Date, 'Acc. Tariff - SMB',
					'Accessorial','Acc. Tariff - SMB',SMB_Date, 
					U.UserName, 'SMB'
				from #ItemsACC_CalcAccessorial I
				inner join Sell_AccessorialRates AR WITH (NOLOCK) on I.MDescription = AR.LineItem 
					and AR.MarketKey = @MarketKey 
				inner join MarketLocation ML WITH (NOLOCK) on AR.MarketKey = ML.MarketLocationKey
				LEft join [user] U WITH (NOLOCK) on AR.SMB_UserKey = U.UserKey
				where SMB_Rate > 0 
			End
			else if(@CustomerSegment = 'ENT')
			Begin
				insert into #InterRecord 
				( RecordSL, LineItem, Market, Terminal, ItemKey, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, 
					isYardPort,isTerminal,isMArket,isTruckType, isZone, isLocation,isState,isCity,
					EffectiveDate, EffectiveDateFrom, CostGroup, FileName, DateUploaded, UploadedBy, CustSegment)
				select SellAccRateKey, AR.LineItem, ML.MarketLocation, '', I.ItemKey, AR.ENT_Rate, AR.ENT_BvsNB,
					AR.ENT_FreeTime, AR.ENT_Min, AR.ENT_Max,
					0,0,1, 0,0,0,1,1,
					ENT_Date, 'Acc. Tariff - ENT',
					'Accessorial','Acc. Tariff - ENT',ENT_Date, 
					U.UserName, @CustomerSegment
				from #ItemsACC_CalcAccessorial I
				inner join Sell_AccessorialRates AR WITH (NOLOCK) on I.MDescription = AR.LineItem 
					and AR.MarketKey = @MarketKey 
				inner join MarketLocation ML WITH (NOLOCK) on AR.MarketKey = ML.MarketLocationKey
				LEft join [user] U WITH (NOLOCK) on AR.ENT_UserKey = U.UserKey
				where ENT_Rate > 0 --and  isnull(I.CustSegment,'') = ''
			End
		End
		
		
		if(@IsDebug = 1)
		Begin
			select '#InterRecord-2', * from #InterRecord
		end

		
		Declare @AccessorialReason varchar(max) = ''
		if((Select count(1) from #InterRecord) = 0 and (Select count(1) from #ItemsACC_CalcAccessorial where CostGroup = 'Accessorial') > 0)
		Begin
			set @AccessorialReason = 'Record not found in ' + 
				Case when @CustomerSegment = 'NAC' then ' NAC Accessorial ' else 'Accessorial Tariff' end + 
				' for the Container: ' + @ContainerNo 
				+ ', Cust Name: ' + @CustName
				+ ', Market: ' + @Market 
				+ ', City : ' + @city
				+ ', State : ' + @State 
		End

		
			select   RecordSL, LineItem, MArket, Terminal,ItemKey,  --TruckType, YardPort, [Zone], [Group], 
				Rate, BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, CostGroup, 
				FileName, DateUploaded, UploadedBy
			from (
				select  *, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc, convert(datetime, EffectiveDate) Desc) RecNo From #InterRecord B 
			) C where RecNo = 1
		


	DROP TABLE #InterRecord
	DROP TABLE #Accessorials
	DROP TABLE #ItemsACC_CalcAccessorial
	DROP TABLE #TempAccessorial
	DROP TABLE #ItemsToProcess

END
