

/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"Container":"JFTL3749373","OrderDetailKey":267221,"InvoiceKey":234569}',
	@Status BIT=0, @Debug bit = 1,
	@Reason VARCHAR(100)=''
EXec Get_InvoiceDetailByContainer_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_InvoiceDetailByContainer_V2]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@Debug			bit = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	SEt Concat_Null_Yields_null On;
	set Transaction isolation level Read committed;
	set Lock_timeout -1;

	DECLARE @ExpenseAmt DECIMAL(18,2),
			@InvoiceKey  INT=28,
			@ContainerNo VARCHAR(50)='BBBB7777777',
			@OrderDetailKey		int = 0,
			@LinkedContainerNo NVARCHAR(20)=''


	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	select @InvoiceKey = InvoiceKey, @ContainerNo = ContainerNo, @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		InvoiceKey				INT				'$.InvoiceKey',
		ContainerNo				varchar(20)		'$.Container',
		OrderDetailKey			INT				'$.OrderDetailKey'
	)
	if(@Debug = 1)
	Begin
		select @InvoiceKey as InvoiceKey, @ContainerNo as ContainerNo, @OrderDetailKey as OrderDetailKey
	End
	DECLARE @ContServiceAmt DECIMAL(18,2)
	declare @DriverNotes	nvarchar(max), @SchedulerNotes  nvarchar(max)

	SET @ContainerNo= LTRIM(RTRIM(@ContainerNo))
	PRINT '@OrderdetailKey before'
	Print @OrderdetailKey
	--added to fetch correct orderdetail key using invoicekey
	--SET @OrderDetailKey=(SELECT TOP 1 OrderDetailKey FROM InvoiceDetail WHERE InvoiceKey=@InvoiceKey)

	PRINT '@OrderdetailKey after'
	PRINT @OrderdetailKey 
	PRINT @ContainerNo
	Print 1
	SELECT @LinkedContainerNo=ISNULL(LinkedContainerNo,'N/A') FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey
	PRINT @LinkedContainerNo

	Select  @DriverNotes = DriverNotes, 
			@SchedulerNotes = SchedulerNotes 
	From dbo.OrderDetail WITH (NOLOCK) where OrderDetailKey = @OrderdetailKey
				
	update invoiceDetail Set Container = LTRIM(RTRIM(Container))	where InvoiceKey = @InvoiceKey

	update ID set OrderDetailKey = IC.OrderDetailsKey
	--select *
	from InvoiceDetail ID
	inner join InvoiceContainers IC WITH (NOLOCK) on ID.InvoiceKey = IC.InvoiceKey and ID.OrderDetailKey = IC.OrderDetailsKey
	where Id.Invoicekey = @InvoiceKey

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

	SELECT  
		I.ItemKey, I.ItemID, ID.[Description],ID.Qty,ID.UnitPrice,ID.ExtAmt,ID.InvoicelineKey,ID.InvoiceKey,ID.OrderDetailKey	,
		ID.Container,ISNULL(@ExpenseAmt,0) AS DriverPay , I.InvoiceItemDesc, LEft(IT.ItemType,1) as ItemType, ID.Charges,
		M.Description as MDescription, ID.SellPrice, ID.BvsNB, ID.FreeTime, ID.Minval, ID.MaxVal, TimeDuration, I.PriceBasisKey,
		Isnull(ID.ItemNotes,'') as ItemNotes, isnull(Id.ReportedCost,0) as ReportedCost,@LinkedContainerNo AS LinkedContainerNo
		INTO #InvContData
	FROM 
		dbo.Invoicedetail ID WITH (NOLOCK)
		JOIN dbo.InvoiceHeader IH WITH (NOLOCK)	ON IH.InvoiceKey = ID.InvoiceKey
		JOIN  dbo.RouteInvoice RI WITH (NOLOCK)	ON RI.InvoiceKey = IH.InvoiceKey AND ID.OrderDetailKey=RI.OrderDetailKey
		JOIN dbo.Item I	WITH (NOLOCK)			ON I.ItemKey=ID.ItemKey
		Join dbo.ItemType IT WITH (NOLOCK)		on I.ItemTypeKey = IT.ItemTypeKey
		LEft join dbo.item M WITH (NOLOCK)		On I.MasterItemKey = M.ItemKey
	WHERE ID.InvoiceKey = @InvoiceKey AND ID.OrderDetailKey=@OrderdetailKey-- AND ltrim(rtrim(ID.Container)) = @ContainerNo

	if(@Debug = 1)
	Begin
		select 'Items', * from #InvContData
	End

	SET @ContServiceAmt= ( SELECT SUM(ISNULL(ExtAmt,0)) FROM #InvContData)

	SELECT	ItemKey,ItemID,[Description],Qty,UnitPrice,ExtAmt,
			Invoicelinekey ,InvoiceKey,OrderDetailKey,Container,DriverPay, 
			(@ContServiceAmt-	DriverPay) AS EstimatedProfit,
			InvoiceItemDesc as InvoiceDescription, ItemType ItemTypeStr,
			@DriverNotes as DriverNotes, convert(bit, 0) as IsNewInvoiceline,
			@SchedulerNotes as SchedulerNotes,Charges as Internalcost, 
			MDescription, SellPrice, BvsNB, FreeTime, Minval, MaxVal, TimeDuration, PriceBasisKey,
			IsCostItem = convert(bit, case when isnull(BvsNB,0) = 0 then 1 else 0 end),
			ItemNotes, ReportedCost,LinkedContainerNo
	FROM #InvContData
	FOR JSON PATH
	SET @Status = 1
	SEt @Reason = 'SUCCESS'
END
