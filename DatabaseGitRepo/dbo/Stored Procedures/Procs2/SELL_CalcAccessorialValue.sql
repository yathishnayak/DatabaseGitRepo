--Exec SELL_CalcAccessorialValue  @MarketKey = 2, @city ='Long Beach',@State='CA',@Location='JCT VICTORIA ST.',@CustKey=1823,@InvoiceKey=134622,@ContainerNo='CAAU5909022'
CREATE PRoc [dbo].[SELL_CalcAccessorialValue]  -- 1765 // 3281
 --SELL_CalcAccessorialValue  @MarketKey = 2, @city ='Phoenix',@State='AZ',@Location='ACD',@CustKey=1765,@InvoiceKey=71706,@ContainerNo='TCNU2584969'
 --SELL_CalcAccessorialValue  @MarketKey = 2, @city ='Perris',@State='CA',@Location='DELL PRODUCTS LP',@CustKey=3170,@InvoiceKey=68738,@ContainerNo='MSDU6189083'
(
	@MarketKey				int = 0,
	@InvoiceKey				int = 0,
	@ContainerNo			varchar(50) = '',
	@Terminal				varchar(50) = '',
	@Location				varchar(100) = '',
	@city					varchar(100) = '',
	@State					varchar(20) = '',
	@TruckType				varchar(50) = '',
	@CustKey				int = 0,
	
	@IsGeneralNAC			Bit = 1,-- When 1, then Ignore custKey and use General Data in NAC
	@IsDebug				bit = 0
)
As
BEGIN
	Declare  
		@AddedAccessorialsTotalCost		decimal(18,2),
		@Market				varchar(50),
		@CustName			varchar(200)

	select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	select @CustName = CustName from Customer WITH (NOLOCK) where Custkey = @Custkey
	--select '@Market', @Market

	create table #Items
	(
		ItemKey				int,
		IDescription			varchar(100),
		MItemKey			int,
		MDescription		varchar(100),
		CostGroup			varchar(50)
	)

	if(@IsDebug = 1)
	Begin
	select 'Accessorial', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, 
		@Location as Location, @ContainerNo as ContainerNo, @TruckType as TruckType 
	End

	insert into #Items (ItemKey, IDescription, MItemKey, MDescription, CostGroup)
	select ID.ItemKey, I.[Description],  M.itemkey , M.[Description] , DD.DriverNonDriverCostDesc
	from Invoicedetail ID
	inner join InvoiceContainers IC on Id.InvoiceKey = IC.InvoiceKey and ID.OrderDetailKey = IC.OrderDetailsKey
	inner join Item I on ID.ItemKey = I.ItemKey
	inner join Item M on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	Left join DriverNonDriverCostItems DD on M.CostGrp = DD.DriverNonDriverCostKey
	where ID.InvoiceKey = @InvoiceKey and IC.ContainerNo = @ContainerNo

	if(@IsDebug = 1)
	Begin
		select' #Items',* from #Items
	end

	Select ROW_NUMBER() over (partition by Lineitem order by   City Desc, State DESC, Terminal DESC, 
		Marketkey Desc, CustName Desc,LocationName Desc, convert(datetime, EffectiveDate) Desc, outputdataKey Desc) Rownum,
		OutputDataKey, RecordSL, B.MarketKey, B.Terminal, B.City, B.State, B.Zip, B.LocationName,
		B.ContainerSize, B.ContainerSizeKey, B.CustKey, B.CustName, B.EffectiveDate, B.EffectiveDateFrom, B.IsLocationExists,
		A.ItemKey, b.LineItem, B.MarketLocation, B.Segment, B.SegmentKey, b.TerminalKey,
		Rate, BvsNB, FreeTime, MinCnt, MaxCnt, CostGroup, 
		FileName, DateUploaded, U.UserName as  UploadedBy
	into #TempAccessorial
	from #Items A
	inner join SELL_NAC_Accessorial_FinalDataOutput B on A.MDescription = b.MasterLineItem -- B.LineItem
	inner join SELL_NAC_Accessorial_FileProcessInfo F on B.FileProcessKey = F.FileProcessKey
			inner join [user] U on F.UserKey = U.UserKey
	where (B.CustName = @CustName OR B.CustName is null ) and MarketKey = isnull(@MarketKey,0) and 
		( State = isnull(@State,'') OR State is null) and 
		( City = isnull(@city,'') OR City is null) and
		( LocationName = isnull(@Location,'') OR LocationName is null)
		and EffectiveDate <= convert(Date, getdate())
	Order by convert(datetime, EffectiveDate) Desc, OutputDataKey Desc

	if(@IsDebug = 1)
	Begin
		select '#TempAccessorial',CostGroup as CG,* from #TempAccessorial order by CostGroup, Lineitem, Rownum
		select '#TempAccessorial',CostGroup as CG,* from #TempAccessorial where CostGroup = 'BobTail'
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

	select  RecordSL, LineItem, MarketLocation as MArket, Terminal,itemKey, --TruckType, YardPort, [Zone], [Group], 
		Rate, BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, CostGroup,
		(isYardPort + isTerminal + isMArket + isTruckType + isZone+  isLocation +isCity + isState) as TotMatch,
		isYardPort , isTerminal , isMArket , isTruckType , isZone ,  isLocation, isCity, isState,
		FileName, DateUploaded, UploadedBy
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

	select   RecordSL, LineItem, MArket, Terminal,ItemKey,  --TruckType, YardPort, [Zone], [Group], 
		Rate, BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, CostGroup, 
		FileName, DateUploaded, UploadedBy
	from (
		select  *, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc, Convert(Datetime, EffectiveDate) Desc) RecNo From #InterRecord B 
	) C where RecNo = 1

	drop table #InterRecord
	drop table #Accessorials
	drop table  #Items 
end