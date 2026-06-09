/*
DECLARE 
	@UserKey INT=29,
	@JSONString NVARCHAR(MAX)='[{"ItemKey":18,"ItemID":"DRAY","Description":"Drayage Base","Qty":"2","UnitPrice":240,"ExtAmt":480,"Invoicelinekey":631936,"InvoiceKey":183776,"OrderDetailKey":205910,"Container":"HAMU1237347","DriverPay":0,"EstimatedProfit":319.2,"InvoiceDescription":"DRAYAGE BASE","ItemTypeStr":"S","DriverNotes":"","IsNewInvoiceline":true,"SchedulerNotes":"","Internalcost":160,"MDescription":"Drayage Base","BvsNB":true,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"N/A","SellPrice":240,"SPType":"DRAY","isEditable":false,"IsOldInvoivelineUpdated":true,"InvoiceCompanyKey":1},{"ItemKey":76,"ItemID":"FSF","Description":"FUEL SURCHARGE (FSC)","Qty":1,"UnitPrice":79.2,"ExtAmt":79.2,"Invoicelinekey":631937,"InvoiceKey":183776,"OrderDetailKey":205910,"Container":"HAMU1237347","DriverPay":0,"EstimatedProfit":319.2,"InvoiceDescription":"FUEL SURCHARGE","ItemTypeStr":"S","DriverNotes":"","IsNewInvoiceline":false,"SchedulerNotes":"","Internalcost":0,"MDescription":"FUEL SURCHARGE (FSC)","BvsNB":true,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"N/A","SellPrice":79.2,"SPType":"FSF","InvoiceCompanyKey":1}]',
	@Status BIT=0, @Debug bit = 0,
	@Reason VARCHAR(100)=''
EXec Update_InvoiceDetail_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
*/

/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)='[{"ItemKey":18,"ItemID":"DRAY","Description":"Drayage Base","Qty":1,"UnitPrice":1,"ExtAmt":1,"Invoicelinekey":1043810,"InvoiceKey":270920,"OrderDetailKey":309938,"Container":"ECMU5431970","DriverPay":0,"EstimatedProfit":185,"InvoiceDescription":"DRAYAGE BASE","ItemTypeStr":"S","IsNewInvoiceline":true,"Internalcost":240,"MDescription":"Drayage Base","BvsNB":true,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"ecmu5028590","isEditable":false,"IsOldInvoivelineUpdated":true,"InvoiceCompanyKey":1},{"ItemKey":76,"ItemID":"FSF","Description":"FUEL SURCHARGE (FSC)","Qty":1,"UnitPrice":1,"ExtAmt":1,"Invoicelinekey":1043811,"InvoiceKey":270920,"OrderDetailKey":309938,"Container":"ECMU5431970","DriverPay":0,"EstimatedProfit":185,"InvoiceDescription":"FUEL SURCHARGE","ItemTypeStr":"S","IsNewInvoiceline":true,"Internalcost":0,"MDescription":"FUEL SURCHARGE (FSC)","BvsNB":true,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"ecmu5028590","isEditable":false,"IsOldInvoivelineUpdated":true,"InvoiceCompanyKey":1},{"ItemKey":116,"ItemID":"SHUTTLE","Description":"Yard Shuttle","Qty":1,"UnitPrice":0,"ExtAmt":0,"Invoicelinekey":1043812,"InvoiceKey":270920,"OrderDetailKey":309938,"Container":"ECMU5431970","DriverPay":0,"EstimatedProfit":185,"InvoiceDescription":"SHUTTLE","ItemTypeStr":"S","IsNewInvoiceline":false,"Internalcost":160,"MDescription":"Yard Shuttle","BvsNB":false,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":true,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"ecmu5028590","InvoiceCompanyKey":1},{"ItemKey":84,"ItemID":"JCT OWN CHASSIS","Description":"Chassis- JCT","Qty":3,"UnitPrice":20,"ExtAmt":60,"Invoicelinekey":1043813,"InvoiceKey":270920,"OrderDetailKey":309938,"Container":"ECMU5431970","DriverPay":0,"EstimatedProfit":185,"InvoiceDescription":"JCT OWN CHASSIS","ItemTypeStr":"S","IsNewInvoiceline":false,"Internalcost":30,"MDescription":"Chassis- JCT","BvsNB":true,"FreeTime":0,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"ecmu5028590","InvoiceCompanyKey":1},{"ItemKey":103,"ItemID":"PRE PULL","Description":"PREPULL","Qty":1,"UnitPrice":125,"ExtAmt":125,"Invoicelinekey":1043814,"InvoiceKey":270920,"OrderDetailKey":309938,"Container":"ECMU5431970","DriverPay":0,"EstimatedProfit":185,"InvoiceDescription":"PRE PULL","ItemTypeStr":"S","IsNewInvoiceline":false,"Internalcost":100,"MDescription":"PREPULL","BvsNB":true,"Minval":0,"MaxVal":0,"PriceBasisKey":1,"IsCostItem":false,"ItemNotes":"","ReportedCost":0,"LinkedContainerNo":"ecmu5028590","InvoiceCompanyKey":1}]',
	@Status BIT=0, @Debug bit = 0,
	@Reason VARCHAR(100)=''
EXEC Update_InvoiceDetail_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
SELECT @Status, @Reason
*/
CREATE PRocedure [dbo].[Update_InvoiceDetail_V2]
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
	DECLARE	@Invoicekey			INT,
			@InvoiceCompanyKey	INT

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	create table #ITems
	(
		ItemKey				int	,			
		ItemID				varchar(100),	
		Description			varchar(200),	
		Qty					decimal(18,4)	,			
		UnitPrice			decimal(18,4),	
		ExtAmt				decimal(18,4),	
		Invoicelinekey		int,				
		InvoiceKey			int	,			
		OrderDetailKey		int	,			
		Container			varchar(20),		
		DriverPay			decimal(18,4),	
		EstimatedProfit		decimal(18,4),	
		InvoiceDescription	varchar(200),	
		ItemTypeStr			varchar(2),		
		DriverNotes			varchar(2000),	
		IsNewInvoiceline	bit	,			
		SchedulerNotes		varchar(2000),	
		Internalcost		decimal(18,4),	
		BvsNB				bit,				
		PriceBasisKey		int	,			
		IsCostItem			bit	,
		SellPrice			decimal(18,4),	
		FreeTime			int,				
		MinCnt				int,			
		MaxCnt				int	,
		TimeDuration		varchar(5),
		InvoiceCompanyKey	int
	)

	insert into #ITems (ItemKey, ItemID, Description, Qty, UnitPrice,ExtAmt,Invoicelinekey,InvoiceKey,OrderDetailKey,
	Container,DriverPay,EstimatedProfit,InvoiceDescription,ItemTypeStr,DriverNotes,IsNewInvoiceline, InvoiceCompanyKey,
	SchedulerNotes,Internalcost,BvsNB,PriceBasisKey,IsCostItem, SellPrice, FreeTime,MinCnt, MaxCnt,TimeDuration	)
	select ItemKey, ItemID,
	--Description,
	CASE WHEN ItemKey=24 THEN 'Empty Stop Off' Else Description END,
	Qty, UnitPrice,ExtAmt,Invoicelinekey,InvoiceKey,OrderDetailKey,
	Container,DriverPay,EstimatedProfit,InvoiceDescription,ItemTypeStr,DriverNotes,IsNewInvoiceline, InvoiceCompanyKey,
	SchedulerNotes,Internalcost,BvsNB,PriceBasisKey,IsCostItem,  SellPrice, FreeTime,MinCnt, MaxCnt	, TimeDuration	
	from OpenJSON(@JsonString, '$')
	WITH (
		ItemKey				int				'$.ItemKey',
		ItemID				varchar(100)	'$.ItemID',
		Description			varchar(200)	'$.Description',
		Qty					decimal(18,4)	'$.Qty',
		UnitPrice			decimal(18,4)	'$.UnitPrice',
		ExtAmt				decimal(18,4)	'$.ExtAmt',
		Invoicelinekey		int				'$.Invoicelinekey',
		InvoiceKey			int				'$.InvoiceKey',
		OrderDetailKey		int				'$.OrderDetailKey',
		Container			varchar(20)		'$.Container',
		DriverPay			decimal(18,4)	'$.DriverPay',
		EstimatedProfit		decimal(18,4)	'$.EstimatedProfit',
		InvoiceDescription	varchar(200)	'$.InvoiceDescription',
		ItemTypeStr			varchar(2)		'$.ItemTypeStr',
		DriverNotes			varchar(2000)	'$.DriverNotes',
		IsNewInvoiceline	bit				'$.IsNewInvoiceline',
		SchedulerNotes		varchar(2000)	'$.SchedulerNotes',
		Internalcost		decimal(18,4)	'$.Internalcost',
		BvsNB				bit				'$.BvsNB',
		SellPrice			decimal(18,4)	'$.SellPrice',
		FreeTime			int				'$.FreeTime',
		MinCnt				int				'$.MinCnt',
		MaxCnt				int				'$.MaxCnt',
		PriceBasisKey		int				'$.PriceBasisKey',
		IsCostItem			bit				'$.IsCostItem',
		TimeDuration		varchar(5)		'$.TimeDuration',
		InvoiceCompanyKey	int				'$.InvoiceCompanyKey'
	)
	if((Select count(1) from #ITems)=0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Item Details not found'
		return
	End

	--SELECT InvoiceKey, COUNT(*) 
	--FROM #Items
	--GROUP BY InvoiceKey

	-- select distinct @Invoicekey = Invoicekey, @InvoiceCompanyKey = InvoiceCompanyKey from #ITems
	SELECT 
    @Invoicekey = MAX(InvoiceKey),
    @InvoiceCompanyKey = MAX(InvoiceCompanyKey)
	FROM #ITems

	PRINT 'InvoiceKey: ' + CAST(@Invoicekey AS VARCHAR)

	IF ( @Invoicekey IS NULL OR @Invoicekey =0)
	BEGIN
		SEt @Status = 0
		Set @Reason = 'Invoice Details not found'
		return
	END	

	declare @InvoiceTotal decimal(18,5) = 0, @NewInvoiceAmount decimal(18,5) = 0, @IsPayReceived bit = 0, @OrderKey int
	select @InvoiceTotal = InvoiceAmount, @IsPayReceived = IsPaymentReceived from InvoiceHeader where InvoiceKey = @Invoicekey

	Select @OrderKey = OrderKey from InvoiceHeader WITH(NOLOCK) where InvoiceKey = @Invoicekey

	Update IT set OrderDetailKey = OD.OrderDetailKey
	from #Items IT
	inner join OrderDetail OD WITH(NOLOCK) on IT.Container = OD.ContainerNo and OD.OrderKey = @OrderKey
	Where isnull(IT.OrderDetailKey,0) = 0

	if (@Debug = 1)
	Begin
		select '#ITems',* from #ITems
	end

	Begin Try
		Begin Transaction
		/*INSERT NEW ITEMS */
		INSERT INTO INVOICEDETAIL (InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, OrderDetailKey, 
			CreateUserKey, CreateDate, Charges, SellPrice, BvsNB, FreeTime, Minval, MaxVal, TimeDuration)
		SELECT InvoiceKey, ItemKey, 
		--Description,
		CASE WHEN ItemKey=24 THEN 'Empty Stop Off' ELSE Description END,
		UnitPrice, Qty, ExtAmt, Container, OrderDetailKey,
			@UserKey, GETDATE(), UnitPrice, SellPrice, BvsNB, FreeTime, MinCnt, MaxCnt, TimeDuration
		FROM #ITems 
		WHERE ISNULL(Invoicelinekey,0) = 0

		insert into InvoiceDetail_SellPriceLog (InvoiceLineKey, LogDate, ItemKey, UnitPrice, Qty, ExtAmt, Container, Charges, 
			SellPrice, BvsNB, FreeTime,	Minval, MaxVal, UserKey)
		select IT.InvoiceLineKey, GetDate(), IT.ItemKey, IT.UnitPrice,IT.Qty, (IT.Qty*IT.UnitPrice), IT.Container, IT.UnitPrice, 
			IT.SellPrice, IT.BvsNB, IT.FreeTime,	IT.Mincnt, IT.Maxcnt, @UserKey 
		from Invoicedetail ID
		inner join #ITems IT on ID.InvoicelineKey = IT.Invoicelinekey
	

		/*UPDATE  EXISTING ITEMS */
		UPDATE ID
		SET UnitPrice= IT.UnitPrice, 
			Qty= IT.Qty, 
			Extamt= (IT.Qty*IT.UnitPrice),
			UpdateUserKey=@UserKey,
			UpdateDate=GETDATE(), 
			Charges=IT.UnitPrice, 
			SellPrice = IT.SellPrice, 
			FreeTime = IT.freeTime, 
			Minval = IT.Mincnt, 
			MaxVal = IT.Maxcnt, 
			BvsNB = IT.BvsNB, 
			TimeDuration=IT.TimeDuration
		From dbo.Invoicedetail ID 
		inner join #ITems IT WITH(NOLOCK) on ID.InvoicelineKey = IT.Invoicelinekey
		WHERE ID.InvoiceKey = @Invoicekey

		SELECT @NewInvoiceAmount = SUM(ExtAmt) FROM dbo.Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@Invoicekey and BvsNB = 1

		UPDATE dbo.InvoiceHeader
		SET InvoiceAmount= @NewInvoiceAmount,InvoiceCompanyKey=@InvoiceCompanyKey,
			IsPaymentReceived = case when @InvoiceTotal = @NewInvoiceAmount then @IsPayReceived else 0 end,
			StatusKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then 2 else StatusKey end,
			PaymentRecdDate = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdDate end,
			PaymentRecdUserKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdUserKey end
		WHERE InvoiceKey=@Invoicekey;

		update invoicedetail set  timeduration = null where InvoiceKey = @Invoicekey and  TimeDuration = ''
		SET @Status = 1
		SET @Reason = 'SUCCESS'

		DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
		SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
		SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
		SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
		SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
		
		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Invoice ' + @InvoiceNo + ' updated'

		Commit Transaction
	End Try
	Begin Catch
		Rollback transaction
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
	End Catch
	drop table #ITems

END