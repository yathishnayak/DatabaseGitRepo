/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '[{"OrderDetailKey":116222,"WarehouseItemKey":27,"ItemKey":286,"Qty":1,"Rate":100,"TimeDuration":"00:00","ExtAmt":100,"CreateUserKey":731,"CreateDate":"2024-08-26T12:24:09.520","UpdateUserKey":29,"UpdateDate":"2024-08-27T10:19:22.470","MDescription":"Devanning Fee- 20 ft Palletized","PriceBasisKey":1,"PriceBasisID":"Fixed","PriceBasis":"Fixed Charge","CreateUserName":"Kathryn Halvorsen","UpdateUserName":"Kathryn Halvorsen","Invoiced":0},{"OrderDetailKey":116222,"WarehouseItemKey":20,"ItemKey":118,"Qty":4,"Rate":10,"TimeDuration":"00:00","ExtAmt":40,"CreateUserKey":886,"CreateDate":"2024-08-22T05:08:52.353","UpdateUserKey":29,"UpdateDate":"2024-08-27T10:19:22.470","MDescription":"Chassis Split","PriceBasisKey":1,"PriceBasisID":"Fixed","PriceBasis":"Fixed Charge","CreateUserName":"Ramya G","UpdateUserName":"Ramya G","Invoiced":0}]'
	exec Charge_UpdateWarehouseItemDetails @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE  PROCEDURE [dbo].[Charge_UpdateWarehouseItemDetails] -- Charge_UpdateWarehouseItemDetails 0, 544
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

	Declare 
		@OrderDetailKey				INT=0,
		@Count						int

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	create table #Temp
	(
		OrderDetailKey			int	,
		WarehouseItemKey		int	,			
		ItemKey					int	,			
		Qty						decimal(18,4),
		Rate					decimal(18,4),
		TimeDuration			varchar	(10),
		ExtAmt					decimal	(18,4),
		FreeTime				INT,
		BvsNB					BIT,
		MinCnt					INT,
		MaxCnt					INT,
		SellRate				DECIMAL(18,5),
		isUpdated				bit default 0
	)

	insert into #Temp (OrderDetailKey, WarehouseItemKey, ItemKey,Qty,
		Rate,TimeDuration,ExtAmt,FreeTime,BvsNB,MinCnt,MaxCnt,SellRate)
	Select OrderDetailKey, WarehouseItemKey, ItemKey,Qty,
		Rate,TimeDuration,ExtAmt,FreeTime,BvsNB,MinCnt,MaxCnt,SellRate
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			int				'$.OrderDetailKey',
		WarehouseItemKey		int				'$.WarehouseItemKey',
		ItemKey					int				'$.ItemKey',
		Qty						decimal(18,4)	'$.Qty',
		Rate					decimal(18,4)	'$.Rate',
		TimeDuration			varchar	(10)	'$.TimeDuration',
		ExtAmt					decimal	(18,4)	'$.ExtAmt',
		FreeTime				int				'$.FreeTime',
		BvsNB					BIT				'$.BvsNB',
		MinCnt					int				'$.MinCnt',
		MaxCnt					int				'$.MaxCnt',
		SellRate				DECIMAL(18,4)	'$.SellRate'
	)

	--select * from #Temp
	
	if((Select count(1) from #Temp) = 0)
	Begin
		set @Status = 0
		set @Reason = 'No Record to Save'
		Return
	End

	Begin Try
			SElect top 1 @OrderDetailKey = OrderDetailKey  from #temp


					Declare @Routekey int = 0

		select @Routekey = Rt.RouteKey
		from Routes RT
		Inner join Leg L on RT.legkey = L.LegKey and (L.ToLocation in ('Yard','Warehouse','Depot'))
		where OrderDetailkey = @OrderDetailKey

		if(isnull(@Routekey,0) = 0)
		Begin
			select top 1 @Routekey = Rt.RouteKey
			from Routes RT
			Inner join Leg L on RT.legkey = L.LegKey
			where OrderDetailkey = @OrderDetailKey
		End

		IF ISNULL(@Routekey, 0) = 0
		BEGIN
			SET @Status = 0
			SET @Reason = 'No route exists. Please add route before saving warehouse charges.'
			RETURN
		END
			insert into Warehouse_Charges(OrderDetailKey, ItemKey,Qty,
				Rate,TimeDuration,ExtAmt, CreateUserKey, CreateDate,FreeTime,BvsNB,MinCnt,MaxCnt,SellRate )
			select OrderDetailKey,  ItemKey,Qty,
				Rate,TimeDuration,ExtAmt, @UserKey, GETDATE(),FreeTime,BvsNB,MinCnt,MaxCnt,SellRate
			from #Temp T
			where WarehouseItemKey = 0
		
			update WC SET
				OrderDetailKey	= T.OrderDetailKey,
				ItemKey			= T.ItemKey,		
				Qty				= T.Qty,		
				Rate			= T.Rate,		
				TimeDuration	= T.TimeDuration,
				ExtAmt			= T.ExtAmt	,
				FreeTime		=T.FreeTime,
				BvsNB			=T.BvsNB,
				MinCnt			=T.MinCnt,
				MaxCnt			=T.MaxCnt,
				SellRate		=T.SellRate,
				UpdateUserKey	= @UserKey,
				UpdateDate		= GETDATE()
			from Warehouse_Charges WC
			inner join #Temp T on WC.WarehouseItemKey = T.WarehouseItemKey

			--Declare @Routekey int = 0
			
			--select @Routekey = Rt.RouteKey
			--from Routes RT
			--Inner join Leg L on RT.legkey = L.LegKey and ( L.ToLocation in ('Yard','Warehouse','Depot') )
			--where OrderDetailkey = @OrderDetailKey

			--if(isnull(@Routekey,0) = 0)
			--Begin
			--	select top 1 @Routekey = Rt.RouteKey
			--	from Routes RT
			--	Inner join Leg L on RT.legkey = L.LegKey 
			--	where OrderDetailkey = @OrderDetailKey
			--End

			--IF ISNULL(@Routekey, 0) = 0
			--BEGIN
			--	SET @Status = 0
			--	SET @Reason = 'No route exists. Please add route before saving warehouse charges.'
			--	RETURN
			--END
			
			insert into OrderExpense (Itemkey, RouteKey,UnitCost, Qty, NewUnitCost, DateFrom, DateTo, 
			CreateDate, CreateUserKey, LastUpdateDate, UpdateUserKey, ExpenseItemKey, TimeDuration, 
			InternalNotes, PvsNP, IsCSRApproved, IsCustomerApproved, FreeTime, BvsNB, MinCnt, MaxCnt, 
			CustomerRate, ChargeSource, isCSApproved, CSApprovedDate, CSUserKey, IsInvoiced, WarehouseItemKey, 
			OrderDetailKey, IsChargeSharedWithCustomer, ChargeSharedWithCustBy, ChargeSharedWithCustDate, 
			IsCustomerApprovedCharge, CustomerApprovedChargeBy, CustomerApprovedChargeDate)
			SELECT  wc.ItemKey, NULLIF(@Routekey, 0), --  @Routekey
			wc.Rate, WC.Qty, WC.Rate, NULL, NULL,
			WC.CreateDate, WC.CreateUserKey, WC.UpdateDate, WC.UpdateUserKey, WC.ItemKey, WC.TimeDuration,
			NULL, 'NP', NULL, NULL, NULL, NULL, NULL, NULL,
			NULL, 'WH', NULL, NULL, NULL, 0, WC.WarehouseItemKey,
			WC.OrderDetailKey, NULL, NULL, NULL,NULL, NULL, NULL
			FROM Warehouse_Charges WC WITH (NOLOCK)
			leFT JOIN OrderExpense OE WITH (NOLOCK) ON WC.WarehouseItemKey = OE.WarehouseItemKey
			WHERE OE.WarehouseItemKey IS NULL and WC.OrderDetailKey = @OrderDetailKey

			update OE set ItemKey = WC.ItemKey,
				QTy = WC.QTY,
				UnitCost = WC.rate,
				TimeDuration = WC.TimeDuration
			from OrderExpense OE 
			inner join Warehouse_Charges WC  WITH (NOLOCK) on OE.WarehouseItemKey = WC.WarehouseItemKey 
				and OE.OrderDetailKey = Wc.OrderDetailKey
			where OE.Qty <> WC.Qty OR OE.UnitCost <> WC.Rate OR OE.TimeDuration <> WC.TimeDuration OR OE.Itemkey <> WC.ItemKey

			update Warehouse_ContainerDetails set 
			StatusKey = 2, UpdateUserKey = @UserKey,
			UpdateDate = GetDate()
			where OrderDetailKey = @OrderDetailKey and IsStoring = 1 and StatusKey <> 3

		set @Status = 1
		set @Reason = 'SUCCESS'
	end try
	begin catch
		set @Status = 0
		set @Reason = 'ERROR IN PROC: ' + convert(varchar, ERROR_LINE()) + ' : ' + ERROR_MESSAGE()
	end catch
END
