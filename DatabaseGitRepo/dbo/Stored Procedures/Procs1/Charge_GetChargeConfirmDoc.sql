/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"OrderDetailKey":102287}'
exec Charge_GetChargeConfirmDoc @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Charge_GetChargeConfirmDoc]   
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
		@OrderDetailKey		int

	update OE SET OrderDetailKey = Rt.OrderDetailKey
	from ORderExpense OE
	inner join Routes RT WITH (NOLOCK) on OE.RouteKey = RT.RouteKey
	where OE.OrderDetailKey is null

	Select @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey		int				'$.OrderDetailKey'
	)
	print @OrderDetailKey

	DECLARE @STRSQL VARCHAR(MAX)
	Declare @RecCount	int, @RowNum int

	Declare 
			@OrderType	varchar(20),
			@S_RouteKey		int = 0,
			@D_RouteKey		int = 0,
			@R_RouteKey		int = 0

	select @OrderType = OT.OrderType
	from OrderDetail OD WITH (nolock)
	INNER JOIN OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where OrderDetailKey = @OrderDetailKey


	if(@OrderType = 'Import')
	Begin
		Select @S_RouteKey = RouteKey from Routes RT WITH (NOLOCK)  
		inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		Where OrderDetailKey = @OrderDetailKey and L.FromLocation = 'Port' and isnull(IsDryRun ,0) = 0
  
		Select @D_RouteKey = RouteKey from Routes RT WITH (NOLOCK)  
		inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		Where OrderDetailKey = @OrderDetailKey and L.ToLocation in ( 'Consignee','Shipper','Customer') and isnull(IsDryRun ,0) = 0

		Select @R_RouteKey = RouteKey from Routes RT WITH (NOLOCK)  
		inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		Where OrderDetailKey = @OrderDetailKey and L.ToLocation = 'Port' and isnull(IsDryRun ,0) = 0
	END
	ELSE
	BEGIN
		Select @S_RouteKey = RouteKey from Routes RT WITH (NOLOCK)  
		inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		Where OrderDetailKey = @OrderDetailKey and L.FromLocation  in ( 'Consignee','Shipper','Customer') and isnull(IsDryRun ,0) = 0
  
		Select @D_RouteKey = RouteKey from Routes RT WITH (NOLOCK)  
		inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		Where OrderDetailKey = @OrderDetailKey and L.ToLocation = 'Port' and isnull(IsDryRun ,0) = 0
	End
	--Select @OrderType, @S_RouteKey, @D_RouteKey, @R_RouteKey
		SELECT
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			isnull(OT.OrderTypeKey,0) as OrderTypeKey,
			OD.CompleteDate as DispatchCompleteDate,
			DateDIFF(d, OD.CompleteDate,GetDate()) as AgingDays,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.LastFreeDay,'') as LastFreeDay,
			--RT.PickupDateFrom AS PickupDate ,
			--RT.PickupDateTo,
			--CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			--RT.DeliveryDateFrom AS DropOffDate,
			--RT.DeliveryDateTo,
			--CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,	
			isnull(OSD.[Description],'') AS [Status],
			isnull(OT.OrderType,'') AS OrderType,
			isnull(OH.BillOfLading,'') AS BillOfLading,
			isnull(OH.BookingNo,'') AS BookingNo,
			isnull(OH.BrokerRefNo,'') as BrokerRefNo,
			isnull(CS.[Description],'') AS ContainerSize,
			--isnull(PT.[Description],'')  AS [Priority],
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
			OH.custKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
			--, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			--, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as isTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			l.FromLocation  AS LocationType ,
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			ISNULL(ISNULL(OH.CsrKey, CU.CSRKey), CR.CsrKey) CsrKey,
			isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CM.CsrKey) AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			ISNULL( OH.SalesPersonKey, CU.SalesPersonKey) SalesPersonKey,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ML.MarketLocationKey,ML.MarketLocation, 
			OD.isWhseChargesConfirmed, 
			OD.isCSChargeConfirmed, 
			OD.isChargesSharedWithCust, 
			OD.isCustApprovedCharges,
			RS.ActualDeparture as ActualPickup,
			RD.ActualArrival as ActualDelivery,
			RR.ActualArrival as ActualReturn
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
			LEFT JOIN dbo.Routes RS					WITH (NOLOCK)	ON OD.OrderDetailKey = RS.OrderDetailKey and RS.RouteKey = @S_RouteKey
			LEFT JOIN dbo.Routes RD					WITH (NOLOCK)	ON OD.OrderDetailKey = RD.OrderDetailKey and RD.RouteKey = @D_RouteKey
			LEFT JOIN dbo.Routes RR					WITH (NOLOCK)	ON OD.OrderDetailKey = RR.OrderDetailKey and RR.RouteKey = @R_RouteKey
			LEFT JOIN [Address] SR					WITH (NOLOCK)	ON	SR.AddrKey=isnull(OD.SourceAddrKey, OH.SourceAddrKey)
			LEFT JOIN [Address] DT					WITH (NOLOCK)	ON	DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
			LEFT JOIN [Address] BT					WITH (NOLOCK)	ON	BT.AddrKey=OH.BillToAddrKey
			LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey= isnull(RR.DestinationAddrKey, OH.ReturnAddrKey)
			LEFT JOIN ADDRESS CSR					WITH (NOLOCK)	ON  RT.SourceAddrKey = CSR.AddrKey
			LEFT JOIN ADDRESS CDT					WITH (NOLOCK)	ON  RT.DestinationAddrKey = CDT.AddrKey
			LEft join vContainerType CT WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and Ct.TypeID = 'Transload'
			LEft join Address RA with (nolock) on RT.DestinationAddrKey = RA.AddrKey
			LEFT join Leg L WITH (NOLOCK) ON RT.LegKey = l.LegKey
			LEFT JOIN ADDRESS RP WITH (NOLOCK) ON RT.SourceAddrKey = RP.AddrKey
			LEFT JOIN vContainerType HZ WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey AND CT.TypeID = 'Hazard'
			LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEft Join CSR CM WITH (NOLOCK) ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
			LEFT JOIN SalesPerson SP WITH (NOLOCK) ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
			LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
			left  join [RouteInvoice]  RI  (nolock) on (RT.OrderDetailKey = RI.OrderDetailKey)
		WHERE  OD.OrderDetailKey = @OrderDetailKey 
			
			
		select OE.OrderExpenseKey,
				OE.Itemkey,
				ISNULL(IM.Description, IT.Description) AS Description,
				OE.Qty,
				OE.UnitCost,
				(OE.Qty - isnull(OE.freetime,0)) * OE.UnitCost as ExtAmt,
				OE.DateFrom, 
				OE.DateTo,
				oe.TimeDuration,
				OE.InternalNotes,
				OE.PvsNP,
				OE.FreeTime,
				OE.Qty - isnull(OE.freetime,0) as BillableQty,
				OE.BvsNB,
				IsCSRApproved,
				IsCustomerApproved,
				MinCnt,
				MaxCnt,
				CustomerRate,
				ChargeSource,
				isCSApproved,
				CSApprovedDate,
				CSUserKey,
				IsInvoiced,
				WarehouseItemKey
		into #Items
		from OrderExpense OE WITH (NOLOCK)
		INNER JOIN ITEM IT WITH (NOLOCK) ON OE.Itemkey = IT.ItemKey
		LEFT JOIN ITEM IM WITH (NOLOCK) ON IT.MasterItemKey = IM.ItemKey
		where OE.OrderDetailKey = @OrderDetailKey and isnull(OE.BvsNB,0) = 1

		UNION 

		select OE.OrderExpenseKey,
				OE.Itemkey,
				ISNULL(IM.Description, IT.Description) AS Description,
				OE.Qty,
				OE.UnitCost,
				(OE.Qty - isnull(OE.freetime,0)) * OE.UnitCost as ExtAmt,
				OE.DateFrom, 
				OE.DateTo,
				oe.TimeDuration,
				OE.InternalNotes,
				OE.PvsNP,
				OE.FreeTime,
				OE.Qty - isnull(OE.freetime,0) as BillableQty,
				OE.BvsNB,
				IsCSRApproved,
				IsCustomerApproved,
				MinCnt,
				MaxCnt,
				CustomerRate,
				ChargeSource,
				isCSApproved,
				CSApprovedDate,
				CSUserKey,
				IsInvoiced,
				WarehouseItemKey
		from OrderExpense_NoRoutes OE WITH (NOLOCK)
		INNER JOIN ITEM IT WITH (NOLOCK) ON OE.Itemkey = IT.ItemKey
		LEFT JOIN ITEM IM WITH (NOLOCK) ON IT.MasterItemKey = IM.ItemKey
		where OE.OrderDetailKey = @OrderDetailKey and isnull(OE.BvsNB,0) = 1

		Update #Items set BillableQty = Qty - isnull(FreeTime,0)

		Update #Items set BillableQty = MinCnt 
		where ISNULL(MinCnt,0) > BillableQty

		Update #Items set BillableQty = MaxCnt 
		where ISNULL(MaxCnt,0) < BillableQty

		Update #Items set ExtAmt = BillableQty * UnitCost 
		where ISNULL(BillableQty,0) > 0

		SET @Status=1
		SET @Reason='Success'
		select 
		OrderExpense = (
			select *, ItemsData = (
				Select *
				from #Items 
				FOR JSON PATH
			)
			from #BaseData A 
			FOR JSON PATH
		)  FOR JSON PATH, without_array_wrapper

END