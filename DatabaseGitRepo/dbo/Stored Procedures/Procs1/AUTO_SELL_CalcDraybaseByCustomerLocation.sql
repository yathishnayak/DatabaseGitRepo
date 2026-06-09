

--[AUTO_SELL_CalcDraybaseByCustomerLocation] @ItemKey = 18, @MarketKey = 2,  @CustKey = 3141,@addressKey = 42160,  @IsDebug = 1
CREATE PRoc [dbo].[AUTO_SELL_CalcDraybaseByCustomerLocation]  -- 1765 // 3281
(
	@ItemKey				int, 
	@MarketKey				int = 0,
	@addressKey				int = 0,
	@CustKey				int = 0,
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


	if(@ItemKey = 0)
	Begin
		return
	End

	Declare
		@City	varchar(50),
		@State		varchar(50),
		@Location	varchar(50),
		@TruckType	varchar(50) = 'Broker Carrier',
		@Terminal	varchar(50) ,
		@TerminalKey	int	,
		@DriverNonDriverCostDesc  varchar(50)

	select @city = City, @State = state, @Location = AddrName from Address where addrkey = @addressKey
	
	select @DriverNonDriverCostDesc = DD.DriverNonDriverCostDesc
	from Item I WITH (NOLOCK) 
	inner join Item M WITH (NOLOCK) on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	Left join DriverNonDriverCostItems DD WITH (NOLOCK) on M.CostGrp = DD.DriverNonDriverCostKey
	where I.itemkey = @Itemkey 
	
	if(@IsDebug = 1)
	Begin
		select 'Accessorial', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, 
			@Location as Location, @TruckType as TruckType, @DriverNonDriverCostDesc as DriverNonDriverCostDesc,
			@TerminalKey as TerminalKey
	End

	IF OBJECT_ID('tempdb..#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

	IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END


	select TOP 1  DraybaseCost, isnull(FSF,0) * 100 as FSF_Perent,
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey 
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join SELL_NAC_Draybase_FileProcessInfo F WITH (NOLOCK) on A.FileProcessKey = F.FileProcessKey
	inner join [user] U WITH (NOLOCK) on F.UserKey = U.UserKey
	where (City = @city OR City is null) and 
			(State = @State OR State is null) and 
			(LocationName = @Location OR LocationName is null) and  
			MarketKey = @MarketKey and A.Custkey = @CustKey and
			(@terminalKey is null OR (TerminalKey = @TerminalKey OR TerminalKey is null)  )
			and EffectiveDate <= convert(date,Getdate())
	ORDER BY city DESC, State DESC, LocationName DESC, convert(datetime,EffectiveDate) DESC, OutputDataKey Desc
	For JSON PATH
			

END
