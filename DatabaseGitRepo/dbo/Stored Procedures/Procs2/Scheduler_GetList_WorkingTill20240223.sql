
Create PROCEDURE [dbo].[Scheduler_GetList_WorkingTill20240223]   
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
	@SorField			varchar(50) = 'OrderNo',
	@IsAscending		bit = 1,
	@CreatedUSer		varchar(50) = '',
	@SearchText			varchar(200) = '',
	@IsExport			bit = 0,
	@CSRManagerKey		int = 0,
	@SalesPersonKey		int = 0,
	@LoggedUserKey		int = 0,
	@isShowAll			bit = 0,
	@marketLocationKey		INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--set @isShowAll = 1
	declare @OpenStatusKey smallint =0;

	select @OpenStatusKey = Status from OrderDetailStatus WITH (NOLOCK)	where Description  = 'Open'



	declare  @UserCount int = 0 

	select @UserCount = count(1)
	from (
	select LinkedUserKey from CSR where LinkedUserKey is not null
	union all
	select LinkedUserKey from SalesPerson where LinkedUserKey is not null
	) A where LinkedUserKey = @LoggedUserKey 

	if (@isShowAll =0)	select @isShowAll = case when isnull(@UserCount ,0) = 0 then 1 else 0 end
	--select @isShowAll
	
	DECLARE @STRSQL VARCHAR(MAX)
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
			isnull(OD.LastFreeDay,'') as LastFreeDay,
			RT.PickupDateFrom AS PickupDate ,
			CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			RT.DeliveryDateFrom AS DropOffDate,
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
			isnull(CDT.AddrName,DT.AddrName)  AS D_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS D_Address1,
			isnull(CDT.City,DT.City)  AS D_City,
			isnull(CDT.[State],DT.[State])  AS D_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS D_ZipCode,
			isnull(CDT.Country,DT.Country)  AS D_Country,
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
			CR.CsrKey,
			CM.CsrKey AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ML.MarketLocationKey,ML.MarketLocation, OH.Consignee, SL.LineName AS SteamShipLine
		into #Temp
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
		WHERE  1=1 AND 
			--( @PickupDateFrom is null OR @PickupDateTo is null  
			--  OR (RT.PickupDateFrom  >=  convert(varchar, @PickupDateFrom, 101)  
			--   and RT.PickupDateTo  <= convert(varchar, @PickupDateTo,101) ) OR 
			-- ( RT.PickupDateTo >= convert(varchar, @PickupDateFrom, 101)  and 
			--  RT.PickupDateTo <= convert(varchar, @PickupDateTo,101) ) ) 
		
			--AND ( @DeleveryDateFrom	IS NULL OR
			--	RT.DeliveryDateFrom IS NULL  OR 
			--	 RT.DeliveryDateFrom >=  convert(varchar, @DeleveryDateFrom, 101) ) 
			( @PickupDateFrom	IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickupDateFrom)
				AND ( @PickupDateTo		IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickupDateTo)
				AND ( @DeleveryDateFrom	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom>=@DeleveryDateFrom)
				AND ( @DeleveryDateTo	IS NULL OR RT.DeliveryDateFrom IS NULL OR RT.DeliveryDateFrom<=@DeleveryDateTo)		

			AND ( @DeleveryDateTo	IS NULL OR RT.DeliveryDateTo IS NULL OR 
				RT.DeliveryDateTo <= convert(varchar, @DeleveryDateTo, 101)  )
			AND (  Isnull(@CSRKey, 0) = 0 OR OH.CsrKey=   @CSRKey) 
			AND (  isnull(@statusKey,0) = 0 OR  OD.[Status] =  @statusKey ) 
			AND (  isnull(@IsTransLoad,0) = 0 OR OD.Status <> @OpenStatusKey   ) 
			AND (  isnull(@CustomerKey,0) = 0 OR CU.CustKey = @CustomerKey   ) 
			AND (  isnull(@CreatedUSer,'') = '' OR  UU.UserName like '' + @CreatedUSer + '%' ) 
			AND (  isnull(@SearchText ,'') = '' OR
				OH.OrderNo like '%' +  @SearchText + '%'  OR
				RA.AddrName like '%' +  @SearchText + '%'  OR
				isnull(BT.AddrName,'') like '%' +  @SearchText + '%'  OR
				DT.AddrName like '%' +  @SearchText + '%'  OR
				CR.CsrName like '%' +  @SearchText + '%'  OR
				OD.ContainerNo like '%' +  @SearchText + '%'  OR
				OH.BookingNo like '%' +  @SearchText + '%'  OR
				OH.BillOfLading like '%' +  @SearchText + '%'  OR
				OT.OrderType like '%' +  @SearchText + '%'  OR
				OH.BrokerRefNo like '%' +  @SearchText + '%'  OR
				CU.CustName like '%' +  @SearchText + '%' 
			)    
			 AND (  ISNULL(@CSRKey,0) = 0 OR ISNULL(ISNULL(OH.CsrKey, CU.CSRKey), CR.CsrKey) =  @CSRKey )	
			 AND (  ISNULL(@CSRManagerKey,0) = 0 OR isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey) =@CSRManagerKey ) 
			 AND (  ISNULL(@SalesPersonKey,0) = 0 OR ISNULL( OH.SalesPersonKey, CU.SalesPersonKey) = @SalesPersonKey ) 
			 AND (  ISNULL(@marketLocationKey,0) = 0 OR  CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(OH.MarketLocationKey,0) END = @marketLocationKey ) 
		
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
			ROW_NUMBER() over (Order by OrderNo) as RowNum,
			@RecCount as RecCount, ISNULL(MarketLocationKey,0)MarketLocationKey , ISNULL(MarketLocation,'')MarketLocation, SteamShipLine,
			Consignee
		into #Temp2
		from #Temp A
		LEft join CSR M with (nolock) on A.CSManagerKey = M.CsrKey 
		where isnull(@isShowAll,0) = 1 OR (
			@LoggedUserKey = A.CSRUser OR @LoggedUserKey = M.LinkedUserKey OR @LoggedUserKey = A.SPUser
		)

		select *
		from #Temp2
		where RowNum between @RecFrom and @RecTo

		drop table #Temp
		drop table #Temp2
END
