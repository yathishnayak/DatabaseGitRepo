/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"ContainerNo":"","ThisWeek":false,"Today":false,"Arrived":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"NearingDemurrage":false,"WithDemurrage":false,"WithDetention":false,"Terminal":"","PageNo":1,"PageSize":50,"SortField":"OrderNo","IsAscending":true,"CSMKeys":"","CSRKeys":"","ContainerStatusKeys":"","CustKeys":"","SalesPersonKeys":"","HoldStatus":"","TerminalNames":"","TerminalCodes":"","VesselIMOs":"","MarketKeys":"","SearchText":"","DischargeYN":"","PickupAvailable":"","HoldTypes":"","PickUpFrom":null,"PickUpTo":null,"StatusKey":3,"OrderType":"","Deliverylocationkeys":"","Tracking":""}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_ContainerListForBulkLegAdd_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

**/

CREATE PROCEDURE [dbo].[Get_ContainerListForBulkLegAdd_V2]   
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	DECLARE @ContainerNo			varchar(20),
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
		@MarketKeys             varchar(max),
		@PickupAvailable		bit		,	
		@PickUpFrom            datetime  ,
        @PickUpTo              datetime  ,

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
		@isShowAll			BIT=1,
		@OutputType			Varchar(50),
		@StatusKey			INT=0,
		@OrderType          varchar(50),
		@Deliverylocationkeys VARCHAR(100),
		@Tracking	VARCHAR(10)

	--	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	--Begin
	--	SEt @Status = 0
	--	Set @Reason = 'Parameters not found'
	--	return
	--End
	
	Select @ContainerNo = ContainerNo, @CustKeys = isnull(CustKeys,''),
		@CSRKeys = isnull(CSRKeys,''),  @ContainerStatusKeys = isnull(ContainerStatusKeys,''),
		@HoldStatus = isnull(HoldStatus,''), @TerminalNames = isnull(TerminalNames,''),
		@TerminalCodes = isnull(TerminalCodes,''), @HoldTypes = isnull(HoldTypes,''),
		@PickupAvailable = isnull(PickupAvailable,''), @VesselIMOs = isnull(VesselIMOs,''),
		@CSMKeys = isnull(CSMKeys,''), @SalesPersonKeys = isnull(SalesPersonKeys,''), @MarketKeys = ISNULL(MarketKeys,''),
		@PickUpFrom =isnull(PickUpFrom ,''), @PickUpTo = isnull(PickUpTo ,''),

		@PageNo = PageNo,  @PageSize =PageSize, 
		@SearchText = isnull(SearchText,''), @SortField = SortField,
		@IsAscending = isnull(IsAscending,1), @OutputType = isnull(OutputType,''), 
		@StatusKey=ISNULL(StatusKey,0), @OrderType=ISNULL(OrderType,0),
		@Deliverylocationkeys=ISNULL(Deliverylocationkeys,''), @Tracking=ISNULL(Tracking,'')
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo			varchar(20)		'$.ContainerNo',
		CSRKeys				varchar(max)	'$.CSRKeys',
		ContainerStatusKeys	varchar(max)	'$.ContainerStatusKeys',
		HoldStatus			varchar(max)		'$.HoldStatus',
		HoldTypes			varchar(50)		'$.HoldTypes',
		TerminalNames		varchar(max)	'$.TerminalNames',
		TerminalCodes		varchar(max)	'$.TerminalCodes',
		VesselIMOs		    varchar(max)    '$.VesselIMOs',
		PickupAvailable		bit				'$.PickupAvailable',
		CustKeys			varchar(max)	'$.CustKeys',
		CSMKeys				varchar(max)	'$.CSMKeys',
		SalesPersonKeys		varchar(max)	'$.SalesPersonKeys',
		MarketKeys          varchar(max)    '$.MarketKeys',     
		PickUpFrom          datetime        '$.PickUpFrom', 
		PickUpTo            datetime        '$.PickUpTo', 

		PageNo				int				'$.PageNo',
		PageSize			int				'$.PageSize',
		SearchText			varchar(50)		'$.SearchText',
		SortField			varchar(50)		'$.SortField',
		IsAscending			bit				'$.IsAscending',
		OutputType			varchar(50)		'$.OutputType',
		StatusKey			varchar(50)		'$.StatusKey',
		OrderType				varchar(50)		'$.OrderType',
		Deliverylocationkeys	varchar(100)	'$.Deliverylocationkeys',
		Tracking				VARCHAR(100)				'$.Tracking'
	)
	--set @isShowAll = 1

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

		Update CK set CustName =C.CustName
		from Customer C WITH (NOLOCK) 
		Inner join #CustKeys CK On C.CustKey = CK.CustKey
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

	--select * from #CSMKeys

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
	   MarketKey   int 
	)
	IF(LEN(ISNULL(@MarketKeys,'')) > 0)
	BEGIN
	     INSERT INTO #MarketKeys(MarketKey)
		 SELECT VALUE FROM Fn_SplitParamCol(@MarketKeys)
	END
	CREATE TABLE #OrderTypeKeys
	(
		OrderTypeKey		int,
		OrderType		varchar(100)
	)
	IF(LEN(ISNULL(@OrderType,'')) > 0)
	BEGIN
		insert into #OrderTypeKeys(OrderType)
		select value from dbo.Fn_SplitParamCol(@OrderType)

		Update A SET OrderTypeKey = M.OrderTypeKey
		From #OrderTypeKeys A
		inner join OrderType M on A.OrderType = M.OrderType
	END

	CREATE TABLE #DelieverLocationKeys
	(
		DeliverocationKey		varchar(200)
	)
	IF(LEN(ISNULL(@Deliverylocationkeys,'')) > 0)
	BEGIN
		insert into #DelieverLocationKeys(DeliverocationKey)
		select value from dbo.Fn_SplitParamCol(@Deliverylocationkeys)
	END


	SELECT UUID ,  
	  [Delivery Location City] as DelLocCity, 
		[Order CSR] as OrderCSR, [Delivery Location State] as DelLocState, 
		[Broker Ref No] as BrokerRefNo, [Customer],[Delivery Location Name] as DelLocName
	Into #CustData
	FROM  
	(
	  SELECT A.UUID, Field_name, Field_value
	  FROM Gnosis_Integration_ContainerCustomer_Final A WITH (NOLOCK)
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
	from Gnosis_Integration_Container_FINAL WITH (NOLOCK)	

	declare @OpenStatusKey smallint =0;

	select @OpenStatusKey = Status from OrderDetailStatus WITH (NOLOCK)	where Description  = 'Open'



	declare  @UserCount int = 0 

	select @UserCount = count(1)
	from (
	select LinkedUserKey from CSR WITH (NOLOCK)	 where LinkedUserKey is not null
	union all
	select LinkedUserKey from SalesPerson WITH (NOLOCK)	 where LinkedUserKey is not null
	) A where LinkedUserKey = @UserKey  

	if (@isShowAll =0)	select @isShowAll = case when isnull(@UserCount ,0) = 0 then 1 else 0 end
	--DECLARE @STRSQL VARCHAR(MAX)
	Declare @RecCount	int, @RowNum int

		SELECT
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			isnull(OT.OrderTypeKey,0) as OrderTypeKey,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.ContainerID, '') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			ISNULL(isnull(OD.LastFreeDay,Last_free_demurrage_day_dt),'') as LastFreeDay,
			RT.PickupDateFrom AS PickupDate ,
			CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			RT.DeliveryDateFrom AS DropOffDate,
			CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,	
			isnull(OSD.[Description],'') AS [Status],
			OD.Status as StatusKey,
			isnull(OT.OrderType,'') AS OrderType,
			isnull(OH.BillOfLading,'') AS BillOfLading,
			isnull(OH.BookingNo,'') AS BookingNo,
			isnull(OH.BrokerRefNo,'') as BrokerRefNo,
			isnull(CS.[Description],'') AS ContainerSize,
			isnull(PT.[Description],'')  AS [Priority],
			isnull(CSR.AddrName,SR.AddrName) AS S_AddrName,
			isnull(CSR.Address1,SR.Address1) AS S_Address1,
			isnull(CSR.City,SR.City)  AS S_City,
			isnull(CSR.[State],SR.[State])  AS S_State,
			isnull(CSR.ZipCode,SR.ZipCode)  AS S_ZipCode,
			isnull(CSR.Country,SR.Country)  AS S_Country,
			isnull(CDT.AddrName,DT.AddrName)  AS D_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS D_Address1,
			isnull(CDT.City,DT.City)  AS D_City,
			isnull(CDT.[State],DT.[State])  AS D_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS D_ZipCode,
			isnull(CDT.Country,DT.Country)  AS D_Country,
			isnull(CSR.AddrName,SR.AddrName) AS Source_AddrName,
			isnull(CSR.Address1,SR.Address1) AS Source_Address1,
			isnull(CSR.City,SR.City)  AS Source_City,
			isnull(CSR.[State],SR.[State])  AS Source_State,
			isnull(CSR.ZipCode,SR.ZipCode)  AS Source_ZipCode,
			isnull(CSR.Country,SR.Country)  AS Source_Country,
			isnull(CDT.AddrName,DT.AddrName)  AS Destination_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS Destination_Address1,
			isnull(CDT.City,DT.City)  AS Destination_City,
			isnull(CDT.[State],DT.[State])  AS Destination_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS Destination_ZipCode,
			isnull(CDT.Country,DT.Country)  AS Destination_Country,
			isnull(BT.AddrName,'')  AS B_AddrName,
			isnull(BT.Address1,'')  AS B_Address1,
			isnull(BT.City,'')  AS B_City,
			isnull(BT.[State],'')  AS B_State,
			isnull(BT.ZipCode,'')  AS B_ZipCode,
			isnull(BT.Country,'')  AS B_Country,
			isnull(RET.AddrName,'') AS R_AddrName,
			isnull(RET.Address1,'') AS R_Address1,
			isnull(RET.City,'') AS R_City,
			isnull(RET.[State],'') AS R_State,
			isnull(RET.ZipCode,'') AS R_ZipCode,
			isnull(RET.Country,'') AS R_Country,	
			ISNULL(isnull(OD.VesselETA,Gnosis_vessel_eta_dt),'') AS VesselETA,
			isnull(OD.IsLinked,0) AS IsLinked,
			isnull(OD.LinkedContainerNo,'') AS LinkedContainerNo,
			OH.custKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
			, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as isTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			ISNULL(UU.UserName,'''') AS CreatedUser,
			
			l.FromLocation  AS LocationType ,
			RA.AddrName AS CurLocation, RT.RouteKey, RP.AddrName, 
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			B.LastFreeDay as  Int_LFD, convert(bit, case when isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end) as IntDataExists ,
			od.CompleteDate as TerminationDate,
			od.isStreetTurn,
			ISNULL(u2.UserName,'') AS StreetTurnSetUser,
			OD.StreetTurnSetDate,
			CR.CsrKey,
			CM.CsrKey AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(OH.CSRManagerKey ,CM.CsrKey) as CSRManagerKey,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ISNULL(ML.MarketLocationKey,0) MarketLocationKey
			, ISNULL(ML.MarketLocation,'') MarketLocation
			, OH.Consignee, SL.LineName AS SteamShipLine, OH.SenderInfo,
			GICF.Ocean_carrier_scac AS SCAC, GICF.Discharged_dt AS Dischargedate, 
			GICF.HoldStatus,'' LiveDrop,PDC.Code AS DelayReasonCode,OD.PUDelayedCodeKey,
			GICF.Available_for_pickup AS AvailableforPickup,
			GICF.Available_dt AS AvailableforPickupDate,
			CAST(0 AS BIT) IsEditDelayReasonCode,
			OD.PrepullDelayedCodeKEy,PPDC.Code AS PrepullDelayedCode,
			CAST(0 AS BIT) IsEditPrepullReasonCode,
			
			Location_at_terminal,
			CASE WHEN ISNULL(GICF.OrderDetailKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS [Tracking],
			GICF.Pod_terminal_name,
			H.CTF, H.Customs, H.Line, H.Other, H.TMF,
			HoldType= (case when isnull(H.CTF,'') = 'true' then 'CTF;' else '' END )+
					(case when isnull(H.TMF,'') = 'true' then 'TMF;' else '' END )+
					(case when isnull(H.Customs,'') = 'true' then 'Customs;' else '' END )+
					(case when isnull(H.Line,'') = 'true' then 'Line;' else '' END )+
					(case when isnull(H.Other,'') = 'true' then 'Other;' else '' END )
					,
			CU.CustName as Customer,
			CR.CsrName as OrderCSR,
			OH.SalesPersonKey,
			Isnull(GICF.Pickup_appointment_dt,RT.ScheduledDeparture) as Pickup_appointment_dt,
			ISNULL(ISNULL(CR.LinkedUserKey, CM.LinkedUserKey),   SP.LinkedUserKey) as LinkedUserKey,
			ISNULL(CDT.AddrKey,DT.AddrKey) as DeliveryLocationKey
		into #TempAll
		FROM  dbo.OrderDetail OD					WITH (NOLOCK)		
			INNER JOIN dbo.OrderHeader OH			WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
			INNER JOIN dbo.OrderStatus OS			WITH (NOLOCK)	ON OS.[Status]=OH.[Status]
			LEFT JOIN dbo.[Broker]  BR				WITH (NOLOCK)	ON BR.BrokerKey=OH.BrokerKey
			INNER JOIN  dbo.OrderDetailStatus OSD	WITH (NOLOCK)	ON OSD.[Status] = OD.[Status]
			INNER JOIN dbo.ContainerSize CS			WITH (NOLOCK)	ON CS.ContainerSizeKey = OD.ContainerSizeKey
			LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
			LEFT JOIN dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey= ISNULL(OH.CsrKey, CU.CSRKey)
			LEFT JOIN  dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
			LEft join Routes RT WITH (NOLOCK) on OD.CurrentRouteKey = Rt.RouteKey
			LEFT JOIN [Address] SR					WITH (NOLOCK)	ON	SR.AddrKey=isnull(OD.SourceAddrKey, OH.SourceAddrKey)
			LEFT JOIN [Address] DT					WITH (NOLOCK)	ON	DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
			LEFT JOIN [Address] BT					WITH (NOLOCK)	ON	BT.AddrKey=OH.BillToAddrKey
			LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey=OH.ReturnAddrKey
			LEFT JOIN ADDRESS CSR					WITH (NOLOCK)	ON  RT.SourceAddrKey = CSR.AddrKey
			LEFT JOIN ADDRESS CDT					WITH (NOLOCK)	ON  RT.DestinationAddrKey = CDT.AddrKey
			LEFT JOIN  dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
			LEFT Join DBO.[User] UU					WITH (NOLOCK)	ON OD.CreateUserKey = uu.UserKey
			LEft join vContainerType CT WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and Ct.TypeID = 'Transload'
			LEft join Address RA with (nolock) on RT.DestinationAddrKey = RA.AddrKey
			LEFT join Leg L WITH (NOLOCK) ON RT.LegKey = l.LegKey
			LEFT JOIN ADDRESS RP WITH (NOLOCK) ON RT.SourceAddrKey = RP.AddrKey
			LEFT JOIN vContainerType HZ WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey AND CT.TypeID = 'Hazard'
			LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEft join Int_ContainerAvailability B with (NOLOCK) on OD.OrderDetailkey  = B.OrderDetailKey
			lEFT jOIN [USER] u2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
			LEft Join CSR CM WITH (NOLOCK) ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
			LEFT JOIN SalesPerson SP WITH (NOLOCK) ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
			LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
			LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
			LEFT JOIN PUScheduleDelayCode PDC WITH (NOLOCK) ON PDC.CodeKey=PUDelayedCodeKEy
			LEFT JOIN PrePullReasonCodes PPDC WITH (NOLOCK) ON PPDC.CodeKey=PrepullDelayedCodeKEy
			LEFT JOIN		#CustData C on C.UUID = GICF.UUID
			LEFT JOIN		Gnosis_Integration_Holds_Final H  WITH (NOLOCK) ON C.UUID = H.UUID
			LEFT JOIN		#MktLocation MLT On GICF.Final_dest_city = MLT.Final_dest_city
		WHERE  1=1  and  OSD.status in (1,2,3,6,7,9, 12, 14)
			
			SELECT * INTO #Temp
			FROM #TempAll
			
			WHERE (Isnull(@ContainerNo,'') = '' OR ContainerNo = @ContainerNo) AND
		
		(ISNULL(@PickupAvailable,0 ) = 0 or @PickupAvailable = AvailableforPickup) AND
		(Isnull(@TerminalNames,'') = '' OR Pod_terminal_name in (select TerminalName from #TerminalNames)) AND
		(ISNULL(@SearchText,'') = '' OR (ContainerNo like '%'+ @SearchText + '%' OR OrderNo like '%'+ @SearchText + '%' OR
				 BrokerRefNo like '%'+ @SearchText + '%' )) and
		(isnull(@IsCTF,0) = 0 OR CTF = 'true') AND
		(isnull(@IsTMF,0) = 0 OR TMF = 'true') AND
		(isnull(@IsLine,0) = 0 OR Line = 'true') AND
		(isnull(@IsOther,0) = 0 OR Other = 'true') AND
		(isnull(@IsCustoms,0) = 0 OR Customs = 'true') AND
		
		(Isnull(@CustKeys,'') = '' OR Customer in (SElect CustName from #CustKeys) ) AND
		(Isnull(@CSRkeys,'') = '' OR OrderCSR in (SElect CSRName from #CSRKeys) ) AND
		(Isnull(@CSMkeys,'') = '' OR CSRManagerKey in (Select CSMKey from #CSMKeys) ) AND
		(Isnull(@MarketKeys,'') = '' OR MarketLocationKey in (select MarketKey from #MarketKeys )) AND 
		
		(Isnull(@SalesPersonKeys,'') = '' OR SalesPersonKey in (Select SalesPersonKey from #SalesPersonKeys ) ) AND
		
		(ISNULL(@PickUpFrom,'') ='' OR Pickup_appointment_dt >= @PickUpFrom) AND
		(ISNULL(@PickUpTo,'') ='' OR Pickup_appointment_dt  <= @PickUpTo) AND
		(isnull(@isShowAll,0) = 1 OR @UserKey =LinkedUserKey)
		AND (ISNULL(@Tracking,'')='' OR @Tracking= case when [Tracking] = 1 then 'Yes' else 'No' end )
		AND (ISNULL(@Deliverylocationkeys,'')='' OR ltrim(rtrim(D_AddrName)) in (Select DeliverocationKey from #DelieverLocationKeys ))
		AND	(ISNULL(@OrderType ,'') =''  OR OrderTypeKey in (SElect OrderTypeKey from #OrderTypeKeys) )
		
		Select @RecCount = COUNT(1) from #Temp A
		--LEft join CSR M with (nolock) on A.CSManagerKey = M.CsrKey 
		--where isnull(@isShowAll,0) = 1 
		if(@OutputType is not null)
			BEGIN
				SET @PageSize = @RecCount
				SEt @PageNo = 1
			END

		select *
		into #TempPrev
		from #Temp
		where StatusKey in (1,2,3,6,7,9, 12, 14) and 
			(isnull(@statusKey,0) = 0 OR  StatusKey =  @statusKey )

		Declare @STRSQL nvarchar(max) = ''
		SET @STRSQL = 'SELECT *,  ROW_NUMBER() over (Order by ' + @SortField + ' ' + 
		CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' ) as RowNum FROM  #TempPrev'

		select *, convert(int, 0) as RowNum into  #FinalData_Temp from #TempPrev WHERE 1 <> 1 
		insert into #FinalData_Temp
		EXEC (@STRSQL)

		select *, @RecCount as RecCount 
		INTO #FinalData_Output
		from #FinalData_Temp

		--select 
		--	OrderKey,
		--	OrderDate,
		--	OrderDetailkey,
		--	OrderTypeKey,
		--	OrderNo,
		--	ContainerNo,
		--	ContainerID,
		--	ContainerSizeKey,
		--	LastFreeDay,
		--	PickupDate ,
		--	PickupTime,		
		--	DropOffDate,
		--	DropOffTime,	
		--	[Status],
		--	OrderType,
		--	BillOfLading,
		--	BookingNo,
		--	BrokerRefNo,
		--	ContainerSize,
		--	[Priority],
		--	S_AddrName,
		--	S_Address1,
		--	S_City,
		--	S_State,
		--	S_ZipCode,
		--	S_Country,
		--	D_AddrName,
		--	D_Address1,
		--	D_City,
		--	D_State,
		--	D_ZipCode,
		--	D_Country,
		--	B_AddrName,
		--	B_Address1,
		--	B_City,
		--	B_State,
		--	B_ZipCode,
		--	B_Country,
		--	R_AddrName,
		--	R_Address1,
		--	R_City,
		--	R_State,
		--	R_ZipCode,
		--	R_Country,	
		--	VesselETA,	
		--	custKey,
		--	BrokerName,
		--	[Weight],
		--	VesselName,
		--	SealNo,
		--	CutOffDate ,
		--	IsEmpty,
		--	DriverNotes , 
		--	SchedulerNotes,
		--	IsTMF,
		--	isTransLoad,
		--	CustName,
		--	CustID,
		--	CreatedUser,
		--	A.StatusKey,
		--	LocationType ,
		--	CurLocation, 
		--	RouteKey, 
		--	AddrName, 
		--	IsHazardous,
		--	DocumentCount,
		--	Int_LFD,
		--	IntDataExists ,
		--	TerminationDate,
		--	isStreetTurn,
		--	StreetTurnSetUser,
		--	StreetTurnSetDate,
		--	A.CsrKey,
		--	CSManagerKey,
		--	SalePersonKey,
		--	A.CsrName,
		--	CSManagerName,
		--	SalesPersonName,
		--	CSRUser,
		--	CMUser,
		--	SPUser,
		--	ROW_NUMBER() over (Order by OrderNo) as RowNum,
		--	@RecCount as RecCount, ISNULL(MarketLocationKey,0)MarketLocationKey , ISNULL(MarketLocation,'')MarketLocation,
		--	SteamShipLine,
		--	Consignee
		--into #Temp2
		--from #Temp A
		--LEft join CSR M with (nolock) on A.CSManagerKey = M.CsrKey 
		--where isnull(@isShowAll,0) = 1
		SET @Status=1
		SET @Reason='SUCCESSS'
		select *
		from #FinalData_Output
		FOR JSON PATH

		drop table #Temp
		drop table #TempPrev
		drop table #FinalData_Temp
		drop table #FinalData_Output
END
