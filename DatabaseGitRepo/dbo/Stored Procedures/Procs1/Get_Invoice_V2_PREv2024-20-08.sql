
/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"InvoiceKey":128488}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_Invoice_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/

create PROCEDURE [dbo].[Get_Invoice_V2_PREv2024-20-08]
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

	DECLARE @ExpenseAmt DECIMAL(18,2),
	@InvoiceKey  INT

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	select @InvoiceKey = InvoiceKey
	from OpenJSON(@JsonString, '$')
	WITH (
		InvoiceKey				INT				'$.InvoiceKey'
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

	SELECT DISTINCT OrderDetailKey INTO #OrderDetailWrk 
	FROM Invoicedetail  WITH (NOLOCK)
	WHERE InvoiceKey= @InvoiceKey

	SET @ExpenseAmt= 0 

	update IH set InvoiceAmount = totAmt
	from InvoiceHeader IH   WITH (NOLOCK)
	inner join (
		select InvoiceKey, sum(extAmt) totAmt 
		from InvoiceDetail IH   WITH (NOLOCK)
		where IH.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
			and IH.BvsNB = 1
		group by Invoicekey 
	) ID on IH.InvoiceKey = ID.InvoiceKey
	where IH.InvoiceKey = @InvoiceKey 


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
	  ,Container	 as Container  

	  ,SR.AddrName AS PickupAddressName
	  ,SR.Address1 AS PickupAddress1
	  ,SR.City AS PickupCity
	  ,SR.[State] AS PickupState
	  ,SR.ZipCode AS PickupZipcode
	  ,SR.Country AS PickupCountry

	  ,DT.AddrName AS DeliveryAddressName
	  ,DT.Address1 AS DeliveryAddress1
	  ,DT.City AS DeliveryCity
	  ,DT.[State] AS DeliveryState
	  ,DT.ZipCode AS DeliveryZipcode
	  ,DT.Country AS DeliveryCountry

	  ,BT.AddrName AS CustomerAddressName
	  ,BT.Address1 AS CustomerAddress1
	  ,BT.City AS CustomerCity
	  ,BT.[State] AS CustomerState
	  ,BT.ZipCode AS CustomerZipcode
	  ,BT.Country AS CustomerCountry

	  ,OH.OrderNo as Orderno
	  ,IH.CustomerNote as CustomerNote
	  ,IH.InternalNote as InternalNote
	  ,@ExpenseAmt AS DriverPay
	  ,(ISNULL(InvoiceAmount,0)-ISNULL(@ExpenseAmt,0) ) AS EstimatedProfit
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
	--  , U6.UserName AS UpdatedUserName
	  , CU.IsFactored 
	  , isnull(IH.BrokerRefNo, OH.BrokerRefNo) as BrokerRefNo
	  , isnull(u3.UserName, U5.UserName) as CreatedUserName
	  ,InvoiceCompanyKey
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
	  ,InvoiceDetail =(
			SELECT 
				  I.ItemID
				, ID.[Description]     
				, ID.[ExtAmt] AS ExtAmt 
				, I.InvoiceItemDesc as InvoiceDescription
				, PriceBasisKey
				, TimeDuration
				, ISNULL(CI.ChargeCode,'') CustomerChargeCode 
				, ISNULL(CI.ChargeDescription, ID.[Description]) ChargeDescription
				, CAST(0 AS INT) FreeQty
				, CAST(0 AS INT) TotalQty
				, CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc
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
			WHERE id.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
			--GROUP BY I.ItemID, ID.[Description], I.InvoiceItemDesc,PriceBasisKey,TimeDuration,
			--		ChargeCode,ChargeDescription,I.[Description],IH.CustKey
			FOR JSON PATH
	  )
	FROM [dbo].[InvoiceHeader] IH    WITH (NOLOCK)
	INNER JOIN
			(				
				SELECT STRING_AGG(ContainerNo + ':' + convert(varchar,OrderDetailsKey) ,', ') AS Container,InvoiceKey
				FROM
				(
					SELECT DISTINCT ContainerNo, OrderDetailsKey ,InvoiceKey FROM InvoiceContainers  WITH (NOLOCK)
				) T GROUP BY InvoiceKey
			)INV ON INV.InvoiceKey=IH.InvoiceKey
	LEFT JOIN dbo.OrderHeader OH	WITH (NOLOCK) ON Oh.OrderKey=IH.OrderKey 
	LEFT JOIN [Address] SR			WITH (NOLOCK) ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN [Address] DT			WITH (NOLOCK) ON	DT.AddrKey=OH.DestinationAddrKey
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
	WHERE IH.InvoiceKey = @InvoiceKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	SET @Status = 1
	SEt @Reason = 'SUCCESS'
END
