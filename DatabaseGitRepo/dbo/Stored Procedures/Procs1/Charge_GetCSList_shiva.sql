
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
--set @JsonString = '{"ContainerNo":"","AgingDaysFrom":0,"AgingDaysTo":0,"CustKey":0,"BookingNo":"","CSRKey":0,"BrokerRef":"","StatusKey":1,"PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}'
set @JsonString = '{"ContainerNo":"","PageNo":1,"PageSize":10,"SortField":"ContainerNo","IsAscending":true}}'
exec Charge_GetCSList_shiva @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Charge_GetCSList_shiva]   
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)	
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	DECLARE
		@PickupDateFrom		DATE='01/01/2020',
		@PickupDateTo		DATE='01/12/2050',
		@DeleveryDateFrom	DATE='01/01/2020',
		@DeleveryDateTo		DATE='01/12/2050',
		@CSRKey				INT=0,
		@statusKey			INT=0,
		@IsTransLoad		BIT = 0,
		@CustomerKey		INT = 0,
		@PageNo				INT = 1,
		@PageSize			INT	= 10,
		@SortField			varchar(50) = 'OrderNo',
		@IsAscending		bit = 1,
		@CreatedUSer		varchar(50) = '',
		@SearchText			varchar(200) = '',
		@IsExport			bit = 0,
		@CSRManagerKey		int = 0,
		@SalesPersonKey		int = 0,
		@LoggedUserKey		int = 0,
		@isShowAll			bit = 0,
		@marketLocationKey		INT = 0,
		@Pickuplocationkey   int = 0,
		@Deliverylocationkey int = 0

	Select @PickupDateFrom = PickupDateFrom, @PickupDateTo = PickupDateTo, @DeleveryDateFrom = DeleveryDateFrom, 
		@DeleveryDateTo = DeleveryDateTo, @CSRKey = CSRKey, @statusKey = statusKey, @IsTransLoad = IsTransLoad, 
		@CustomerKey = CustomerKey, @PageNo = PageNo,@PageSize = PageSize, @SortField = SortField, 
		@IsAscending=IsAscending, @CreatedUSer=CreatedUSer, @SearchText=SearchText, @IsExport=IsExport, 
		@CSRManagerKey=CSRManagerKey, @SalesPersonKey=SalesPersonKey, @LoggedUserKey=LoggedUserKey, 
		@isShowAll=isShowAll, @marketLocationKey=marketLocationKey, @Pickuplocationkey=Pickuplocationkey, 
		@Deliverylocationkey=Deliverylocationkey
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo				varchar(20)		'$.ContainerNo',
		PickupDateFrom			DATE			'$.PickupDateFrom',
		PickupDateTo			DATE			'$.PickupDateTo',
		DeleveryDateFrom		DATE			'$.DeleveryDateFrom',
		DeleveryDateTo			DATE			'$.DeleveryDateTo',
		CSRKey					INT				'$.CSRKey',
		statusKey				INT				'$.statusKey',
		IsTransLoad				BIT				'$.IsTransLoad',
		CustomerKey				INT				'$.CustomerKey',
		PageNo					INT				'$.PageNo',
		PageSize				INT				'$.PageSize',
		SortField				varchar(50) 	'$.SortField',
		IsAscending				bit				'$.IsAscending',
		CreatedUSer				varchar(50) 	'$.CreatedUSer',
		SearchText				varchar(200)	'$.SearchText',
		IsExport				bit				'$.IsExport',
		CSRManagerKey			int				'$.CSRManagerKey',
		SalesPersonKey			int				'$.SalesPersonKey',
		LoggedUserKey			int				'$.LoggedUserKey',
		isShowAll				bit				'$.isShowAll',
		marketLocationKey		INT				'$.marketLocationKey',
		Pickuplocationkey		int				'$.Pickuplocationkey',
		Deliverylocationkey		int				'$.Deliverylocationkey'
	)
	if(@PickupDateFrom is null)
	begin
		SEt @PickupDateFrom = '2020/01/01'
	End
	if(@PickupDateTo is null)
	Begin
		set @PickupDateTo = Getdate() + 30
	End
	set @SearchText = Isnull(@SearchText,'')

	set @isShowAll = 1
	--Select @PickupDateFrom  as  PickupDateFrom, @PickupDateTo  as  PickupDateTo, @DeleveryDateFrom  as  DeleveryDateFrom, 
	--	@DeleveryDateTo  as  DeleveryDateTo, @CSRKey  as  CSRKey, @statusKey  as  statusKey, @IsTransLoad  as  IsTransLoad, 
	--	@CustomerKey  as  CustomerKey, @PageNo  as  PageNo,@PageSize  as  PageSize, @SortField  as  SorField, 
	--	@IsAscending as IsAscending, @CreatedUSer as CreatedUSer, @SearchText as SearchText, @IsExport as IsExport, 
	--	@CSRManagerKey as CSRManagerKey, @SalesPersonKey as SalesPersonKey, @LoggedUserKey as LoggedUserKey, 
	--	@isShowAll as isShowAll, @marketLocationKey as marketLocationKey, @Pickuplocationkey as Pickuplocationkey, 
	--	@Deliverylocationkey as Deliverylocationkey

	DECLARE @STRSQL VARCHAR(MAX)
	Declare @RecCount	int, @RowNum int

		SELECT
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			isnull(OT.OrderTypeKey,0) as OrderTypeKey,
			OD.CompleteDate as DispatchCompleteDate,
			DateDIFF(d, OD.CompleteDate,GetDate()) as AgingDays,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.ContainerID, '') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			isnull(OD.LastFreeDay,'') as LastFreeDay,
			RT.PickupDateFrom AS PickupDate ,
			RT.PickupDateTo,
			CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			RT.DeliveryDateFrom AS DropOffDate,
			RT.DeliveryDateTo,
			CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,	
			isnull(OSD.[Description],'') AS [Status],
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
			ISNULL(CSR.AddrKey,SR.AddrKey)  AS S_AddrKey,
			isnull(CDT.AddrName,DT.AddrName)  AS D_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS D_Address1,
			isnull(CDT.City,DT.City)  AS D_City,
			isnull(CDT.[State],DT.[State])  AS D_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS D_ZipCode,
			isnull(CDT.Country,DT.Country)  AS D_Country,
			ISNULL(CDT.AddrKey,DT.AddrKey)  AS D_ADDRKEY,
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
			isnull(OD.VesselETA,'') AS VesselETA,
			isnull(OD.IsLinked,0) AS IsLinked,
			isnull(OD.LinkedContainerNo,'') AS LinkedContainerNo,
			CASE 
				WHEN OD.status = 1 THEN 'Proceed to Schedule' 
				WHEN OD.status = 3 THEN 'Complete Schedule'          
				WHEN OD.status = 4 THEN 'Confirm/Complete Schedule' 
				WHEN OD.status = 5 THEN 'Process Dispatch' 
				WHEN OD.status = 7 THEN 'Complete Dispatch'   
				WHEN OD.status = 8 THEN 'Confirm/Complete Dispatch'  
				WHEN OD.status = 9 THEN 'Approve Invoice/Driver Pay'  
				WHEN OD.status = 10 THEN 'Closed' 
				WHEN OD.status = 6 THEN 'Approve for Invoice/Driver Pay' 
				WHEN OD.status = 2 THEN 'Proceed to Dispatch'
				END AS NextAction,
			OH.custKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
			, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as isTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			ISNULL(UU.UserName,'''') AS CreatedUser,
			OD.[Status] as StatusKey,
			CAST(ISNULL(od.CurrentLegNo,0) AS VARCHAR(10))+' [ ' + ISNULL(CAST(od.CurrentLegNo AS VARCHAR(10)),0)+ ' of '+ CAST(od.TotalLegs AS VARCHAR(10))+' ]' AS CurLeg,
			l.FromLocation  AS LocationType ,
			RA.AddrName AS CurLocation, RT.RouteKey, RP.AddrName, 
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			B.LastFreeDay as  Int_LFD, convert(bit, case when isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end) as IntDataExists ,
			od.CompleteDate as TerminationDate,
			od.isStreetTurn,
			ISNULL(u2.UserName,'') AS StreetTurnSetUser,
			OD.StreetTurnSetDate,
			ISNULL(ISNULL(OH.CsrKey, CU.CSRKey), CR.CsrKey) CsrKey,
			isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CM.CsrKey) AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			ISNULL( OH.SalesPersonKey, CU.SalesPersonKey) SalesPersonKey,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ML.MarketLocationKey,ML.MarketLocation, OH.Consignee, SL.LineName AS SteamShipLine, OH.SenderInfo
		into #BaseData
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
			left  join [RouteInvoice]  RI  (nolock) on (RT.OrderDetailKey = RI.OrderDetailKey)
		WHERE  1=1 AND RT.[Status] =5 and OD.status in (6,10,12,13,14) and RI.InvoiceKey is null  -- AND OH.OrderNo = 'C&B20242164'
		
		Declare @TotCnt int = 0
		select @TotCnt = count(1) from #BaseData

		update AppConfig set  ConfigValue1 = @TotCnt
		where ConfigID = 72

		select *
		into #Temp
		from #BaseData
			Where 1=1
			--( @PickupDateFrom is null OR @PickupDateTo is null  
			--  OR (RT.PickupDateFrom  >=  convert(varchar, @PickupDateFrom, 101)  
			--   and RT.PickupDateTo  <= convert(varchar, @PickupDateTo,101) ) OR 
			-- ( RT.PickupDateTo >= convert(varchar, @PickupDateFrom, 101)  and 
			--  RT.PickupDateTo <= convert(varchar, @PickupDateTo,101) ) ) 
		
			--AND ( @DeleveryDateFrom	IS NULL OR
			--	RT.DeliveryDateFrom IS NULL  OR 
			--	 RT.DeliveryDateFrom >=  convert(varchar, @DeleveryDateFrom, 101) ) 
			AND ( @PickupDateFrom	IS NULL OR PickupDate IS NULL OR PickupDate>=@PickupDateFrom)
				AND ( @PickupDateTo		IS NULL OR PickupDate IS NULL OR PickupDate<=@PickupDateTo)
				AND ( @DeleveryDateFrom	IS NULL OR DropOffDate IS NULL OR DropOffDate>=@DeleveryDateFrom)
				AND ( @DeleveryDateTo	IS NULL OR DropOffDate IS NULL OR DropOffDate<=@DeleveryDateTo)		

			AND ( @DeleveryDateTo	IS NULL OR DeliveryDateTo IS NULL OR 
				DeliveryDateTo <= convert(varchar, @DeleveryDateTo, 101)  )
			AND (  Isnull(@CSRKey, 0) = 0 OR CsrKey=   @CSRKey) 
			AND (  isnull(@statusKey,0) = 0 OR  [Status] =  @statusKey ) 
			AND (  isnull(@CustomerKey,0) = 0 OR CustKey = @CustomerKey   ) 
			AND (  isnull(@CreatedUSer,'') = '' OR  CreatedUser like '' + @CreatedUSer + '%' ) 
			AND (  isnull(@SearchText ,'') = '' OR
				OrderNo like '%' +  @SearchText + '%'  OR
				CurLocation like '%' +  @SearchText + '%'  OR
				isnull(B_addrName,'') like '%' +  @SearchText + '%'  OR
				D_AddrName like '%' +  @SearchText + '%'  OR
				CsrName like '%' +  @SearchText + '%'  OR
				ContainerNo like '%' +  @SearchText + '%'  OR
				BookingNo like '%' +  @SearchText + '%'  OR
				BillOfLading like '%' +  @SearchText + '%'  OR
				OrderType like '%' +  @SearchText + '%'  OR
				BrokerRefNo like '%' +  @SearchText + '%'  OR
				CustName like '%' +  @SearchText + '%' 
			)    
			 AND (  ISNULL(@CSRKey,0) = 0 OR CsrKey =  @CSRKey )	
			 AND (  ISNULL(@CSRManagerKey,0) = 0 OR CSManagerKey =@CSRManagerKey ) 
			 AND (  ISNULL(@SalesPersonKey,0) = 0 OR SalesPersonKey = @SalesPersonKey ) 
			 AND (  ISNULL(@marketLocationKey,0) = 0 OR  
				CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(MarketLocationKey,0) END = @marketLocationKey ) 
			 AND (ISNULL(@Pickuplocationkey,0)=0 OR S_AddrKey=@Pickuplocationkey)
			 AND (ISNULL(@Deliverylocationkey,0)=0 OR D_ADDRKEY=@Deliverylocationkey)
		
		Select @RecCount = COUNT(1) from #Temp A
		LEft join CSR M with (nolock) on A.CSManagerKey = M.CsrKey 
		where isnull(@isShowAll,0) = 1 OR (
			@LoggedUserKey = A.CSRUser OR @LoggedUserKey = M.LinkedUserKey OR @LoggedUserKey = A.SPUser
		)

		IF(@IsExport = 1)
		BEGIN
			SET @PageSize = @RecCount
		END


		declare @RecFrom int, @RecTo  int
		select @RecFrom = (@PageNo - 1) * @PageSize
		select @RecTo = @RecFrom +  @PageSize

		select 
			OrderKey,
			OrderDate,
			OrderDetailkey,
			OrderTypeKey,
			isnull(DispatchCompleteDate,'01/01/2000') as DispatchCompleteDate,
			isnull(AgingDays,0) as AgingDays,
			OrderNo,
			ContainerNo,
			ContainerID,
			ContainerSizeKey,
			LastFreeDay,
			PickupDate ,
			PickupTime,		
			DropOffDate,
			DropOffTime,	
			[Status],
			OrderType,
			BillOfLading,
			BookingNo,
			BrokerRefNo,
			ContainerSize,
			[Priority],
			S_AddrName,
			S_Address1,
			S_City,
			S_State,
			S_ZipCode,
			S_Country,
			D_AddrName,
			D_Address1,
			D_City,
			D_State,
			D_ZipCode,
			D_Country,
			B_AddrName,
			B_Address1,
			B_City,
			B_State,
			B_ZipCode,
			B_Country,
			R_AddrName,
			R_Address1,
			R_City,
			R_State,
			R_ZipCode,
			R_Country,	
			VesselETA,	
			NextAction,
			custKey,
			BrokerName,
			[Weight],
			VesselName,
			SealNo,
			CutOffDate ,
			IsEmpty,
			DriverNotes , 
			SchedulerNotes,
			IsTMF,
			isTransLoad,
			CustName,
			CustID,
			CreatedUser,
			A.StatusKey,
			CurLeg,
			LocationType ,
			CurLocation, 
			RouteKey, 
			AddrName, 
			IsHazardous,
			DocumentCount,
			Int_LFD,
			IntDataExists ,
			TerminationDate,
			isStreetTurn,
			StreetTurnSetUser,
			StreetTurnSetDate,
			A.CsrKey,
			CSManagerKey,
			SalePersonKey,
			A.CsrName,
			CSManagerName,
			SalesPersonName,
			CSRUser,
			CMUser,
			SPUser,
			--ROW_NUMBER() over (Order by OrderNo) as RowNum,
			--@RecCount as RecCount, 
			ISNULL(MarketLocationKey,0)MarketLocationKey , ISNULL(MarketLocation,'')MarketLocation, SteamShipLine,SenderInfo,
			Consignee,
			LinkedContainerNo,
			IsLinked
		into #Temp2
		from #Temp A
		LEft join CSR M with (nolock) on A.CSManagerKey = M.CsrKey 
		where isnull(@isShowAll,0) = 1 OR (
			@LoggedUserKey = A.CSRUser OR @LoggedUserKey = M.LinkedUserKey OR @LoggedUserKey = A.SPUser
		)


		declare @cnt int
		select @cnt = count(1) from #Temp2 

		select *, 0 as RowNum, 0 as RecCount  into  #FinalData from #Temp2 WHERE 1 <> 1 

		SET @STRSQL = '
		SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
			select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SortField + ' ' + 
			CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ') RowNum
			from #Temp2
			where (' + convert(varchar, isnull(@StatusKey,0)) + ' = 0 OR StatusKey = ' +  
			convert(varchar, isnull(@StatusKey,0)) + ')'+
		+') a
		where RowNum  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + 
		CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
		+' Order BY ROWNUM'

		PRINT (@STRSQL)
		insert into #FinalData
		EXEC (@STRSQL)

		SET @Status=1
		SET @Reason='Success'
		select 
		ContainerList = (
			select * from 		#FinalData A 
			FOR JSON PATH
		)  FOR JSON PATH

		drop table #Temp
		drop table #Temp2
END
