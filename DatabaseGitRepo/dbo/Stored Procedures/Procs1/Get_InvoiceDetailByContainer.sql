
CREATE PRocedure [dbo].[Get_InvoiceDetailByContainer]  
@InvoiceKey  INT=28,
@ContainerNo VARCHAR(50)='BBBB7777777',
@OrderDetailKey		int = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--DECLARE @OrderdetailKey INT
	DECLARE @ExpenseAmt		DECIMAL(18,2)
	DECLARE @ContServiceAmt DECIMAL(18,2)
	declare @DriverNotes	nvarchar(max), @SchedulerNotes  nvarchar(max)

	SET @ContainerNo= LTRIM(RTRIM(@ContainerNo))

	--SET @OrderdetailKey= (	SELECT DISTINCT OD.OrderDetailKey 
	--						FROM dbo.Invoicedetail ID INNER JOIN OrderDetail OD ON OD.OrderDetailKey=ID.OrderDetailKey
	--						WHERE InvoiceKey=@InvoiceKey AND ltrim(rtrim(OD.ContainerNo))= @ContainerNo)
	PRINT @OrderdetailKey 

	Select  @DriverNotes = DriverNotes, @SchedulerNotes = SchedulerNotes From dbo.OrderDetail where OrderDetailKey = @OrderdetailKey
				

	CREATE TABLE #ExpenseItems
	(
		ItemKey		INT,
		ItemDesc	VARCHAR(500),
		UnitCost	DECIMAL(18,5),
		Qty			DECIMAL(18,2),
		OrderDetailKey INT,
		ContainerNo VARCHAR(20),
		InvoiceItemDesc		varchar(100),
		ItemType	varchar(50)
	);	

	SELECT @OrderdetailKey  AS  OrderDetailKey INTO #OrderDetailWrk 	

	--INSERT INTO #ExpenseItems (ItemKey,ItemDesc,UnitCost,Qty,OrderDetailKey,ContainerNo)
	--EXECUTE Get_ExpenseItem	

	SET @ExpenseAmt= 0 -- ( SELECT SUM(ISNULL(UnitCost,0)*CASE WHEN Qty=0 THEN 1 WHEN Qty IS NULL THEN 1 ELSE Qty END) FROM #ExpenseItems )

	--select * from #ExpenseItems

	SELECT  
		I.ItemKey, I.ItemID, ID.[Description],ID.Qty,ID.UnitPrice,ID.ExtAmt,ID.InvoicelineKey,ID.InvoiceKey,ID.OrderDetailKey	,
		ID.Container,ISNULL(@ExpenseAmt,0) AS DriverPay , I.InvoiceItemDesc, LEft(IT.ItemType,1) as ItemType, ID.Charges,
		M.Description as MDescription, ID.SellPrice, ID.BvsNB, ID.FreeTime, ID.Minval, ID.MaxVal, TimeDuration, I.PriceBasisKey,
		ReportedCost
		INTO #InvContData
	FROM 
		dbo.Invoicedetail ID WITH (NOLOCK)
		JOIN dbo.InvoiceHeader IH WITH (NOLOCK)	ON IH.InvoiceKey = ID.InvoiceKey
		JOIN  dbo.RouteInvoice RI WITH (NOLOCK)	ON RI.InvoiceKey = IH.InvoiceKey AND ID.OrderDetailKey=RI.OrderDetailKey
		JOIN dbo.Item I	WITH (NOLOCK)			ON I.ItemKey=ID.ItemKey
		Join dbo.ItemType IT WITH (NOLOCK)		on I.ItemTypeKey = IT.ItemTypeKey
		LEft join dbo.item M WITH (NOLOCK)		On I.MasterItemKey = M.ItemKey
	WHERE ID.InvoiceKey = @InvoiceKey AND ltrim(rtrim(ID.Container)) = @ContainerNo

	SET @ContServiceAmt= ( SELECT SUM(ISNULL(ExtAmt,0)) FROM #InvContData)

	SELECT	ItemKey,ItemID,[Description],Qty,UnitPrice,ExtAmt,
			InvoicelineKey,InvoiceKey,OrderDetailKey,Container,DriverPay, 
			(@ContServiceAmt-	DriverPay) AS EstimatedProfit,
			InvoiceItemDesc, ItemType,
			@DriverNotes as DriverNotes,
			@SchedulerNotes as SchedulerNotes,Charges,
			MDescription, SellPrice, BvsNB, FreeTime, Minval, MaxVal, TimeDuration, PriceBasisKey,
			ReportedCost
	FROM #InvContData

END
