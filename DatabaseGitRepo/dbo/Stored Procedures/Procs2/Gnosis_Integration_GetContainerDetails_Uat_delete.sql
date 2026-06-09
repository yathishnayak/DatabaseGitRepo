

/*
--set @JsonString = '{"ContainerNo":"","ThisWeek":false,"NearingDemurrage":false,"WithDemurrage":false,"CustKey":3170,"CSRKey":"","Customer":"","ContainerStatusKey":"","HoldStatus":"","Terminal":"","PickupAvailable":"ALL","DemurrageStatus":"","CSMKey":"","SalesPersonKey":"","PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"ContainerNo":"","ThisWeek":false,"Today":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"ContainerStatusKeys":"Out for Delivery:Empty Returned:","ContainerNo":"","ThisWeek":false,"Today":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"TerminalNames":"Long Beach Container Terminal:Yusen Terminals:","ContainerNo":"","ThisWeek":false,"Today":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"SearchText":"131041","ContainerNo":"","ThisWeek":false,"Today":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"HoldTypes":"CUSTOMS:OTHER:","ContainerNo":"","ThisWeek":false,"Today":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
--set @JsonString = '{"ThisWeek":false,"Today":false,"Arrived":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"NearingDemurrage":false,"WithDemurrage":false,"WithDetention":false,"Terminal":"","PageNo":1,"PageSize":50,"SortField":"ContainerNo","IsAscending":true,"CSMKeys":"","CSRKeys":"Candy Basulto:","ContainerStatusKeys":"","CustKeys":"","SalesPersonKeys":"","HoldStatus":"","TerminalNames":"","MarketKeys":"","SearchText":"","DischargeYN":"","IsScheduledYN":"","PickupAvailable":"","HoldTypes":""}'

Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"ThisWeek":false,"Today":false,"Arrived":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"NearingDemurrage":false,"WithDemurrage":false,"WithDetention":false,"Terminal":"","PageNo":1,"PageSize":50,"SortField":"ContainerNo","IsAscending":true,"CSMKeys":"","CSRKeys":"Candy Basulto:","ContainerStatusKeys":"","CustKeys":"","SalesPersonKeys":"","HoldStatus":"","TerminalNames":"","MarketKeys":"","SearchText":"","DischargeYN":"","IsScheduledYN":"","PickupAvailable":"","HoldTypes":""}'
exec Gnosis_Integration_GetContainerDetails_Uat_delete @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE	[dbo].[Gnosis_Integration_GetContainerDetails_Uat_delete] 
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @IsDebug	bit = 1,
			@IsAllCount	bit = 0

	DECLARE 
		@ContainerNo			varchar(20),
		@IsThisWeek				bit		,	
		@IsArrived				bit		,
		@IsToday				bit		,
		@IsNextWeek				bit		,
		@IsThisMonth			bit		,
		@IsDemurrageStatus		bit		,
		@IsDetentionStatus		bit		,
		@NearingDemurrage		bit		,	
		@WithDemurrage			bit		,	

		@CustKeys				varchar(max),
		@CSRKeys				varchar(max),
		@CSMKeys				varchar(max),
		@ContainerStatusKeys	varchar(max),	
		@HoldStatus				varchar(20)	,
		@HoldTypes				varchar(50)	,
		@TerminalNames			varchar(max),
		@TerminalCodes			varchar(max),
		@VesselIMOs				varchar(max),
		@SalesPersonKeys		varchar(max),
		@PickupAvailable		varchar(5)		,	
		@PickUpFrom            datetime  ,
        @PickUpTo              datetime  ,
		@MarketKeys				varchar(100),
		@DischargeYN			varchar(2),
		@CSRName				varchar(50),
		@PageNo			int,
		@PageSize		int,
		@SearchText		varchar(50),
		@SortField		varchar(50),
		@IsAscending	Bit = 1,
		@IsCTF				bit		,
		@IsTMF				bit		,
		@IsLine				bit		,
		@IsOther			bit		,	
		@IsCustoms			bit		,
		@OutputType			varchar(50)

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End
	
	Select @ContainerNo = ContainerNo, @IsThisWeek = isnull(ThisWeek,0), 
		@IsToday = isnull(Today,0), @IsNextWeek = isnull(NextWeek,0), @IsArrived = isnull(Arrived,0),
		@IsThisMonth = isnull(ThisMonth,0), @CustKeys = isnull(CustKeys,''),
		@NearingDemurrage = isnull(NearingDemurrage,0),  @WithDemurrage = isnull(WithDemurrage,0),
		@CSRKeys = isnull(CSRKeys,''),  @ContainerStatusKeys = isnull(ContainerStatusKeys,''),
		@HoldStatus = isnull(HoldStatus,''), @TerminalNames = isnull(TerminalNames,''),
		@TerminalCodes = isnull(TerminalCodes,''), @HoldTypes = isnull(HoldTypes,''),
		@PickupAvailable = isnull(PickupAvailable,''), @IsDemurrageStatus = isnull(DemurrageStatus,0), 
		@IsDetentionStatus =isnull(DetentionStatus,0), @VesselIMOs = isnull(VesselIMOs,''),
		@CSMKeys = isnull(CSMKeys,''), @SalesPersonKeys = isnull(SalesPersonKeys,''),
		@PickUpFrom =isnull(PickUpFrom ,''), @PickUpTo = isnull(PickUpTo ,''),
		@MarketKeys = isnull(MarketKeys,''), @DischargeYN = isnull(DischargeYN,'N'),
		@PageNo = PageNo,  @PageSize =PageSize, 
		@SearchText = isnull(SearchText,''), @SortField = SortField,
		@IsAscending = isnull(IsAscending,1), @OutputType = isnull(OutputType,'')
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo			varchar(20)		'$.ContainerNo',
		ThisWeek			bit				'$.ThisWeek',
		Today				bit				'$.Today',
		Arrived				bit				'$.Arrived',
		NextWeek			bit				'$.NextWeek',
		ThisMonth			bit				'$.ThisMonth',
		NearingDemurrage	bit				'$.NearingDemurrage',
		WithDemurrage		bit				'$.WithDemurrage',
		CSRKeys				varchar(max)	'$.CSRKeys',
		ContainerStatusKeys	varchar(max)	'$.ContainerStatusKeys',
		HoldStatus			varchar(20)		'$.HoldStatus',
		HoldTypes			varchar(50)		'$.HoldTypes',
		TerminalNames		varchar(max)	'$.TerminalNames',
		TerminalCodes		varchar(max)	'$.TerminalCodes',
		VesselIMOs		    varchar(max)    '$.VesselIMOs',
		PickupAvailable		varchar(5)		'$.PickupAvailable',
		DetentionStatus		bit				'$.DetentionStatus',
		DemurrageStatus		bit				'$.DemurrageStatus', -- 1: Approching, 2: with Demurrage
		CustKeys			varchar(max)	'$.CustKeys',
		CSMKeys				varchar(max)	'$.CSMKeys',
		SalesPersonKeys		varchar(max)	'$.SalesPersonKeys',
		PickUpFrom          datetime        '$.PickUpFrom', 
		PickUpTo            datetime        '$.PickUpTo', 
		MarketKeys			varchar(max)	'$.MarketKeys',
		DischargeYN			varchar(2)		'$.DischargeYN',
		PageNo				int				'$.PageNo',
		PageSize			int				'$.PageSize',
		SearchText			varchar(50)		'$.SearchText',
		SortField			varchar(50)		'$.SortField',
		IsAscending			bit				'$.IsAscending',
		OutputType			varchar(50)		'$.OutputType'
	)

	SET @IsCTF = CASE WHEN @HoldTypes LIKE '%CTF%' THEN 1 ELSE 0 END 
	SET @IsTMF = CASE WHEN @HoldTypes LIKE '%TMF%' THEN 1 ELSE 0 END 
	SET @IsLine = CASE WHEN @HoldTypes LIKE '%LINE%' THEN 1 ELSE 0 END  
	SET	@IsOther = CASE WHEN @HoldTypes LIKE '%OTHER%' THEN 1 ELSE 0 END 
	SET @IsCustoms = CASE WHEN @HoldTypes LIKE '%CUSTOMS%' THEN 1 ELSE 0 END 
	
	CREATE TABLE #CustKeys
	(
		CustKey		int,
		CustName	varchar(200)
	)
	IF(LEN(ISNULL(@CustKeys,'')) > 0)
	BEGIN
		insert into #CustKeys(CustName)
		select value from dbo.Fn_SplitParamCol(@CustKeys)
	END

	CREATE TABLE #CSRKeys
	(
		CSRKey		int,
		CSRName		varchar(100)
	)
	IF(LEN(ISNULL(@CSRKeys,'')) > 0)
	BEGIN
		insert into #CSRKeys(CSRName)
		select value from dbo.Fn_SplitParamCol(@CSRKeys)
	END

	CREATE TABLE #CSMKeys
	(
		CSMKey		int,
		CSMName		varchar(100)
	)
	IF(LEN(ISNULL(@CSMKeys,'')) > 0)
	BEGIN
		insert into #CSMKeys(CSMName)
		select value from dbo.Fn_SplitParamCol(@CSMKeys)

		Update A SET CSMKey = M.CsrKey
		From #CSMKeys A
		inner join CSR M on A.CSMName = M.CsrName
	END

	CREATE TABLE #SalesPersonKeys
	(
		SalesPersonKey		int
	)
	IF(LEN(ISNULL(@SalesPersonKeys,'')) > 0)
	BEGIN
		insert into #SalesPersonKeys(SalesPersonKey)
		select value from dbo.Fn_SplitParamCol(@SalesPersonKeys)
	END

	CREATE TABLE #ContainerStatusKeys
	(
		ContainerStatusKey		varchar(50)
	)
	IF(LEN(ISNULL(@ContainerStatusKeys,'')) > 0)
	BEGIN
		insert into #ContainerStatusKeys(ContainerStatusKey)
		select value from dbo.Fn_SplitParamCol(@ContainerStatusKeys)
	END

	CREATE TABLE #TerminalNames
	(
		TerminalName		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalNames,'')) > 0)
	BEGIN
		insert into #TerminalNames(TerminalName)
		select value from dbo.Fn_SplitParamCol(@TerminalNames)
	END

	CREATE TABLE #TerminalCodes
	(
		TerminalCode		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalCodes,'')) > 0)
	BEGIN
		insert into #TerminalCodes(TerminalCode)
		select value from dbo.Fn_SplitParamCol(@TerminalCodes)
	END

	CREATE TABLE #VesselIMOs
	(
		VesselIMO		varchar(100)
	)
	IF(LEN(ISNULL(@VesselIMOs,'')) > 0)
	BEGIN
		insert into #VesselIMOs(VesselIMO)
		select value from dbo.Fn_SplitParamCol(@VesselIMOs)
	END
	CREATE TABLE #MarketKeys
	(
		MarketKey		varchar(50)
	)
	IF(LEN(ISNULL(@MarketKeys,'')) > 0)
	BEGIN
		insert into #MarketKeys(MarketKey)
		select value from dbo.Fn_SplitParamCol(@MarketKeys)
	END
	

	if(@IsDebug = 1)
	Begin
		SElect
		@ContainerNo  as  ContainerNo, @IsThisWeek  as  ThisWeek, @IsToday  as  Today, @IsNextWeek  as  NextWeek,@IsArrived as Arrived,
		@IsThisMonth  as  ThisMonth, @CustKeys  as  CustKeys, @HoldTypes as HoldTypes,
		@NearingDemurrage  as  NearingDemurrage,  @WithDemurrage  as  WithDemurrage,
		@CSRKeys  as  CSRKey,  @ContainerStatusKeys  as  ContainerStatusKey,@MarketKeys as MarketKeys,
		@HoldStatus  as  HoldStatus, @TerminalNames  as  TerminalNames, @TerminalCodes  as  TerminalCodes,
		@PickupAvailable  as  PickupAvailable, @IsDemurrageStatus  as  DemurrageStatus, @IsDetentionStatus  as DetentionStatus,
		@CSMKeys  as  CSMKeys, @SalesPersonKeys  as  SalesPersonKeys,@VesselIMOs as VesselIMOs, @PickUpFrom as PickUpFrom,@PickUpTo as PickUpTo,
		@IsCTF  as  IsCTF, @IsTMF  as  IsTMF, @IsLine  as  IsLine, @IsOther  as  IsOther, @IsCustoms  as  IsCustoms,
		@DischargeYN as DischargeYN,
		@PageNo  as  PageNo,  @PageSize  as PageSize, 
		@SearchText  as  SearchText, @SortField  as  SortField,
		@IsAscending  as  IsAscending

		select * from #CustKeys
		select * from #CSRKeys
		select * from #CSMKeys
		select * from #SalesPersonKeys
		select * from #ContainerStatusKeys
		select * from #TerminalNames
		select * from #TerminalCodes
		select * from #VesselIMOs
		SElect * from #MarketKeys
	End

	

	Declare @Today					Date,
			@AllCount				int,
			@arrivedCount			int,
			@ThisWeekNum			int,
			@NextWeeknum			int,
			@ThisMonthFrom			date,
			@ThisMonthTo			date,
			@TodayCount				int,
			@ThisWeekCount			int,
			@NextWeekCount			int,
			@ThisMonthCount			int,
			@DemCount				int,
			@DemAmt					Decimal(18,4),
			@DetCount				int,
			@DetAmt					Decimal(18,4),
			@ActivePriorityCount	int,
			@CustName				varchar(200),
			@AprDemurrage			int =55,
			@InDemurrage			int = 66

	
	Set @Today = convert(Date,GetDate())
	Set	@ThisWeekNum = Datepart(ISO_WEEK,@Today)
	SEt @NextWeeknum = DatePart(ISO_WEEK, Getdate() + 7) --Case when @ThisWeekNum = 52 then 1 else @ThisWeekNum + 1 end
	SEt @ThisMonthFrom	 = convert(Date,Getdate() +1)  --month(@today)
	SEt @ThisMonthTo	 = convert(Date,Getdate() +30)  --month(@today)

	if(@IsDebug = 1)
	Begin
		Select @Today as Today, @ThisWeekNum as ThisWeekNum,
				@NextWeeknum as NextWeeknum,
				@ThisMonthFrom as ThisMonthFrom, @ThisMonthTo as ThisMonthTo
	End
	
	SELECT UUID ,  
	  [Delivery Location City] as DelLocCity, 
		[Order CSR] as OrderCSR, [Delivery Location State] as DelLocState, 
		[Broker Ref No] as BrokerRefNo, [Customer],[Delivery Location Name] as DelLocName
	Into #CustData
	FROM  
	(
	  SELECT A.UUID, Field_name, Field_value
	  FROM Gnosis_Integration_ContainerCustomer_Final A
	  --inner join Gnosis B on a.DataKey = b.DataKey
	) AS SourceTable  
	PIVOT  
	(  
	  max(Field_Value)
	  FOR Field_name IN ([Delivery Location City], 
		[Order CSR], [Delivery Location State], [Broker Ref No], [Customer],[Delivery Location Name])  
	) AS PivotTable; 
	
	Select distinct Final_dest_city , 
		MarketLocation = case when Final_dest_city in ('Chicago, US','Harvey, US','Joliet, US','Elwood, US')
		Then 'Chicago' 
		when isnull(Final_dest_city,'') = '' then 'NA' 
		else 'Long Beach' end
	into #MktLocation
	from Gnosis_Integration_Container_FINAL

	print 'Done 1'
	if(@IsDebug = 1)
	Begin
		Select count(1) as CustDataCount from #CustData
		select top 100 * from #CustData
	End

	if ((select count(1) from #CustKeys) > 0)
	Begin
		update T set  T.CustName = C.Custname 
		from Customer C WITH (NOLOCK) 
		inner join #CustKeys T on C.CustName = T.CustName
	End

	if(@IsDebug = 1)
	Begin
		select * from #CustKeys
	End
  
	SELECT			--CD.DataKey,CD.RecordKey,
					CD.UUID,
					CD.Container_number as ContainerNo,
					CD.Container_journey_start_key,
					CD.Seal_no
					,isnull(CD.Container_type,'') + ' - ' + isnull(Cd.Length,'') as ContainserSize
					,CAST(CD.Length AS INT) as ContainerLength
					,CD.Weight,CAST(CD.Empty_out_dt AS DATETIME)Empty_out_dt
					,CAST(CD.In_gate_dt AS DATETIME)In_gate_dt
					,CAST(CD.Early_receive_dt AS DATETIME)Early_receive_dt
					,CAST(CD.Cut_off_dt AS DATETIME)Cut_off_dt
					,CAST(CD.Out_gate_dt  AS DATETIME)Out_gate_dt
					,CAST(CD.Port_eta_dt  AS DATETIME)Port_eta_dt
					,CAST(CD.Gnosis_vessel_eta_dt  AS DATETIME) Gnosis_vessel_eta_dt
					,CAST(CD.Gnosis_estimated_discharge_dt  AS DATETIME) Gnosis_estimated_discharge_dt
					,CAST(CD.Gnosis_rail_eta_dt  AS DATETIME)Gnosis_rail_eta_dt
					,CAST(isnull(CD.Vessel_eta_dt,Gnosis_vessel_eta_dt)  AS DATETIME)Vessel_eta_dt
					,CAST(CD.Vessel_etd_dt  AS DATETIME)Vessel_etd_dt
					,CAST(CD.Vessel_ata_dt  AS DATETIME)Vessel_ata_dt
					,CAST(CD.Vessel_atd_dt  AS DATETIME)Vessel_atd_dt
					,CAST( case when Is_railing = 'true' then CD.Rail_discharged_dt else  CD.Discharged_dt end  AS DATETIME)Discharged_dt
					,CAST(CD.Empty_returned_dt  AS DATETIME) Empty_returned_dt
					,CD.Pod_locode,CD.Pod_city,CD.Pod_terminal_name,CD.Pod_terminal_firms_code
					,CD.Pol_locode,CD.Pol_city,CD.Pol_terminal_name,CD.Pol_terminal_firms_code
					,CD.Por_locode,CD.Por_city,CD.Ocean_carrier_name,CD.Ocean_carrier_scac,CD.Mother_vessel,CD.Mother_vessel_imo,CD.Mother_voyage
					,CAST(CD.Motherload_dt  AS DATETIME)Motherload_dt,CD.Current_vessel,CD.Current_vessel_imo,CD.First_vessel
					,CD.First_vessel_imo
					,case when Is_railing = 'true' then CD.Current_vessel else '' end as Rail_Carrier
					,CD.Location_at_terminal,CD.Is_railing
					,CD.Rail_eta_dt,CD.Rail_ata_dt,CD.Rail_departed_dt
					,CD.Rail_discharged_dt,CD.Rail_terminal,CD.Rail_terminal_firms_code
					,CD.Rail_notify_dt,CD.Pickup_number,CAST(CD.Available_dt  AS DATETIME)Available_dt
					,CD.Final_dest_locode,CD.Final_dest_city
					,CAST(CD.Last_free_demurrage_day_dt AS DATETIME) Last_free_demurrage_day_dt
					,TempLFD = case when @IsAscending = 1 then 
						CAST(isnull(CD.Last_free_demurrage_day_dt,'12/31/2050') AS DATETIME) 
						else CAST(isnull(CD.Last_free_demurrage_day_dt,'01/01/2020') AS DATETIME)  end
					,CAST(CD.Last_free_detention_day_dt  AS DATETIME)Last_free_detention_day_dt
					,CAST(CD.Estd_last_free_demurrage_day_dt  AS DATETIME)Estd_last_free_demurrage_day_dt
					,CONVERT(DECIMAL(18,2), ISNULL(CD.Demurrage_amount,0)) AS Demurrage_amount
					,CONVERT(DECIMAL(18,2), ISNULL(CD.Estd_demurrage_amount,gnosis_estimated_demurrage_amount)) as Estd_demurrage_amount
					,CAST(CD.Estd_last_free_detention_day_dt AS DATETIME) Estd_last_free_detention_day_dt
					,CD.Estd_detention_amount
					,CAST(CD.Carrier_release_dt  AS DATETIME) Carrier_release_dt
					,CAST(CD.Customs_clearance_dt  AS DATETIME) Customs_clearance_dt
					,isnull(CD.Available_for_pickup,'false') as Available_for_pickup
					,CAST(CD.Loaded_on_vessel_dt  AS DATETIME)Loaded_on_vessel_dt
					,CAST(CD.Pickup_appointment_dt  AS DATETIME)Pickup_appointment_dt
					,CAST(CD.Updated_dt  AS DATETIME)Updated_dt
					,CD.Chassis_number
					,CD.Customer_tag
					,CD.Carrier_contract
--					,'' Custom_detention_demurrage_calc
					,CD.Distribution_center
					,CD.Drayage_carrier
					,MBL_number
					,Dropped
					, CTF,TMF,Line,Other,Customs
					,C.BrokerRefNo, isnull(C.Customer,CU.CustName) as Customer 
					,isnull(C.DelLocCity,AD.City) as DelLocCity
					,isnull(C.DelLocName,AD.AddrName ) as DelLocName
					,isnull(C.DelLocState, AD.State) as DelLocState
					, isnull(C.OrderCSR, CR.CsrName) as OrderCSR
					, OH.OrderNo, OH.OrderKey, OD.OrderDetailKey, OH.CsrKey, OH.CSRManagerKey AS CSMKey,
					OH.SalesPersonKey, OH.CustKey
					, CD.ContainerStatus
					, ISNULL(ML.MarketLocation,ML1.MarketLocation) AS MarketLocation
					, case when isnull(Discharged_dt,'') = '' then 'N' else 'Y' end as DischargeYN
					,CASE WHEN IsAutoMove IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS IsSentToSchedule
					--,(SELECT	UUID ,incoming_vessel,incoming_voyage
					--	,CAST(in_vessel_eta_dt  AS DATETIME)in_vessel_eta_dt 
					--	,CAST(in_vessel_ata_dt AS DATETIME)in_vessel_ata_dt
					--	,pod_locode
					--	,pod_city
					--	,outgoing_vessel
					--	,outgoing_voyage
					--	,CAST(out_vessel_etd_dt  AS DATETIME)out_vessel_etd_dt
					--	,CAST(out_vessel_atd_dt  AS DATETIME)out_vessel_atd_dt
					--	,CAST(loaded_on_vessel_dt  AS DATETIME) loaded_on_vessel_dt
					--	,CAST(discharged_dt AS DATETIME)discharged_dt
					--FROM	Gnosis_Integration_Shipments_Final S  WITH (NOLOCK)
					--WHERE	CD.UUID = S.UUID
					--FOR JSON PATH ) AS Shipments
					, LFDDateColor =
							case when  isnull(Last_free_demurrage_day_dt ,'') = ''
								then 'text-black'
							when  isnull(Last_free_demurrage_day_dt ,'') <> ''
							and convert(Date, Last_free_demurrage_day_dt) > convert(Date,getdate()+ 4)
								then 'text-black'
							when  isnull(Last_free_demurrage_day_dt ,'') <> ''
							and convert(Date, Last_free_demurrage_day_dt) = convert(Date,getdate())
							then 'text-danger'
							when  isnull(Last_free_demurrage_day_dt ,'') <> ''
							and convert(Date, Last_free_demurrage_day_dt) < convert(Date,getdate())
							then 'text-danger'
							when isnull(Last_free_demurrage_day_dt ,'') <> ''
							and DateDiff(d,convert(Date,getdate()), convert(Date, Last_free_demurrage_day_dt)) in (1,2,3)
							then 'text-warning'
							else 'text-primary' end
							

	INTO #DATA
	FROM			Gnosis_Integration_Container_Final CD  WITH (NOLOCK) --ON CDJ.RecordKey = CD.RecordKey
	LEFT JOIN		Gnosis_Integration_MBL_FINAL MB  WITH (NOLOCK) ON CD.UUID = MB.UUID
	LEFT JOIN		Gnosis_Integration_Holds_Final H  WITH (NOLOCK) ON CD.UUID = H.UUID
	--LEFT JOIN		vGnosis_ContainerCustomers CC WITH (NOLOCK) on CD.DataKey = CC.DataKey
	LEFT JOIN		#CustData C on CD.UUID = C.UUID
	LEFT JOIN		OrderDetail OD WITH (NOLOCK) ON CD.Container_number = OD.ContainerNo
	LEFT JOIN		ORDERHEADER OH WITH (NOLOCK) ON OD.ORDERKEY = OH.OrderKey
	LEFT JOIN		MarketLocation ML1 WITH (NOLOCK) ON OH.MarketLocationKey = ML1.MarketLocationKey
	LEFT JOIN		#MktLocation ML On CD.Final_dest_city = ML.Final_dest_city
	Left join		CSR CR WITH (NOLOCK)  on OH.CsrKey = CR.CsrKey
	LEFT JOIN		CUSTOMER CU WITH (NOLOCK)  on OH.CustKey = CU.CustKey
	LEFT JOIN		Address AD WITH (NOLOCK) on OH.DestinationAddrKey = AD.AddrKey
	where 			CD.ContainerStatus not in ('Out for Delivery','Empty Returned', 'Loaded on Vessel','Ready to Load', 'At Origin') 

	SELECT * from #DATA
	if(@IsDebug = 1)
	Begin
		Select count(1) as DataCount from #DATA
	End
	print 'Done 2'

	if(@IsAllCount = 1)
	Begin
		SELECT	@AllCount = COUNT(1) from #DATA

		SELECT @TodayCount = COUNT(1) from #DATA 
			where case when Is_railing = 'true' then  convert(date, ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))  
			else convert(date, ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)) end  = @Today 
		SELECT @ThisWeekCount = COUNT(1) from #DATA 
			WHERE case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,Rail_eta_dt)) 
				else DATEPART(ISO_WEEK,convert(Date,Vessel_ata_dt)) end  = @ThisWeekNum 
			 and case when Is_railing = 'true' then  convert(date, Rail_eta_dt)  
				else convert(date, Vessel_ata_dt) end > @Today
		SELECT @NextWeekCount = COUNT(1) from #DATA 
			WHERE case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,Rail_eta_dt)) 
				else DATEPART(ISO_WEEK,convert(Date,Vessel_ata_dt))  end = @NextWeeknum
		SELECT @ThisMonthCount = COUNT(1) from #DATA 
			WHERE case when Is_railing = 'true' then  convert(date, Rail_eta_dt)  
				else convert(date, Vessel_ata_dt) end between @ThisMonthFrom and @ThisMonthTo
		SELECT @arrivedCount = count(1) from #DATA 
			where case when Is_railing = 'true' then  convert(date, Rail_ata_dt)  else convert(date, Vessel_ata_dt) end <= @Today
		Select @InDemurrage = count(1) from #data 
			where  convert(Date, Last_free_demurrage_day_dt) <= convert(Date,getdate()) --(convert(decimal,isnull(Demurrage_amount,0)) > 0 and Last_free_demurrage_day_dt > @Today )
		SElect @AprDemurrage = Count(1) from #data 
			where DateDiff(d,convert(Date,getdate()), convert(Date, Last_free_demurrage_day_dt)) in (1,2,3) 

		Select @DemCount = Count(1), @DemAmt = sum(convert(decimal,isnull(Demurrage_amount,0)))
		from #DATA where datepart(iso_week,Last_free_demurrage_day_dt) = @ThisWeekNum

		Select @DetCount = Count(1), @DetAmt = sum(convert(decimal,isnull(Demurrage_amount,0)))
		from #DATA where datepart(iso_week,Last_free_detention_day_dt) = @ThisWeekNum
	End
	
	Set @SearchText = ltrim(rtrim(@SearchText))

	Select A.* , A.Updated_dt as MaxDate
	into #InterData
	from #DATA A
	--LEft join vGnosis_Container_Status V with (NOLOCK) on A.DataKey = v.DataKey
	WHERE			
		(Isnull(@ContainerNo,'') = '' OR ContainerNo = ltrim(rtrim(@ContainerNo))) AND
		(ISNULL(@PickupAvailable,'' ) = '' or 
			@PickupAvailable =  isnull(Available_for_pickup,'false') ) AND
		(Isnull(@TerminalNames,'') = '' OR Pod_terminal_name in (select TerminalName from #TerminalNames)) AND
		(ISNULL(@SearchText,'') = '' OR (ContainerNo like '%'+ @SearchText + '%' OR
				MBL_number like '%'+ @SearchText + '%' OR BrokerRefNo like '%'+ @SearchText + '%' )) and
		(Isnull(@HoldStatus,'') = '' OR (@HoldStatus ='YES' and ( CTF = 'true' OR TMF = 'true' 
			OR Line = 'true' OR Other = 'true' OR Customs = 'true')) OR 
			(@HoldStatus ='NO' and (CTF = 'false' and TMF = 'false' 
			and Line = 'false' and Other = 'false' and Customs = 'false'))) AND
		(isnull(@IsCTF,0) = 0 OR CTF = 'true') AND
		(isnull(@IsTMF,0) = 0 OR TMF = 'true') AND
		(isnull(@IsLine,0) = 0 OR Line = 'true') AND
		(isnull(@IsOther,0) = 0 OR Other = 'true') AND
		(isnull(@IsCustoms,0) = 0 OR Customs = 'true') AND
		(Isnull(@IsDemurrageStatus,0) = 0 OR (Datepart(wk,Last_free_demurrage_day_dt) >= @ThisWeekNum)) AND
		(Isnull(@IsDetentionStatus,0) = 0 OR (Datepart(wk,Last_free_detention_day_dt) >= @ThisWeekNum)) AND
		(Isnull(@CustKeys,'') = '' OR Customer in (SElect CustName from #CustKeys) ) AND
		(Isnull(@CSRkeys,'') = '' OR OrderCSR in (SElect CSRName from #CSRKeys) ) AND
		(Isnull(@CSMkeys,'') = '' OR CsMKey in (Select CSMKey from #CSMKeys) ) AND
		(Isnull(@TerminalCodes,'') = '' OR Pod_terminal_firms_code in (Select TerminalCode from #TerminalCodes) ) AND
		(Isnull(@SalesPersonKeys,'') = '' OR SalesPersonKey in (Select SalesPersonKey from #SalesPersonKeys ) ) AND
		(ISNULL(@VesselIMOs,'') ='' OR Current_vessel_imo in (Select VesselIMO from #VesselIMOs )) AND
		(ISNULL(@PickUpFrom,'') ='' OR Pickup_appointment_dt >= @PickUpFrom) AND
		(ISNULL(@PickUpTo,'') ='' OR Pickup_appointment_dt  <= @PickUpTo) AND
		(ISNULL(@DischargeYN,'') = '' OR DischargeYN = @DischargeYN) AND
		(ISNULL(@MarketKeys,'') = '' OR MarketLocation in (Select MarketKey from #MarketKeys)) AND
		(ISNULL(@ContainerStatusKeys,'') ='' OR A.ContainerStatus in (Select ContainerStatusKey from #ContainerStatusKeys )) 
		

	print 'Done 3'
	if(@IsAllCount = 0)
	Begin
		SELECT	@AllCount = COUNT(1) from #InterData
		SELECT @TodayCount = COUNT(1) from #InterData 
			where case when Is_railing = 'true' then  convert(date, ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))  
			else convert(date, ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)) end   = @Today 
		SELECT @ThisWeekCount = COUNT(1) from #InterData 
			WHERE case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))) 
				else DATEPART(ISO_WEEK,convert(Date,ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt))) end  = @ThisWeekNum 
			 and case when Is_railing = 'true' then  convert(date, ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))  
				else convert(date, ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)) end > @Today
		SELECT @NextWeekCount = COUNT(1) from #InterData 
			WHERE case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))) 
				else DATEPART(ISO_WEEK,convert(Date,ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)))  end = @NextWeeknum
		SELECT @ThisMonthCount = COUNT(1) from #InterData 
			WHERE case when Is_railing = 'true' then  convert(date, ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))  
				else convert(date, ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)) end between @ThisMonthFrom and @ThisMonthTo
		SELECT @arrivedCount = count(1) from #InterData 
			where case when Is_railing = 'true' then  convert(date, Rail_ata_dt)  
			else convert(date, Vessel_ata_dt) end <= @Today
		Select @InDemurrage = count(1) from #InterData where  convert(Date, Last_free_demurrage_day_dt) <= convert(Date,getdate()) --(convert(decimal,isnull(Demurrage_amount,0)) > 0 and Last_free_demurrage_day_dt > @Today )
		SElect @AprDemurrage = Count(1) from #InterData 
			where DateDiff(d,convert(Date,getdate()), convert(Date, Last_free_demurrage_day_dt)) in (1,2,3) 

		Select @DemCount = Count(1), @DemAmt = sum(convert(decimal,isnull(Demurrage_amount,0)))
		from #InterData where datepart(iso_week,Last_free_demurrage_day_dt) = @ThisWeekNum

		Select @DetCount = Count(1), @DetAmt = sum(convert(decimal,isnull(Demurrage_amount,0)))
		from #InterData where datepart(iso_week,Last_free_detention_day_dt) = @ThisWeekNum
	End

	Select A.* 
	into #FinalData
	from #InterData A
	--LEft join vGnosis_Container_Status V with (NOLOCK) on A.DataKey = v.DataKey
	WHERE			
		(Isnull(@IsToday,0) = 0 OR 
			 case when Is_railing = 'true' then  convert(date, ISNULL(Rail_eta_dt, Gnosis_rail_eta_dt))  
			else convert(date, ISNULL(Vessel_eta_dt, Gnosis_vessel_eta_dt)) end  =@Today) AND
		(Isnull(@IsArrived,0) = 0 OR case when Is_railing = 'true' then  convert(date, Rail_ata_dt)  else convert(date, Vessel_ata_dt) end   <= @Today) AND
		(Isnull(@IsThisWeek,0) = 0 OR case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,Rail_eta_dt)) 
				else DATEPART(ISO_WEEK,convert(Date,Vessel_ata_dt)) end  = @ThisWeekNum 
			 and case when Is_railing = 'true' then  convert(date, Rail_eta_dt)  
				else convert(date, Vessel_ata_dt) end > @Today) AND
		(Isnull(@IsNextWeek,0) = 0 OR 
				case when Is_railing = 'true' then  DATEPART(ISO_WEEK,convert(Date,Rail_eta_dt)) 
				else DATEPART(ISO_WEEK,convert(Date,Vessel_ata_dt))  end = @NextWeeknum) AND
		(Isnull(@IsThisMonth,0) = 0 OR 
				case when Is_railing = 'true' then  convert(date, Rail_eta_dt)  
				else convert(date, Vessel_ata_dt) end between @ThisMonthFrom and @ThisMonthTo) AND
		(ISNULL(@WithDemurrage,0) = 0 OR convert(Date, Last_free_demurrage_day_dt) <= convert(Date,getdate())) AND  --(convert(decimal,isnull(Demurrage_amount,0)) > 0 and Last_free_demurrage_day_dt > @Today )) AND
		(ISNULL(@NearingDemurrage,0) = 0 OR 
					DateDiff(d,convert(Date,getdate()), convert(Date, Last_free_demurrage_day_dt)) in (1,2,3) )

	if(@IsDebug = 1)
	Begin
		Select count(1) as FinalDataCount from #FinalData
	End

	Declare @NotTrackingCount	int = 0

	SELECt			@NotTrackingCount = count(1)
	FROm			(SELECT			ROW_NUMBER() OVER (PARTITION BY MBL,ContainerNo ORDER BY CreatedDate DESC )SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate
					FROM			Gnosis_TrackingContainerRequestResponseDetail WITH (NOLOCK)) A
	INNER JOIN		OrderDetail  OD WITH (NOLOCK) ON A.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN		OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	INNER JOIN		Customer C WITH (NOLOCK) ON OH.CustKey = C.CustKey
	WHERE			Sl  = 1 and TrackingStatus IN ('Failed','Pending')

	declare @cnt int
	select @cnt = count(1) from #FinalData 

	if(@OutputType is not null)
	Begin
		SEt @PageSize = @cnt
		SEt @PageNo = 1
	End

	select *, 0 as RowNum, 0 as RecCount  into  #FinalData_Temp from #FinalData WHERE 1 <> 1 
	Declare @STRSQL nvarchar(max) = ''
	SET @STRSQL = '
	SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
		select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SortField + ' ' + 
		CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ') RowNum
		from #FinalData'
	+') a
	where RowNum  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + 
	CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
	+' Order BY ROWNUM'

	PRINT (@STRSQL)
	insert into #FinalData_Temp
	EXEC (@STRSQL)


	SET @Status=1
	SET @Reason='Success'
	select 
	DashboardData = (
		Select isnull(@TodayCount,0) as TodaysCount,
				Isnull(@arrivedCount,0) as ArrivedCount,
				isnull(@ThisWeekCount,0) as ThisWeekCount,
				isnull(@NextWeekCount,0) as NextWeekCount,
				isnull(@ThisMonthCount,0) as ThisMonthCount,
				isnull(@DemCount,0) as DemurrageCount,
				isnull(@DemAmt,0) as DemurrageAmount,
				isnull(@DetCount,0) as DetentionCount,
				isnull(@DetAmt,0) as DetentionAmount,
				isnull(@AprDemurrage,0) as AprDemurrage,
				isnull(@InDemurrage,0) as InDemurrage,
				isnull(@AllCount,0) as AllCount,
				isnull(@NotTrackingCount,0) as NotTrackingCount
		For Json path
	),
	ContainerList = (
		select * 
		from 		#FinalData_Temp CD 
		FOR JSON PATH
	) 
	FOR JSON PATH

	drop table #CustData
	drop table #DATA
	drop table #FinalData 
	drop table #FinalData_Temp
	drop table #ContainerStatusKeys
	drop table #CSMKeys
	drop table #CSRKeys
	drop table #CustKeys
	drop table #SalesPersonKeys
	drop table #TerminalCodes
	drop table #TerminalNames
	drop table #VesselIMOs
	

	Set @Status = 1
    Set @Reason = 'SUCCESS'
END
