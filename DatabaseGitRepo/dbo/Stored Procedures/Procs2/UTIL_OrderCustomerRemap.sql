
CREATE Procedure [dbo].[UTIL_OrderCustomerRemap]
(
	@OrderNo	varchar(20),
	@CustId		varchar(20),
	@NewCustId	varchar(20),
	@UserKey	int,
	@Status		bit = 0 OUTPUT,
	@Reason		varchar(100) = '' OUTPUT,
	@NewOrderno	varchar(20) = '' OUTPUT
)
as
Begin
	Declare @Cur as Cursor
	Declare @OldAddrKey as int 
	Declare @OldCustKey as int 
	Declare @NewCustKey as int 
	Declare @NewAddrKey as int 
	Declare @UserName	varchar(50)

	select @UserName = UserName from [User] where userkey = @UserKey

	Declare @OrderKey int 
	Declare @OrderDetailKey int
	Declare @RoutKey int 
	Declare @InvoiceKey int
	
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader WHERE OrderNo = @OrderNo
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Order not exists'
		return
	END

	set @CNT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader OH
	inner join Customer C on OH.CustKey = C.CustKey
	WHERE OrderNo = @OrderNo and C.CustKey = @CustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid From Customer'
		return
	END

	set @CNT = 0
	SELECT @CNT = COUNT(1) FROM Customer
	WHERE CustKey = @NewCustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid To Customer'
		return
	END

	select A.OrderKey,  A.CustKey,  A.BillToAddrKey as OrderBillTo, A.SourceAddrKey as OrderSource, A.DestinationAddrKey as OrderDest, A.ReturnAddrKey as OrderReturn, 
	B.OrderDetailKey,  B.SourceAddrKey as DetaiLSource, B.DestinationAddrKey as DetailDest, 
	C.RouteKey,  
	case when L.FromLocation in ('Customer','Consignee')  then C.SourceAddrKey  else 0 end as RoutSource,
	case when L.ToLocation in ('Customer','Consignee')  then C.DestinationAddrKey  else 0 end as RoutDest, 
	D.InvoiceKey,  D.BillToAddrKey as InvBillTo
	into #tmp 
	from Orderheader A
	inner join  OrderDetail B on (A.OrderKey = B.OrderKey)
	left outer join Routes  C on (B.OrderDetailKey = C.OrderDetailKey)
	left outer join LEG L on C.legkey = L.LegKey
	left outer join InvoiceHeader  D on (A.OrderKey = D.OrderKey)
	left outer join Customer E on (A.CustKey = E.CustKey)
	where A.OrderNo = @OrderNo and E.CustKey = @CustId

	select distinct  @OldCustKey = CustKey from #tmp
	select @NewCustKey =   CustKey from Customer where CustKey =@NewCustId		
	set @NewCustId=(SELECt CustId from Customer WHERE CustKey=@NewCustKey)
	if  isnull(@OldCustKey,0) = 0 or isnull(@NewCustKey,0) =0 return 

	Begin Try	
		begin Tran
		set @Cur = cursor for 
			select OrderKey,  OrderDetailKey, RouteKey, InvoiceKey  from #tmp
		open @Cur
		while (0=0)
		Begin
	  
		   fetch next from @Cur into  @OrderKey, @OrderDetailKey,@RoutKey,  @InvoiceKey
		   if @@FETCH_STATUS <> 0 break

		   --Order header updates
		   update OrderHeader set CustKey = @NewCustKey where orderKey = @OrderKey
		  
		   --select @OldAddrKey= OrderBillTo  from #tmp where orderkey = @OrderKey
		   --Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		    select @NewAddrKey = BillToAddrKey from Customer where CustKey=@NewCustKey
		   If isnull(@NewAddrKey,0) <>0  update OrderHeader set BillToAddrKey = @NewAddrKey where orderKey = @OrderKey

		   select @OldAddrKey= OrderSource  from #tmp where orderkey = @OrderKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update OrderHeader set SourceAddrKey = @NewAddrKey where orderKey = @OrderKey

		   select @OldAddrKey= OrderDest  from #tmp where orderkey = @OrderKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update OrderHeader set DestinationAddrKey = @NewAddrKey where orderKey = @OrderKey

			select @OldAddrKey= OrderReturn  from #tmp where orderkey = @OrderKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update OrderHeader set ReturnAddrKey = @NewAddrKey where orderKey = @OrderKey


		   --Order Deail updates
		   select @OldAddrKey= DetaiLSource  from #tmp where OrderDetailKey = @OrderDetailKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update OrderDetail set SourceAddrKey = @NewAddrKey where OrderDetailKey = @OrderDetailKey

		   select @OldAddrKey= DetailDest  from #tmp where OrderDetailKey = @OrderDetailKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update OrderDetail set DestinationAddrKey = @NewAddrKey where OrderDetailKey = @OrderDetailKey

		   --Route detail updates
		   select @OldAddrKey= RoutSource  from #tmp where RouteKey = @RoutKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update Routes set SourceAddrKey = @NewAddrKey where RouteKey = @RoutKey

		   select @OldAddrKey= RoutDest  from #tmp where RouteKey = @RoutKey
		   Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   If isnull(@NewAddrKey,0) <>0  update Routes set DestinationAddrKey = @NewAddrKey where RouteKey = @RoutKey

		   --Invoice  updates
		   --select @OldAddrKey= InvBillTo  from #tmp where InvoiceKey = @InvoiceKey
		   --Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   --If isnull(@NewAddrKey,0) <>0  
			select @NewAddrKey = BillToAddrKey from Customer where CustKey=@NewCustKey
		    update InvoiceHeader set BillToAddrKey = @NewAddrKey where InvoiceKey = @InvoiceKey

			
		End
		Close @Cur
		Deallocate @cur

		declare  @OrdCount int = 0,  @OrderDate datetime
		select @OrderDate = OrderDate from OrderHeader where orderkey = @OrderKey
		select @OrdCount = count(1) from orderheader where orderno like @NewCustId + convert(varchar,right(year(@OrderDate),2))
			+ right(convert(varchar, 100 + month(@OrderDate)),2) + '%'
		select @OrdCount = isnull(@OrdCount,0) + 1
		select @NewOrderNo = @NewCustId+convert(varchar,right(year(@OrderDate),2)) + right(convert(varchar, 100 + month(@OrderDate)),2) 
				+ right( convert(varchar,1000 + @OrdCount),3)
		--select @OrderDate, @OrdCount, @NewOrderno
		update Orderheader SEt Orderno = @NewOrderNo where OrderKey = @OrderKey

		update IH set CustKey = OH.CustKey
		from invoiceHeader IH
		inner join Invoicedetail ID on IH.InvoiceKey = ID.InvoiceKey
		inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
		where OH.OrderKey = @OrderKey

		insert into OrderHeader_AuditLog(OrderKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
		select @OrderKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed from ' + @CustId + ' to ' + @NewCustId,
			@UserKey, 1

		insert into Invoice_Log(InvoiceKey, LogDate, LogText, ActionUserKey)
		select distinct IH.InvoiceKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed from ' + @CustId + ' to ' + @NewCustId,
			@UserKey
		from invoiceHeader IH
		inner join Invoicedetail ID on IH.InvoiceKey = ID.InvoiceKey
		inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
		where OH.OrderKey = @OrderKey

		Commit  tran
		SET @Status = 1
		SET @Reason = 'Updated Successfully'
	End Try
	Begin Catch  	
		Rollback tran
		print ERROR_MESSAGE()
		SET @Status = 0
		SET @Reason = 'Technical Error'
	End Catch
End

