/*
declare @UserKey		int=512,
	@JSONString		nvarchar(max)='[{"OrderExpenseKey":772582,"Itemkey":132,"LineItem":"Weekend Surcharge","RouteKey":729441,"UnitCost":0,"Qty":1,"NewUnitCost":0,"DateFrom":null,"DateTo":null,"ExtAmt":0,"CreateDate":"2025-12-11T04:15:52.747","CreateUserKey":1,"LegKey":34,"LegID":"Port To Consignee ","OrderDetailKey":226933,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":null,"InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"Auto","isCSApproved":false,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":false,"WarehouseItemKey":null,"ContainerNo":"IMPT2512080","PriceBasisKey":1,"BillableQty":1,"WaitFromString":null,"WaitToString":null,"UserName":"Arun Kumar","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":772583,"Itemkey":80,"LineItem":"Genset","RouteKey":729441,"UnitCost":150,"Qty":1,"NewUnitCost":150,"DateFrom":null,"DateTo":null,"ExtAmt":150,"CreateDate":"2025-12-11T04:15:52.757","CreateUserKey":1,"LegKey":34,"LegID":"Port To Consignee ","OrderDetailKey":226933,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":null,"InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"Auto","isCSApproved":false,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":false,"WarehouseItemKey":null,"ContainerNo":"IMPT2512080","PriceBasisKey":1,"BillableQty":1,"WaitFromString":null,"WaitToString":null,"UserName":"Arun Kumar","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":772584,"Itemkey":18,"LineItem":"Drayage Base","RouteKey":729441,"UnitCost":0,"Qty":1,"NewUnitCost":0,"DateFrom":null,"DateTo":null,"ExtAmt":0,"CreateDate":"2025-12-11T04:15:52.780","CreateUserKey":1,"LegKey":34,"LegID":"Port To Consignee ","OrderDetailKey":226933,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":null,"InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"Auto","isCSApproved":false,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":false,"WarehouseItemKey":null,"ContainerNo":"IMPT2512080","PriceBasisKey":1,"BillableQty":1,"WaitFromString":null,"WaitToString":null,"UserName":"Arun Kumar","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":772585,"Itemkey":76,"LineItem":"FUEL SURCHARGE (FSC)","RouteKey":729441,"UnitCost":0,"Qty":1,"NewUnitCost":0,"DateFrom":null,"DateTo":null,"ExtAmt":0,"CreateDate":"2025-12-11T04:15:52.783","CreateUserKey":1,"LegKey":34,"LegID":"Port To Consignee ","OrderDetailKey":226933,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":null,"InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"Auto","isCSApproved":false,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":false,"WarehouseItemKey":null,"ContainerNo":"IMPT2512080","PriceBasisKey":1,"BillableQty":1,"WaitFromString":null,"WaitToString":null,"UserName":"Arun Kumar","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":3,"Itemkey":40,"LineItem":"Administrative Fee","RouteKey":null,"UnitCost":27.5,"Qty":1,"NewUnitCost":null,"DateFrom":null,"DateTo":"2025-12-11T18:30:00","ExtAmt":27,"CreateDate":"2025-12-11T03:40:37.193","CreateUserKey":886,"LegKey":null,"LegID":null,"OrderDetailKey":null,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":"00:00","InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"CM","isCSApproved":null,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":null,"WarehouseItemKey":null,"ContainerNo":null,"PriceBasisKey":1,"BillableQty":1,"WaitFromString":null,"WaitToString":"12/11/2025 18:30:00","UserName":"Ramya G","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":4,"Itemkey":84,"LineItem":"Chassis- JCT","RouteKey":null,"UnitCost":35,"Qty":1,"NewUnitCost":null,"DateFrom":"2025-12-10T18:30:00","DateTo":"2025-12-12T18:30:00","ExtAmt":35,"CreateDate":"2025-12-11T03:42:41.170","CreateUserKey":886,"LegKey":null,"LegID":null,"OrderDetailKey":null,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":"00:00","InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":1,"BvsNB":true,"MinCnt":1,"MaxCnt":1,"CustomerRate":null,"ChargeSource":"CM","isCSApproved":null,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":null,"WarehouseItemKey":null,"ContainerNo":null,"PriceBasisKey":1,"BillableQty":1,"WaitFromString":"12/10/2025 18:30:00","WaitToString":"12/12/2025 18:30:00","UserName":"Ramya G","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":5,"Itemkey":137,"LineItem":"Permit","RouteKey":null,"UnitCost":111,"Qty":12,"NewUnitCost":null,"DateFrom":"2025-12-10T18:30:00","DateTo":"2025-12-12T18:30:00","ExtAmt":1332,"CreateDate":"2025-12-11T03:42:41.170","CreateUserKey":886,"LegKey":null,"LegID":null,"OrderDetailKey":null,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":null,"TimeDuration":"00:00","InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":true,"FreeTime":0,"BvsNB":true,"MinCnt":0,"MaxCnt":0,"CustomerRate":null,"ChargeSource":"CM","isCSApproved":null,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":null,"WarehouseItemKey":null,"ContainerNo":null,"PriceBasisKey":1,"BillableQty":12,"WaitFromString":"12/10/2025 18:30:00","WaitToString":"12/12/2025 18:30:00","UserName":"Ramya G","PickupDate":null,"DeliveryDate":null},{"Itemkey":291,"Description":"Dry Van","LineItem":"Dry Van","Rate":11,"Qty":1,"ExtAmt":11,"UnitPrice":11,"UnitCost":11,"ReportedCost":0,"OrderDetailKey":226933,"Internalcost":11,"PriceBasisKey":1,"DateFrom":"2025-12-10T18:30:00.000Z","DateTo":"2025-12-11T18:30:00.000Z","TimeDuration":"00:00","FreeTime":0,"SellPrice":11,"ChargeSource":"CM","IsCustomerApproved":false,"BvsNB":true,"MaxCnt":0,"MinCnt":0,"IsCSRApproved":true,"IsSharedWithCustomer":true}]',
	@Status			bit	= 0 ,
	@Reason			varchar(1000) = '' 
	exec Charge_InsertUpdateItems_V3 @UserKey,@JsonString,@status output, @reason output
	select @Status,@Reason
	*/

/*
declare @UserKey		int=512,
	@JSONString		nvarchar(max)='[{"OrderExpenseKey":1060,"ItemKey":40,"LineItem":"Administrative Fee","RouteKey":null,"UnitCost":130,"Qty":1,"NewUnitCost":null,"DateFrom":"2026-05-19T18:30:00","DateTo":"2026-05-20T18:30:00","ExtAmt":0,"CreateDate":"2026-05-20T10:54:49.360","CreateUserKey":951,"LegKey":null,"LegID":null,"OrderDetailKey":314016,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":0,"TimeDuration":"00:00","InternalNotes":null,"PvsNP":null,"IsCSRApproved":true,"IsCustomerApproved":false,"IsSharedWithCustomer":null,"FreeTime":3,"BvsNB":true,"MinCnt":2,"MaxCnt":20,"CustomerRate":null,"ChargeSource":"CM","IsCSApproved":null,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":null,"WarehouseItemKey":null,"ContainerNo":null,"PriceBasisKey":1,"BillableQty":0,"WaitFromString":"05/19/2026 18:30:00","WaitToString":"05/20/2026 18:30:00","UserName":"Yathish Nayak","PickupDate":null,"DeliveryDate":null},{"OrderExpenseKey":1061,"ItemKey":234,"LineItem":"Bobtail/Drop fee","RouteKey":null,"UnitCost":20,"Qty":1,"NewUnitCost":null,"DateFrom":"2026-05-20T18:30:00","DateTo":"2026-05-19T18:30:00","ExtAmt":0,"CreateDate":"2026-05-20T11:15:44.463","CreateUserKey":951,"LegKey":null,"LegID":null,"OrderDetailKey":314016,"LastUpdateDate":null,"UpdateUserKey":null,"ExpenseItemKey":0,"TimeDuration":"00:00","InternalNotes":null,"PvsNP":null,"IsCSRApproved":null,"IsCustomerApproved":false,"IsSharedWithCustomer":null,"FreeTime":20,"BvsNB":null,"MinCnt":20,"MaxCnt":30,"CustomerRate":null,"ChargeSource":"CM","IsCSApproved":null,"CSApprovedDate":null,"CSUserKey":null,"IsInvoiced":null,"WarehouseItemKey":null,"ContainerNo":null,"PriceBasisKey":1,"BillableQty":0,"WaitFromString":"05/20/2026 18:30:00","WaitToString":"05/19/2026 18:30:00","UserName":"Yathish Nayak","PickupDate":null,"DeliveryDate":null}]',
	@Status			bit	= 0 ,
	@Reason			varchar(1000) = '' 
	exec Charge_InsertUpdateItems_V3 @UserKey,@JsonString,@status output, @reason output
	select @Status,@Reason
*/

CREATE proc [dbo].[Charge_InsertUpdateItems_V3]
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

	Declare @OrderDetailKey		int,
			@RouteKey			int,
			@Comments           VARCHAR(500)='',
			@UserName			VARCHAR(100)='',
			@ContainerNo		VARCHAR(20)=''

	Create Table #Items
	(
		OrderExpenseKey		int				,
		Itemkey				int				,
		RouteKey			int				,
		UnitCost			decimal(18,5)	,
		Qty					decimal(18,5)	,
		NewUnitCost			decimal(18,5)	,
		DateFrom			varchar(50)		,
		DateTo				varchar(50)		,
		ExpenseItemKey		int				,
		TimeDuration		varchar(10)		,
		InternalNotes		nvarchar(MAX)	,
		PvsNP				varchar(5)		,
		IsCSRApproved		bit				,
		IsCustomerApproved	bit			,
		FreeTime			int				,
		BvsNB				varchar(5)		,
		MinCnt				int				,
		MaxCnt				int				,
		CustomerRate		decimal(18,4)	,
		ChargeSource		varchar(5)		,
		isCSApproved		bit				,
		CSApprovedDate		datetime		,
		CSUserKey			int				,
		IsInvoiced			bit				,
		WarehouseItemKey	int				,
		OrderDetailKey		int				,
		IsSharedWithCustomer	bit		    ,
		ContainerNo			VARCHAR(20)		,
		ReportedCost		decimal(18,5)	
	)

	insert into #Items (OrderExpenseKey,Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,DateFrom,DateTo,
	ExpenseItemKey,TimeDuration,InternalNotes,PvsNP,IsCSRApproved,IsCustomerApproved,
		FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,
		WarehouseItemKey, OrderDetailKey, IsSharedWithCustomer,ContainerNo, ReportedCost)
	Select OrderExpenseKey,Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,DateFrom,DateTo,
		ExpenseItemKey,TimeDuration,InternalNotes,PvsNP,IsCSRApproved,IsCustomerApproved,
		FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,
		WarehouseItemKey, OrderDetailKey, IsSharedWithCustomer,ContainerNo, ReportedCost
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderExpenseKey		int				'$.OrderExpenseKey',	
		Itemkey				int				'$.ItemKey',
		RouteKey			int				'$.RouteKey',
		UnitCost			decimal(18,5)	'$.UnitCost',
		Qty					decimal(18,5)	'$.Qty',
		NewUnitCost			decimal(18,5)	'$.NewUnitCost',
		DateFrom			varchar(50)		'$.DateFrom',
		DateTo				varchar(50)		'$.DateTo',
		ExpenseItemKey		int				'$.ExpenseItemKey',
		TimeDuration		varchar(10)		'$.TimeDuration',
		InternalNotes		nvarchar(MAX)	'$.InternalNotes',
		PvsNP				varchar(5)		'$.PvsNP',
		IsCSRApproved		bit				'$.IsCSRApproved',
		IsCustomerApproved	bit				'$.IsCustomerApproved',
		FreeTime			int				'$.FreeTime',
		BvsNB				varchar(5)		'$.BvsNB',
		MinCnt				int				'$.MinCnt',
		MaxCnt				int				'$.MaxCnt',
		CustomerRate		decimal(18,4)	'$.CustomerRate',
		ChargeSource		varchar(5)		'$.ChargeSource',
		isCSApproved		bit				'$.IsCSApproved',
		CSApprovedDate		datetime		'$.CSApprovedDate',
		CSUserKey			int				'$.CSUserKey',
		IsInvoiced			bit				'$.IsInvoiced',
		WarehouseItemKey		int			'$.WarehouseItemKey',
		OrderDetailKey		int				'$.OrderDetailKey',
		IsSharedWithCustomer bit			'$.IsSharedWithCustomer',
		ContainerNo			VARCHAR(20)		'$.ContainerNo',
		ReportedCost		decimal(18,5)	'$.ReportedCost'
	)

	update #items set 
		BvsNB = case when BvsNB = 'B' then 1 when BvsNB ='NB' then 0 when BvsNB ='' then 0 when BvsNB = 'false' then 0 when BvsNB ='true' then 1 else BvsNB end

	select @OrderDetailKey = OrderDetailKey from #Items
	
	select top 1 @RouteKey = RouteKey from routes WITH (NOLOCK) where orderdetailkey = @OrderDetailKey order by  isnull(IsDryRun,0) desc

	BEGIN TRY 
		BEGIN TRANSACTION
		if((Select count(1) from #Items) > 0 AND ISNULL(@RouteKey,0)>0)
		Begin
			
			IF((SELECT COUNT(1) FROM OrderExpense_NoRoutes)>0)
			BEGIN
				update OrderExpense_NoRoutes set RouteKey=@RouteKey where OrderDetailKey=@OrderDetailKey

				INSERT INTO OrderExpense (Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,
				DateFrom,DateTo,
				CreateDate,CreateUserKey,LastUpdateDate,UpdateUserKey,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, OrderDetailKey, IsChargeSharedWithCustomer,
				ReportedCost)
				SELECT Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,
				DateFrom,DateTo,
				CreateDate,CreateUserKey,LastUpdateDate,UpdateUserKey,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, OrderDetailKey, IsChargeSharedWithCustomer,
				ReportedCost FROM OrderExpense_NoRoutes WHERE OrderDetailKey=@OrderDetailKey

				DELETE FROM  OrderExpense_NoRoutes WHERE OrderDetailKey=@OrderDetailKey
			END

			SELECT T.* INTO #ItemAdded FROM #Items T
			WHERE T.Itemkey Not IN (SELECT ItemKey FROM OrderExpense WITH (NOLOCK) WHERE OrderDetailKey= @OrderDetailKey) AND ChargeSource<>'Auto'

			INSERT INTO OrderExpense (Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,
				DateFrom,DateTo,
				CreateDate,CreateUserKey,LastUpdateDate,UpdateUserKey,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, OrderDetailKey, IsChargeSharedWithCustomer,
				ReportedCost)
			SELECT Itemkey,-- isnull(RouteKey,@RouteKey),
			ISNULL(NULLIF(RouteKey,0), @RouteKey), UnitCost,Qty,NewUnitCost, 
				convert(datetime,replace( replace(DateFrom,'T',' '),'Z','')	),	convert(datetime,replace( replace(DateTo,'T',' '),'Z','')	),
				gETDATE(),@UserKey,NULL,NULL,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,'CM',
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, @OrderDetailKey, IsSharedWithCustomer
				,ReportedCost
			FROM #ITEMS 
			WHERE ISNULL(OrderExpenseKey ,0) = 0

			

			SELECT T.*,OE.IsChargeSharedWithCustomer INTO #ItemUpdated FROM OrderExpense OE WITH (NOLOCK)
			INNER JOIN #Items T ON OE.OrderExpenseKey = T.OrderExpenseKey
			WHERE (OE.UnitCost<>T.UnitCost OR OE.Qty<>T.Qty OR OE.NewUnitCost<>T.NewUnitCost OR OE.BvsNB<>T.BvsNB) AND T.ChargeSource<>'Auto'

			SELECT T.*,OE.IsChargeSharedWithCustomer INTO #IsChargeSharedWithCustomer fROM OrderExpense OE WITH (NOLOCK)
			INNER JOIN #Items T ON OE.OrderExpenseKey = t.OrderExpenseKey
			WHERE OE.IsChargeSharedWithCustomer<>T.IsSharedWithCustomer

			SELECT T.*,OE.IsCSRApproved AS OEIsCSRApproved INTO #IsCSRApproved fROM OrderExpense OE WITH (NOLOCK)
			INNER JOIN #Items T ON OE.OrderExpenseKey = t.OrderExpenseKey
			WHERE OE.IsCSRApproved<>T.IsCSRApproved

			SELECT @UserName=UserName FROM[User] WITH (NOLOCK) WHERE UserKey=@UserKey;
			SET @Comments='by '+@UserName +' on '+ CAST(GETDATE() AS VARCHAR);
			SET @ContainerNo =(SELECT TOP 1 ContainerNo FROM #Items)
			--select * from #Items
			--print 'hi'
			UPDATE oe SET 
				Itemkey				= T.Itemkey			,
				RouteKey			= isnull(T.RouteKey,@RouteKey)			,
				UnitCost			= T.UnitCost			,
				Qty					= T.Qty				,
				NewUnitCost			= T.NewUnitCost		,
				DateFrom			= convert(datetime,replace( replace(T.DateFrom,'T',' '),'Z','')	)		,
				DateTo				= convert(datetime,replace( replace(T.DateTo,'T',' '),'Z','')	)		,
				ExpenseItemKey		= T.ExpenseItemKey	,
				TimeDuration		= T.TimeDuration		,
				InternalNotes		= T.InternalNotes		,
				PvsNP				= T.PvsNP				,
				IsCSRApproved		= T.IsCSRApproved		,
				IsCustomerApproved	= T.IsCustomerApproved,
				FreeTime			= T.FreeTime			,
				BvsNB				= T.BvsNB				,
				MinCnt				= T.MinCnt			,
				MaxCnt				= T.MaxCnt			,
				CustomerRate		= T.CustomerRate		,
				isCSApproved		= T.isCSApproved		,
				CSApprovedDate		= Case when OE.isCSApproved <> T.IsCSApproved then GETDATE() else OE.CSApprovedDate end	,
				CSUserKey			= T.CSUserKey			,
				IsInvoiced			= T.IsInvoiced		,
				WarehouseItemKey	= T.WarehouseItemKey	,
				OrderDetailKey		= T.OrderDetailKey,
				chargesource		= T.chargesource,
				LastUpdateDate		= Getdate(),
				IsChargeSharedWithCustomer = T.IsSharedWithCustomer,
				UpdateUserKey		= @UserKey,
				ReportedCost		= T.ReportedCost
			FROM OrderExpense OE
			INNER JOIN #Items T ON OE.OrderExpenseKey = t.OrderExpenseKey
			where	ISNULL(OE.UnitCost,0)						<> ISNULL(T.UnitCost,0) OR 
					ISNULL(OE.Qty,0)							<> ISNULL(T.Qty,0)  OR
					ISNULL(OE.DateFrom,'2020-01-01')			<> ISNULL(T.DateFrom,'2020-01-01') OR
					ISNULL(OE.DateTo,'2020-01-01')				<> ISNULL(T.DateTo,'2020-01-01') OR
					ISNULL(OE.TimeDuration,'00:00')				<> ISNULL(T.TimeDuration,'00:00') OR
					ISNULL(OE.BvsNB,0)							<> ISNULL(T.BvsNB,0) OR
					ISNULL(OE.FreeTime,0)						<> ISNULL(T.FreeTime,0) OR
					ISNULL(OE.isCSRApproved,0)					<> ISNULL(T.IsCSRApproved,0) OR
					ISNULL(OE.IsChargeSharedWithCustomer,0)		<> ISNULL(T.IsSharedWithCustomer,0) OR
					ISNULL(OE.InternalNotes,'')					<> ISNULL(T.InternalNotes,'')

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',ContainerNo,@OrderDetailKey,null,'Text', 'Charge Shared with customer updated ' +@Comments  FROM #IsChargeSharedWithCustomer T

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Charges approved by CSR  has been updated ' + @Comments FROM #IsCSRApproved T

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Charges added ' + @Comments FROM #ItemAdded T

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Charges updated ' + @Comments FROM #ItemUpdated T

			COMMIT TRANSACTION
			SEt @Status = 1
			Set @Reason = 'SUCCESS'
			drop table #Items
			drop table #IsCSRApproved
			drop table #IsChargeSharedWithCustomer
			return
		End 
		ELSE if((Select count(1) from #Items) > 0)
		BEGIN
			SELECT T.* INTO #ItemAdded_noroute FROM #Items T
			WHERE T.Itemkey Not IN (SELECT ItemKey FROM OrderExpense WITH (NOLOCK) WHERE OrderDetailKey= @OrderDetailKey) AND ChargeSource<>'Auto'

			INSERT INTO OrderExpense_NoRoutes(Itemkey,RouteKey,UnitCost,Qty,NewUnitCost,
				DateFrom,DateTo,
				CreateDate,CreateUserKey,LastUpdateDate,UpdateUserKey,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,ChargeSource,
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, OrderDetailKey, IsChargeSharedWithCustomer,
				ReportedCost)
			SELECT Itemkey, ISNULL(NULLIF(RouteKey,0), @RouteKey),-- isnull(RouteKey,@RouteKey),
			UnitCost,Qty,NewUnitCost, 
				convert(datetime,replace( replace(DateFrom,'T',' '),'Z','')	),	convert(datetime,replace( replace(DateTo,'T',' '),'Z','')	),
				gETDATE(),@UserKey,NULL,NULL,ExpenseItemKey,TimeDuration,InternalNotes,
				PvsNP,IsCSRApproved,IsCustomerApproved,FreeTime,BvsNB,MinCnt,MaxCnt,CustomerRate,'CM',
				isCSApproved,CSApprovedDate,CSUserKey,IsInvoiced,WarehouseItemKey, @OrderDetailKey, IsSharedWithCustomer
				,ReportedCost
			FROM #ITEMS 
			WHERE ISNULL(OrderExpenseKey ,0) = 0

			UPDATE oe SET 
				Itemkey				= T.Itemkey			,
				--RouteKey			= isnull(T.RouteKey,@RouteKey)			,
				UnitCost			= T.UnitCost			,
				Qty					= T.Qty				,
				NewUnitCost			= T.NewUnitCost		,
				DateFrom			= convert(datetime,replace( replace(T.DateFrom,'T',' '),'Z','')	)		,
				DateTo				= convert(datetime,replace( replace(T.DateTo,'T',' '),'Z','')	)		,
				ExpenseItemKey		= T.ExpenseItemKey	,
				TimeDuration		= T.TimeDuration		,
				InternalNotes		= T.InternalNotes		,
				PvsNP				= T.PvsNP				,
				IsCSRApproved		= T.IsCSRApproved		,
				IsCustomerApproved	= T.IsCustomerApproved,
				FreeTime			= T.FreeTime			,
				BvsNB				= T.BvsNB				,
				MinCnt				= T.MinCnt			,
				MaxCnt				= T.MaxCnt			,
				CustomerRate		= T.CustomerRate		,
				isCSApproved		= T.isCSApproved		,
				CSApprovedDate		= Case when OE.isCSApproved <> T.IsCSApproved then GETDATE() else OE.CSApprovedDate end	,
				CSUserKey			= T.CSUserKey			,
				IsInvoiced			= T.IsInvoiced		,
				WarehouseItemKey	= T.WarehouseItemKey	,
				OrderDetailKey		= T.OrderDetailKey,
				chargesource			= T.chargesource,
				LastUpdateDate		= Getdate(),
				IsChargeSharedWithCustomer = T.IsSharedWithCustomer,
				UpdateUserKey		= @UserKey,
				ReportedCost		= T.ReportedCost
			FROM OrderExpense_NoRoutes OE
			INNER JOIN #ItemAdded_noroute T ON OE.OrderExpenseKey = t.OrderExpenseKey
			where	ISNULL(OE.UnitCost,0)						<> ISNULL(T.UnitCost,0) OR 
					ISNULL(OE.Qty,0)							<> ISNULL(T.Qty,0)  OR
					ISNULL(OE.DateFrom,'2020-01-01')			<> ISNULL(T.DateFrom,'2020-01-01') OR
					ISNULL(OE.DateTo,'2020-01-01')				<> ISNULL(T.DateTo,'2020-01-01') OR
					ISNULL(OE.TimeDuration,'00:00')				<> ISNULL(T.TimeDuration,'00:00') OR
					ISNULL(OE.BvsNB,0)							<> ISNULL(T.BvsNB,0) OR
					ISNULL(OE.FreeTime,0)						<> ISNULL(T.FreeTime,0) OR
					ISNULL(OE.isCSRApproved,0)					<> ISNULL(T.isCSRApproved,0) OR
					ISNULL(OE.IsChargeSharedWithCustomer,0)		<> ISNULL(T.IsSharedWithCustomer,0) OR
					ISNULL(OE.InternalNotes,'')					<> ISNULL(T.InternalNotes,'')

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Charges added ' + @Comments FROM #ItemAdded_noroute T

			COMMIT TRANSACTION
			SEt @Status = 1
			Set @Reason = 'SUCCESS'
			drop table #ItemAdded_noroute
			return
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SEt @Status = 0
		-- Set @Reason = 'TECHNICAL ERROR'
		Set @Reason = ERROR_MESSAGE()
		return
	END CATCH
	
End