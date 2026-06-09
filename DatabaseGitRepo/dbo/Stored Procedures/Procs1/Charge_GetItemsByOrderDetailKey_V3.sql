/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"OrderDetailKey":216653,"ItemType":"Service"}'
exec Charge_GetItemsByOrderDetailKey_V3 @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE proc [dbo].[Charge_GetItemsByOrderDetailKey_V3]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Declare @OrderDetailKey	int = 0,
			@ItemType		varchar(50) = 'Service'

	select  @OrderDetailKey = OrderDetailKey,
			@ItemType = ItemType
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey	int				'$.OrderDetailKey',
		ItemType		varchar(50)		'$.ItemType'
	)

	SEt @ItemType = isnull(@ItemType, 'Service')
	--SElect @OrderDetailKey as  OrderDetailKey

	if(isnull(@OrderDetailKey ,0) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'OrderDetailKey not found'
		return
	End

	print 'CTF/TMF'
	-- CHECK CTF/TMF ITEMS AND CREATE, IF NOT CREATED
	EXEC Auto_ChargeTMFCTF @OrderDetailkey

	print 'Yard Storage'
	-- CHECK YARD STORAGE LOADED / EMPTY
	EXEC Auto_ChargeYardStorage @OrderDetailkey

	print 'chassis'
	-- CHECK THE TRI-AXLE / JCT/PORT Chassis ITem, if not CREATED
	Exec AUTO_ChargeChassisDays @OrderDetailkey, 0

	print 'Contianer Props'
	-- CHECK THE CONTAINER PROPS ITem, if not CREATED
	Exec Auto_ChargeContainerProps @OrderDetailkey, 0

	Print 'Drayage'
	-- CHECK THE Drayage, FSF, Prepull, Shuttle, Yard Stopoff  ITem, if not CREATED
	Exec AUTO_ChargeDrayageFSFPrepullShuttleYardStopoff @OrderDetailkey, 0

	print 'Delete Drabase'
	-- Deleting DrayBase For TL
	Exec DeleteDrayBaseForTL @OrderDetailKey, 0

	print 'DryRunBobtail'
	-- CHECK THE DRY RUN / BOBTAIL ITem, if not CREATED
	Exec AUTO_ChargeDryRunBobtail @OrderDetailkey, 0

	SELECT * INTO #Items FROM (Select OrderExpenseKey,OE.Itemkey as ItemKey,IM.Description AS LineItem,
		OE.RouteKey,OE.UnitCost,OE.Qty,NewUnitCost,DateFrom,DateTo,ExtAmt = 0, --isnull(OE.UnitCost,0) * isnull(OE.Qty,0),
		OE.CreateDate,OE.CreateUserKey, L.LegKey, L.LegID, RT.OrderDetailKey,
		OE.LastUpdateDate,OE.UpdateUserKey,ExpenseItemKey,OE.TimeDuration,
		InternalNotes,PvsNP,IsCSRApproved,IsCustomerApproved,OE.IsChargeSharedWithCustomer as IsSharedWithCustomer,
		OE.FreeTime,OE.BvsNB,OE.MinCnt,OE.MaxCnt,CustomerRate,ChargeSource,isCSApproved as IsCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,
		OE.WarehouseItemKey,  od.ContainerNo, IT.PriceBasisKey,
		convert(decimal(18,4),0 )as BillableQty,
		WaitFromString = convert(varchar,DateFrom, 101) + ' ' + convert(varchar,DateFrom,108),
		WaitToString = convert(varchar,DateTo, 101) + ' ' + convert(varchar,DateTo,108),
		UC.UserName AS UserName,
		RT.ActualDeparture AS PickupDate,
		RT.ActualArrival as DeliveryDate
	
	from OrderExpense OE WITH (NOLOCK)
	LEFT JOIN ITEM IT WITH (NOLOCK) ON OE.Itemkey = IT.ItemKey
	LEFT JOIN ITEM IM WITH (NOLOCK) ON IT.MasterItemKey = IM.ItemKey
	LEFT JOIN ITEMTYPE TT WITH (NOLOCK) ON IM.ItemTypeKey = TT.ItemTypeKey
	LEFT JOIN Warehouse_Charges WC WITH (NOLOCK) ON OE.WarehouseItemKey = WC.WarehouseItemKey
	LEFT JOIN ROUTES RT WITH (NOLOCK) ON OE.RouteKey = RT.RouteKey
	LEFT JOIN LEG L WITH (NOLOCK) ON RT.LegKey = L.LegKey
	LEFT JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
	LEFT JOIN [USER] UC WITH (NOLOCK) ON ISNULL(oe.UpdateUserKey, OE.CreateUserKey) = UC.UserKey
	WHERE RT.OrderDetailKey = @OrderDetailKey AND TT.ItemType LIKE '%' + @ItemType + '%'
	UNION ALL
	Select OrderExpenseKey,OE.Itemkey as ItemKey,IM.Description AS LineItem,
		OE.RouteKey,OE.UnitCost,OE.Qty,NewUnitCost,DateFrom,DateTo,ExtAmt = 0, --isnull(OE.UnitCost,0) * isnull(OE.Qty,0),
		OE.CreateDate,OE.CreateUserKey, L.LegKey, L.LegID, RT.OrderDetailKey,
		OE.LastUpdateDate,OE.UpdateUserKey,ExpenseItemKey,OE.TimeDuration,
		InternalNotes,PvsNP,IsCSRApproved,IsCustomerApproved,OE.IsChargeSharedWithCustomer as IsSharedWithCustomer,
		OE.FreeTime,OE.BvsNB,OE.MinCnt,OE.MaxCnt,CustomerRate,ChargeSource,isCSApproved as IsCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,
		OE.WarehouseItemKey,  od.ContainerNo, IT.PriceBasisKey,
		convert(decimal(18,4),0 )as BillableQty,
		WaitFromString = convert(varchar,DateFrom, 101) + ' ' + convert(varchar,DateFrom,108),
		WaitToString = convert(varchar,DateTo, 101) + ' ' + convert(varchar,DateTo,108),
		UC.UserName AS UserName,
		RT.ActualDeparture AS PickupDate,
		RT.ActualArrival as DeliveryDate
	
	from OrderExpense_NoRoutes OE WITH (NOLOCK)
	LEFT JOIN ITEM IT WITH (NOLOCK) ON OE.Itemkey = IT.ItemKey
	LEFT JOIN ITEM IM WITH (NOLOCK) ON IT.MasterItemKey = IM.ItemKey
	LEFT JOIN ITEMTYPE TT WITH (NOLOCK) ON IM.ItemTypeKey = TT.ItemTypeKey
	LEFT JOIN Warehouse_Charges WC WITH (NOLOCK) ON OE.WarehouseItemKey = WC.WarehouseItemKey
	LEFT JOIN ROUTES RT WITH (NOLOCK) ON OE.RouteKey = RT.RouteKey
	LEFT JOIN LEG L WITH (NOLOCK) ON RT.LegKey = L.LegKey
	LEFT JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
	LEFT JOIN [USER] UC WITH (NOLOCK) ON ISNULL(oe.UpdateUserKey, OE.CreateUserKey) = UC.UserKey
	WHERE OE.OrderDetailKey = @OrderDetailKey AND TT.ItemType LIKE '%' + @ItemType + '%') A

	Update #Items set BillableQty = Qty - isnull(FreeTime,0) where BvsNB = 1

	Update #Items set BillableQty = MinCnt 
	where ISNULL(MinCnt,0) > BillableQty and isnull(MinCnt,0)<> 0 and BvsNB = 1

	Update #Items set BillableQty = MaxCnt 
	where ISNULL(MaxCnt,0) < BillableQty and isnull(MaxCnt,0) <> 0 and BvsNB = 1

	Update #Items set ExtAmt = ISNULL(BillableQty * UnitCost ,0)
	where ISNULL(BillableQty,0) > 0

	Select *
	from #Items
	FOR JSON PATH, INCLUDE_NULL_VALUES
	SEt @Status = 1
	Set @Reason = 'SUCCESS'
End