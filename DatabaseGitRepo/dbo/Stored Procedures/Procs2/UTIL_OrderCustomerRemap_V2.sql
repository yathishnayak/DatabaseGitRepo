
CREATE PROCEDURE [dbo].[UTIL_OrderCustomerRemap_V2]
(
	@UserKey		INT=953,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	
	DECLARE 
	@OrderNo			VARCHAR(50),
	@CustId				VARCHAR(100),
	@NewCustId			VARCHAR(100),
	@NewOrderno			VARCHAR(50)
	--@CustKey			VARCHAR(50);
	--@NewCustKey		     VARCHAR(50)

	SELECT @OrderNo = OrderNo,@CustId=CustId,@NewCustId=NewCustId
	--,@CustKey=CustKey,@NewCustKey=NewCustKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderNo			VARCHAR(50)				'$.OrderNo',
			CustId			VARCHAR(50)				'$.CustId',
			NewCustId		VARCHAR(100)			'$.NewCustId'
			--CustKey			VARCHAR(50)				'$.CustKey',
			--NewCustKey		VARCHAR(50)				'$.NewCustKey'
		)


	DECLARE @Cur AS CURSOR
	DECLARE @OldAddrKey AS INT 
	DECLARE @OldCustKey AS INT 
	DECLARE @NewCustKey AS INT 
	DECLARE @NewAddrKey AS INT 
	DECLARE @UserName	VARCHAR(50)

	SELECT @UserName = UserName FROM [User] WITH (NOLOCK) WHERE userkey = @UserKey

	DECLARE @OrderKey INT 
	DECLARE @OrderDetailKey INT
	DECLARE @RoutKey INT 
	DECLARE @InvoiceKey INT
	
	
	
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader WITH (NOLOCK) WHERE OrderNo = @OrderNo
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Order not exists'
		return
	END

	SET @CNT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader OH WITH (NOLOCK)
	INNER JOIN Customer C WITH (NOLOCK) on OH.CustKey = C.CustKey
	WHERE OrderNo = @OrderNo and C.CustKey = @CustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid From Customer'
		return
	END

	SET @CNT = 0
	SELECT @CNT = COUNT(1) FROM Customer WITH (NOLOCK)
	WHERE CustKey = @NewCustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid To Customer'
		return
	END

	SELECT A.OrderKey,  A.CustKey,  A.BillToAddrKey AS OrderBillTo, A.SourceAddrKey AS OrderSource, A.DestinationAddrKey AS OrderDest, A.ReturnAddrKey AS OrderReturn, 
	B.OrderDetailKey,  B.SourceAddrKey AS DetaiLSource, B.DestinationAddrKey AS DetailDest, 
	C.RouteKey,  
	CASE WHEN L.FromLocation in ('Customer','Consignee')  THEN C.SourceAddrKey  ELSE 0 END AS RoutSource,
	CASE WHEN L.ToLocation in ('Customer','Consignee')  THEN C.DestinationAddrKey  ELSE 0 END AS RoutDest, 
	D.InvoiceKey,  D.BillToAddrKey as InvBillTo
	INTO #tmp 
	FROM Orderheader A WITH (NOLOCK)
	INNER JOIN  OrderDetail B WITH (NOLOCK) ON (A.OrderKey = B.OrderKey)
	LEFT OUTER JOIN Routes  C WITH (NOLOCK) ON (B.OrderDetailKey = C.OrderDetailKey)
	LEFT OUTER JOIN LEG L WITH (NOLOCK) ON C.legkey = L.LegKey
	LEFT OUTER JOIN InvoiceHeader  D WITH (NOLOCK) ON (A.OrderKey = D.OrderKey)
	LEFT OUTER JOIN Customer E WITH (NOLOCK) ON (A.CustKey = E.CustKey)
	WHERE A.OrderNo = @OrderNo AND E.CustKey = @CustId

	SELECT DISTINCT  @OldCustKey = CustKey FROM #tmp
	SELECT @NewCustKey =   CustKey FROM Customer WITH (NOLOCK) WHERE CustKey =@NewCustId		
	SET @NewCustId=(SELECT CustId FROM Customer WITH (NOLOCK) WHERE CustKey=@NewCustKey)
	IF  isnull(@OldCustKey,0) = 0 or isnull(@NewCustKey,0) =0 RETURN 

	BEGIN TRY	
		BEGIN TRAN
		SET @Cur = CURSOR FOR 
			SELECT OrderKey,  OrderDetailKey, RouteKey, InvoiceKey  FROM #tmp
		OPEN @Cur
		WHILE (0=0)
		BEGIN
	  
		   FETCH NEXT FROM @Cur INTO  @OrderKey, @OrderDetailKey,@RoutKey,  @InvoiceKey
		   IF @@FETCH_STATUS <> 0 BREAK

		   --Order header updates
		   UPDATE OrderHeader SET CustKey = @NewCustKey WHERE orderKey = @OrderKey
		  
		   --select @OldAddrKey= OrderBillTo  from #tmp where orderkey = @OrderKey
		   --Exec UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   SELECT @NewAddrKey = BillToAddrKey FROM Customer WITH (NOLOCK)  WHERE CustKey=@NewCustKey
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET BillToAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

		   SELECT @OldAddrKey= OrderSource  FROM #tmp WHERE orderkey = @OrderKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey output 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET SourceAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

		   SELECT @OldAddrKey= OrderDest  FROM #tmp WHERE orderkey = @OrderKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  update OrderHeader SET DestinationAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

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
			select @NewAddrKey = BillToAddrKey from Customer WITH (NOLOCK) where CustKey=@NewCustKey
		    update InvoiceHeader set BillToAddrKey = @NewAddrKey where InvoiceKey = @InvoiceKey

			
		End
		Close @Cur
		Deallocate @cur

		declare  @OrdCount int = 0,  @OrderDate datetime
		select @OrderDate = OrderDate from OrderHeader WITH (NOLOCK) where orderkey = @OrderKey
		select @OrdCount = count(1) from orderheader WITH (NOLOCK) where orderno like @NewCustId + convert(varchar,right(year(@OrderDate),2))
			+ right(convert(varchar, 100 + month(@OrderDate)),2) + '%'
		select @OrdCount = isnull(@OrdCount,0) + 1
		select @NewOrderNo = @NewCustId+convert(varchar,right(year(@OrderDate),2)) + right(convert(varchar, 100 + month(@OrderDate)),2) 
				+ right( convert(varchar,1000 + @OrdCount),3)
		--select @OrderDate, @OrdCount, @NewOrderno
		update Orderheader SEt Orderno = @NewOrderNo where OrderKey = @OrderKey

		update IH set CustKey = OH.CustKey
		from invoiceHeader IH
		inner join Invoicedetail ID WITH (NOLOCK) on IH.InvoiceKey = ID.InvoiceKey
		inner join OrderDetail OD WITH (NOLOCK) on ID.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
		where OH.OrderKey = @OrderKey

		insert into OrderHeader_AuditLog(OrderKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
		select @OrderKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed from ' + @CustId + ' to ' + @NewCustId,
			@UserKey, 1

		insert into Invoice_Log(InvoiceKey, LogDate, LogText, ActionUserKey)
		select distinct IH.InvoiceKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed from ' + @CustId + ' to ' + @NewCustId,
			@UserKey
		from invoiceHeader IH WITH (NOLOCK)
		inner join Invoicedetail ID WITH (NOLOCK) on IH.InvoiceKey = ID.InvoiceKey
		inner join OrderDetail OD WITH (NOLOCK) on ID.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
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
