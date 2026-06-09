/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"MBLNo":"","BookingNo":"NAM9436021","CustKey":1966,"InvoiceList":[{"InvoiceKey":184875,"DocumentKeys":"561206,561213"},{"InvoiceKey":185409,"DocumentKeys":"569927"},{"InvoiceKey":186536,"DocumentKeys":"572277,561760,569483"}]}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_Invoice_Combined_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/

CREATE   PROCEDURE [dbo].[Get_Invoice_Combined_V2]
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

	DECLARE @MBLNo			varchar(50),
			@BookingNo		varchar(50),
			@CustKey		int

	CREATE TABLE #InvoiceKeys_temp
	(
		InvoiceKey			int,
		DocumentKeys		varchar(2000)	,
		ExpenseAmt			DECIMAL(18,2),
		InvoiceCompanyKey	INT default 0,
		CustCompanyKey		int default 0, 
		Marketlocationkey	int default 0,
		InvoiceOutput		nvarchar(max)	
	)
	
	INSERT INTO #InvoiceKeys_temp (InvoiceKey, DocumentKeys)
	select InvoiceKey, DocumentKeys
	from OpenJSON(@JsonString, '$.InvoiceList')
	WITH (
		InvoiceKey				Int				'$.InvoiceKey',
		DocumentKeys			varchar(2000)	'$.DocumentKeys'
		
	)
	
	Create table #InvoiceDocument
	(
		InvoiceKey	int,
		DocumentKey	int
	)
	
	select 
			@MBLNo		= MBLNo,
			@BookingNo	= BookingNo,
			@CustKey	= CustKey
	from OpenJSON(@JsonString, '$')
	WITH (
		MBLNo			varchar(50)			'$.MBLNo',
		BookingNo		varchar(50)			'$.BookingNo',
		CustKey			int					'$.CustKey'
	)

	print @MBLNo
	PRint @BookingNo
	Print @CustKey

	IF((SELECT COUNT(1)  FROM #InvoiceKeys_temp) = 0)
	Begin
		SET @Status = 0;
		set @Reason = 'Invoice Keys not found';
		return;
	END
	
	create table #OrderDetailKeys
	(
		InvoiceKey		int,
		OrderDetailKey	int
	)
	CREATE TABLE #ExpenseItems
	(
		ItemKey INT,
		ItemDesc VARCHAR(500),
		UnitCost decimal(18,5),
		Qty decimal(18,2),
		OrderDetailKey INT,
		ContainerNo VARCHAR(20)

	);	

	DECLARE @MasterInvoiceNo NVARCHAR(100)=''
	SET @MasterInvoiceNo=(SELECT '90-' + InvoiceNo FROM InvoiceHeader WHERE InvoiceKey=(SELECT MIN(InvoiceKey) FROM #InvoiceKeys_temp))

	Declare @InvoiceKey	int, @DocumentKeys varchar(2000);

	Declare _cursor CURSOR for Select InvoiceKey, DocumentKeys from #InvoiceKeys_temp order by InvoiceKey;
	Open _Cursor;

	FETCH NEXT FROM _cursor INTO @InvoiceKey, @DocumentKeys;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		print @InvoiceKey
		Print @DocumentKeys

		insert into #InvoiceDocument (InvoiceKey, DocumentKey)
		SElect @InvoiceKey, Value from dbo.Fn_SplitParam(@DocumentKeys)

		Declare @CustCompanyKey int,
				@InvoiceCompanyKey int,
				@Marketlocationkey Int

		insert into #OrderDetailKeys (InvoiceKey, OrderDetailKey)
		SELECT DISTINCT @InvoiceKey, OrderDetailKey   
		FROM InvoiceDetail ID WITH (NOLOCK)
		WHERE InvoiceKey=@InvoiceKey

		select @CustCompanyKey =CustomerCompanykey from invoiceheader  IH
		inner join customer c with (nolock) on c.custkey=ih.custkey
		where invoicekey=@Invoicekey
		select @Marketlocationkey=marketLocationKey from invoiceheader  IH
		inner join OrderHeader OH with (nolock) on OH.OrderKey=IH.OrderKey
		where invoicekey=@Invoicekey

		SET @InvoiceCompanyKey=(
		CASE WHEN @CustCompanyKey=1 AND @Marketlocationkey=2 THEN 1
		WHEN @CustCompanyKey=1 AND @Marketlocationkey=3 THEN 3
		WHEN @CustCompanyKey=2  THEN 2 
		ELSE 2
		END
		)
		update #InvoiceKeys_temp set 
				Marketlocationkey = @Marketlocationkey,
				CustCompanyKey = @CustCompanyKey,
				InvoiceCompanyKey = @InvoiceCompanyKey
		Where InvoiceKey = @InvoiceKey


		update IH set InvoiceAmount = isnull(totAmt,0)
		from InvoiceHeader IH   WITH (NOLOCK)
		left join (
			select InvoiceKey, sum(extAmt) totAmt 
			from InvoiceDetail IH   WITH (NOLOCK)
			where IH.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
				and IH.BvsNB = 1
			group by Invoicekey 
		) ID on IH.InvoiceKey = ID.InvoiceKey
		where IH.InvoiceKey = @InvoiceKey 

		Declare @InvoiceOutput nvarchar(MAX) = ''
		SElect @InvoiceOutput =  
		(
			SELECT 
			IH.[InvoiceKey] as Invoicekey
		  ,[InvoiceNo] as InvoiceNo
		  ,[InvoiceDate] InvoiceDate
		  ,IH.[CustKey] as CustKey
		  ,IH.[BillToAddrKey] BilltoAddrKey
		  ,[InvoiceAmount] InvoiceAmount
		  , InvoiceAmount as InvoiceAmt
		  ,[DueDate] DueDate
		  ,[InvoiceType]
		  ,IH.[CompanyKey] CompanyKey
		  ,IH.[StatusKey]
		  ,IH.[CreateUserKey]
		  ,[IsInvoiceApproved] as IsInvoiceApproved
		  ,IH.[CreateDate]
		  ,IH.[UpdateUserKey]
		  ,IH.[UpdateDate]
		  ,[InvoiceApprovedUserKey]
		  ,isnull([InvoiceApprovedDate],'1900-01-01') as InvoiceApprovedDate
		  ,INV.Container as Container  
		  ,''  as TruckType --,@DriverType as TruckType --** TruckType Tag Added

		  ,SR.AddrName AS PickupAddressName
		  ,SR.Address1 AS PickupAddress1
		  ,SR.City AS PickupCity
		  ,SR.[State] AS PickupState
		  ,SR.ZipCode AS PickupZipcode
		  ,SR.Country AS PickupCountry
		  ,ODSP.ActualPickupDate AS PickupDate

		  ,DT.AddrName AS DeliveryAddressName
		  ,DT.Address1 AS DeliveryAddress1
		  ,DT.City AS DeliveryCity
		  ,DT.[State] AS DeliveryState
		  ,DT.ZipCode AS DeliveryZipcode
		  ,DT.Country AS DeliveryCountry
		  ,ODSD.ActualDeliveryDate AS DeliveryDate

		  ,BT.AddrName AS CustomerAddressName
		  ,BT.Address1 AS CustomerAddress1
		  ,BT.City AS CustomerCity
		  ,BT.[State] AS CustomerState
		  ,BT.ZipCode AS CustomerZipcode
		  ,BT.Country AS CustomerCountry

		  ,isnull(RET.AddrName,'') AS ReturnAddrName
		  ,isnull(RET.Address1,'') AS ReturnAddress1
		  ,isnull(RET.City,'') AS ReturnCity
		  ,isnull(RET.[State],'') AS ReturnState
		  ,isnull(RET.ZipCode,'') AS ReturnZipCode
		  ,isnull(RET.Country,'') AS ReturnCountry
		  ,ODSRT.ActualDeliveryDate AS ReturnDate

		  ,OH.OrderNo as Orderno
		  ,IH.CustomerNote as CustomerNote
		  ,IH.InternalNote as InternalNote
		  ,0 AS DriverPay -- **@ExpenseAmt AS DriverPay
		  , (ISNULL(InvoiceAmount,0) ) AS EstimatedProfit --**(ISNULL(InvoiceAmount,0)-ISNULL(@ExpenseAmt,0) ) AS EstimatedProfit
		  ,CS.CsrName as CSRName
		  ,ih.IsPaymentReceived
		  ,IH.IsPrinted as IsPrinted
		  ,ih.IsRevised
		  ,isnull(ih.PrintedDate,'1900-01-01') as PrintedDate
		  ,isnull(ih.PaymentRecdDate, '1900-01-01') as PaymentRecdDate
		  ,isnull(ih.RevisionDate, '1900-01-01') as RevisionDate
		  , U1.UserName AS ApprovedUserName
		  , u2.UserName as PrintedUserName
		  , U3.UserName as RevisedUserName
		  , U4.UserName as PaymentRecdUserName
		  , CU.IsFactored 
		  , ISNULL(ISNULL(IH.BrokerRefNo,isnull(INV2.CustRefNo, OH.BrokerRefNo)),'NA') as BrokerRefNo
		  , isnull(u3.UserName, U5.UserName) as CreatedUserName
		  ,CASE WHEN IsInvoiceApproved=0 AND IH.StatusKey=1 THEN @InvoiceCompanyKey ELSE IH.InvoiceCompanyKey END AS InvoiceCompanyKey
		  ,ISNULL(ML.MarketLocation,'N/A') MarketLocation
		  ,ISNULL(OH.MarketLocationKey,0) MarketLocationKey,
		  SP.SalesPersonName
		  , CustomerAddress = (
				SELECT	A.Addrkey,A.AddrName,A.Address1, A.Address2, A.City,
						A.[State],A.ZipCode,A.Country,A.Website,
						A.Phone,A.Phone2,A.Email,A.Email2,A.Fax 
				FROM dbo.[Address] A	
				WHERE A.Addrkey = IH.BillToAddrKey
				FOR JSON PATH
		  )
		  ,InvoiceDetail =JSON_QUERY((
				SELECT 
					  I.ItemID
					, ID.[Description]     
					, id.Qty 
					, ID.[ExtAmt] AS ExtAmt 
					, I.InvoiceItemDesc as InvoiceDescription
					, I.PriceBasisKey
					, IPB.PriceBasisID
					, TimeDuration
					, ISNULL(CI.ChargeCode,'') CustomerChargeCode 
					, ISNULL(CI.ChargeDescription, ID.[Description]) ChargeDescription
					, CAST(0 AS INT) FreeQty
					, CAST(0 AS INT) TotalQty
					, CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) 
						THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc
					, CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) 
						THEN CAST(ISNULL(ShowChargeCode,0) AS BIT) ELSE CAST(0 AS BIT) END AS ShowChargeCode
					, ID.Charges
					, ID.SellPrice
					, isnull(ID.BvsNB,0) as BvsNB
					, isnull(ID.FreeTime,0) as FreeTime
					, isnull(ID.MaxVal,0) as  MaxVal
					, isnull(ID.Minval,0) as  Minval
					, IsCostItem = convert(bit, case when isnull(BvsNB,0) = 0 then 1 else 0 end)
					, Isnull(ID.ItemNotes,'') as ItemNotes
				FROM [dbo].[Invoicedetail] ID 
					JOIN dbo.InvoiceHeader IH  ON IH.InvoiceKey =  ID.InvoiceKey
					JOIN dbo.Item I ON I.Itemkey=ID.ItemKey
					LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
					LEFT JOIN ItemPriceBasis IPB WITH (NOLOCK) ON IPB.PriceBasisKey=I.PriceBasisKey
				WHERE id.InvoiceKey = @InvoiceKey and ID.OrderDetailKey is not null  AND isnull(ID.BvsNB,0)=1
				FOR JSON PATH
		  )),
		ContainerDocuments =  JSON_QUERY((Select cD.OrderDetailKey, cD.OriginalFileName, OriginalFileType, 
			cd.FileSizeinMB, cd.DocType
		from #InvoiceDocument A
		inner join vContainerDocuments_V2 CD on A.DocumentKey = cd.DocumentKey
		WHERE a.InvoiceKey = @InvoiceKey AND LOWER(cd.OriginalFileType) IN ('jpeg','jpg','PNG','TIFF')
		FOR JSON PATH
		)),
		PickupDates =(SELECT OD.ContainerNo, ODSPI.OrderDetailKey,ODSPI.ActualPickupDate AS PickupDate
					FROM OrderDetailStops ODSPI WITH (NOLOCK)
					INNER JOIN #OrderDetailKeys K ON K.OrderDetailKey = ODSPI.OrderDetailKey
					INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey = ODSPI.OrderDetailKey
					WHERE ODSPI.StopTypeKey = 1 AND ISNULL(ODSPI.IsDryRunPort,0)=0 AND ISNULL(ODSPI.IsDryRunCustomer,0)=0
					ORDER BY OD.ContainerNo FOR JSON PATH),

		DeliveryDates =(SELECT OD.ContainerNo, ODSDI.OrderDetailKey, ODSDI.ActualDeliveryDate AS DeliveryDate
						FROM OrderDetailStops ODSDI WITH (NOLOCK)
						INNER JOIN #OrderDetailKeys K ON K.OrderDetailKey = ODSDI.OrderDetailKey
						INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey = ODSDI.OrderDetailKey
						WHERE ODSDI.StopTypeKey = 3  AND ISNULL(ODSDI.IsDryRunPort,0)=0 AND ISNULL(ODSDI.IsDryRunCustomer,0)=0
							ORDER BY OD.ContainerNo FOR JSON PATH),
		ReturnDates =(SELECT OD.ContainerNo,ODSRI.OrderDetailKey, ODSRI.ActualDeliveryDate AS ReturnDate
						FROM OrderDetailStops ODSRI WITH (NOLOCK)
						INNER JOIN #OrderDetailKeys K ON K.OrderDetailKey = ODSRI.OrderDetailKey
						INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey = ODSRI.OrderDetailKey
						WHERE ODSRI.StopTypeKey = 5 AND ISNULL(ODSRI.IsDryRunPort,0)=0 AND ISNULL(ODSRI.IsDryRunCustomer,0)=0
						ORDER BY OD.ContainerNo FOR JSON PATH),
		  ISNULL(OH.BillOfLading, 'NA') AS MBL
		FROM [dbo].[InvoiceHeader] IH    WITH (NOLOCK)
		INNER JOIN
				(				
					SELECT STRING_AGG(ContainerNo + ':' + convert(varchar,OrderDetailsKey) ,',') WITHIN GROUP (ORDER BY ContainerNo DESC) AS Container,InvoiceKey
					FROM
					(
						SELECT DISTINCT ContainerNo, OrderDetailsKey ,InvoiceKey FROM InvoiceContainers  
					) T  GROUP BY InvoiceKey 
				)INV ON INV.InvoiceKey=IH.InvoiceKey
		INNER JOIN
				(				
					SELECT STRING_AGG(CustRefNo ,', ') AS CustRefNo,InvoiceKey
					FROM
					(
						SELECT DISTINCT REPLACE(CustRefNo,'N/A',null) CustRefNo ,InvoiceKey FROM InvoiceContainers IV1-- Invoicedetail
						INNER JOIN OrderDetail ODI ON ODI.OrderDetailKey=IV1.OrderDetailsKey
					) T1 GROUP BY InvoiceKey
				)INV2 ON INV2.InvoiceKey=IH.InvoiceKey
		LEFT JOIN dbo.OrderHeader OH	WITH (NOLOCK) ON Oh.OrderKey=IH.OrderKey 
		LEFT JOIN [Address] SR			WITH (NOLOCK) ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] BT			WITH (NOLOCK) ON	BT.AddrKey=IH.BillToAddrKey
		LEFT JOIN [Customer] CU			WITH (NOLOCK) on IH.CustKey = CU.CustKey
		LEFT JOIN dbo.CSR CS			WITH (NOLOCK) ON CS.CsrKey=OH.CsrKey
		LEFT JOIN [User] U1   WITH (NOLOCK) ON IH.InvoiceApprovedUserKey = U1.UserKey
		LEFT JOIN [User] U2   WITH (NOLOCK) ON IH.PrintedUserKey = U2.UserKey
		LEFT JOIN [User] U3   WITH (NOLOCK) ON IH.RevisionUserKey = U3.UserKey
		LEFT JOIN [User] U4   WITH (NOLOCK) ON IH.PaymentRecdUserKey = U4.UserKey
		LEFT JOIN [User] U5   WITH (NOLOCK) ON IH.CreateUserKey = U5.UserKey
		LEFT JOIN MarketLocation ML		WITH (NOLOCK) ON (ML.MarketLocationKey=OH.MarketLocationKey)
		LEFT JOIN SalesPerson SP		WITH (NOLOCK) ON SP.SalesPersonKey=OH.SalesPErsonKey
		OUTER APPLY (
							SELECT TOP 1 *
							FROM OrderStops OS WITH (NOLOCK)
							WHERE OS.OrderKey = OH.OrderKey
							  AND OS.StopTypeKey = 3
							ORDER BY OS.StopNumber ASC
							) OS_STpD 
		OUTER APPLY (
							SELECT TOP 1 *
							FROM InvoiceDetail ID WITH (NOLOCK)
							WHERE ID.InvoiceKey = IH.InvoiceKey
							ORDER BY ID.InvoiceKey ASC
							) IDO 
		LEFT JOIN [Address] DT			WITH (NOLOCK) ON	DT.AddrKey=OS_STpD.StopAddrKey
		LEFT JOIN OrderDetailStops	ODSP		WITH (NOLOCK)   ON ODSP.OrderDetailKey=IDO.OrderDetailKey
													AND ODSP.StopTypeKey=1 AND ISNULL(ODSP.IsDryRunPort,0)=0
		LEFT JOIN OrderDetailStops	ODSD		WITH (NOLOCK)   ON ODSD.OrderDetailKey=IDO.OrderDetailKey
													AND ODSD.StopTypeKey=3 AND ISNULL(ODSD.IsDryRunCustomer,0)=0
		LEFT JOIN OrderDetailStops	ODSRT		WITH (NOLOCK)   ON ODSRT.OrderDetailKey=IDO.OrderDetailKey
													AND ODSRT.StopTypeKey=5 AND ISNULL(ODSRT.IsDryRunPort,0)=0
		LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey=ODSRT.StopAddrKey
		WHERE IH.InvoiceKey = @InvoiceKey
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		) 
		
		update #InvoiceKeys_temp set InvoiceOutput =  @InvoiceOutput where InvoiceKey = @InvoiceKey
		FETCH NEXT FROM _cursor INTO @InvoiceKey, @DocumentKeys;
	END

	CLOSE _Cursor
	Deallocate _Cursor
	
	INSERT INTO MasterInvoiceLink
	(MasterInvoiceNo,InvoiceKey)
	SELECT @MasterInvoiceNo, InvoiceKey FROM #InvoiceKeys_temp
	WHERE InvoiceKey  NOT IN (SELECT InvoiceKey FROM MasterInvoiceLink)
	
	--select * from #InvoiceKeys_temp
	select InvoiceKey, JSON_query( InvoiceOutput) as InvoiceOutput from #InvoiceKeys_temp FOR JSON PATH
	SET @Status = 1
	SET @Reason = 'SUCCESS'
	
	
	/*
	

	--Creation of Temp Table Structure/Skeleton
	SELECT * INTO #BaseInfo1_Auto_ReturnBaseInfo FROM BaseInfo_WRK WHERE 1= 0
	Declare @DriverType Varchar(50) = '', @DriverTypeKey Int, @OrderType Varchar(20)

	--Insertion to temp table from procedure
	INSERT
	INTO #BaseInfo1_Auto_ReturnBaseInfo
	EXEC Auto_ReturnBaseInfo @InvoiceKey
	
	Select @OrderType = OT.OrderType
	from InvoiceHeader IH
	inner join OrderHeader OH  WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where IH.InvoiceKey = @InvoiceKey
	
	select distinct OrderdetailKey, ContainerNo 
	into #ContainerBase 
	from #BaseInfo1_Auto_ReturnBaseInfo

	Declare @_OrderdetailKey int,@_ContainerNo varchar(50)
	declare   _ContainerList Cursor Local
	For Select OrderdetailKey, ContainerNo from #ContainerBase

	Open _ContainerList
	Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	WHILE  @@FETCH_STATUS = 0
	BEGIN
		select top 1 @DriverType = TruckType
		from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND TruckType is not null and 
		Case when @OrderType = 'Import' then ToLocation else FromLocation end in ('Consignee','Customer','Shipper')

		print '@TruckType'
		print @DriverType
		if(isnull(@DriverType,'') = '')
		Begin
			select  @DriverType = TruckType, @DriverTypeKey = TruckTypeKey from TruckType where TruckType = 'Broker Carrier'
			print @DriverType
		end

		Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	END
	CLOSE _ContainerList
	DEALLOCATE _ContainerList

	Drop Table #BaseInfo1_Auto_ReturnBaseInfo
	Drop Table #ContainerBase

	insert into InvoiceContainers (InvoiceKey, OrderDetailsKey, ContainerNo)
	select distinct @InvoiceKey, ID.OrderDetailkey, OD.ContainerNo
	from InvoiceDetail ID WITH (NOLOCK) 
	inner join OrderDetail OD WITH (NOLOCK) on ID.OrderDetailKey = OD.OrderDetailKey
	LEFT join InvoiceContainers IC WITH (NOLOCK) on ID.InvoiceKey = IC.InvoiceKey and ID.OrderDetailKey = IC.OrderDetailsKey
	where ID.InvoiceKey = @InvoiceKey and IC.OrderDetailsKey is null

	SET @ExpenseAmt= 0 

	


	
	SET @Status = 1
	SEt @Reason = 'SUCCESS'
	*/
END
