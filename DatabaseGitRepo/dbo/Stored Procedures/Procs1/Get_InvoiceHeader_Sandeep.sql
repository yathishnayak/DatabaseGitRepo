Create PROCEDURE [dbo].[Get_InvoiceHeader_Sandeep] -- [Get_InvoiceHeader_Sandeep] 11671
@InvoiceKey  INT=52
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @ExpenseAmt DECIMAL(18,2)

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
	FROM Invoicedetail 
	WHERE InvoiceKey= @InvoiceKey

	--INSERT INTO #ExpenseItems (ItemKey,ItemDesc,UnitCost,Qty,OrderDetailKey,ContainerNo)
	--EXECUTE Get_ExpenseItem	

	SET @ExpenseAmt= 0 --( SELECT SUM(ISNULL(UnitCost,0)*CASE WHEN Qty=0 THEN 1 WHEN Qty IS NULL THEN 1 ELSE Qty END) FROM #ExpenseItems )

	update IH set InvoiceAmount = totAmt
	from InvoiceHeader IH
	inner join (
		select InvoiceKey, sum(extAmt) totAmt 
		from InvoiceDetail IH
		where IH.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
		group by Invoicekey 
	) ID on IH.InvoiceKey = ID.InvoiceKey
	where IH.InvoiceKey = @InvoiceKey 


	SELECT 
		IH.[InvoiceKey]
      ,[InvoiceNo]
      ,[InvoiceDate]
      ,IH.[CustKey]
      ,IH.[BillToAddrKey]
      ,[InvoiceAmount]
      ,[DueDate]
      ,[InvoiceType]
      ,IH.[CompanyKey]
      ,IH.[StatusKey]
      ,IH.[CreateUserKey]
      ,[IsInvoiceApproved]
      ,IH.[CreateDate]
      ,[UpdateUserKey]
      ,[UpdateDate]
      ,[InvoiceApprovedUserKey]
      ,isnull([InvoiceApprovedDate],'1900-01-01') as [InvoiceApprovedDate]
	  ,Container	  
	  ,SR.AddrName AS S_AddrName,SR.Address1 AS S_Address1,SR.City AS S_City,SR.[State] AS S_State,SR.ZipCode AS S_ZipCode,SR.Country AS S_Country
	  ,DT.AddrName AS D_AddrName,DT.Address1 AS D_Address1,DT.City AS D_City,DT.[State] AS D_State,DT.ZipCode AS D_ZipCode,DT.Country AS D_Country
	  ,BT.AddrName AS B_AddrName,BT.Address1 AS B_Address1,BT.City AS B_City,BT.[State] AS B_State,BT.ZipCode AS B_ZipCode,BT.Country AS B_Country
	  ,OH.OrderNo
	  ,IH.CustomerNote
	  ,IH.InternalNote
	  ,@ExpenseAmt AS DriverPay
	  ,(ISNULL(InvoiceAmount,0)-ISNULL(@ExpenseAmt,0) ) AS EstimatedProfit
	  ,CS.CsrName
	  ,ih.IsPaymentReceived
	  ,IH.IsPrinted
	  ,ih.IsRevised
	  ,isnull(ih.PrintedDate,'1900-01-01') as PrintedDate
	  ,isnull(ih.PaymentRecdDate, '1900-01-01') as PaymentRecdDate
	  ,isnull(ih.RevisionDate, '1900-01-01') as RevisionDate
	  , U1.UserName AS InvoiceApprovedUserName
	  , u2.UserName as PrintedUserName
	  , U3.UserName as RevisedUserName
	  , U4.UserName as PaymentReceivedUserName
	  , CU.IsFactored 
	  , IH.BrokerRefNo
	  , isnull(u3.UserName, U5.UserName) as CreatedUserName
  FROM [dbo].[InvoiceHeader] IH 
	INNER JOIN
			(				
				SELECT STRING_AGG(Container + ':' + convert(varchar,OrderDetailKey) ,', ') AS Container,InvoiceKey
				FROM
				(
					SELECT DISTINCT Container, OrderDetailKey ,InvoiceKey FROM Invoicedetail
				) T GROUP BY InvoiceKey
			)INV ON INV.InvoiceKey=IH.InvoiceKey
	LEFT JOIN dbo.OrderHeader OH ON Oh.OrderKey=IH.OrderKey 
	LEFT JOIN [Address] SR	ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN [Address] DT	ON	DT.AddrKey=OH.DestinationAddrKey
	LEFT JOIN [Address] BT	ON	BT.AddrKey=IH.BillToAddrKey
	LEFT JOIN [Customer] CU on IH.CustKey = CU.CustKey
	LEFT JOIN dbo.CSR CS ON CS.CsrKey=OH.CsrKey
	LEFT JOIN [User] U1 ON IH.InvoiceApprovedUserKey = U1.UserKey
	LEFT JOIN [User] U2 ON IH.PrintedUserKey = U2.UserKey
	LEFT JOIN [User] U3 ON IH.RevisionUserKey = U3.UserKey
	LEFT JOIN [User] U4 ON IH.PaymentRecdUserKey = U4.UserKey
	LEFT JOIN [User] U5 ON IH.CreateUserKey = U5.UserKey
	WHERE IH.InvoiceKey = @InvoiceKey;
END
