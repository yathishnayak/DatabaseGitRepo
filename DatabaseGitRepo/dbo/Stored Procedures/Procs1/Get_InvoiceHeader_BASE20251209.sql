
CREATE PROCEDURE [dbo].[Get_InvoiceHeader_BASE20251209] -- [Get_InvoiceHeader] 136
@InvoiceKey  INT
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
      ,IH.[UpdateUserKey]
      ,IH.[UpdateDate]
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
	--  , U6.UserName AS UpdatedUserName
	  , CU.IsFactored 
	  --, isnull(IH.BrokerRefNo, OH.BrokerRefNo) as BrokerRefNo
	  , ISNULL(IH.BrokerRefNo,isnull(INV2.CustRefNo, OH.BrokerRefNo)) as BrokerRefNo
	  , isnull(u3.UserName, U5.UserName) as CreatedUserName
	  ,InvoiceCompanyKey
	  ,ISNULL(ML.MarketLocation,'N/A') MarketLocation, ISNULL(OH.MarketLocationKey,0) MarketLocationKey,
	  SP.SalesPersonName
  FROM [dbo].[InvoiceHeader] IH 
	INNER JOIN
			(				
				SELECT STRING_AGG(ContainerNo + ':' + convert(varchar,OrderDetailsKey) ,', ') AS Container,InvoiceKey
				FROM
				(
					SELECT DISTINCT ContainerNo, OrderDetailsKey ,InvoiceKey FROM InvoiceContainers-- Invoicedetail
				) T GROUP BY InvoiceKey
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
--	LEFT JOIN [User] U6 ON IH.UpdateUserKey = U6.UserKey
LEFT JOIN MarketLocation ML WITH (NOLOCK) ON (ML.MarketLocationKey=OH.MarketLocationKey)
LEFT JOIN SalesPerson SP WITH (NOLOCK) ON SP.SalesPersonKey=OH.SalesPErsonKey
	WHERE IH.InvoiceKey = @InvoiceKey;
END
